import '../model/alert_model.dart';
import 'package:grad_project/doctor/features/patients/model/patient_model.dart';

/// UI model for a doctor alert list item.
class DoctorAlertItem {
  final String id;
  final String patientId;
  final String patientName;
  final AlertType type;
  final AlertSeverity severity;
  final String message;
  final String? description;
  final DateTime time;

  const DoctorAlertItem({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.type,
    required this.severity,
    required this.message,
    this.description,
    required this.time,
  });

  Patient toPatientPreview() {
    return Patient(
      id: patientId,
      name: patientName,
      age: 0,
      status: severity.name,
      heartRate: 0,
      emgReading: 0,
    );
  }
}
