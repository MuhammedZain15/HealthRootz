// lib/patient/features/chat/data/datasources/chat_firestore_data_source.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grad_project/patient/features/chat/chat_model.dart';
import 'package:grad_project/patient/features/chat/data/firebase/chat_firebase.dart';
import 'package:grad_project/patient/features/chat/data/utils/chat_id_helper.dart';
import 'package:grad_project/patient/features/chat/patient_chat_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class ChatFirestoreDataSource {
  Stream<List<ChatMessage>> watchMessages({
    required String doctorId,
    required String patientId,
  });

  Future<String?> resolveDoctorId(String patientId);

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

  static const String _doctorIdPrefsKey = 'chat_doctor_id';

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
    final isSender = senderId == patientId;
    return ChatMessage(
      id: doc.id,
      text: data['text']?.toString() ?? '',
      isSender: isSender,
      timestamp: dateTime,
      doctorName: isSender ? null : 'Dr. Sarah Johnson',
      patientId: patientId,
      isRead: data['isRead'] as bool? ?? false,
    );
  }

  @override
  Future<String?> resolveDoctorId(String patientId) async {
    await _ensureReady();
    if (PatientChatSession.activeDoctorId != null &&
        PatientChatSession.activeDoctorId!.isNotEmpty) {
      return PatientChatSession.activeDoctorId;
    }

    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_doctorIdPrefsKey);
    if (stored != null && stored.isNotEmpty) {
      PatientChatSession.activeDoctorId = stored;
      return stored;
    }

    final snapshot = await _firestore.collection('chats').get();
    for (final doc in snapshot.docs) {
      final doctorId = ChatIdHelper.doctorIdFromChatId(doc.id, patientId);
      if (doctorId != null) {
        PatientChatSession.activeDoctorId = doctorId;
        await prefs.setString(_doctorIdPrefsKey, doctorId);
        return doctorId;
      }
    }
    return null;
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
  Future<ChatMessage> sendMessage({
    required String doctorId,
    required String patientId,
    required String senderId,
    required String text,
  }) async {
    await _ensureReady();
    PatientChatSession.activeDoctorId = doctorId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_doctorIdPrefsKey, doctorId);

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
