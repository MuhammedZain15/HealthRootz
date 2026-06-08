import 'package:grad_project/core/services/dashboard_service.dart';
import '../models/doctor_dashboard_model.dart';

class DoctorDashboardViewModel {
  final DashboardService _dashboardService = DashboardService();

  Future<(DoctorDashboardModel, String?)> fetchStats(
    DoctorDashboardModel current,
  ) async {
    try {
      final result = await _dashboardService.getStats();

      if (result.success && result.data != null) {
        return (
          current.copyWith(
            stats: result.data!.stats,
            recentAlerts: result.data!.recentAlerts,
            isLoading: false,
            clearError: true,
          ),
          null,
        );
      }

      return (
        current.copyWith(
          isLoading: false,
          errorMessage: result.message ?? 'Failed to load dashboard stats',
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
}
