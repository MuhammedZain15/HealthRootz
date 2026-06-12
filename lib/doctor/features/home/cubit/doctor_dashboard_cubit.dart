import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grad_project/core/services/dashboard_service.dart';
import '../models/doctor_dashboard_model.dart';

class DoctorDashboardCubit extends Cubit<DoctorDashboardModel> {
  final DashboardService _dashboardService = DashboardService();

  DoctorDashboardCubit() : super(DoctorDashboardModel.initial());

  Future<void> loadStats() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final result = await _dashboardService.getStats();

      if (result.success && result.data != null) {
        emit(
          state.copyWith(
            stats: result.data!.stats,
            recentAlerts: result.data!.recentAlerts,
            isLoading: false,
            clearError: true,
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: result.message ?? 'Failed to load dashboard stats',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Error: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> retry() => loadStats();
}
