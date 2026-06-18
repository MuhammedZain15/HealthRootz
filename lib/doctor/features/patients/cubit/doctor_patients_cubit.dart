import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grad_project/patient/features/patient/viewmodel/patient_cubit.dart';
import 'package:grad_project/patient/features/patient/viewmodel/patient_state.dart';
import '../models/doctor_patients_list_model.dart';
import '../view_models/doctor_patients_view_model.dart';

/// Cubit for doctor patients list (GET /api/patients).
class DoctorPatientsCubit extends Cubit<DoctorPatientsListModel> {
  final DoctorPatientsViewModel _viewModel = DoctorPatientsViewModel();
  final PatientCubit _patientCubit;
  late final StreamSubscription _patientSubscription;

  DoctorPatientsCubit(this._patientCubit) : super(DoctorPatientsListModel.initial()) {
    _patientSubscription = _patientCubit.stream.listen(_onPatientStateChanged);
  }

  void _onPatientStateChanged(PatientState patientState) {
    if (patientState is PatientsListLoaded) {
      final updated = _viewModel.processPatientsList(state, patientState.patients);
      emit(updated);
    } else if (patientState is PatientError) {
      emit(state.copyWith(isLoading: false, errorMessage: patientState.message));
    }
  }

  Future<void> loadPatients() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    await _patientCubit.fetchPatients();
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

  @override
  Future<void> close() {
    _patientSubscription.cancel();
    return super.close();
  }
}

// commit update
 