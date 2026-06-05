import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grad_project/patient/features/patient/data/models/patient_model.dart' as new_api;
import 'package:grad_project/patient/features/patient/viewmodel/patient_cubit.dart';
import 'package:grad_project/patient/features/patient/viewmodel/patient_state.dart';
import '../models/add_patient_model.dart';
import '../view_models/add_patient_view_model.dart';

class AddPatientCubit extends Cubit<AddPatientModel> {
  final AddPatientViewModel _viewModel = AddPatientViewModel();
  final PatientCubit _patientCubit;
  StreamSubscription? _patientSubscription;

  AddPatientCubit(this._patientCubit) : super(AddPatientModel.initial());

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

  Future<(bool success, new_api.PatientModel? patient)> submit() async {
    final validation = _viewModel.validate(state);
    if (validation != null) {
      emit(state.copyWith(errorMessage: validation));
      return (false, null);
    }

    emit(state.copyWith(isLoading: true, clearError: true));

    final map = _viewModel.toMap(state);
    final completer = Completer<(bool, new_api.PatientModel?)>();

    _patientSubscription?.cancel();
    _patientSubscription = _patientCubit.stream.listen((patientState) {
      if (patientState is PatientLoaded) {
        emit(state.copyWith(isLoading: false, clearError: true));
        completer.complete((true, patientState.patient));
      } else if (patientState is PatientError) {
        emit(state.copyWith(isLoading: false, errorMessage: patientState.message));
        completer.complete((false, null));
      }
    });

    await _patientCubit.createPatient(map);

    return completer.future;
  }

  @override
  Future<void> close() {
    _patientSubscription?.cancel();
    return super.close();
  }
}
