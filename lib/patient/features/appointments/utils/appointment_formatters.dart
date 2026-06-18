import 'package:flutter/material.dart';
import 'package:grad_project/core/models/appointment_model.dart';
import 'package:intl/intl.dart';

class AppointmentFormatters {
  static DateTime? parseDate(AppointmentModel appointment) {
    final raw = appointment.date;
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  static String formatDate(AppointmentModel appointment) {
    final dt = parseDate(appointment);
    if (dt == null) return appointment.date ?? '—';
    return DateFormat('EEE, MMM d, yyyy • h:mm a').format(dt.toLocal());
  }

  static String formatStatusLabel(String? status) {
    if (status == null || status.isEmpty) return 'Pending';
    final lower = status.toLowerCase();
    if (lower == 'pending') return 'Pending';
    if (lower == 'approved') return 'Approved';
    if (lower == 'cancelled' || lower == 'canceled') return 'Cancelled';
    if (lower == 'completed') return 'Completed';
    return status[0].toUpperCase() + status.substring(1);
  }

  static Color statusColor(String? status) {
    final lower = (status ?? 'pending').toLowerCase();
    switch (lower) {
      case 'approved':
        return const Color(0xFF16A34A);
      case 'cancelled':
      case 'canceled':
        return const Color(0xFFDC2626);
      case 'completed':
        return const Color(0xFF6B7280);
      case 'pending':
      default:
        return const Color(0xFFF59E0B);
    }
  }

  static Color statusBackgroundColor(String? status) {
    return statusColor(status).withValues(alpha: 0.12);
  }
}

// commit update
 