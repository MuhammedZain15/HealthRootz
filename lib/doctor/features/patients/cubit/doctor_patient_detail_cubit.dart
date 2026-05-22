import 'package:flutter_bloc/flutter_bloc.dart';
import '../model/patient_model.dart';
import '../models/doctor_patient_detail_model.dart';
import '../view_models/doctor_patients_view_model.dart';

/// Cubit for a single patient (GET /api/patients/:id).
class DoctorPatientDetailCubit extends Cubit<DoctorPatientDetailModel> {
  final DoctorPatientsViewModel _viewModel = DoctorPatientsViewModel();

  DoctorPatientDetailCubit({
    required String patientId,
    Patient? preview,
  }) : super(DoctorPatientDetailModel.initial(patientId, preview: preview));

  Future<void> loadPatient() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final (updated, _) = await _viewModel.fetchPatientById(state);
    emit(updated);
  }

  Future<void> retry() => loadPatient();
}
