import 'package:grad_project/core/models/patient_model.dart' as api;
import 'package:grad_project/core/services/patient_service.dart';
import '../models/add_patient_model.dart';

class AddPatientViewModel {
  final PatientService _patientService = PatientService();

  String? validate(AddPatientModel form) {
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

  api.PatientModel toApiModel(AddPatientModel form) {
    return api.PatientModel(
      name: form.name.trim(),
      email: form.email.trim(),
      age: int.parse(form.age.trim()),
      phone: form.phone.trim(),
      gender: form.gender,
      medicalHistory: form.medicalHistory.trim().isEmpty
          ? 'No significant prior history.'
          : form.medicalHistory.trim(),
      condition: form.condition.trim(),
      status: form.status,
    );
  }

  Future<(AddPatientModel, api.PatientModel?, String?)> createPatient(
    AddPatientModel current,
  ) async {
    final validation = validate(current);
    if (validation != null) {
      return (current.copyWith(errorMessage: validation), null, validation);
    }

    try {
      final result = await _patientService.createPatient(toApiModel(current));

      if (result.success && result.data != null) {
        return (
          current.copyWith(isLoading: false, clearError: true),
          result.data,
          null,
        );
      }

      return (
        current.copyWith(
          isLoading: false,
          errorMessage: result.message ?? 'Failed to add patient',
        ),
        null,
        result.message,
      );
    } catch (e) {
      return (
        current.copyWith(
          isLoading: false,
          errorMessage: 'Error: ${e.toString()}',
        ),
        null,
        e.toString(),
      );
    }
  }
}
