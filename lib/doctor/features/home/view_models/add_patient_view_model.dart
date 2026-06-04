import '../models/add_patient_model.dart';

class AddPatientViewModel {

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

  Map<String, dynamic> toMap(AddPatientModel form) {
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
