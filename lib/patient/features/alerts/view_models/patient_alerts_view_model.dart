import 'package:flutter/material.dart';
import 'package:grad_project/core/models/alert_model.dart' as api;
import 'package:grad_project/core/services/alert_service.dart';
import 'package:intl/intl.dart';
import '../models/patient_alert_item.dart';
import '../models/patient_alerts_list_model.dart';

class PatientAlertsViewModel {
  final AlertService _alertService = AlertService();

  (IconData icon, Color bg, Color fg) iconStyle(String? type, bool resolved) {
    if (resolved) {
      return (
        Icons.check_circle_outline,
        const Color(0xFFEFF6FF),
        const Color(0xFF4A628A),
      );
    }
    final t = (type ?? '').toLowerCase();
    if (t == 'critical') {
      return (
        Icons.warning_amber_rounded,
        const Color(0xFFFEE2E2),
        const Color(0xFFEF4444),
      );
    }
    if (t == 'warning') {
      return (
        Icons.info_outline,
        const Color(0xFFFEF3C7),
        const Color(0xFFD97706),
      );
    }
    return (
      Icons.notifications_active_outlined,
      const Color(0xFFE0F2FE),
      const Color(0xFF0EA5E9),
    );
  }

  String formatDate(DateTime dt) {
    return DateFormat('MMM d, yyyy \'at\' h:mm a').format(dt);
  }

  DateTime parseTime(api.AlertModel model) {
    if (model.createdAt != null) {
      try {
        return DateTime.parse(model.createdAt!).toLocal();
      } catch (_) {}
    }
    return DateTime.now();
  }

  PatientAlertItem mapToUi(api.AlertModel model) {
    final resolved =
        model.isResolved == true || (model.type ?? '').toLowerCase() == 'resolved';
    final style = iconStyle(model.type, resolved);
    final time = parseTime(model);

    return PatientAlertItem(
      id: model.id ?? '',
      title: model.message ?? 'Health Alert',
      message: model.description ?? model.message ?? '',
      dateTimeLabel: formatDate(time),
      icon: style.$1,
      iconBgColor: style.$2,
      iconColor: style.$3,
      isResolved: resolved,
    );
  }

  Future<(PatientAlertsListModel, String?)> fetchAlerts(
    PatientAlertsListModel current,
  ) async {
    try {
      final result = await _alertService.getAllAlerts();

      if (result.success && result.data != null) {
        final items = result.data!.map(mapToUi).toList();
        return (
          current.copyWith(
            alerts: items,
            isLoading: false,
            clearError: true,
          ),
          null,
        );
      }

      return (
        current.copyWith(
          isLoading: false,
          errorMessage: result.message ?? 'Failed to load alerts',
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

  Future<(PatientAlertsListModel, String?)> markResolved(
    PatientAlertsListModel current,
    String id,
  ) async {
    try {
      final result = await _alertService.updateAlert(id, {
        'isResolved': true,
        'type': 'resolved',
      });

      if (result.success) {
        final updated = current.alerts.map((item) {
          if (item.id != id) return item;
          final style = iconStyle('resolved', true);
          return PatientAlertItem(
            id: item.id,
            title: item.title,
            message: item.message,
            dateTimeLabel: item.dateTimeLabel,
            icon: style.$1,
            iconBgColor: style.$2,
            iconColor: style.$3,
            isResolved: true,
          );
        }).toList();

        return (
          current.copyWith(
            alerts: updated,
            isUpdating: false,
            successMessage: 'Alert dismissed',
            clearError: true,
          ),
          null,
        );
      }

      return (
        current.copyWith(
          isUpdating: false,
          errorMessage: result.message ?? 'Failed to update alert',
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

  Future<(PatientAlertsListModel, String?)> deleteAlert(
    PatientAlertsListModel current,
    String id,
  ) async {
    try {
      final result = await _alertService.deleteAlert(id);

      if (result.success) {
        final updated = current.alerts.where((a) => a.id != id).toList();
        return (
          current.copyWith(
            alerts: updated,
            isUpdating: false,
            successMessage: 'Alert removed',
            clearError: true,
          ),
          null,
        );
      }

      return (
        current.copyWith(
          isUpdating: false,
          errorMessage: result.message ?? 'Failed to remove alert',
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

// commit update
 