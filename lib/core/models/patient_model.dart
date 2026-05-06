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
    return PatientModel(
      id: json['_id'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      age: json['age'] as int?,
      phone: json['phone'] as String?,
      gender: json['gender'] as String?,
      medicalHistory: json['medicalHistory'] as String?,
      condition: json['condition'] as String?,
      status: json['status'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
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
