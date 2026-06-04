import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/repositories/patient_repository.dart';
import 'patient_state.dart';

/// Cubit that drives all patient-related data operations.
///
/// Typical usage:
/// ```dart
/// // Provide via BlocProvider
/// BlocProvider(create: (_) => PatientCubit(PatientRepositoryImpl()))
///
/// // Trigger an action
/// context.read<PatientCubit>().fetchMe();
///
/// // React to state
/// BlocBuilder<PatientCubit, PatientState>(builder: (context, state) { ... })
/// ```
class PatientCubit extends Cubit<PatientState> {
  final PatientRepository _repository;

  PatientCubit(this._repository) : super(PatientInitial());

  // ─── GET /patients/me ──────────────────────────────────────────────

  /// Fetches the currently authenticated patient's own profile.
  Future<void> fetchMe() async {
    emit(PatientLoading());
    final result = await _repository.getMe();
    result.fold(
      (failure) => emit(PatientError(failure.message)),
      (patient) => emit(PatientLoaded(patient)),
    );
  }

  // ─── GET /patients/ ────────────────────────────────────────────────

  /// Fetches all patients associated with the logged-in doctor.
  Future<void> fetchPatients() async {
    emit(PatientLoading());
    final result = await _repository.getPatients();
    result.fold(
      (failure) => emit(PatientError(failure.message)),
      (patients) => emit(PatientsListLoaded(patients)),
    );
  }

  // ─── GET /patients/:id ─────────────────────────────────────────────

  /// Fetches a single patient by their [id].
  Future<void> fetchPatientById(String id) async {
    emit(PatientLoading());
    final result = await _repository.getPatientById(id);
    result.fold(
      (failure) => emit(PatientError(failure.message)),
      (patient) => emit(PatientLoaded(patient)),
    );
  }

  // ─── GET /patients/:id/details ─────────────────────────────────────

  /// Fetches the extended details view for a patient by their [id].
  Future<void> fetchPatientDetails(String id) async {
    emit(PatientLoading());
    final result = await _repository.getPatientDetails(id);
    result.fold(
      (failure) => emit(PatientError(failure.message)),
      (patient) => emit(PatientLoaded(patient)),
    );
  }

  // ─── POST /patients/ ───────────────────────────────────────────────

  /// Creates a new patient record with the provided [body].
  ///
  /// On success, persists the returned `_id` to [SharedPreferences]
  /// under the key `'patientId'` before emitting [PatientLoaded].
  Future<void> createPatient(Map<String, dynamic> body) async {
    emit(PatientLoading());
    final result = await _repository.createPatient(body);
    result.fold(
      (failure) => emit(PatientError(failure.message)),
      (patient) async {
        // Persist the new patient's ID for later use.
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('patientId', patient.id);
        emit(PatientLoaded(patient));
      },
    );
  }

  // ─── PUT /patients/:id ─────────────────────────────────────────────

  /// Updates the patient identified by [id] with fields from [body].
  Future<void> updatePatient(String id, Map<String, dynamic> body) async {
    emit(PatientLoading());
    final result = await _repository.updatePatient(id, body);
    result.fold(
      (failure) => emit(PatientError(failure.message)),
      (patient) => emit(PatientLoaded(patient)),
    );
  }

  // ─── POST /patients/:id/notes ──────────────────────────────────────

  /// Appends a doctor note with [text] to the patient identified by [id].
  Future<void> addDoctorNote(String id, String text) async {
    emit(PatientLoading());
    final result = await _repository.addDoctorNote(id, text);
    result.fold(
      (failure) => emit(PatientError(failure.message)),
      (_) => emit(PatientActionSuccess('Note added successfully')),
    );
  }

  // ─── DELETE /patients/:id ──────────────────────────────────────────

  /// Deletes the patient identified by [id].
  Future<void> deletePatient(String id) async {
    emit(PatientLoading());
    final result = await _repository.deletePatient(id);
    result.fold(
      (failure) => emit(PatientError(failure.message)),
      (_) => emit(PatientActionSuccess('Patient deleted successfully')),
    );
  }

  // ─── DELETE /patients?confirm=true ─────────────────────────────────

  /// Deletes all patient records (requires server-side `confirm=true` flag).
  Future<void> deleteAllPatients() async {
    emit(PatientLoading());
    final result = await _repository.deleteAllPatients();
    result.fold(
      (failure) => emit(PatientError(failure.message)),
      (_) => emit(PatientActionSuccess('All patients deleted successfully')),
    );
  }
}
