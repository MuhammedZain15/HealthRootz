import 'patient_alert_item.dart';

class PatientAlertsListModel {
  final List<PatientAlertItem> alerts;
  final bool isLoading;
  final bool isUpdating;
  final String? errorMessage;
  final String? successMessage;

  const PatientAlertsListModel({
    this.alerts = const [],
    this.isLoading = false,
    this.isUpdating = false,
    this.errorMessage,
    this.successMessage,
  });

  factory PatientAlertsListModel.initial() => const PatientAlertsListModel();

  PatientAlertsListModel copyWith({
    List<PatientAlertItem>? alerts,
    bool? isLoading,
    bool? isUpdating,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return PatientAlertsListModel(
      alerts: alerts ?? this.alerts,
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  List<PatientAlertItem> get activeAlerts =>
      alerts.where((a) => !a.isResolved).toList();
}
