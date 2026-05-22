import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/doctor_dashboard_model.dart';
import '../view_models/doctor_dashboard_view_model.dart';

class DoctorDashboardCubit extends Cubit<DoctorDashboardModel> {
  final DoctorDashboardViewModel _viewModel = DoctorDashboardViewModel();

  DoctorDashboardCubit() : super(DoctorDashboardModel.initial());

  Future<void> loadStats() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    final (updated, _) = await _viewModel.fetchStats(state);
    emit(updated);
  }

  Future<void> retry() => loadStats();
}
