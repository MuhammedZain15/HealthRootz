/// Patient model — maps to POST /api/patients body & response.
class PatientModel {
  final String? id;
  final String? name;
  final String? email;
  final int? age;
  final String? phone;
  final String? gender;
  final String? medicalHistory;
  final String? condition;
  final String? status;
  final String? createdAt;
  final String? updatedAt;

  PatientModel({
    this.id,
    this.name,
    this.email,
    this.age,
    this.phone,
    this.gender,
    this.medicalHistory,
    this.condition,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    final data = json.containsKey('data') && json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    int? parseAge(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      return int.tryParse(value.toString());
    }

    return PatientModel(
      id: (data['_id'] ?? data['id'] ?? json['_id'] ?? json['id']) as String?,
      name: (data['name'] ?? json['name']) as String?,
      email: (data['email'] ?? json['email']) as String?,
      age: parseAge(data['age'] ?? json['age']),
      phone: (data['phone'] ?? json['phone']) as String?,
      gender: (data['gender'] ?? json['gender']) as String?,
      medicalHistory:
          (data['medicalHistory'] ?? json['medicalHistory']) as String?,
      condition: (data['condition'] ?? json['condition']) as String?,
      status: (data['status'] ?? json['status']) as String?,
      createdAt: (data['createdAt'] ?? json['createdAt']) as String?,
      updatedAt: (data['updatedAt'] ?? json['updatedAt']) as String?,
    );
  }

  /// Parses GET /patients list items (raw patient maps).
  factory PatientModel.fromApi(dynamic json) {
    if (json is Map<String, dynamic>) return PatientModel.fromJson(json);
    throw ArgumentError('Invalid patient JSON');
  }

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (age != null) 'age': age,
      if (phone != null) 'phone': phone,
      if (gender != null) 'gender': gender,
      if (medicalHistory != null) 'medicalHistory': medicalHistory,
      if (condition != null) 'condition': condition,
      if (status != null) 'status': status,
    };
  }
}
