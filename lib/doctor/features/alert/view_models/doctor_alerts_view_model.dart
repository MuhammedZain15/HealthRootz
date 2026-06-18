import 'package:grad_project/core/models/alert_model.dart' as api;
import 'package:grad_project/core/services/alert_service.dart';
import '../model/alert_model.dart';
import '../models/doctor_alert_item.dart';
import '../models/doctor_alerts_list_model.dart';

class DoctorAlertsViewModel {
  final AlertService _alertService = AlertService();

  AlertSeverity mapSeverity(api.AlertModel model) {
    if (model.isResolved == true) return AlertSeverity.resolved;
    final t = (model.type ?? '').toLowerCase();
    if (t == 'critical') return AlertSeverity.critical;
    if (t == 'warning' || t == 'monitoring') return AlertSeverity.warning;
    if (t == 'resolved') return AlertSeverity.resolved;
    return AlertSeverity.warning;
  }

  AlertType mapAlertType(api.AlertModel model) {
    final text =
        '${model.message ?? ''} ${model.description ?? ''}'.toLowerCase();
    if (text.contains('heart') || text.contains('bpm')) {
      return AlertType.heartRate;
    }
    if (text.contains('blood pressure') || text.contains('bp')) {
      return AlertType.bloodPressure;
    }
    if (text.contains('temperature') || text.contains('fever')) {
      return AlertType.temperature;
    }
    return AlertType.other;
  }

  DateTime parseTime(api.AlertModel model) {
    if (model.createdAt != null) {
      try {
        return DateTime.parse(model.createdAt!).toLocal();
      } catch (_) {}
    }
    return DateTime.now();
  }

  DoctorAlertItem mapToUi(api.AlertModel model) {
    return DoctorAlertItem(
      id: model.id ?? '',
      patientId: model.patientId ?? '',
      patientName: model.patientName ?? 'Unknown Patient',
      type: mapAlertType(model),
      severity: mapSeverity(model),
      message: model.message ?? model.description ?? 'Alert',
      description: model.description,
      time: parseTime(model),
    );
  }

  Future<(DoctorAlertsListModel, String?)> fetchAlerts(
    DoctorAlertsListModel current,
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

  Future<(DoctorAlertsListModel, String?)> markResolved(
    DoctorAlertsListModel current,
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
          return DoctorAlertItem(
            id: item.id,
            patientId: item.patientId,
            patientName: item.patientName,
            type: item.type,
            severity: AlertSeverity.resolved,
            message: item.message,
            description: item.description,
            time: item.time,
          );
        }).toList();

        return (
          current.copyWith(
            alerts: updated,
            isUpdating: false,
            successMessage: 'Alert marked as resolved',
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
}

// commit update
 