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
/// Supports both flat JSON and `{ "data": {...} }` envelope responses.
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
    // Unwrap `{ "data": {...} }` envelope if present.
    final Map<String, dynamic> data =
        json['data'] is Map<String, dynamic>
            ? json['data'] as Map<String, dynamic>
            : json;

    return PatientModel(
      id: (data['_id'] ?? data['id'] ?? '') as String,
      name: (data['name'] ?? '') as String,
      email: (data['email'] ?? '') as String,
      age: _parseInt(data['age']),
      phone: (data['phone'] ?? '') as String,
      gender: (data['gender'] ?? '') as String,
      medicalHistory: data['medicalHistory'] as String?,
      condition: (data['condition'] ?? '') as String,
      status: (data['status'] ?? '') as String,
      notes: _parseNotes(data['notes'] ?? data['doctorNotes']),
    );
  }

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

  @override
  String toString() =>
      'PatientModel(id: $id, name: $name, email: $email, status: $status)';
}
