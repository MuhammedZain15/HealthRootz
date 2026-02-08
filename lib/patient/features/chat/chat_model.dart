class ChatMessage {
  final String text;
  final bool isSender;
  final DateTime timestamp;
  final String? doctorName;

  ChatMessage({
    required this.text,
    required this.isSender,
    required this.timestamp,
    this.doctorName,
  });
}
