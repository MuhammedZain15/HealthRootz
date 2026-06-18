/// Patient Profile Model - Pure data class
/// Represents the patient's profile state
class PatientProfileModel {
  final String? id;
  final String? name;
  final String? email;
  final String? phone;
  final int? age;
  final String? gender;
  final String? medicalHistory;
  final String? address;
  final bool isLoading;
  final bool isUpdating;
  final String? errorMessage;
  final String? successMessage;

  const PatientProfileModel({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.age,
    this.gender,
    this.medicalHistory,
    this.address,
    this.isLoading = false,
    this.isUpdating = false,
    this.errorMessage,
    this.successMessage,
  });

  /// Create initial/empty state
  factory PatientProfileModel.initial() {
    return const PatientProfileModel(isLoading: false, isUpdating: false);
  }

  /// Create loading state
  factory PatientProfileModel.loading() {
    return const PatientProfileModel(isLoading: true, isUpdating: false);
  }

  /// Create updating state
  factory PatientProfileModel.updating() {
    return const PatientProfileModel(isLoading: false, isUpdating: true);
  }

  /// Copy with method for immutability
  PatientProfileModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    int? age,
    String? gender,
    String? medicalHistory,
    String? address,
    bool? isLoading,
    bool? isUpdating,
    String? errorMessage,
    String? successMessage,
  }) {
    return PatientProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      address: address ?? this.address,
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
    );
  }

  /// Check if profile is complete
  bool get isProfileComplete {
    return name != null &&
        name!.isNotEmpty &&
        email != null &&
        email!.isNotEmpty &&
        phone != null &&
        phone!.isNotEmpty;
  }

  /// Get completion percentage
  int get completionPercentage {
    int completed = 0;
    int total =
        8; // name, email, phone, age, gender, address, medicalHistory, id

    if (id != null && id!.isNotEmpty) completed++;
    if (name != null && name!.isNotEmpty) completed++;
    if (email != null && email!.isNotEmpty) completed++;
    if (phone != null && phone!.isNotEmpty) completed++;
    if (age != null && age! > 0) completed++;
    if (gender != null && gender!.isNotEmpty) completed++;
    if (address != null && address!.isNotEmpty) completed++;
    if (medicalHistory != null && medicalHistory!.isNotEmpty) completed++;

    return ((completed / total) * 100).toInt();
  }

  @override
  String toString() {
    return 'PatientProfileModel('
        'id: $id, '
        'name: $name, '
        'email: $email, '
        'isLoading: $isLoading, '
        'isUpdating: $isUpdating'
        ')';
  }
}

// commit update
 