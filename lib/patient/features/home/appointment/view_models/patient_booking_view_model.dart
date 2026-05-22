import 'package:grad_project/core/network/token_storage.dart';
import 'package:grad_project/core/services/appointment_service.dart';
import 'package:intl/intl.dart';
import '../models/patient_booking_model.dart';

class PatientBookingViewModel {
  final AppointmentService _appointmentService = AppointmentService();

  Future<String?> resolvePatientId() async {
    return TokenStorage.getUserId();
  }

  Future<(PatientBookingModel, String?)> loadSlots(
    PatientBookingModel current,
    int dateIndex,
  ) async {
    if (dateIndex < 0 || dateIndex >= current.dateOptions.length) {
      return (current, 'Invalid date');
    }

    final date = current.dateOptions[dateIndex];

    try {
      final result = await _appointmentService.getAvailableSlots(
        date: date.apiDate,
      );

      if (result.success && result.data != null) {
        return (
          current.copyWith(
            selectedDateIndex: dateIndex,
            availableSlots: result.data!,
            selectedSlotIndex: -1,
            isLoadingSlots: false,
            clearError: true,
            resetSlots: false,
          ),
          null,
        );
      }

      return (
        current.copyWith(
          selectedDateIndex: dateIndex,
          availableSlots: const [],
          isLoadingSlots: false,
          errorMessage: result.message ?? 'No slots available',
          resetSlots: false,
        ),
        result.message,
      );
    } catch (e) {
      return (
        current.copyWith(
          isLoadingSlots: false,
          errorMessage: 'Error: ${e.toString()}',
        ),
        e.toString(),
      );
    }
  }

  String buildIsoDateTime(BookingDateOption date, String slotLabel) {
    final parsed = _parseSlotTime(slotLabel);
    final dt = DateTime(
      date.date.year,
      date.date.month,
      date.date.day,
      parsed.hour,
      parsed.minute,
    );
    return dt.toUtc().toIso8601String();
  }

  ({int hour, int minute}) _parseSlotTime(String slot) {
    try {
      final dt = DateFormat('hh:mm a').parse(slot);
      return (hour: dt.hour, minute: dt.minute);
    } catch (_) {
      final parts = slot.split(':');
      if (parts.length >= 2) {
        return (
          hour: int.tryParse(parts[0]) ?? 9,
          minute: int.tryParse(parts[1].replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
        );
      }
      return (hour: 9, minute: 0);
    }
  }

  String formatDisplayDate(BookingDateOption date) {
    return '${date.dayLabel}, ${date.dateLabel} ${DateFormat('MMM').format(date.date)}, ${date.date.year}';
  }

  Future<(PatientBookingModel, String?)> createAppointment(
    PatientBookingModel current,
  ) async {
    final patientId = current.patientId;
    final selectedDate = current.selectedDate;
    final slot = current.selectedSlotLabel;

    if (patientId == null || patientId.isEmpty) {
      return (current, 'Patient ID not found. Please log in again.');
    }
    if (selectedDate == null || slot == null) {
      return (current, 'Please select date and time');
    }

    final reason = current.reason.trim().isEmpty
        ? 'Routine checkup'
        : current.reason.trim();

    try {
      final iso = buildIsoDateTime(selectedDate, slot);
      final result = await _appointmentService.createAppointment(
        patientId: patientId,
        dateIso: iso,
        reason: reason,
      );

      if (result.success) {
        return (
          current.copyWith(
            isBooking: false,
            isSuccess: true,
            clearError: true,
          ),
          null,
        );
      }

      return (
        current.copyWith(
          isBooking: false,
          errorMessage: result.message ?? 'Failed to book appointment',
        ),
        result.message,
      );
    } catch (e) {
      return (
        current.copyWith(
          isBooking: false,
          errorMessage: 'Error: ${e.toString()}',
        ),
        e.toString(),
      );
    }
  }
}
