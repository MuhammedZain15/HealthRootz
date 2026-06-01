import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grad_project/patient/features/chat/chat_model.dart';

abstract class AiChatDataSource {
  Future<String> createSession(String patientId);

  Future<void> saveMessage(
    String patientId,
    String sessionId,
    String text,
    bool isSender,
  );

  Stream<List<ChatMessage>> watchMessages(
    String patientId,
    String sessionId,
  );

  Future<List<Map<String, dynamic>>> getSessions(String patientId);

  Future<void> updateSessionMeta(
    String patientId,
    String sessionId,
    String firstMessage,
    String lastMessage,
  );

  Future<void> deleteSession(String patientId, String sessionId);

  Future<void> deleteMessage(
    String patientId,
    String sessionId,
    String messageId,
  );
}

class AiChatDataSourceImpl implements AiChatDataSource {
  AiChatDataSourceImpl({FirebaseFirestore? firestore})
    : _firestoreOverride = firestore;

  final FirebaseFirestore? _firestoreOverride;

  FirebaseFirestore get _firestore =>
      _firestoreOverride ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _sessionsRef(String patientId) =>
      _firestore.collection('ai_chats').doc(patientId).collection('sessions');

  CollectionReference<Map<String, dynamic>> _messagesRef(
    String patientId,
    String sessionId,
  ) =>
      _sessionsRef(patientId).doc(sessionId).collection('messages');

  @override
  Future<String> createSession(String patientId) async {
    final docRef = _sessionsRef(patientId).doc();
    final now = DateTime.now();
    
    await docRef.set({
      'title': 'AI Chat ${now.toLocal()}',
      'createdAt': FieldValue.serverTimestamp(),
      'lastMessage': '',
      'lastMessageTime': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  @override
  Future<void> saveMessage(
    String patientId,
    String sessionId,
    String text,
    bool isSender,
  ) async {
    await _messagesRef(patientId, sessionId).add({
      'text': text,
      'isSender': isSender,
      'timestamp': FieldValue.serverTimestamp(),
      'isAI': !isSender,
    });
  }

  @override
  Stream<List<ChatMessage>> watchMessages(
    String patientId,
    String sessionId,
  ) {
    return _messagesRef(patientId, sessionId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) {
                final data = doc.data();
                final timestamp = data['timestamp'];
                final DateTime dateTime = timestamp is Timestamp
                    ? timestamp.toDate()
                    : DateTime.now();

                return ChatMessage(
                  id: doc.id,
                  text: data['text'] as String? ?? '',
                  isSender: data['isSender'] as bool? ?? false,
                  timestamp: dateTime,
                  doctorName: data['isSender'] == false ? 'AI Assistant' : null,
                );
              })
              .toList(growable: false);
        });
  }

  @override
  Future<List<Map<String, dynamic>>> getSessions(String patientId) async {
    try {
      final snapshot = await _sessionsRef(patientId)
          .orderBy('lastMessageTime', descending: true)
          .get();

      return snapshot.docs
          .map((doc) {
            final data = doc.data();
            return {
              ...data,
              'id': doc.id,
            };
          })
          .toList(growable: false);
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> updateSessionMeta(
    String patientId,
    String sessionId,
    String firstMessage,
    String lastMessage,
  ) async {
    await _sessionsRef(patientId).doc(sessionId).update({
      'title': firstMessage.length > 50
          ? '${firstMessage.substring(0, 50)}...'
          : firstMessage,
      'lastMessage': lastMessage,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteSession(String patientId, String sessionId) async {
    // Delete all messages first
    final messages = await _messagesRef(patientId, sessionId).get();
    for (final doc in messages.docs) {
      await doc.reference.delete();
    }
    // Then delete the session
    await _sessionsRef(patientId).doc(sessionId).delete();
  }

  @override
  Future<void> deleteMessage(
    String patientId,
    String sessionId,
    String messageId,
  ) async {
    await _messagesRef(patientId, sessionId).doc(messageId).delete();
  }
}
