import 'package:grad_project/core/models/appointment_model.dart';

abstract class PatientAppointmentsState {}

class PatientAppointmentsInitial extends PatientAppointmentsState {}

class PatientAppointmentsLoading extends PatientAppointmentsState {}

class PatientAppointmentsLoaded extends PatientAppointmentsState {
  final List<AppointmentModel> appointments;
  PatientAppointmentsLoaded(this.appointments);
}

class PatientAppointmentsError extends PatientAppointmentsState {
  final String message;
  PatientAppointmentsError(this.message);
}
