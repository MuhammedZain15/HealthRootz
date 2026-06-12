import 'package:flutter/material.dart';
import 'package:grad_project/app_colors.dart';
import 'package:grad_project/doctor/features/home/cubit/add_patient_cubit.dart';
import 'package:grad_project/doctor/features/home/models/add_patient_model.dart';
import 'package:grad_project/doctor/features/home/widgets/patient_page_widgets/custom_labeled_input.dart';
import 'package:grad_project/shared/widgets/custom_button.dart';

/// Add-patient form fields (presentation layer).
class AddPatientForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final AddPatientModel state;
  final AddPatientCubit cubit;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController ageController;
  final TextEditingController phoneController;
  final TextEditingController conditionController;
  final TextEditingController medicalHistoryController;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;

  const AddPatientForm({
    super.key,
    required this.formKey,
    required this.state,
    required this.cubit,
    required this.nameController,
    required this.emailController,
    required this.ageController,
    required this.phoneController,
    required this.conditionController,
    required this.medicalHistoryController,
    required this.onSubmit,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _AddPatientHeaderCard(),
            const SizedBox(height: 20),
            CustomLabeledInput(
              label: 'Full Name',
              hint: "Enter patient's full name",
              prefixIcon: Icons.person_outline,
              controller: nameController,
              onChanged: (_) => cubit.update(name: nameController.text),
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CustomLabeledInput(
                    label: 'Age',
                    hint: 'Enter age',
                    prefixIcon: Icons.calendar_today_outlined,
                    keyboardType: TextInputType.number,
                    controller: ageController,
                    onChanged: (_) => cubit.update(age: ageController.text),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      final n = int.tryParse(v.trim());
                      if (n == null || n <= 0 || n > 150) return 'Invalid age';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(child: _GenderDropdown(state: state, cubit: cubit)),
              ],
            ),
            const SizedBox(height: 20),
            CustomLabeledInput(
              label: 'Email Address',
              hint: 'patient@email.com',
              prefixIcon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
              controller: emailController,
              onChanged: (_) => cubit.update(email: emailController.text),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(v.trim())) {
                  return 'Invalid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            CustomLabeledInput(
              label: 'Phone Number',
              hint: '5551234567',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              controller: phoneController,
              onChanged: (_) => cubit.update(phone: phoneController.text),
            ),
            const SizedBox(height: 20),
            CustomLabeledInput(
              label: 'Medical Condition',
              hint: 'e.g. Asthma, Diabetes',
              prefixIcon: Icons.medical_services_outlined,
              controller: conditionController,
              onChanged: (_) =>
                  cubit.update(condition: conditionController.text),
            ),
            const SizedBox(height: 20),
            _StatusDropdown(state: state, cubit: cubit),
            const SizedBox(height: 20),
            CustomLabeledInput(
              label: 'Medical History',
              hint: 'Enter relevant medical history or notes...',
              prefixIcon: Icons.description_outlined,
              maxLines: 4,
              isRequired: false,
              controller: medicalHistoryController,
              onChanged: (_) => cubit.update(
                medicalHistory: medicalHistoryController.text,
              ),
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: state.isLoading
                      ? const SizedBox(
                          height: 50,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : CustomButton(
                          text: 'Add Patient',
                          onPressed: onSubmit,
                          color: AppColors.skyBlue,
                          height: 50,
                          textStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    text: 'Cancel',
                    onPressed: state.isLoading ? null : onCancel,
                    filled: false,
                    borderColor: Colors.grey[300],
                    height: 50,
                    textStyle: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _AddPatientHeaderCard extends StatelessWidget {
  const _AddPatientHeaderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Patient Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Fields match the server: name, email, age, phone, gender, condition, status, and medical history.',
            style: TextStyle(fontSize: 14, color: Colors.grey[500], height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _GenderDropdown extends StatelessWidget {
  final AddPatientModel state;
  final AddPatientCubit cubit;

  const _GenderDropdown({required this.state, required this.cubit});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: 'Gender',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            children: const [
              TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: state.gender,
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          items: AddPatientModel.genderOptions
              .map((g) => DropdownMenuItem(value: g, child: Text(g)))
              .toList(),
          onChanged: state.isLoading
              ? null
              : (v) {
                  if (v != null) cubit.update(gender: v);
                },
        ),
      ],
    );
  }
}

class _StatusDropdown extends StatelessWidget {
  final AddPatientModel state;
  final AddPatientCubit cubit;

  const _StatusDropdown({required this.state, required this.cubit});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: 'Status',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            children: const [
              TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: state.status,
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          items: AddPatientModel.statusOptions
              .map(
                (s) => DropdownMenuItem(
                  value: s,
                  child: Text(s[0].toUpperCase() + s.substring(1)),
                ),
              )
              .toList(),
          onChanged: state.isLoading
              ? null
              : (v) {
                  if (v != null) cubit.update(status: v);
                },
        ),
      ],
    );
  }
}
