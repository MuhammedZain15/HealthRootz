import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grad_project/patient/features/patient/data/models/patient_model.dart' as new_api;
import 'package:grad_project/patient/features/patient/viewmodel/patient_cubit.dart';
import 'package:grad_project/patient/features/patient/viewmodel/patient_state.dart';
import '../models/add_patient_model.dart';

class AddPatientCubit extends Cubit<AddPatientModel> {
  final PatientCubit _patientCubit;

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
    final validation = _validate(state);
    if (validation != null) {
      emit(state.copyWith(errorMessage: validation));
      return (false, null);
    }

    emit(state.copyWith(isLoading: true, clearError: true));

    final map = _toPatientMap(state);
    final result = _patientCubit.stream.firstWhere(
      (patientState) =>
          patientState is PatientLoaded || patientState is PatientError,
    );

    await _patientCubit.createPatient(map);
    final patientState = await result;

    if (patientState is PatientLoaded) {
      emit(state.copyWith(isLoading: false, clearError: true));
      return (true, patientState.patient);
    }
    final message = (patientState as PatientError).message;
    emit(state.copyWith(isLoading: false, errorMessage: message));
    return (false, null);
  }

  String? _validate(AddPatientModel form) {
    if (form.name.trim().isEmpty) return 'Enter patient full name';
    if (form.name.trim().length < 2) return 'Name is too short';

    final email = form.email.trim();
    if (email.isEmpty) return 'Enter email address';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return 'Enter a valid email';
    }

    final age = int.tryParse(form.age.trim());
    if (age == null || age <= 0 || age > 150) return 'Enter a valid age';

    if (form.phone.trim().isEmpty) return 'Enter phone number';
    if (form.gender.trim().isEmpty) return 'Select gender';
    if (form.condition.trim().isEmpty) return 'Enter medical condition';
    if (form.status.trim().isEmpty) return 'Select status';

    return null;
  }

  Map<String, dynamic> _toPatientMap(AddPatientModel form) {
    return {
      'name': form.name.trim(),
      'email': form.email.trim(),
      'age': int.parse(form.age.trim()),
      'phone': form.phone.trim(),
      'gender': form.gender,
      'medicalHistory': form.medicalHistory.trim().isEmpty
          ? 'No significant prior history.'
          : form.medicalHistory.trim(),
      'condition': form.condition.trim(),
      'status': form.status,
    };
  }
}

// commit update
 