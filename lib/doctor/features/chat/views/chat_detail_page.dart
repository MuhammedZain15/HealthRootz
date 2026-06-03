import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import '../view_models/chat_detail_view_model.dart';
import '../widgets/chat_widgets.dart';

class ChatDetailPage extends StatefulWidget {
  final ChatUser user;
  const ChatDetailPage({super.key, required this.user});

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final _vm = ChatDetailViewModel();
  final _controller = TextEditingController();

  @override
  void dispose() {
    _vm.close();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A65EB)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF1A65EB),
              child: Text(
                widget.user.name.substring(0, 2).toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.user.name,
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                ),
                const Text(
                  'Active now',
                  style: TextStyle(color: Colors.green, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: _vm,
        builder: (context, _) => Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 16),
                itemCount: _vm.messages.length,
                itemBuilder: (ctx, i) =>
                    MessageBubble(message: _vm.messages[i]),
              ),
            ),
            ChatInputArea(
              controller: _controller,
              onSend: () {
                _vm.sendMessage(_controller.text);
                _controller.clear();
              },
            ),
          ],
        ),
      ),
    );
  }
}
