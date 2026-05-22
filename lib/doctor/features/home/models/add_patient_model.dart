/// State for the add-patient form (POST /api/patients).
class AddPatientModel {
  final String name;
  final String email;
  final String age;
  final String phone;
  final String gender;
  final String condition;
  final String status;
  final String medicalHistory;
  final bool isLoading;
  final String? errorMessage;

  const AddPatientModel({
    this.name = '',
    this.email = '',
    this.age = '',
    this.phone = '',
    this.gender = 'Male',
    this.condition = '',
    this.status = 'monitoring',
    this.medicalHistory = '',
    this.isLoading = false,
    this.errorMessage,
  });

  factory AddPatientModel.initial() => const AddPatientModel();

  AddPatientModel copyWith({
    String? name,
    String? email,
    String? age,
    String? phone,
    String? gender,
    String? condition,
    String? status,
    String? medicalHistory,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AddPatientModel(
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      condition: condition ?? this.condition,
      status: status ?? this.status,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  static const List<String> genderOptions = ['Male', 'Female', 'Other'];
  static const List<String> statusOptions = [
    'monitoring',
    'stable',
    'normal',
    'critical',
  ];
}
