/// User model — used for both patient and doctor roles.
class UserModel {
  final String? id;
  final String? name;
  final String? email;
  final String? role;
  final String? token;
  final String? phone;
  final String? address;
  final String? specialty;
  final String? licenseNumber;
  final int? age;
  final String? gender;
  final String? medicalHistory;

  UserModel({
    this.id,
    this.name,
    this.email,
    this.role,
    this.token,
    this.phone,
    this.address,
    this.specialty,
    this.licenseNumber,
    this.age,
    this.gender,
    this.medicalHistory,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final data = json.containsKey('data') && json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    return UserModel(
      id: (data['_id'] ?? data['id'] ?? json['_id'] ?? json['id']) as String?,
      name: (data['name'] ?? json['name']) as String?,
      email: (data['email'] ?? json['email']) as String?,
      role: (data['role'] ?? json['role']) as String?,
      token: (data['token'] ?? json['token']) as String?,
      phone: (data['phone'] ?? json['phone']) as String?,
      address: (data['address'] ?? json['address']) as String?,
      specialty: (data['specialty'] ?? json['specialty']) as String?,
      licenseNumber: (data['licenseNumber'] ?? json['licenseNumber']) as String?,
      age: data['age'] is int
          ? data['age'] as int
          : (data['age'] != null ? int.tryParse(data['age'].toString()) : null) ??
              (json['age'] is int
                  ? json['age'] as int
                  : (json['age'] != null ? int.tryParse(json['age'].toString()) : null)),
      gender: (data['gender'] ?? json['gender']) as String?,
      medicalHistory: (data['medicalHistory'] ?? json['medicalHistory']) as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (role != null) 'role': role,
      if (token != null) 'token': token,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (specialty != null) 'specialty': specialty,
      if (licenseNumber != null) 'licenseNumber': licenseNumber,
      if (age != null) 'age': age,
      if (gender != null) 'gender': gender,
      if (medicalHistory != null) 'medicalHistory': medicalHistory,
    };
  }
}
