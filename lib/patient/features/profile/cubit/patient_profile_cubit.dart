import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grad_project/patient/features/patient/viewmodel/patient_cubit.dart';
import 'package:grad_project/patient/features/patient/viewmodel/patient_state.dart';
import '../models/patient_profile_model.dart';
import '../view_models/patient_profile_view_model.dart';

/// Patient Profile Cubit - State Management with BLoC pattern
/// Manages patient profile state and delegates business logic to ViewModel
class PatientProfileCubit extends Cubit<PatientProfileModel> {
  final PatientProfileViewModel _viewModel = PatientProfileViewModel();
  final PatientCubit _patientCubit;
  StreamSubscription? _subscription;
  PatientProfileCubit(this._patientCubit) : super(PatientProfileModel.initial()) {
    _subscription = _patientCubit.stream.listen(_onPatientStateChanged);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }

  void _onPatientStateChanged(PatientState patientState) {
    if (patientState is PatientLoaded) {
      final profile = _viewModel.modelFromPatient(patientState.patient);
      if (state.isUpdating) {
        emit(profile.copyWith(isUpdating: false, successMessage: 'Profile updated successfully!'));
        Future.delayed(const Duration(seconds: 2), () {
          if (!isClosed) emit(state.copyWith(successMessage: null));
        });
      } else {
        emit(profile.copyWith(isLoading: false));
      }
    } else if (patientState is PatientError) {
      if (state.isUpdating) {
        emit(state.copyWith(isUpdating: false, errorMessage: patientState.message));
      } else {
        emit(state.copyWith(isLoading: false, errorMessage: patientState.message));
      }
    }
  }

  // ─── Initialization ────────────────────────────────────────────

  /// Initialize and fetch profile
  Future<void> initialize() async {
    if (_patientCubit.state is PatientLoaded) {
      final patient = (_patientCubit.state as PatientLoaded).patient;
      emit(_viewModel.modelFromPatient(patient));
    }
    await fetchProfile();
  }

  // ─── Fetch Profile ────────────────────────────────────────────

  /// Fetch profile from backend
  Future<void> fetchProfile() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    await _patientCubit.fetchMe();
  }

  // ─── Update Profile ───────────────────────────────────────────

  /// Update patient profile
  Future<void> updateProfile({
    required String name,
    required String phone,
    required int age,
    required String gender,
    required String medicalHistory,
    required String address,
  }) async {
    final validation = _viewModel.validateProfileData(
      name: name,
      phone: phone,
      age: age,
    );

    if (validation != null) {
      emit(state.copyWith(errorMessage: validation));
      return;
    }

    emit(state.copyWith(isUpdating: true, errorMessage: null));

    final updates = _viewModel.createUpdateMap(
      name: name,
      phone: phone,
      age: age,
      gender: gender,
      medicalHistory: medicalHistory,
      address: address,
    );

    if (state.id != null) {
      await _patientCubit.updatePatient(state.id!, updates);
      await _patientCubit.fetchMe();
    } else {
      emit(state.copyWith(isUpdating: false, errorMessage: 'Patient ID missing'));
    }
  }

  /// Update name, age, and medical history from the edit dialog.
  Future<bool> updateBasicInfo({
    required String name,
    required int age,
    required String medicalHistory,
  }) async {
    await updateProfile(
      name: name,
      phone: state.phone ?? '',
      age: age,
      gender: state.gender ?? 'Other',
      medicalHistory: medicalHistory,
      address: state.address ?? '',
    );
    return !hasError;
  }

  // ─── Partial Updates ──────────────────────────────────────────

  /// Update only name
  Future<void> updateName(String newName) async {
    final phone = state.phone ?? '';
    final age = state.age ?? 0;
    final gender = state.gender ?? '';
    final medicalHistory = state.medicalHistory ?? '';
    final address = state.address ?? '';

    await updateProfile(
      name: newName,
      phone: phone,
      age: age,
      gender: gender,
      medicalHistory: medicalHistory,
      address: address,
    );
  }

  /// Update only phone
  Future<void> updatePhone(String newPhone) async {
    final name = state.name ?? '';
    final phone = newPhone;
    final age = state.age ?? 0;
    final gender = state.gender ?? '';
    final medicalHistory = state.medicalHistory ?? '';
    final address = state.address ?? '';

    await updateProfile(
      name: name,
      phone: phone,
      age: age,
      gender: gender,
      medicalHistory: medicalHistory,
      address: address,
    );
  }

  /// Update only age
  Future<void> updateAge(int newAge) async {
    final name = state.name ?? '';
    final phone = state.phone ?? '';
    final age = newAge;
    final gender = state.gender ?? '';
    final medicalHistory = state.medicalHistory ?? '';
    final address = state.address ?? '';

    await updateProfile(
      name: name,
      phone: phone,
      age: age,
      gender: gender,
      medicalHistory: medicalHistory,
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
    required String phone,
    required int age,
  }) {
    return _viewModel.validateProfileData(name: name, phone: phone, age: age);
  }

  // ─── Display Helpers ──────────────────────────────────────────

  /// Get formatted display name
  String getDisplayName() => _viewModel.getDisplayName(state);

  /// Get formatted display email
  String getDisplayEmail() => _viewModel.getDisplayEmail(state);

  /// Get formatted phone
  String getFormattedPhone() => _viewModel.formatPhone(state.phone);

  /// Get formatted age
  String getFormattedAge() => _viewModel.formatAge(state.age);

  /// Get medical history display
  String getMedicalHistoryDisplay() =>
      _viewModel.getMedicalHistoryDisplay(state.medicalHistory);

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
