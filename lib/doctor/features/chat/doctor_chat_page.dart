import 'package:flutter/material.dart';
import 'models/chat_model.dart';
import 'view_models/chat_list_view_model.dart';
import 'views/chat_detail_page.dart';
import 'widgets/chat_widgets.dart';

class DoctorChatPage extends StatefulWidget {
  const DoctorChatPage({super.key});

  @override
  State<DoctorChatPage> createState() => _DoctorChatPageState();
}

class _DoctorChatPageState extends State<DoctorChatPage> {
  final _vm = ChatListViewModel();

  void _openChat(BuildContext context, ChatUser user) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ChatDetailPage(user: user)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Chat', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: ChatSearchField(),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListenableBuilder(
                listenable: _vm,
                builder: (context, _) => ListView.separated(
                  itemCount: _vm.chats.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (ctx, i) => ChatListTile(
                    user: _vm.chats[i],
                    onTap: () => _openChat(context, _vm.chats[i]),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
