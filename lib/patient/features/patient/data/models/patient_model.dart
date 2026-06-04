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
  final String name;
  final String email;
  final int age;
  final String phone;
  final String gender;
  final String? medicalHistory;
  final String condition;
  final String status;
  final List<PatientNoteModel> notes;

  const PatientModel({
    required this.id,
    required this.name,
    required this.email,
    required this.age,
    required this.phone,
    required this.gender,
    this.medicalHistory,
    required this.condition,
    required this.status,
    this.notes = const [],
  });

  // ─── Deserialization ───────────────────────────────────────────────

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data =
        PatientResponseParser.extractPatientMap(json) ?? json;

    return PatientModel(
      id: _parseString(data['_id'] ?? data['id']),
      name: _parseString(data['name']),
      email: _parseString(data['email']),
      age: _parseInt(data['age']),
      phone: _parseString(data['phone']),
      gender: _parseString(data['gender']),
      medicalHistory: _parseOptionalString(data['medicalHistory']),
      condition: _parseString(data['condition']),
      status: _parseString(data['status']),
      notes: _parseNotes(data['notes'] ?? data['doctorNotes']),
    );
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
      };

  // ─── Copy With ─────────────────────────────────────────────────────

  PatientModel copyWith({
    String? id,
    String? name,
    String? email,
    int? age,
    String? phone,
    String? gender,
    String? medicalHistory,
    String? condition,
    String? status,
    List<PatientNoteModel>? notes,
  }) {
    return PatientModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      condition: condition ?? this.condition,
      status: status ?? this.status,
      notes: notes ?? this.notes,
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
      'PatientModel(id: $id, name: $name, email: $email, status: $status)';
}
