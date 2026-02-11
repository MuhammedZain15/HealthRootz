import 'package:flutter/material.dart';
import 'package:grad_project/app_colors.dart';
import 'chat_view_model.dart';
import 'chat_widgets.dart';

class ChatView extends StatefulWidget {
  final bool isDoctorChat;

  const ChatView({super.key, this.isDoctorChat = true});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  late ChatViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ChatViewModel(isDoctorChat: widget.isDoctorChat);
    _viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.textController.dispose();
    super.dispose();
  }

  void _onViewModelChanged() => setState(() {});

  Color get _accentColor =>
      _viewModel.isDoctorChat ? AppColors.skyBlue : AppColors.purple;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back_ios, color: const Color(0xFF0F172A)),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Messages',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            Text(
              'Chat with your doctor or AI assistant',
              style: TextStyle(color: const Color(0xff6B7280), fontSize: 14),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 80,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // السويتش بين الدكاترة والذكاء الاصطناعي
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  itemCount: _viewModel.messages.length,
                  itemBuilder: (context, index) => ChatMessageBubble(
                    message: _viewModel.messages[index],
                    maxWidth: size.width > 900 ? 600 : size.width * 0.75,
                    accentColor: _accentColor,
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
