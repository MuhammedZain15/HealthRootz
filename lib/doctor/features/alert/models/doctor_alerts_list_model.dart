import '../model/alert_model.dart';
import 'doctor_alert_item.dart';

class DoctorAlertsListModel {
  final List<DoctorAlertItem> alerts;
  final int selectedFilterIndex;
  final bool isLoading;
  final bool isUpdating;
  final String? errorMessage;
  final String? successMessage;

  const DoctorAlertsListModel({
    this.alerts = const [],
    this.selectedFilterIndex = 0,
    this.isLoading = false,
    this.isUpdating = false,
    this.errorMessage,
    this.successMessage,
  });

  factory DoctorAlertsListModel.initial() => const DoctorAlertsListModel();

  DoctorAlertsListModel copyWith({
    List<DoctorAlertItem>? alerts,
    int? selectedFilterIndex,
    bool? isLoading,
    bool? isUpdating,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return DoctorAlertsListModel(
      alerts: alerts ?? this.alerts,
      selectedFilterIndex: selectedFilterIndex ?? this.selectedFilterIndex,
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  static const List<String> filterKeys = [
    'all',
    'critical',
    'warning',
    'resolved',
  ];

  List<DoctorAlertItem> get filteredAlerts {
    if (selectedFilterIndex == 0) return alerts;
    final key = filterKeys[selectedFilterIndex];
    return alerts.where((a) {
      if (key == 'resolved') return a.severity == AlertSeverity.resolved;
      return a.severity.name == key;
    }).toList();
  }

  int countBySeverity(AlertSeverity severity) =>
      alerts.where((a) => a.severity == severity).length;

  List<String> buildFilterLabels() {
    return [
      'All (${alerts.length})',
      'Critical (${countBySeverity(AlertSeverity.critical)})',
      'Warning (${countBySeverity(AlertSeverity.warning)})',
      'Resolved (${countBySeverity(AlertSeverity.resolved)})',
    ];
  }
}
