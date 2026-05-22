import '../model/patient_model.dart';

/// State for a single patient details screen.
class DoctorPatientDetailModel {
  final String patientId;
  final Patient? patient;
  final bool isLoading;
  final String? errorMessage;

  const DoctorPatientDetailModel({
    required this.patientId,
    this.patient,
    this.isLoading = false,
    this.errorMessage,
  });

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
  }) {
    return DoctorPatientDetailModel(
      patientId: patientId,
      patient: patient ?? this.patient,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
