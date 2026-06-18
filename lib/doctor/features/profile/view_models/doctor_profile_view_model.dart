import 'package:grad_project/core/models/user_model.dart';
import 'package:grad_project/core/services/auth_service.dart';
import 'package:grad_project/doctor/features/profile/models/doctor_profile_model.dart';


/// Doctor Profile ViewModel - Business Logic Layer
/// Handles all business logic for doctor profile
/// Transforms UserModel data into DoctorProfileModel state
class DoctorProfileViewModel {
  final AuthService _authService = AuthService();

  /// Convert UserModel to DoctorProfileModel
  DoctorProfileModel modelFromUser(UserModel? user) {
    if (user == null) {
      return DoctorProfileModel.initial();
    }

    return DoctorProfileModel(
      id: user.id,
      name: user.name,
      email: user.email,
      phone: user.phone,
      specialty: user.specialty,
      licenseNumber: user.licenseNumber,
      address: user.address,
    );
  }

  /// Fetch profile from backend
  Future<(DoctorProfileModel, String?)> fetchProfile() async {
    try {
      final result = await _authService.getProfile();

      if (result.success && result.data != null) {
        final profile = modelFromUser(result.data);
        return (profile, null);
      } else {
        return (
          DoctorProfileModel.initial(),
          result.message ?? 'Failed to fetch profile',
        );
      }
    } catch (e) {
      return (DoctorProfileModel.initial(), 'Error: ${e.toString()}');
    }
  }

  /// Update profile on backend
  Future<(DoctorProfileModel, String?)> updateProfile({
    required String name,
    required String phone,
    required String specialty,
    required String licenseNumber,
    required String address,
  }) async {
    try {
      // Validate inputs
      final validation = validateProfileData(
        name: name,
        specialty: specialty,
        licenseNumber: licenseNumber,
      );

      if (validation != null) {
        return (DoctorProfileModel.initial(), validation);
      }

      final updates = {
        'name': name,
        'phone': phone,
        'specialty': specialty,
        'licenseNumber': licenseNumber,
        'address': address,
      };

      final result = await _authService.updateProfile(updates);

      if (result.success && result.data != null) {
        final profile = modelFromUser(result.data);
        return (profile, null);
      } else {
        return (
          DoctorProfileModel.initial(),
          result.message ?? 'Failed to update profile',
        );
      }
    } catch (e) {
      return (DoctorProfileModel.initial(), 'Error: ${e.toString()}');
    }
  }

  /// Validate profile data
  String? validateProfileData({
    required String name,
    required String specialty,
    required String licenseNumber,
  }) {
    if (name.isEmpty) {
      return 'Name cannot be empty';
    }

    if (name.length < 2) {
      return 'Name must be at least 2 characters';
    }

    if (specialty.isEmpty) {
      return 'Specialty cannot be empty';
    }

    if (licenseNumber.isEmpty) {
      return 'License number cannot be empty';
    }

    if (licenseNumber.length < 5) {
      return 'License number must be valid';
    }

    return null;
  }

  /// Check if profile needs completion
  bool isProfileIncomplete(DoctorProfileModel profile) {
    return profile.name == null ||
        profile.email == null ||
        profile.specialty == null ||
        profile.licenseNumber == null;
  }

  /// Get profile display name (with fallback)
  String getDisplayName(DoctorProfileModel profile) {
    return profile.name?.isNotEmpty == true ? profile.name! : 'Doctor Profile';
  }

  /// Get professional title
  String getProfessionalTitle(DoctorProfileModel profile) {
    if (profile.name == null || profile.specialty == null) {
      return 'Doctor';
    }
    return 'Dr. ${profile.name} • ${profile.specialty}';
  }

  /// Get profile display email (with fallback)
  String getDisplayEmail(DoctorProfileModel profile) {
    return profile.email?.isNotEmpty == true
        ? profile.email!
        : 'No email provided';
  }

  /// Format phone for display
  String formatPhone(String? phone) {
    if (phone == null || phone.isEmpty) return 'No phone provided';
    return phone;
  }

  /// Get specialty display
  String getSpecialtyDisplay(String? specialty) {
    if (specialty == null || specialty.isEmpty) {
      return 'Not specified';
    }
    return specialty;
  }

  /// Get license display
  String getLicenseDisplay(String? license) {
    if (license == null || license.isEmpty) {
      return 'Not provided';
    }
    return license;
  }

  /// Get address display
  String getAddressDisplay(String? address) {
    if (address == null || address.isEmpty) {
      return 'Not specified';
    }
    return address;
  }

  /// Clear error message
  DoctorProfileModel clearError(DoctorProfileModel profile) {
    return profile.copyWith(errorMessage: null, successMessage: null);
  }

  /// Show success message
  DoctorProfileModel showSuccess(DoctorProfileModel profile, String message) {
    return profile.copyWith(successMessage: message, errorMessage: null);
  }

  /// Show error message
  DoctorProfileModel showError(DoctorProfileModel profile, String message) {
    return profile.copyWith(errorMessage: message, successMessage: null);
  }
}

// commit update
 