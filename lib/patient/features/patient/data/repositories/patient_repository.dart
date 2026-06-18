import 'package:dartz/dartz.dart';

import '../models/patient_model.dart';

/// Represents a server-side error returned by any patient API call.
class ServerFailure {
  final String message;
  const ServerFailure(this.message);
}

/// Abstract contract for all patient-related data operations.
abstract class PatientRepository {
  /// GET /patients/me — returns the currently authenticated patient's profile.
  Future<Either<ServerFailure, PatientModel>> getMe();

  /// GET /patients/ — returns all patients for the logged-in doctor.
  Future<Either<ServerFailure, List<PatientModel>>> getPatients();

  /// GET /patients/:id — returns a single patient by ID.
  Future<Either<ServerFailure, PatientModel>> getPatientById(String id);

  /// GET /patients/:id/details — returns extended patient details.
  Future<Either<ServerFailure, PatientModel>> getPatientDetails(String id);

  /// POST /patients/ — creates a new patient record.
  Future<Either<ServerFailure, PatientModel>> createPatient(
      Map<String, dynamic> body);

  /// PUT /patients/:id — updates an existing patient record.
  Future<Either<ServerFailure, PatientModel>> updatePatient(
      String id, Map<String, dynamic> body);

  /// POST /patients/:id/notes — appends a doctor note to the patient.
  Future<Either<ServerFailure, Unit>> addDoctorNote(String id, String text);

  /// DELETE /patients/:id — deletes a single patient.
  Future<Either<ServerFailure, Unit>> deletePatient(String id);

  /// DELETE /patients?confirm=true — deletes all patients.
  Future<Either<ServerFailure, Unit>> deleteAllPatients();
}

// commit update
 