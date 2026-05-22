import 'package:grad_project/core/models/dashboard_model.dart';

class DoctorDashboardModel {
  final DashboardStats? stats;
  final bool isLoading;
  final String? errorMessage;

  const DoctorDashboardModel({
    this.stats,
    this.isLoading = false,
    this.errorMessage,
  });

  factory DoctorDashboardModel.initial() {
    return const DoctorDashboardModel(isLoading: true);
  }

  DoctorDashboardModel copyWith({
    DashboardStats? stats,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DoctorDashboardModel(
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
