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
    : _firestoreOverride = firestore;

  static const String _chatsCollection = 'chats';
  static const String _messageField = 'message';
  static const String _senderIdField = 'senderId';
  static const String _timestampField = 'timestamp';
  static const String _chatIdField = 'chatId';
  static const String _doctorIdField = 'doctorId';
  static const String _patientIdField = 'patientId';
  static const String _patientNameField = 'patientName';

  final FirebaseFirestore? _firestoreOverride;
  bool _initialized = false;

  FirebaseFirestore get _firestore =>
      _firestoreOverride ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _chatsRef =>
      _firestore.collection(_chatsCollection);

  Future<void> _ensureReady() async {
    if (_initialized) return;
    await ChatFirebase.ensureInitialized();
    _initialized = true;
  }

  String _chatId(String doctorId, String patientId) =>
      ChatIdHelper.build(doctorId, patientId);

  ChatMessage _mapMessage(
    DocumentSnapshot<Map<String, dynamic>> doc,
    String doctorId,
    String patientId,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    final senderId = data[_senderIdField]?.toString() ?? '';
    final timestamp = data[_timestampField];
    final dateTime = timestamp is Timestamp
        ? timestamp.toDate()
        : DateTime.now();

    return ChatMessage(
      id: doc.id,
      text: (data[_messageField] ?? data['text'] ?? '').toString(),
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
  Stream<List<ChatUser>> watchChatList({required String doctorId}) async* {
    await _ensureReady();

    yield* _chatsRef.snapshots().asyncMap((snapshot) async {
      final grouped =
          <String, List<QueryDocumentSnapshot<Map<String, dynamic>>>>{};

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final patientId =
            data[_patientIdField]?.toString() ??
            _patientIdFromDoctorChat(
              data[_chatIdField]?.toString() ?? '',
              doctorId,
            );
        if (patientId == null) continue;
        grouped.putIfAbsent(patientId, () => []).add(doc);
      }

      final rows = <({ChatUser user, int timestamp})>[];
      for (final entry in grouped.entries) {
        final messages = entry.value..sort(_sortByTimestamp);
        final latest = messages.last;
        final data = latest.data();
        final patientName =
            _extractPatientName(data) ?? await _resolvePatientName(entry.key);
        rows.add((
          user: ChatUser(
            id: entry.key,
            name: patientName ?? _fallbackPatientName(entry.key),
            lastMessage: (data[_messageField] ?? data['text'] ?? '').toString(),
            time: _formatChatTime(data[_timestampField]),
            unreadCount: messages.where((message) {
              final messageData = message.data();
              return messageData[_senderIdField]?.toString() != doctorId &&
                  (messageData['isRead'] as bool? ?? false) == false;
            }).length,
            isActive: true,
          ),
          timestamp: _timestampValue(data[_timestampField]),
        ));
      }

      rows.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return rows.map((row) => row.user).toList(growable: false);
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
    return null;
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
      return _extractPatientName(snapshot.data());
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
      return _extractPatientName(snapshot.docs.first.data());
    } on FirebaseException {
      return null;
    }
  }

  String? _extractPatientName(Map<String, dynamic>? data) {
    final raw =
        data?[_patientNameField] ??
        data?['name'] ??
        data?['fullName'] ??
        data?['displayName'];
    final name = raw?.toString().trim();
    return name == null || name.isEmpty ? null : name;
  }

  String _fallbackPatientName(String patientId) {
    final visible = patientId.length <= 6
        ? patientId
        : patientId.substring(patientId.length - 6);
    return 'Patient $visible';
  }
}
