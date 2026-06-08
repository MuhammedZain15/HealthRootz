import 'dart:async';

import 'package:flutter/material.dart';
import 'package:grad_project/app_colors.dart';
import 'package:grad_project/patient/features/ai_chat/ai_sessions_screen.dart';
import 'chat_view_model.dart';
import 'chat_widgets.dart';

class ChatView extends StatefulWidget {
  final bool isDoctorChat;
  final String? sessionId;

  const ChatView({super.key, this.isDoctorChat = true, this.sessionId});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  late ChatViewModel _viewModel;
  final ScrollController _scrollController = ScrollController();


  @override
  void initState() {
    super.initState();
    _viewModel = ChatViewModel(isDoctorChat: widget.isDoctorChat, sessionId: widget.sessionId);
    _viewModel.addListener(_onViewModelChanged);
    _scrollToBottom();
    _viewModel.setOnEmergency(() {
      _showEmergencyDialog();
    });
    if (!widget.isDoctorChat) {
      unawaited(_viewModel.initAISession(widget.sessionId));
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.close();
    super.dispose();
  }

  void _onViewModelChanged() {
    setState(() {});
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showEmergencyDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('⚠️ Emergency Alert'),
          content: const Text(
            'The AI assistant has detected an emergency situation. '
            'Please call an ambulance immediately or contact emergency services.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Color get _accentColor =>
      _viewModel.isDoctorChat ? AppColors.skyBlue : AppColors.purple;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back_ios, color: onSurface),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Messages',
              style: TextStyle(
                color: onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            Text(
              'Chat with your doctor or AI assistant',
              style: TextStyle(
                color: onSurface.withValues(alpha: 0.6),
                fontSize: 14,
              ),
            ),
          ],
        ),
        backgroundColor: theme.appBarTheme.backgroundColor ?? theme.cardColor,
        elevation: 0,
        toolbarHeight: 80,
        automaticallyImplyLeading: false,
        actions: !_viewModel.isDoctorChat
            ? [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AiSessionsScreen(),
                        ),
                      );
                    },
                    child: Icon(
                      Icons.history,
                      color: AppColors.purple,
                      size: 24,
                    ),
                  ),
                ),
              ]
            : null,
      ),
      body: Column(
        children: [
          // السويتش بين الدكاترة والذكاء الاصطناعي
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  ChatTabButton(
                    text: 'Dr. Johnson',
                    icon: Icons.person_outline,
                    isSelected: _viewModel.isDoctorChat,
                    selectedColor: AppColors.skyBlue,
                    onTap: () => _viewModel.toggleChatMode(true),
                  ),
                  // aiالفرق بين الدكتور وال
                  // هو ان الدكتور بيكون لونه سماوي ولما يضغط عليه يفتح شات الدكاترة
                  //ai بيكون لونه بنفسجي ولما يضغط عليه يفتح شات ال ai
                  ChatTabButton(
                    text: 'AI Assistant',
                    icon: Icons.smart_toy_outlined,
                    isSelected: !_viewModel.isDoctorChat,
                    selectedColor: AppColors.purple,
                    onTap: () => _viewModel.toggleChatMode(false),
                  ),
                ],
              ),
            ),
          ),
          // ليست المسدجات
          Expanded(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 900),
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  itemCount: _viewModel.messages.length,
                  itemBuilder: (context, index) => ChatMessageBubble(
                    message: _viewModel.messages[index],
                    maxWidth: size.width > 900 ? 600 : size.width * 0.75,
                    accentColor: _accentColor,
                    onDelete: () {
                      final message = _viewModel.messages[index];
                      if (message.id != null) {
                        _viewModel.deleteMessage(message.id!);
                      }
                    },
                    onForward: (destination) {
                      final messageText = _viewModel.messages[index].text;
                      if (destination == 'doctor') {
                        _viewModel.forwardToDoctor(messageText);
                      } else if (destination == 'ai') {
                        _viewModel.forwardToAI(messageText);
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
          // الكيبورد
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 900),
              child: ChatInputArea(
                controller: _viewModel.textController,
                hintText: _viewModel.isDoctorChat
                    ? 'Message Dr. Johnson...'
                    : 'Message AI Assistant...',
                accentColor: _accentColor,
                onSend: _viewModel.sendMessage,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
