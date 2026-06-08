// lib/patient/features/chat/data/datasources/chat_firestore_data_source.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:grad_project/core/network/api_client.dart';
import 'package:grad_project/core/network/api_constants.dart';
import 'package:grad_project/core/network/token_storage.dart';
import 'package:grad_project/core/services/auth_service.dart';
import 'package:grad_project/patient/features/chat/chat_model.dart';
import 'package:grad_project/patient/features/chat/data/firebase/chat_firebase.dart';
import 'package:grad_project/patient/features/chat/data/utils/chat_doctor_id.dart';
import 'package:grad_project/patient/features/chat/data/utils/chat_id_helper.dart';
import 'package:grad_project/patient/features/chat/patient_chat_session.dart';
import 'package:grad_project/patient/features/patient/data/models/patient_model.dart';
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
  /// Legacy prefs key (global); prefer [TokenStorage] per-patient cache.
  static const String _doctorIdPrefsKey = 'chat_doctor_id';
  static const String _messageField = 'message';
  static const String _senderIdField = 'senderId';
  static const String _timestampField = 'timestamp';
  static const String _chatIdField = 'chatId';
  static const String _doctorIdField = 'doctorId';
  static const String _patientIdField = 'patientId';
  static const String _patientNameField = 'patientName';
  static const String _senderRoleField = 'senderRole';

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
    final senderRole = data[_senderRoleField]?.toString();
    final timestamp = data[_timestampField];
    final DateTime dateTime = timestamp is Timestamp
        ? timestamp.toDate()
        : DateTime.now();
    // Align bubble side with senderId or senderRole for two-way sync.
    final isSender = senderId == patientId || senderRole == 'patient';
    return ChatMessage(
      id: doc.id,
      text: (data[_messageField] ?? data['text'] ?? '').toString(),
      isSender: isSender,
      timestamp: dateTime,
      doctorName: isSender
          ? null
          : (data['doctorName']?.toString() ?? 'Your Doctor'),
      patientId: patientId,
      isRead: data['isRead'] as bool? ?? false,
    );
  }

  /// Resolves the doctor id that must match the doctor app's [TokenStorage.getUserId].
  ///
  /// Order: in-memory session → per-patient cache → GET /patients/me →
  /// GET /auth/profile → existing Firestore messages.
  /// Never falls back to a hardcoded placeholder.
  @override
  Future<String?> resolveDoctorId(String patientId) async {
    await _ensureReady();

    String? resolved;

    // 1. In-memory session (e.g. after a successful send in this app session).
    if (isResolvableDoctorId(PatientChatSession.activeDoctorId)) {
      resolved = PatientChatSession.activeDoctorId!.trim();
    }

    // 2. Per-patient cache (survives app restarts; keyed by patient id).
    resolved ??= await _readCachedDoctorId(patientId);

    // 3. Backend: patient's assigned doctor from GET /patients/me.
    resolved ??= await _fetchAssignedDoctorFromPatientsMe(patientId);

    // 4. Backend fallback: GET /auth/profile (some APIs expose doctorId there).
    resolved ??= await _fetchAssignedDoctorFromProfile(patientId);

    // 5. Firestore: reuse doctorId from an existing chat document.
    resolved ??= await _doctorIdFromExistingMessages(patientId);

    if (isResolvableDoctorId(resolved)) {
      await _persistResolvedDoctorId(patientId, resolved!.trim());
      debugPrint('Resolved doctor ID: $resolved (patient: $patientId)');
      return resolved.trim();
    }

    debugPrint(
      'Could not resolve doctor ID for patient $patientId. '
      'Assign a doctor via the backend or send from doctor app first.',
    );
    return null;
  }

  Future<String?> _readCachedDoctorId(String patientId) async {
    final perPatient = await TokenStorage.getAssignedDoctorId(patientId);
    if (isResolvableDoctorId(perPatient)) {
      return perPatient!.trim();
    }
    if (perPatient != null && !isResolvableDoctorId(perPatient)) {
      await TokenStorage.removeAssignedDoctorId(patientId);
    }

    final prefs = await SharedPreferences.getInstance();
    final legacyGlobal = prefs.getString(_doctorIdPrefsKey);
    if (isResolvableDoctorId(legacyGlobal)) {
      return legacyGlobal!.trim();
    }
    if (legacyGlobal != null) {
      await prefs.remove(_doctorIdPrefsKey);
    }
    return null;
  }

  Future<void> _persistResolvedDoctorId(
    String patientId,
    String doctorId,
  ) async {
    PatientChatSession.activeDoctorId = doctorId;
    await TokenStorage.saveAssignedDoctorId(patientId, doctorId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_doctorIdPrefsKey, doctorId);
  }

  Future<String?> _fetchAssignedDoctorFromPatientsMe(String patientId) async {
    try {
      // Option A: GET /patients — find row where user matches logged-in JWT id.
      final patientUserId = await TokenStorage.getUserId();
      if (patientUserId != null && patientUserId.isNotEmpty) {
        final response = await ApiClient.instance.dio.get(ApiConstants.patients);
        final body = response.data;
        final list = body is Map && body['data'] is List
            ? body['data'] as List
            : body is List
            ? body
            : <dynamic>[];

        for (final item in list) {
          if (item is! Map) continue;
          final record = Map<String, dynamic>.from(item);
          final user = record['user'];
          final userId = user is Map
              ? (user['_id'] ?? user['id'])?.toString()
              : user?.toString();
          if (userId != patientUserId) continue;

          final doctor = record['doctor'];
          if (doctor is Map) {
            final resolved =
                (doctor['_id'] ?? doctor['id'])?.toString().trim();
            if (isResolvableDoctorId(resolved)) {
              debugPrint('Resolved doctor from API: $resolved');
              return resolved;
            }
          }
        }
      }

      // Option B: GET /auth/profile — doctor._id on profile payload.
      final profileResponse =
          await ApiClient.instance.dio.get(ApiConstants.profile);
      final profileBody = profileResponse.data;
      if (profileBody is Map) {
        final doctor = profileBody['doctor'] ?? profileBody['data']?['doctor'];
        if (doctor is Map) {
          final resolved = (doctor['_id'] ?? doctor['id'])?.toString().trim();
          if (isResolvableDoctorId(resolved)) {
            debugPrint('Resolved doctor from API: $resolved');
            return resolved;
          }
        }
      }
    } catch (e) {
      debugPrint('Failed to resolve doctor from patients/profile API: $e');
    }
    return null;
  }

  Future<String?> _fetchAssignedDoctorFromProfile(String patientId) async {
    try {
      final response = await ApiClient.instance.dio.get(ApiConstants.profile);
      final doctorId = PatientModel.extractAssignedDoctorIdFromResponse(
        response.data,
        patientId: patientId,
      );
      if (isResolvableDoctorId(doctorId)) {
        debugPrint('Assigned doctor from GET ${ApiConstants.profile}: $doctorId');
        return doctorId!.trim();
      }
    } catch (e) {
      debugPrint('GET ${ApiConstants.profile} failed: $e');
    }
    return null;
  }

  Future<String?> _doctorIdFromExistingMessages(String patientId) async {
    final snapshot = await _chatsRef
        .where(_patientIdField, isEqualTo: patientId)
        .limit(20)
        .get();
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final candidate = data[_doctorIdField]?.toString().trim() ??
          ChatIdHelper.doctorIdFromChatId(
            data[_chatIdField]?.toString() ?? doc.id,
            patientId,
          );
      if (isResolvableDoctorId(candidate)) {
        debugPrint('Doctor ID from existing Firestore message: $candidate');
        return candidate!.trim();
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
    // Same compound filter as doctor app so both sides read the same documents.
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
  Future<ChatMessage> sendMessage({
    required String doctorId,
    required String patientId,
    required String senderId,
    required String text,
  }) async {
    await _ensureReady();
    if (!isResolvableDoctorId(doctorId)) {
      throw StateError(kDoctorAssignmentMissingMessage);
    }
    await _persistResolvedDoctorId(patientId, doctorId.trim());

    final chatId = _chatId(doctorId, patientId);
    final messageRef = _chatsRef.doc();
    final patientName = await _resolvePatientName(patientId);
    final payload = <String, dynamic>{
      _messageField: text,
      _senderIdField: senderId,
      _senderRoleField: 'patient',
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
