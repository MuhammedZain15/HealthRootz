import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/patient_alerts_list_model.dart';
import '../view_models/patient_alerts_view_model.dart';

class PatientAlertsCubit extends Cubit<PatientAlertsListModel> {
  final PatientAlertsViewModel _viewModel = PatientAlertsViewModel();

  PatientAlertsCubit() : super(PatientAlertsListModel.initial());

  Future<void> loadAlerts() async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));
    final (updated, _) = await _viewModel.fetchAlerts(state);
    emit(updated);
  }

  Future<void> acknowledge(String id) async {
    emit(state.copyWith(isUpdating: true, clearError: true));
    final (updated, _) = await _viewModel.markResolved(state, id);
    emit(updated);
  }

  Future<void> dismiss(String id) async {
    emit(state.copyWith(isUpdating: true, clearError: true));
    final (updated, _) = await _viewModel.deleteAlert(state, id);
    emit(updated);
  }

  void clearMessages() {
    emit(state.copyWith(clearError: true, clearSuccess: true));
  }

  Future<void> retry() => loadAlerts();
}
