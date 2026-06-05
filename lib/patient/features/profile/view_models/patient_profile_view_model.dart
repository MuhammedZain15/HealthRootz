import 'package:grad_project/patient/features/patient/data/models/patient_model.dart';
import 'package:grad_project/patient/features/profile/models/patient_profile_model.dart';

/// Patient Profile ViewModel - Business Logic Layer
/// Handles all business logic for patient profile
/// Transforms PatientModel data into PatientProfileModel state
class PatientProfileViewModel {
  /// Convert PatientModel to PatientProfileModel
  PatientProfileModel modelFromPatient(PatientModel? patient) {
    if (patient == null) {
      return PatientProfileModel.initial();
    }

    return PatientProfileModel(
      id: patient.id,
      name: patient.name,
      email: patient.email,
      phone: patient.phone,
      age: patient.age,
      gender: patient.gender,
      medicalHistory: patient.medicalHistory,
      address: '', // Address not available in new PatientModel
    );
  }

  Map<String, dynamic> createUpdateMap({
    required String name,
    required String phone,
    required int age,
    required String gender,
    required String medicalHistory,
    required String address,
  }) {
    return {
      'name': name,
      'phone': phone,
      'age': age,
      'gender': gender,
      'medicalHistory': medicalHistory,
    };
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
