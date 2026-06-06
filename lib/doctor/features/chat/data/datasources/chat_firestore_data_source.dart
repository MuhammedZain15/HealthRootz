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

  Stream<List<ChatUser>> watchAllPatients({
    required String doctorId,
    required Future<List<Map<String, dynamic>>> Function() fetchPatients,
  });

  Future<ChatMessage> sendMessage({
    required String doctorId,
    required String patientId,
    required String senderId,
    required String text,
  });

  Future<ChatMessage> sendMediaMessage({
    required String doctorId,
    required String patientId,
    required String senderId,
    required String fileUrl,
    required String fileType,
    required String fileName,
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
  static const String _clientTimestampField = 'clientTimestamp';
  static const String _chatIdField = 'chatId';
  static const String _doctorIdField = 'doctorId';
  static const String _patientIdField = 'patientId';
  static const String _patientNameField = 'patientName';
  static const String _mediaUrlField = 'mediaUrl';
  static const String _mediaTypeField = 'mediaType';
  static const String _fileNameField = 'fileName';

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

  DateTime _parseMessageDateTime(Object? timestamp) {
    if (timestamp is Timestamp) return timestamp.toDate().toLocal();
    if (timestamp is DateTime) return timestamp.toLocal();
    if (timestamp is num) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp.toInt()).toLocal();
    }
    if (timestamp is String && timestamp.isNotEmpty) {
      return DateTime.tryParse(timestamp)?.toLocal() ?? DateTime.now();
    }
    return DateTime.now();
  }

  ChatMessage _mapMessage(
    DocumentSnapshot<Map<String, dynamic>> doc,
    String doctorId,
    String patientId,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    final senderId = data[_senderIdField]?.toString() ?? '';
    final dateTime = _parseMessageDateTime(
      data[_timestampField] ?? data[_clientTimestampField],
    );

    return ChatMessage(
      id: doc.id,
      text: (data[_messageField] ?? data['text'] ?? '').toString(),
      isMe: senderId == doctorId,
      time: DateFormat.jm().format(dateTime),
      patientId: patientId,
      isRead: data['isRead'] as bool? ?? false,
      mediaUrl: data[_mediaUrlField]?.toString(),
      mediaType: data[_mediaTypeField]?.toString(),
      fileName: data[_fileNameField]?.toString(),
    );
  }

  @override
  Stream<List<ChatMessage>> watchMessages({
    required String doctorId,
    required String patientId,
  }) async* {
    await _ensureReady();

    yield* _chatsRef
        .where(_doctorIdField, isEqualTo: doctorId)
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
  Stream<List<ChatUser>> watchAllPatients({
    required String doctorId,
    required Future<List<Map<String, dynamic>>> Function() fetchPatients,
  }) async* {
    await _ensureReady();

    yield* _chatsRef
        .where(_doctorIdField, isEqualTo: doctorId)
        .snapshots()
        .asyncMap((snapshot) async {
          final patients = await fetchPatients();
          final grouped = _groupMessagesByPatient(snapshot.docs, doctorId);
          return _mergePatientsWithChats(
            patients: patients,
            grouped: grouped,
            doctorId: doctorId,
          );
        });
  }

  Map<String, List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  _groupMessagesByPatient(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    String doctorId,
  ) {
    final grouped =
        <String, List<QueryDocumentSnapshot<Map<String, dynamic>>>>{};

    for (final doc in docs) {
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

    return grouped;
  }

  List<ChatUser> _mergePatientsWithChats({
    required List<Map<String, dynamic>> patients,
    required Map<String, List<QueryDocumentSnapshot<Map<String, dynamic>>>>
    grouped,
    required String doctorId,
  }) {
    final rows = <({ChatUser user, int timestamp})>[];

    for (final patient in patients) {
      final patientId = (patient['id'] ?? patient['_id'] ?? '').toString();
      if (patientId.isEmpty) continue;

      final name = (patient['patientName'] ?? patient['name'] ?? patientId)
          .toString();
      final phone = patient['phone']?.toString();
      final messages = grouped[patientId];

      if (messages == null || messages.isEmpty) {
        rows.add((
          user: ChatUser(
            id: patientId,
            name: name,
            phone: phone,
            lastMessage: 'No messages yet',
            time: '',
            unreadCount: 0,
            isActive: true,
          ),
          timestamp: 0,
        ));
        continue;
      }

      final sortedMessages = messages.toList()..sort(_sortByTimestamp);
      final latest = sortedMessages.last;
      final data = latest.data();
      final patientName = _patientNameFromMessages(sortedMessages) ?? name;

      rows.add((
        user: ChatUser(
          id: patientId,
          name: patientName,
          phone: phone,
          lastMessage: (data[_messageField] ?? data['text'] ?? '').toString(),
          time: _formatChatTime(
            data[_timestampField] ?? data[_clientTimestampField],
          ),
          unreadCount: sortedMessages.where((message) {
            final messageData = message.data();
            return messageData[_senderIdField]?.toString() != doctorId &&
                (messageData['isRead'] as bool? ?? false) == false;
          }).length,
          isActive: true,
        ),
        timestamp: _timestampValue(
          data[_timestampField] ?? data[_clientTimestampField],
        ),
      ));
    }

    rows.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return rows.map((row) => row.user).toList(growable: false);
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
    final patientName =
        await _patientNameFromExistingMessages(patientId) ??
        await _resolvePatientName(patientId);
    final payload = <String, dynamic>{
      _messageField: text,
      _senderIdField: senderId,
      _clientTimestampField: DateTime.now().millisecondsSinceEpoch,
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
  Future<ChatMessage> sendMediaMessage({
    required String doctorId,
    required String patientId,
    required String senderId,
    required String fileUrl,
    required String fileType,
    required String fileName,
  }) async {
    await _ensureReady();
    final chatId = _chatId(doctorId, patientId);
    final messageRef = _chatsRef.doc();
    final patientName =
        await _patientNameFromExistingMessages(patientId) ??
        await _resolvePatientName(patientId);
    final payload = <String, dynamic>{
      _messageField: fileName,
      _senderIdField: senderId,
      _clientTimestampField: DateTime.now().millisecondsSinceEpoch,
      _timestampField: FieldValue.serverTimestamp(),
      _chatIdField: chatId,
      _doctorIdField: doctorId,
      _patientIdField: patientId,
      _mediaUrlField: fileUrl,
      _mediaTypeField: fileType,
      _fileNameField: fileName,
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
    return DateFormat.jm().format(_parseMessageDateTime(value));
  }

  int _sortByTimestamp(
    QueryDocumentSnapshot<Map<String, dynamic>> a,
    QueryDocumentSnapshot<Map<String, dynamic>> b,
  ) {
    return _timestampValue(
      a.data()[_timestampField] ?? a.data()[_clientTimestampField],
    ).compareTo(
      _timestampValue(
        b.data()[_timestampField] ?? b.data()[_clientTimestampField],
      ),
    );
  }

  int _timestampValue(Object? value) {
    if (value is Timestamp) return value.millisecondsSinceEpoch;
    if (value is DateTime) return value.millisecondsSinceEpoch;
    if (value is num) return value.toInt();
    return 0;
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

  String? _patientNameFromMessages(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> messages,
  ) {
    for (final doc in messages.reversed) {
      final name = doc.data()[_patientNameField]?.toString().trim();
      if (name != null && name.isNotEmpty) return name;
    }
    return null;
  }

  Future<String?> _patientNameFromExistingMessages(String patientId) async {
    try {
      final snapshot = await _chatsRef
          .where(_patientIdField, isEqualTo: patientId)
          .get();
      final docs = snapshot.docs.toList()..sort(_sortByTimestamp);
      return _patientNameFromMessages(docs);
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
}
