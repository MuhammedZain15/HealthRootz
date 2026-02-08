import 'package:flutter/material.dart';
import 'chat_model.dart';

class ChatViewModel extends ChangeNotifier {
  bool _isDoctorChat = true; //اول ما يفتح الصفحة بيكون الدكاترة
  final List<ChatMessage> _messages = [];
  final TextEditingController textController = TextEditingController();

  bool get isDoctorChat => _isDoctorChat;
  List<ChatMessage> get messages => _messages;

  ChatViewModel({required bool isDoctorChat}) {
    _addInitialMessages();
  }

  void toggleChatMode(bool isDoctor) {
    if (_isDoctorChat != isDoctor) {
      _isDoctorChat = isDoctor;
      _messages.clear();
      _addInitialMessages();
      notifyListeners();
      //  يمسح الرسال اللي فاتت بمجرد ما ينقل من tap للتاني لحد ما نعدلها لما نخلص الباك اند
      // وبعدين يضيف رسالة ترحيبية جديدة حسب نوع الشات اللي هو فيه
      // بعد كداطبعا يبلغي التغيرات عشان يعيد بناء الويدجيت ويظهر الرسالة الجديدة
    }
  }

  void sendMessage() {
    if (textController.text.trim().isEmpty) return;

    final newMessage = ChatMessage(
      text: textController.text,
      isSender: true,
      timestamp: DateTime.now(),
    );

    _messages.add(newMessage);
    textController.clear();
    notifyListeners();

    // محاكاة رد من الدكاترة أو الذكاء الاصطناعي بعد 
    //إرسال رسالة بثانية واحدة شكل بس يعني لحد ما تبقي حقيقيه
    Future.delayed(const Duration(seconds: 1), () {
      _messages.add(
        ChatMessage(
          text: _isDoctorChat
              ? "شكرا علي رسالتك لما افضي هبقا اكلمك "
              : "انا الذكاء الاصطبحي لو محتاجني ف حاجه متكلمنيش ",
          isSender: false,
          timestamp: DateTime.now(),
          doctorName: _isDoctorChat ? "Dr. Sarah Johnson" : "AI Assistant",
        ),
      );
      notifyListeners();
      // بعد ما يضيف الرد الجديد بيبلغي التغيرات عشان يعيد بناء الويدجيت ويظهر الرسالة الجديدة
    });
  }

  void _addInitialMessages() {
    if (_isDoctorChat) {
      _messages.add(
        ChatMessage(
          text:
              "يا فتاح يا عليم يا رزاق يا كريم يا بركه باسم الله اي يا مريض يا عاجز عامل اي ",
          isSender: false,
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
          doctorName: "Dr. Sarah Johnson",
        ),
      );
    } else {
      _messages.add(
        ChatMessage(
          text:
              "صباحك كلو رزق يا مريض يا عاجز انا الذكاء الاصطبحي لو محتاجني ف حاجه متكلمنيش ",
          isSender: false,
          timestamp: DateTime.now(),
          doctorName: "AI Assistant",
        ),
      );
    }
  }
}
