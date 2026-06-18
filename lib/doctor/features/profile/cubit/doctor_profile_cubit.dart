import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grad_project/core/cubit/auth_cubit.dart';
import '../models/doctor_profile_model.dart';
import '../view_models/doctor_profile_view_model.dart';

/// Doctor Profile Cubit - State Management with BLoC pattern
/// Manages doctor profile state and delegates business logic to ViewModel
class DoctorProfileCubit extends Cubit<DoctorProfileModel> {
  final DoctorProfileViewModel _viewModel = DoctorProfileViewModel();
  final AuthCubit _authCubit;

  DoctorProfileCubit(this._authCubit) : super(DoctorProfileModel.initial());

  // ─── Initialization ────────────────────────────────────────────

  /// Initialize and fetch profile
  Future<void> initialize() async {
    final user = _authCubit.user;
    final profile = _viewModel.modelFromUser(user);
    emit(profile);

    // Then fetch fresh data
    await fetchProfile();
  }

  // ─── Fetch Profile ────────────────────────────────────────────

  /// Fetch profile from backend
  Future<void> fetchProfile() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    final (profile, error) = await _viewModel.fetchProfile();

    if (error != null) {
      emit(profile.copyWith(isLoading: false, errorMessage: error));
    } else {
      emit(profile.copyWith(isLoading: false));
    }
  }

  // ─── Update Profile ───────────────────────────────────────────

  /// Update doctor profile
  Future<void> updateProfile({
    required String name,
    required String phone,
    required String specialty,
    required String licenseNumber,
    required String address,
  }) async {
    emit(state.copyWith(isUpdating: true, errorMessage: null));

    final (updatedProfile, error) = await _viewModel.updateProfile(
      name: name,
      phone: phone,
      specialty: specialty,
      licenseNumber: licenseNumber,
      address: address,
    );

    if (error != null) {
      emit(state.copyWith(isUpdating: false, errorMessage: error));
    } else {
      emit(
        updatedProfile.copyWith(
          isUpdating: false,
          successMessage: 'Profile updated successfully!',
        ),
      );

      // Clear success message after 2 seconds
      await Future.delayed(const Duration(seconds: 2));
      if (isClosed) return;
      emit(updatedProfile.copyWith(successMessage: null));
    }
  }

  // ─── Partial Updates ──────────────────────────────────────────

  /// Update only name
  Future<void> updateName(String newName) async {
    final phone = state.phone ?? '';
    final specialty = state.specialty ?? '';
    final licenseNumber = state.licenseNumber ?? '';
    final address = state.address ?? '';

    await updateProfile(
      name: newName,
      phone: phone,
      specialty: specialty,
      licenseNumber: licenseNumber,
      address: address,
    );
  }

  /// Update only specialty
  Future<void> updateSpecialty(String newSpecialty) async {
    final name = state.name ?? '';
    final phone = state.phone ?? '';
    final licenseNumber = state.licenseNumber ?? '';
    final address = state.address ?? '';

    await updateProfile(
      name: name,
      phone: phone,
      specialty: newSpecialty,
      licenseNumber: licenseNumber,
      address: address,
    );
  }

  /// Update only license number
  Future<void> updateLicenseNumber(String newLicense) async {
    final name = state.name ?? '';
    final phone = state.phone ?? '';
    final specialty = state.specialty ?? '';
    final address = state.address ?? '';

    await updateProfile(
      name: name,
      phone: phone,
      specialty: specialty,
      licenseNumber: newLicense,
      address: address,
    );
  }

  // ─── Validation ───────────────────────────────────────────────

  /// Validate profile completeness
  bool validateProfile() {
    return !_viewModel.isProfileIncomplete(state);
  }

  /// Get validation error if any
  String? getValidationError({
    required String name,
    required String specialty,
    required String licenseNumber,
  }) {
    return _viewModel.validateProfileData(
      name: name,
      specialty: specialty,
      licenseNumber: licenseNumber,
    );
  }

  // ─── Display Helpers ──────────────────────────────────────────

  /// Get professional title
  String getProfessionalTitle() => _viewModel.getProfessionalTitle(state);

  /// Get formatted display name
  String getDisplayName() => _viewModel.getDisplayName(state);

  /// Get formatted display email
  String getDisplayEmail() => _viewModel.getDisplayEmail(state);

  /// Get formatted phone
  String getFormattedPhone() => _viewModel.formatPhone(state.phone);

  /// Get specialty display
  String getSpecialtyDisplay() =>
      _viewModel.getSpecialtyDisplay(state.specialty);

  /// Get license display
  String getLicenseDisplay() =>
      _viewModel.getLicenseDisplay(state.licenseNumber);

  /// Get address display
  String getAddressDisplay() => _viewModel.getAddressDisplay(state.address);

  /// Get profile completion percentage
  int getCompletionPercentage() => state.completionPercentage;

  // ─── Error Handling ───────────────────────────────────────────

  /// Retry last operation
  Future<void> retry() async {
    if (state.isLoading) {
      await fetchProfile();
    } else if (state.isUpdating) {
      // Retry update is handled separately
      await fetchProfile();
    }
  }

  /// Clear error message
  void clearError() {
    emit(_viewModel.clearError(state));
  }

  /// Clear success message
  void clearSuccess() {
    emit(state.copyWith(successMessage: null));
  }

  // ─── State Helpers ────────────────────────────────────────────

  /// Check if loading
  bool get isLoading => state.isLoading;

  /// Check if updating
  bool get isUpdating => state.isUpdating;

  /// Check if has error
  bool get hasError => state.errorMessage != null;

  /// Check if has success
  bool get hasSuccess => state.successMessage != null;

  /// Get current error message
  String? get errorMessage => state.errorMessage;

  /// Get current success message
  String? get successMessage => state.successMessage;

  /// Check if profile is complete
  bool get isProfileComplete => state.isProfileComplete;
}

// commit update
 