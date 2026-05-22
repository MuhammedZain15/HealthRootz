import 'package:grad_project/core/models/patient_model.dart' as api;
import 'package:grad_project/core/services/patient_service.dart';
import '../model/patient_model.dart';
import '../models/doctor_patients_list_model.dart';
import '../models/doctor_patient_detail_model.dart';

/// Business logic for doctor patient list and detail API calls.
class DoctorPatientsViewModel {
  final PatientService _patientService = PatientService();

  /// Maps API patient to UI [Patient].
  Patient mapToUiPatient(api.PatientModel model) {
    return Patient(
      id: model.id ?? '',
      name: model.name ?? 'Unknown',
      age: model.age ?? 0,
      status: formatStatus(model.status),
      heartRate: 0,
      emgReading: 0,
      email: model.email,
      phone: model.phone,
      gender: model.gender,
      condition: model.condition,
      medicalHistory: model.medicalHistory,
      address: model.phone,
    );
  }

  /// Human-readable status for chips and filters.
  String formatStatus(String? status) {
    if (status == null || status.isEmpty) return 'Normal';
    final lower = status.toLowerCase();
    if (lower == 'critical') return 'Critical';
    if (lower == 'warning' || lower == 'monitoring') return 'Warning';
    if (lower == 'stable' || lower == 'normal') return 'Normal';
    return status[0].toUpperCase() + status.substring(1);
  }

  /// GET /api/patients — all patients for the logged-in doctor.
  Future<(DoctorPatientsListModel, String?)> fetchPatients(
    DoctorPatientsListModel current,
  ) async {
    try {
      final result = await _patientService.getAllPatients();

      if (result.success && result.data != null) {
        final patients = result.data!.map(mapToUiPatient).toList();
        return (
          current.copyWith(
            patients: patients,
            isLoading: false,
            clearError: true,
          ),
          null,
        );
      }

      return (
        current.copyWith(
          isLoading: false,
          errorMessage: result.message ?? 'Failed to load patients',
        ),
        result.message,
      );
    } catch (e) {
      return (
        current.copyWith(
          isLoading: false,
          errorMessage: 'Error: ${e.toString()}',
        ),
        e.toString(),
      );
    }
  }

  /// GET /api/patients/:id — full patient record.
  Future<(DoctorPatientDetailModel, String?)> fetchPatientById(
    DoctorPatientDetailModel current,
  ) async {
    try {
      final result = await _patientService.getPatientById(current.patientId);

      if (result.success && result.data != null) {
        return (
          current.copyWith(
            patient: mapToUiPatient(result.data!),
            isLoading: false,
            clearError: true,
          ),
          null,
        );
      }

      return (
        current.copyWith(
          isLoading: false,
          errorMessage: result.message ?? 'Failed to load patient',
        ),
        result.message,
      );
    } catch (e) {
      return (
        current.copyWith(
          isLoading: false,
          errorMessage: 'Error: ${e.toString()}',
        ),
        e.toString(),
      );
    }
  }
}
