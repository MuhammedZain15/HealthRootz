import 'package:grad_project/patient/features/patient/data/models/patient_model.dart' as new_api;
import '../model/patient_model.dart';
import '../models/doctor_patients_list_model.dart';
import '../models/doctor_patient_detail_model.dart';

/// Business logic for doctor patient list and detail mapping.
class DoctorPatientsViewModel {
  /// Maps API patient to UI [Patient].
  Patient mapToUiPatient(new_api.PatientModel model) {
    return Patient(
      id: model.id,
      name: model.name,
      age: model.age,
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

  /// Process loaded list of patients.
  DoctorPatientsListModel processPatientsList(
    DoctorPatientsListModel current,
    List<new_api.PatientModel> apiPatients,
  ) {
    final patients = apiPatients.map(mapToUiPatient).toList();
    return current.copyWith(
      patients: patients,
      isLoading: false,
      clearError: true,
    );
  }

  /// Process loaded single patient details.
  DoctorPatientDetailModel processPatientDetail(
    DoctorPatientDetailModel current,
    new_api.PatientModel apiPatient,
  ) {
    return current.copyWith(
      patient: mapToUiPatient(apiPatient),
      isLoading: false,
      clearError: true,
    );
  }
}
