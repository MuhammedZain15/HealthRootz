/// Chat message model — maps to the Chat endpoints.
class ChatMessageModel {
  final String? id;
  final String? patientId;
  final String? doctorId;
  final String? sender; // "doctor" or "patient"
  final String? text;
  final bool? isRead;
  final String? createdAt;
  final String? updatedAt;

  ChatMessageModel({
    this.id,
    this.patientId,
    this.doctorId,
    this.sender,
    this.text,
    this.isRead,
    this.createdAt,
    this.updatedAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['_id'] as String?,
      patientId: json['patientId'] as String?,
      doctorId: json['doctorId'] as String?,
      sender: json['sender'] as String?,
      text: json['text'] as String?,
      isRead: json['isRead'] as bool?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (patientId != null) 'patientId': patientId,
      if (doctorId != null) 'doctorId': doctorId,
      if (sender != null) 'sender': sender,
      if (text != null) 'text': text,
    };
  }
}
