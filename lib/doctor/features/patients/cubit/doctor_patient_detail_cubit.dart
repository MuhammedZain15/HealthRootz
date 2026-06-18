import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grad_project/core/services/vital_service.dart';
import 'package:grad_project/patient/features/patient/viewmodel/patient_cubit.dart';
import 'package:grad_project/patient/features/patient/viewmodel/patient_state.dart';
import '../model/patient_model.dart';
import '../models/doctor_patient_detail_model.dart';
import '../view_models/doctor_patients_view_model.dart';

/// Cubit for a single patient (GET /api/patients/:id) plus their vitals.
class DoctorPatientDetailCubit extends Cubit<DoctorPatientDetailModel> {
  final DoctorPatientsViewModel _viewModel = DoctorPatientsViewModel();
  final VitalService _vitalService = VitalService();
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
    _loadVitals();
    await _patientCubit.fetchPatientById(state.patientId);
  }

  /// Fetches the patient's vitals (GET /vitals?patientId=). Runs alongside the
  /// patient fetch and updates state independently when it completes.
  Future<void> _loadVitals() async {
    emit(state.copyWith(vitalsLoading: true));
    final response = await _vitalService.getVitalsForPatient(state.patientId);
    if (isClosed) return;
    emit(state.copyWith(
      vitals: response.data ?? const [],
      vitalsLoading: false,
    ));
  }

  Future<void> retry() => loadPatient();

  @override
  Future<void> close() {
    _patientSubscription.cancel();
    return super.close();
  }
}

// commit update
 