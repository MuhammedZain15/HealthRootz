// lib/patient/features/chat/chat_model.dart
class ChatMessage {
  final String text;
  final bool isSender;
  final DateTime timestamp;
  final String? doctorName;
  final String? id;
  final String? patientId;
  final bool isRead;

  const ChatMessage({
    required this.text,
    required this.isSender,
    required this.timestamp,
    this.doctorName,
    this.id,
    this.patientId,
    this.isRead = false,
  });

  factory ChatMessage.fromJson(Map<String, Object?> json) {
    return ChatMessage(
      id: (json['id'] ?? json['_id'])?.toString(),
      text: (json['text'] ?? '').toString(),
      isSender: json['isSender'] as bool? ?? json['isMe'] as bool? ?? false,
      timestamp: _parseTimestamp(json['timestamp'] ?? json['time']),
      doctorName: json['doctorName']?.toString(),
      patientId: json['patientId']?.toString(),
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'text': text,
      'isSender': isSender,
      'timestamp': timestamp.toIso8601String(),
      'doctorName': doctorName,
      'patientId': patientId,
      'isRead': isRead,
    };
  }

  static DateTime _parseTimestamp(Object? value) {
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return parsed;
    }
    return DateTime.now();
  }
}
