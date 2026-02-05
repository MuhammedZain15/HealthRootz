import 'package:flutter/material.dart';
import '../models/chat_model.dart';

class ChatListViewModel extends ChangeNotifier {
  final List<ChatUser> _chats = [
    ChatUser(id: '1', name: 'John Anderson', lastMessage: 'Thank you for the update, Doctor.', time: '10:30 AM', unreadCount: 2, isActive: true),
    ChatUser(id: '2', name: 'Sarah Mitchell', lastMessage: 'I have been feeling much better.', time: '9:44 AM'),
    ChatUser(id: '3', name: 'Michael Chen', lastMessage: 'Can we schedule a follow-up?', time: 'Yesterday'),
    ChatUser(id: '4', name: 'Emily Rodriguez', lastMessage: 'Here are my latest test results.', time: 'Yesterday'),
    ChatUser(id: '5', name: 'David Thompson', lastMessage: 'Thank you, Doctor.', time: '2 days ago'),
    ChatUser(id: '6', name: 'Lisa Wang', lastMessage: 'I will follow the treatment plan.', time: '3 days ago'),
    ChatUser(id: '7', name: 'Robert Martinez', lastMessage: 'When should I come in next?', time: '3 days ago', unreadCount: 1),
    ChatUser(id: '8', name: 'Jennifer Brown', lastMessage: 'Thanks for your help!', time: '4 days ago'),
  ];

  List<ChatUser> get chats => _chats;

  void filterChats(String query) {
    // Implement search logic if needed
    notifyListeners();
  }
}
