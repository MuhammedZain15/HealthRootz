
import 'package:flutter/material.dart';
import 'package:grad_project/doctor/features/patients/model/patient_model.dart';

enum AlertSeverity { critical, warning, resolved }

enum AlertType { heartRate, bloodPressure, temperature, other }

class DoctorAlert {
  final String id;
  final Patient patient;
  final AlertType type;
  final AlertSeverity severity;
  final String message;
  final DateTime time;

  DoctorAlert({
    required this.id,
    required this.patient,
    required this.type,
    required this.severity,
    required this.message,
    required this.time,
  });
}
