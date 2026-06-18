import '../utils/patient_response_parser.dart';

/// A single doctor note attached to a patient record.
class PatientNoteModel {
  final String id;
  final String text;
  final String? doctorName;
  final DateTime? createdAt;

  const PatientNoteModel({
    required this.id,
    required this.text,
    this.doctorName,
    this.createdAt,
  });

  factory PatientNoteModel.fromJson(dynamic json) {
    if (json is String) {
      return PatientNoteModel(id: '', text: json);
    }
    if (json is! Map) {
      return PatientNoteModel(id: '', text: json.toString());
    }
    final map = Map<String, dynamic>.from(json);
    return PatientNoteModel(
      id: (map['_id'] ?? map['id'] ?? '').toString(),
      text: (map['text'] ?? map['note'] ?? map['content'] ?? '').toString(),
      doctorName: (map['doctorName'] ?? map['addedBy'] ?? map['author'])
          ?.toString(),
      createdAt: _parseDate(map['createdAt'] ?? map['timestamp'] ?? map['date']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}

/// Patient model for the patient feature.
///
/// All required fields are non-nullable; only [medicalHistory] is optional.
/// Supports flat JSON and envelopes (`data`, `patient`, `user`, `result`, etc.).
class PatientModel {
  final String id;
  /// Auth user id (`user` on API) — use for Firestore `patientId`, not [id].
  final String userId;
  final String name;
  final String email;
  final int age;
  final String phone;
  final String gender;
  final String? medicalHistory;
  final String condition;
  final String status;
  final List<PatientNoteModel> notes;
  final String? password;
  /// Backend user id of the patient's assigned doctor (matches doctor JWT id).
  final String? assignedDoctorId;

  const PatientModel({
    required this.id,
    this.userId = '',
    required this.name,
    required this.email,
    required this.age,
    required this.phone,
    required this.gender,
    this.medicalHistory,
    required this.condition,
    required this.status,
    this.notes = const [],
    this.password,
    this.assignedDoctorId,
  });

  // ─── Deserialization ───────────────────────────────────────────────

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data =
        PatientResponseParser.extractPatientMap(json) ?? json;

    return PatientModel(
      id: _parseString(data['_id'] ?? data['id']),
      userId: _parseUserId(data),
      name: _parseString(data['name']),
      email: _parseString(data['email']),
      age: _parseInt(data['age']),
      phone: _parseString(data['phone']),
      gender: _parseString(data['gender']),
      medicalHistory: _parseOptionalString(data['medicalHistory']),
      condition: _parseString(data['condition']),
      status: _parseString(data['status']),
      notes: _parseNotes(data['notes'] ?? data['doctorNotes']),
      password: _parseOptionalString(data['password'] ?? data['generatedPassword']),
      assignedDoctorId: extractAssignedDoctorId(data),
    );
  }

  /// Firestore/API chat participant id (JWT `user`, not patient record `_id`).
  static String _parseUserId(Map<String, dynamic> data) {
    final user = data['user'];
    if (user is Map) {
      return _parseString(user['_id'] ?? user['id']);
    }
    final asString = _parseOptionalString(user);
    if (asString != null) return asString;
    return _parseString(data['userId']);
  }

  /// Prefer [userId] for chat; falls back to [id].
  String get chatUserId => userId.isNotEmpty ? userId : id;

  /// Reads assigned doctor id from API payloads (supports several field names).
  static String? extractAssignedDoctorId(Map<String, dynamic> data) {
    final raw = data['assignedDoctorId'] ??
        data['assignedDoctor'] ??
        data['doctorId'] ??
        data['doctor'];
    if (raw is Map) {
      final nested = (raw['_id'] ?? raw['id'])?.toString().trim();
      return nested == null || nested.isEmpty ? null : nested;
    }
    final id = raw?.toString().trim();
    return id == null || id.isEmpty ? null : id;
  }

  /// Extracts assigned doctor id from any supported API envelope.
  ///
  /// When [patientId] is set, list responses are scanned for the row whose
  /// `user` / `userId` / `id` matches the logged-in patient, then
  /// `doctor._id` (or equivalent) is returned.
  static String? extractAssignedDoctorIdFromResponse(
    dynamic body, {
    String? patientId,
  }) {
    if (body == null) return null;

    final map = PatientResponseParser.extractPatientMap(body);
    if (map != null) {
      final fromMap = extractAssignedDoctorId(map);
      if (fromMap != null) return fromMap;
    }

    for (final list in _extractCandidateLists(body)) {
      for (final item in list) {
        if (item is! Map) continue;
        final record = Map<String, dynamic>.from(item);
        if (patientId != null && !_recordMatchesPatient(record, patientId)) {
          continue;
        }
        final doctorId = _doctorIdFromPatientRecord(record);
        if (doctorId != null) return doctorId;
      }
    }

    if (body is Map<String, dynamic>) {
      return extractAssignedDoctorId(body);
    }
    return null;
  }

  static List<List<dynamic>> _extractCandidateLists(dynamic body) {
    final lists = <List<dynamic>>[];
    if (body is List) lists.add(body);
    if (body is Map) {
      final map = Map<String, dynamic>.from(body);
      for (final key in const ['data', 'patients', 'results', 'items']) {
        final value = map[key];
        if (value is List) lists.add(value);
      }
    }
    return lists;
  }

  static bool _recordMatchesPatient(
    Map<String, dynamic> record,
    String patientId,
  ) {
    final candidates = <String?>[
      record['userId']?.toString(),
      record['patientId']?.toString(),
      record['_id']?.toString(),
      record['id']?.toString(),
      _userIdFromNested(record['user']),
    ];
    return candidates.any((id) => id != null && id == patientId);
  }

  static String? _userIdFromNested(Object? user) {
    if (user is Map) {
      final id = (user['_id'] ?? user['id'])?.toString().trim();
      return id == null || id.isEmpty ? null : id;
    }
    final id = user?.toString().trim();
    return id == null || id.isEmpty ? null : id;
  }

  static String? _doctorIdFromPatientRecord(Map<String, dynamic> record) {
    final fromFields = extractAssignedDoctorId(record);
    if (fromFields != null) return fromFields;

    final doctor = record['doctor'];
    if (doctor is Map) {
      final id = (doctor['_id'] ?? doctor['id'])?.toString().trim();
      if (id != null && id.isNotEmpty) return id;
    }
    return null;
  }

  /// Returns null when the JSON does not contain usable patient fields.
  static PatientModel? tryFromJson(dynamic json) {
    if (json is! Map) return null;
    final map = PatientResponseParser.extractPatientMap(json);
    if (map == null || !PatientResponseParser.hasMinimumPatientFields(map)) {
      return null;
    }
    return PatientModel.fromJson(map);
  }

  bool get hasProfileData => id.isNotEmpty || name.isNotEmpty || email.isNotEmpty;

  static List<PatientNoteModel> _parseNotes(dynamic raw) {
    if (raw is! List) return const [];
    return raw.map(PatientNoteModel.fromJson).toList();
  }

  // ─── Serialization ─────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'age': age,
        'phone': phone,
        'gender': gender,
        if (medicalHistory != null) 'medicalHistory': medicalHistory,
        'condition': condition,
        'status': status,
        if (password != null) 'password': password,
      };

  // ─── Copy With ─────────────────────────────────────────────────────

  PatientModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? email,
    int? age,
    String? phone,
    String? gender,
    String? medicalHistory,
    String? condition,
    String? status,
    List<PatientNoteModel>? notes,
    String? password,
    String? assignedDoctorId,
  }) {
    return PatientModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      condition: condition ?? this.condition,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      password: password ?? this.password,
      assignedDoctorId: assignedDoctorId ?? this.assignedDoctorId,
    );
  }

  // ─── Helpers ───────────────────────────────────────────────────────

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static String _parseString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  static String? _parseOptionalString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  @override
  String toString() =>
      'PatientModel(id: $id, name: $name, email: $email, status: $status, password: $password)';
}

// commit update
 