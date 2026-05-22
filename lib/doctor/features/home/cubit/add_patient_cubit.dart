import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grad_project/core/models/patient_model.dart' as api;
import '../models/add_patient_model.dart';
import '../view_models/add_patient_view_model.dart';

class AddPatientCubit extends Cubit<AddPatientModel> {
  final AddPatientViewModel _viewModel = AddPatientViewModel();

  AddPatientCubit() : super(AddPatientModel.initial());

  void update({
    String? name,
    String? email,
    String? age,
    String? phone,
    String? gender,
    String? condition,
    String? status,
    String? medicalHistory,
  }) {
    emit(
      state.copyWith(
        name: name,
        email: email,
        age: age,
        phone: phone,
        gender: gender,
        condition: condition,
        status: status,
        medicalHistory: medicalHistory,
        clearError: true,
      ),
    );
  }

  Future<(bool success, api.PatientModel? patient)> submit() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final (updated, patient, _) = await _viewModel.createPatient(state);
    emit(updated);

    return (patient != null, patient);
  }
}
