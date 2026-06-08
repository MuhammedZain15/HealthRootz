import 'package:grad_project/core/models/dashboard_model.dart';
import 'package:grad_project/core/models/alert_model.dart';

class DoctorDashboardModel {
  final DashboardStats? stats;
  final List<AlertModel>? recentAlerts;
  final bool isLoading;
  final String? errorMessage;

  const DoctorDashboardModel({
    this.stats,
    this.recentAlerts,
    this.isLoading = false,
    this.errorMessage,
  });

  factory DoctorDashboardModel.initial() {
    return const DoctorDashboardModel(isLoading: true);
  }

  DoctorDashboardModel copyWith({
    DashboardStats? stats,
    List<AlertModel>? recentAlerts,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DoctorDashboardModel(
      stats: stats ?? this.stats,
      recentAlerts: recentAlerts ?? this.recentAlerts,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
