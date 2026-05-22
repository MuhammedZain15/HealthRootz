import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/doctor_patients_list_model.dart';
import '../view_models/doctor_patients_view_model.dart';

/// Cubit for doctor patients list (GET /api/patients).
class DoctorPatientsCubit extends Cubit<DoctorPatientsListModel> {
  final DoctorPatientsViewModel _viewModel = DoctorPatientsViewModel();

  DoctorPatientsCubit() : super(DoctorPatientsListModel.initial());

  Future<void> loadPatients() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final (updated, _) = await _viewModel.fetchPatients(state);
    emit(updated);
  }

  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void setStatusFilter(String filter) {
    emit(state.copyWith(statusFilter: filter));
  }

  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  Future<void> retry() => loadPatients();
}
