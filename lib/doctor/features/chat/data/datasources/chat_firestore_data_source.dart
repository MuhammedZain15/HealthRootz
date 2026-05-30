// lib/doctor/features/chat/data/datasources/chat_firestore_data_source.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grad_project/doctor/features/chat/data/firebase/chat_firebase.dart';
import 'package:grad_project/doctor/features/chat/data/utils/chat_id_helper.dart';
import 'package:grad_project/doctor/features/chat/models/chat_model.dart';
import 'package:intl/intl.dart';

abstract class ChatFirestoreDataSource {
  Stream<List<ChatMessage>> watchMessages({
    required String doctorId,
    required String patientId,
  });

  Stream<List<ChatUser>> watchChatList({required String doctorId});

  Future<ChatMessage> sendMessage({
    required String doctorId,
    required String patientId,
    required String senderId,
    required String text,
  });

  Future<void> markAsRead({
    required String doctorId,
    required String patientId,
    required String messageId,
  });

  Future<void> deleteMessage({
    required String doctorId,
    required String patientId,
    required String messageId,
  });
}

class ChatFirestoreDataSourceImpl implements ChatFirestoreDataSource {
  ChatFirestoreDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  bool _initialized = false;

  Future<void> _ensureReady() async {
    if (_initialized) return;
    await ChatFirebase.ensureInitialized();
    _initialized = true;
  }

  String _chatId(String doctorId, String patientId) =>
      ChatIdHelper.build(doctorId, patientId);

  CollectionReference<Map<String, dynamic>> _messagesRef(String chatId) =>
      _firestore.collection('chats').doc(chatId).collection('messages');

  DocumentReference<Map<String, dynamic>> _chatRef(String chatId) =>
      _firestore.collection('chats').doc(chatId);

  ChatMessage _mapMessage(
    DocumentSnapshot<Map<String, dynamic>> doc,
    String doctorId,
    String patientId,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    final senderId = data['senderId']?.toString() ?? '';
    final timestamp = data['timestamp'];
    final DateTime dateTime =
        timestamp is Timestamp ? timestamp.toDate() : DateTime.now();
    return ChatMessage(
      id: doc.id,
      text: data['text']?.toString() ?? '',
      isMe: senderId == doctorId,
      time: DateFormat.jm().format(dateTime),
      patientId: patientId,
      isRead: data['isRead'] as bool? ?? false,
    );
  }

  @override
  Stream<List<ChatMessage>> watchMessages({
    required String doctorId,
    required String patientId,
  }) async* {
    await _ensureReady();
    final chatId = _chatId(doctorId, patientId);
    yield* _messagesRef(chatId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => _mapMessage(doc, doctorId, patientId))
              .toList(growable: false),
        );
  }

  @override
  Stream<List<ChatUser>> watchChatList({required String doctorId}) async* {
    await _ensureReady();
    yield* _firestore.collection('chats').snapshots().map((snapshot) {
      final users = <ChatUser>[];
      for (final doc in snapshot.docs) {
        final patientId = _patientIdFromDoctorChat(doc.id, doctorId);
        if (patientId == null) continue;

        final data = doc.data();
        users.add(
          ChatUser(
            id: patientId,
            name: data['patientName']?.toString() ?? patientId,
            lastMessage: data['lastMessage']?.toString() ?? '',
            time: _formatChatTime(data['updatedAt']),
            unreadCount: (data['unreadCount'] as num?)?.toInt() ?? 0,
            isActive: true,
          ),
        );
      }
      return users;
    });
  }

  String? _patientIdFromDoctorChat(String chatId, String doctorId) {
    final prefix = '${doctorId}_';
    if (!chatId.startsWith(prefix)) return null;
    final patientId = chatId.substring(prefix.length);
    return patientId.isEmpty ? null : patientId;
  }

  String _formatChatTime(Object? value) {
    if (value is Timestamp) {
      return DateFormat.jm().format(value.toDate());
    }
    return '';
  }

  @override
  Future<ChatMessage> sendMessage({
    required String doctorId,
    required String patientId,
    required String senderId,
    required String text,
  }) async {
    await _ensureReady();
    final chatId = _chatId(doctorId, patientId);
    final messageRef = _messagesRef(chatId).doc();
    final payload = <String, dynamic>{
      'senderId': senderId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    };

    await messageRef.set(payload);
    await _chatRef(chatId).set(
      <String, dynamic>{
        'doctorId': doctorId,
        'patientId': patientId,
        'lastMessage': text,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    final snapshot = await messageRef.get();
    return _mapMessage(snapshot, doctorId, patientId);
  }

  @override
  Future<void> markAsRead({
    required String doctorId,
    required String patientId,
    required String messageId,
  }) async {
    await _ensureReady();
    final chatId = _chatId(doctorId, patientId);
    await _messagesRef(chatId).doc(messageId).update(<String, dynamic>{
      'isRead': true,
    });
  }

  @override
  Future<void> deleteMessage({
    required String doctorId,
    required String patientId,
    required String messageId,
  }) async {
    await _ensureReady();
    final chatId = _chatId(doctorId, patientId);
    await _messagesRef(chatId).doc(messageId).delete();
  }
}
