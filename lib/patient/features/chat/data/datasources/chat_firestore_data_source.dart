// lib/patient/features/chat/data/datasources/chat_firestore_data_source.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grad_project/core/services/auth_service.dart';
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
    : _firestoreOverride = firestore;

  static const String _chatsCollection = 'chats';
  static const String _doctorIdPrefsKey = 'chat_doctor_id';
  static const String _defaultDoctorId = 'dr_sarah_johnson';
  static const String _messageField = 'message';
  static const String _senderIdField = 'senderId';
  static const String _timestampField = 'timestamp';
  static const String _chatIdField = 'chatId';
  static const String _doctorIdField = 'doctorId';
  static const String _patientIdField = 'patientId';
  static const String _patientNameField = 'patientName';

  final FirebaseFirestore? _firestoreOverride;
  final AuthService _authService = AuthService();
  bool _initialized = false;

  FirebaseFirestore get _firestore =>
      _firestoreOverride ?? FirebaseFirestore.instance;

  Future<void> _ensureReady() async {
    if (_initialized) return;
    await ChatFirebase.ensureInitialized();
    _initialized = true;
  }

  String _chatId(String doctorId, String patientId) =>
      ChatIdHelper.build(doctorId, patientId);

  CollectionReference<Map<String, dynamic>> get _chatsRef =>
      _firestore.collection(_chatsCollection);

  ChatMessage _mapMessage(
    DocumentSnapshot<Map<String, dynamic>> doc,
    String doctorId,
    String patientId,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    final senderId = data[_senderIdField]?.toString() ?? '';
    final timestamp = data[_timestampField];
    final DateTime dateTime = timestamp is Timestamp
        ? timestamp.toDate()
        : DateTime.now();
    final isSender = senderId == patientId;
    return ChatMessage(
      id: doc.id,
      text: (data[_messageField] ?? data['text'] ?? '').toString(),
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

    final snapshot = await _chatsRef
        .where(_patientIdField, isEqualTo: patientId)
        .limit(1)
        .get();
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final doctorId =
          data[_doctorIdField]?.toString() ??
          ChatIdHelper.doctorIdFromChatId(doc.id, patientId);
      if (doctorId != null) {
        PatientChatSession.activeDoctorId = doctorId;
        await prefs.setString(_doctorIdPrefsKey, doctorId);
        return doctorId;
      }
    }

    PatientChatSession.activeDoctorId = _defaultDoctorId;
    await prefs.setString(_doctorIdPrefsKey, _defaultDoctorId);
    return _defaultDoctorId;
  }

  @override
  Stream<List<ChatMessage>> watchMessages({
    required String doctorId,
    required String patientId,
  }) async* {
    await _ensureReady();
    yield* _chatsRef
        .where(_patientIdField, isEqualTo: patientId)
        .snapshots()
        .map((snapshot) {
          final docs = snapshot.docs.toList()..sort(_sortByTimestamp);
          return docs
              .map((doc) => _mapMessage(doc, doctorId, patientId))
              .toList(growable: false);
        });
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
    final messageRef = _chatsRef.doc();
    final patientName = await _resolvePatientName(patientId);
    final payload = <String, dynamic>{
      _messageField: text,
      _senderIdField: senderId,
      _timestampField: FieldValue.serverTimestamp(),
      _chatIdField: chatId,
      _doctorIdField: doctorId,
      _patientIdField: patientId,
      'isRead': false,
    };
    if (patientName != null) {
      payload[_patientNameField] = patientName;
    }

    await messageRef.set(payload);

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
    await _chatsRef.doc(messageId).update(<String, dynamic>{'isRead': true});
  }

  @override
  Future<void> deleteMessage({
    required String doctorId,
    required String patientId,
    required String messageId,
  }) async {
    await _ensureReady();
    await _chatsRef.doc(messageId).delete();
  }

  int _sortByTimestamp(
    QueryDocumentSnapshot<Map<String, dynamic>> a,
    QueryDocumentSnapshot<Map<String, dynamic>> b,
  ) {
    return _timestampValue(
      a.data()[_timestampField],
    ).compareTo(_timestampValue(b.data()[_timestampField]));
  }

  int _timestampValue(Object? value) {
    if (value is Timestamp) return value.millisecondsSinceEpoch;
    if (value is DateTime) return value.millisecondsSinceEpoch;
    return DateTime.now().millisecondsSinceEpoch;
  }

  Future<String?> _resolvePatientName(String patientId) async {
    for (final collection in const <String>[
      'users',
      'patients',
      'patient_profiles',
      'profiles',
    ]) {
      final byDocumentId = await _nameFromDocument(collection, patientId);
      if (byDocumentId != null) return byDocumentId;

      final byIdField = await _nameFromQuery(collection, 'id', patientId);
      if (byIdField != null) return byIdField;

      final byUnderscoreId = await _nameFromQuery(collection, '_id', patientId);
      if (byUnderscoreId != null) return byUnderscoreId;

      final byUserId = await _nameFromQuery(collection, 'userId', patientId);
      if (byUserId != null) return byUserId;
    }
    return _nameFromProfile(patientId);
  }

  Future<String?> _nameFromDocument(
    String collection,
    String documentId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(collection)
          .doc(documentId)
          .get();
      if (!snapshot.exists) return null;
      return _extractName(snapshot.data());
    } on FirebaseException {
      return null;
    }
  }

  Future<String?> _nameFromQuery(
    String collection,
    String field,
    String value,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(collection)
          .where(field, isEqualTo: value)
          .limit(1)
          .get();
      if (snapshot.docs.isEmpty) return null;
      return _extractName(snapshot.docs.first.data());
    } on FirebaseException {
      return null;
    }
  }

  String? _extractName(Map<String, dynamic>? data) {
    final raw = data?['name'] ?? data?['fullName'] ?? data?['displayName'];
    final name = raw?.toString().trim();
    return name == null || name.isEmpty ? null : name;
  }

  Future<String?> _nameFromProfile(String patientId) async {
    final result = await _authService.getProfile();
    final user = result.data;
    if (!result.success || user == null) return null;
    if (user.id != null && user.id != patientId) return null;
    final name = user.name?.trim();
    return name == null || name.isEmpty ? null : name;
  }
}
