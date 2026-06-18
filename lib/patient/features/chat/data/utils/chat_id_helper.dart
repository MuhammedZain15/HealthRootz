// lib/patient/features/chat/data/utils/chat_id_helper.dart
class ChatIdHelper {
  ChatIdHelper._();

  static String build(String doctorId, String patientId) =>
      '${doctorId}_$patientId';

  static String? doctorIdFromChatId(String chatId, String patientId) {
    final suffix = '_$patientId';
    if (!chatId.endsWith(suffix)) return null;
    final doctorId = chatId.substring(0, chatId.length - suffix.length);
    return doctorId.isEmpty ? null : doctorId;
  }
}

// commit update
 