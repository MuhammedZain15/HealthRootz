import 'package:grad_project/core/models/vital_model.dart';
import '../model/patient_model.dart';

/// State for a single patient details screen.
class DoctorPatientDetailModel {
  final String patientId;
  final Patient? patient;
  final bool isLoading;
  final String? errorMessage;

  /// Patient's vitals (newest first) from `GET /vitals?patientId=`.
  final List<VitalModel> vitals;
  final bool vitalsLoading;

  const DoctorPatientDetailModel({
    required this.patientId,
    this.patient,
    this.isLoading = false,
    this.errorMessage,
    this.vitals = const [],
    this.vitalsLoading = false,
  });

  /// Most recent reading, or null when the patient has no vitals yet.
  VitalModel? get latestVital => vitals.isNotEmpty ? vitals.first : null;

  factory DoctorPatientDetailModel.initial(String patientId, {Patient? preview}) {
    return DoctorPatientDetailModel(
      patientId: patientId,
      patient: preview,
      isLoading: preview == null,
    );
  }

  DoctorPatientDetailModel copyWith({
    Patient? patient,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    List<VitalModel>? vitals,
    bool? vitalsLoading,
  }) {
    return DoctorPatientDetailModel(
      patientId: patientId,
      patient: patient ?? this.patient,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      vitals: vitals ?? this.vitals,
      vitalsLoading: vitalsLoading ?? this.vitalsLoading,
    );
  }
}
