import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grad_project/core/models/appointment_model.dart';
import 'package:grad_project/core/services/appointment_service.dart';
import 'patient_appointments_state.dart';

class PatientAppointmentsCubit extends Cubit<PatientAppointmentsState> {
  final AppointmentService _appointmentService = AppointmentService();

  PatientAppointmentsCubit() : super(PatientAppointmentsInitial());

  Future<void> loadAppointments() async {
    emit(PatientAppointmentsLoading());
    final result = await _appointmentService.getAllAppointments();
    if (result.success && result.data != null) {
      final sorted = List<AppointmentModel>.from(result.data!)
        ..sort((a, b) {
          final da = _parseDate(a);
          final db = _parseDate(b);
          if (da == null && db == null) return 0;
          if (da == null) return 1;
          if (db == null) return -1;
          return db.compareTo(da);
        });
      emit(PatientAppointmentsLoaded(sorted));
    } else {
      emit(
        PatientAppointmentsError(
          result.message ?? 'Failed to load appointments',
        ),
      );
    }
  }

  Future<void> approveAppointment(String id) async {
    final result = await _appointmentService.updateAppointment(id, {'status': 'approved'});
    if (result.success) {
      await loadAppointments();
    } else {
      emit(PatientAppointmentsError(result.message ?? 'Failed to approve appointment'));
    }
  }

  Future<void> declineAppointment(String id) async {
    final result = await _appointmentService.updateAppointment(id, {'status': 'cancelled'});
    if (result.success) {
      await loadAppointments();
    } else {
      emit(PatientAppointmentsError(result.message ?? 'Failed to decline appointment'));
    }
  }

  int get visitsCount {
    final current = state;
    if (current is PatientAppointmentsLoaded) {
      return current.appointments.length;
    }
    return 0;
  }

  int get thisWeekCount {
    final current = state;
    if (current is! PatientAppointmentsLoaded) return 0;
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartMidnight =
        DateTime(weekStart.year, weekStart.month, weekStart.day);
    return current.appointments.where((a) {
      final d = _parseDate(a);
      return d != null && !d.isBefore(weekStartMidnight);
    }).length;
  }

  static DateTime? _parseDate(AppointmentModel appointment) {
    final raw = appointment.date;
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }
}

// commit update
 