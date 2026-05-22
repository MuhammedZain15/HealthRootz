/// Doctor Profile Model - Pure data class
/// Represents the doctor's profile state
class DoctorProfileModel {
  final String? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? specialty;
  final String? licenseNumber;
  final String? address;
  final bool isLoading;
  final bool isUpdating;
  final String? errorMessage;
  final String? successMessage;

  const DoctorProfileModel({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.specialty,
    this.licenseNumber,
    this.address,
    this.isLoading = false,
    this.isUpdating = false,
    this.errorMessage,
    this.successMessage,
  });

  /// Create initial/empty state
  factory DoctorProfileModel.initial() {
    return const DoctorProfileModel(isLoading: false, isUpdating: false);
  }

  /// Create loading state
  factory DoctorProfileModel.loading() {
    return const DoctorProfileModel(isLoading: true, isUpdating: false);
  }

  /// Create updating state
  factory DoctorProfileModel.updating() {
    return const DoctorProfileModel(isLoading: false, isUpdating: true);
  }

  /// Copy with method for immutability
  DoctorProfileModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? specialty,
    String? licenseNumber,
    String? address,
    bool? isLoading,
    bool? isUpdating,
    String? errorMessage,
    String? successMessage,
  }) {
    return DoctorProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      specialty: specialty ?? this.specialty,
      licenseNumber: licenseNumber ?? this.licenseNumber,
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
        specialty != null &&
        specialty!.isNotEmpty &&
        licenseNumber != null &&
        licenseNumber!.isNotEmpty;
  }

  /// Get completion percentage
  int get completionPercentage {
    int completed = 0;
    int total = 7; // id, name, email, specialty, licenseNumber, phone, address

    if (id != null && id!.isNotEmpty) completed++;
    if (name != null && name!.isNotEmpty) completed++;
    if (email != null && email!.isNotEmpty) completed++;
    if (specialty != null && specialty!.isNotEmpty) completed++;
    if (licenseNumber != null && licenseNumber!.isNotEmpty) completed++;
    if (phone != null && phone!.isNotEmpty) completed++;
    if (address != null && address!.isNotEmpty) completed++;

    return ((completed / total) * 100).toInt();
  }

  /// Get professional title
  String get professionalTitle => specialty != null && specialty!.isNotEmpty
      ? 'Dr. $name • $specialty'
      : 'Dr. $name';

  @override
  String toString() {
    return 'DoctorProfileModel('
        'id: $id, '
        'name: $name, '
        'email: $email, '
        'specialty: $specialty, '
        'isLoading: $isLoading, '
        'isUpdating: $isUpdating'
        ')';
  }
}
