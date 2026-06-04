import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grad_project/patient/features/patient/viewmodel/patient_cubit.dart';
import 'package:grad_project/patient/features/patient/viewmodel/patient_state.dart';
import '../model/patient_model.dart';
import '../models/doctor_patient_detail_model.dart';
import '../view_models/doctor_patients_view_model.dart';

/// Cubit for a single patient (GET /api/patients/:id).
class DoctorPatientDetailCubit extends Cubit<DoctorPatientDetailModel> {
  final DoctorPatientsViewModel _viewModel = DoctorPatientsViewModel();
  final PatientCubit _patientCubit;
  late final StreamSubscription _patientSubscription;

  DoctorPatientDetailCubit({
    required PatientCubit patientCubit,
    required String patientId,
    Patient? preview,
  })  : _patientCubit = patientCubit,
        super(DoctorPatientDetailModel.initial(patientId, preview: preview)) {
    _patientSubscription = _patientCubit.stream.listen(_onPatientStateChanged);
  }

  void _onPatientStateChanged(PatientState patientState) {
    if (patientState is PatientLoaded &&
        patientState.patient.id == state.patientId) {
      final updated = _viewModel.processPatientDetail(
        state,
        patientState.patient,
      );
      emit(updated);
    } else if (patientState is PatientError) {
      emit(
        state.copyWith(isLoading: false, errorMessage: patientState.message),
      );
    }
  }

  Future<void> loadPatient() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    await _patientCubit.fetchPatientById(state.patientId);
  }

  Future<void> retry() => loadPatient();

  @override
  Future<void> close() {
    _patientSubscription.cancel();
    return super.close();
  }
}
