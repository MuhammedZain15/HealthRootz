import 'package:flutter/material.dart';
import '../models/chat_model.dart';

class ChatDetailViewModel extends ChangeNotifier {
  final List<ChatMessage> _messages = [
    ChatMessage(id: '1', text: 'Good morning, Doctor. How are my latest test results?', isMe: false, time: '10:15 AM'),
    ChatMessage(id: '2', text: 'Good morning, John! Your results look very promising. Your heart rate has stabilized nicely.', isMe: true, time: '10:21 AM'),
    ChatMessage(id: '3', text: 'I\'m attaching your detailed report for your records.', isMe: true, time: '10:21 AM'),
    ChatMessage(id: '4', text: 'Thank you for the update, Doctor.', isMe: false, time: '10:30 AM'),
  ];

  List<ChatMessage> get messages => _messages;

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;
    final newMessage = ChatMessage(
      id: DateTime.now().toString(),
      text: text,
      isMe: true,
      time: 'Now', // Formatting logic can be added
    );
    _messages.add(newMessage);
    notifyListeners();
  }
}
