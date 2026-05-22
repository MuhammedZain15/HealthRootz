import 'package:grad_project/core/models/user_model.dart';
import 'package:grad_project/core/services/auth_service.dart';
import 'package:grad_project/patient/features/profile/models/patient_profile_model.dart';


/// Patient Profile ViewModel - Business Logic Layer
/// Handles all business logic for patient profile
/// Transforms UserModel data into PatientProfileModel state
class PatientProfileViewModel {
  final AuthService _authService = AuthService();

  /// Convert UserModel to PatientProfileModel
  PatientProfileModel modelFromUser(UserModel? user) {
    if (user == null) {
      return PatientProfileModel.initial();
    }

    return PatientProfileModel(
      id: user.id,
      name: user.name,
      email: user.email,
      phone: user.phone,
      age: user.age,
      gender: user.gender,
      medicalHistory: user.medicalHistory,
      address: user.address,
    );
  }

  /// Fetch profile from backend
  Future<(PatientProfileModel, String?)> fetchProfile() async {
    try {
      final result = await _authService.getProfile();

      if (result.success && result.data != null) {
        final profile = modelFromUser(result.data);
        return (profile, null);
      } else {
        return (
          PatientProfileModel.initial(),
          result.message ?? 'Failed to fetch profile',
        );
      }
    } catch (e) {
      return (PatientProfileModel.initial(), 'Error: ${e.toString()}');
    }
  }

  /// Update profile on backend
  Future<(PatientProfileModel, String?)> updateProfile({
    required String name,
    required String phone,
    required int age,
    required String gender,
    required String medicalHistory,
    required String address,
  }) async {
    try {
      // Validate inputs
      final validation = validateProfileData(
        name: name,
        phone: phone,
        age: age,
      );

      if (validation != null) {
        return (PatientProfileModel.initial(), validation);
      }

      final updates = {
        'name': name,
        'phone': phone,
        'age': age,
        'gender': gender,
        'medicalHistory': medicalHistory,
        'address': address,
      };

      final result = await _authService.updateProfile(updates);

      if (result.success && result.data != null) {
        final profile = modelFromUser(result.data);
        return (profile, null);
      } else {
        return (
          PatientProfileModel.initial(),
          result.message ?? 'Failed to update profile',
        );
      }
    } catch (e) {
      return (PatientProfileModel.initial(), 'Error: ${e.toString()}');
    }
  }

  /// Validate profile data
  String? validateProfileData({
    required String name,
    required String phone,
    required int age,
  }) {
    if (name.isEmpty) {
      return 'Name cannot be empty';
    }

    if (name.length < 2) {
      return 'Name must be at least 2 characters';
    }

    if (phone.isEmpty) {
      return 'Phone cannot be empty';
    }

    if (phone.length < 10) {
      return 'Phone number must be at least 10 digits';
    }

    if (age <= 0 || age > 150) {
      return 'Age must be between 1 and 150';
    }

    return null;
  }

  /// Check if profile needs completion
  bool isProfileIncomplete(PatientProfileModel profile) {
    return profile.name == null ||
        profile.email == null ||
        profile.phone == null ||
        profile.age == null;
  }

  /// Get profile display name (with fallback)
  String getDisplayName(PatientProfileModel profile) {
    return profile.name?.isNotEmpty == true ? profile.name! : 'Patient Profile';
  }

  /// Get profile display email (with fallback)
  String getDisplayEmail(PatientProfileModel profile) {
    return profile.email?.isNotEmpty == true
        ? profile.email!
        : 'No email provided';
  }

  /// Format phone for display
  String formatPhone(String? phone) {
    if (phone == null || phone.isEmpty) return 'No phone provided';
    // Simple formatting - add your own logic
    return phone;
  }

  /// Format age for display
  String formatAge(int? age) {
    if (age == null || age <= 0) return 'Not provided';
    return '$age years old';
  }

  /// Get medical history display
  String getMedicalHistoryDisplay(String? medicalHistory) {
    if (medicalHistory == null || medicalHistory.isEmpty) {
      return 'No medical history provided';
    }
    return medicalHistory;
  }

  /// Clear error message
  PatientProfileModel clearError(PatientProfileModel profile) {
    return profile.copyWith(errorMessage: null, successMessage: null);
  }

  /// Show success message
  PatientProfileModel showSuccess(PatientProfileModel profile, String message) {
    return profile.copyWith(successMessage: message, errorMessage: null);
  }

  /// Show error message
  PatientProfileModel showError(PatientProfileModel profile, String message) {
    return profile.copyWith(errorMessage: message, successMessage: null);
  }
}
