// lib/doctor/features/chat/models/chat_model.dart
class ChatUser {
  final String id;
  final String name;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final bool isActive;

  const ChatUser({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.time,
    this.unreadCount = 0,
    this.isActive = false,
  });

  factory ChatUser.fromJson(Map<String, Object?> json) {
    return ChatUser(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? json['patientName'] ?? '').toString(),
      lastMessage: (json['lastMessage'] ?? '').toString(),
      time: (json['time'] ?? '').toString(),
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? false,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'name': name,
      'lastMessage': lastMessage,
      'time': time,
      'unreadCount': unreadCount,
      'isActive': isActive,
    };
  }
}

class ChatMessage {
  final String id;
  final String text;
  final bool isMe;
  final String time;
  final String? patientId;
  final bool isRead;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isMe,
    required this.time,
    this.patientId,
    this.isRead = false,
  });

  factory ChatMessage.fromJson(Map<String, Object?> json) {
    final sender = json['sender']?.toString();
    final isMeFromSender = sender == 'doctor';
    return ChatMessage(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      text: (json['text'] ?? '').toString(),
      isMe: json['isMe'] as bool? ?? isMeFromSender,
      time: (json['time'] ?? json['createdAt'] ?? '').toString(),
      patientId: json['patientId']?.toString(),
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'text': text,
      'isMe': isMe,
      'time': time,
      'patientId': patientId,
      'isRead': isRead,
    };
  }
}
