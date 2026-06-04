import 'package:grad_project/patient/features/patient/data/models/patient_model.dart';

/// Base class for all patient Cubit states.
abstract class PatientState {}

/// Initial state — no operation has been performed yet.
class PatientInitial extends PatientState {}

/// Emitted while an async operation is in progress.
class PatientLoading extends PatientState {}

/// Emitted when a single patient is successfully fetched or modified.
class PatientLoaded extends PatientState {
  final PatientModel patient;
  PatientLoaded(this.patient);
}

/// Emitted when the full patient list is successfully fetched.
class PatientsListLoaded extends PatientState {
  final List<PatientModel> patients;
  PatientsListLoaded(this.patients);
}

/// Emitted when any patient API call fails.
class PatientError extends PatientState {
  final String message;
  PatientError(this.message);
}

/// Emitted after a destructive or write-only action succeeds
/// (delete, deleteAll, addDoctorNote).
class PatientActionSuccess extends PatientState {
  final String message;
  PatientActionSuccess(this.message);
}
