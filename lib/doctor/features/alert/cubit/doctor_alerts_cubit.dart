import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/doctor_alerts_list_model.dart';
import '../view_models/doctor_alerts_view_model.dart';

class DoctorAlertsCubit extends Cubit<DoctorAlertsListModel> {
  final DoctorAlertsViewModel _viewModel = DoctorAlertsViewModel();

  DoctorAlertsCubit() : super(DoctorAlertsListModel.initial());

  Future<void> loadAlerts() async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));
    final (updated, _) = await _viewModel.fetchAlerts(state);
    emit(updated);
  }

  void setFilterIndex(int index) {
    emit(state.copyWith(selectedFilterIndex: index));
  }

  Future<void> markResolved(String id) async {
    emit(state.copyWith(isUpdating: true, clearError: true));
    final (updated, _) = await _viewModel.markResolved(state, id);
    emit(updated);
  }



  void clearMessages() {
    emit(state.copyWith(clearError: true, clearSuccess: true));
  }

  Future<void> retry() => loadAlerts();
}

// commit update
 