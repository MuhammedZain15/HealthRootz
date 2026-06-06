// lib/doctor/features/chat/models/chat_model.dart
class ChatUser {
  final String id;
  final String name;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final bool isActive;
  final String? phone;

  const ChatUser({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.time,
    this.unreadCount = 0,
    this.isActive = false,
    this.phone,
  });

  factory ChatUser.fromJson(Map<String, Object?> json) {
    return ChatUser(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['patientName'] ?? json['name'] ?? '').toString(),
      lastMessage: (json['lastMessage'] ?? '').toString(),
      time: (json['time'] ?? '').toString(),
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? false,
      phone: json['phone']?.toString(),
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
      'phone': phone,
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
  final String? mediaUrl;
  final String? mediaType;
  final String? fileName;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isMe,
    required this.time,
    this.patientId,
    this.isRead = false,
    this.mediaUrl,
    this.mediaType,
    this.fileName,
  });

  factory ChatMessage.fromJson(Map<String, Object?> json) {
    final sender = json['sender']?.toString();
    final isMeFromSender = sender == 'doctor';
    return ChatMessage(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      text: (json['message'] ?? json['text'] ?? '').toString(),
      isMe: json['isMe'] as bool? ?? isMeFromSender,
      time: (json['time'] ?? json['createdAt'] ?? '').toString(),
      patientId: json['patientId']?.toString(),
      isRead: json['isRead'] as bool? ?? false,
      mediaUrl: json['mediaUrl']?.toString(),
      mediaType: json['mediaType']?.toString(),
      fileName: json['fileName']?.toString(),
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'message': text,
      'isMe': isMe,
      'time': time,
      'patientId': patientId,
      'isRead': isRead,
      'mediaUrl': mediaUrl,
      'mediaType': mediaType,
      'fileName': fileName,
    };
  }
}
