import 'package:grad_project/core/models/appointment_model.dart';
import 'package:grad_project/core/services/appointment_service.dart';
import 'package:intl/intl.dart';
import '../models/doctor_appointment_item.dart';
import '../models/doctor_appointments_list_model.dart';

class DoctorAppointmentsViewModel {
  final AppointmentService _appointmentService = AppointmentService();

  DoctorAppointmentItem mapToUi(AppointmentModel model) {
    final parsed = _parseDate(model.date);
    return DoctorAppointmentItem(
      id: model.id ?? '',
      patientName: model.patientName ?? 'Unknown Patient',
      dateLabel: parsed?.dateLabel ?? '—',
      timeLabel: parsed?.timeLabel ?? '—',
      status: formatStatus(model.status),
      reason: model.reason ?? model.description ?? 'No reason provided',
      type: 'Consultation',
    );
  }

  String formatStatus(String? status) {
    if (status == null || status.isEmpty) return 'Pending';
    final lower = status.toLowerCase();
    if (lower == 'approved') return 'Approved';
    if (lower == 'completed') return 'Completed';
    if (lower == 'cancelled' || lower == 'rejected') return 'Cancelled';
    if (lower == 'pending') return 'Pending';
    return status[0].toUpperCase() + status.substring(1);
  }

  ({String dateLabel, String timeLabel})? _parseDate(String? iso) {
    if (iso == null || iso.isEmpty) return null;
    try {
      final dt = DateTime.parse(iso).toLocal();
      return (
        dateLabel: DateFormat('MMM d, yyyy').format(dt),
        timeLabel: DateFormat('hh:mm a').format(dt),
      );
    } catch (_) {
      return null;
    }
  }

  Future<(DoctorAppointmentsListModel, String?)> fetchAppointments(
    DoctorAppointmentsListModel current,
  ) async {
    try {
      final result = await _appointmentService.getAllAppointments();

      if (result.success && result.data != null) {
        final items = result.data!.map(mapToUi).toList();
        return (
          current.copyWith(
            appointments: items,
            isLoading: false,
            clearError: true,
          ),
          null,
        );
      }

      return (
        current.copyWith(
          isLoading: false,
          errorMessage: result.message ?? 'Failed to load appointments',
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

  Future<(DoctorAppointmentsListModel, String?)> updateStatus(
    DoctorAppointmentsListModel current,
    String id,
    String apiStatus,
  ) async {
    try {
      final result = await _appointmentService.updateAppointment(id, {
        'status': apiStatus,
      });

      if (result.success) {
        final updated = current.appointments.map((item) {
          if (item.id != id) return item;
          return DoctorAppointmentItem(
            id: item.id,
            patientName: item.patientName,
            dateLabel: item.dateLabel,
            timeLabel: item.timeLabel,
            status: formatStatus(apiStatus),
            reason: item.reason,
            type: item.type,
          );
        }).toList();

        return (
          current.copyWith(
            appointments: updated,
            isUpdating: false,
            successMessage: 'Appointment updated',
            clearError: true,
          ),
          null,
        );
      }

      return (
        current.copyWith(
          isUpdating: false,
          errorMessage: result.message ?? 'Failed to update appointment',
        ),
        result.message,
      );
    } catch (e) {
      return (
        current.copyWith(
          isUpdating: false,
          errorMessage: 'Error: ${e.toString()}',
        ),
        e.toString(),
      );
    }
  }

  Future<(DoctorAppointmentsListModel, String?)> deleteAppointment(
    DoctorAppointmentsListModel current,
    String id,
  ) async {
    try {
      final result = await _appointmentService.deleteAppointment(id);

      if (result.success) {
        final updated =
            current.appointments.where((a) => a.id != id).toList();
        return (
          current.copyWith(
            appointments: updated,
            isUpdating: false,
            successMessage: 'Appointment deleted',
            clearError: true,
          ),
          null,
        );
      }

      return (
        current.copyWith(
          isUpdating: false,
          errorMessage: result.message ?? 'Failed to delete appointment',
        ),
        result.message,
      );
    } catch (e) {
      return (
        current.copyWith(
          isUpdating: false,
          errorMessage: 'Error: ${e.toString()}',
        ),
        e.toString(),
      );
    }
  }
}
