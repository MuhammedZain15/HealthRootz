import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grad_project/app_colors.dart';
import 'package:grad_project/doctor/features/home/cubit/add_patient_cubit.dart';
import 'package:grad_project/doctor/features/home/models/add_patient_model.dart';
import 'package:grad_project/doctor/features/home/widgets/add_patient_form.dart';
import 'package:grad_project/shared/widgets/responsive_layout.dart';

/// Page: add patient (MVVM via [AddPatientCubit]).
class AddPatientPage extends StatefulWidget {
  const AddPatientPage({super.key});

  @override
  State<AddPatientPage> createState() => _AddPatientPageState();
}

class _AddPatientPageState extends State<AddPatientPage> {
  late final AddPatientCubit _cubit;
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _conditionController = TextEditingController();
  final _medicalHistoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cubit = AddPatientCubit();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _conditionController.dispose();
    _medicalHistoryController.dispose();
    _cubit.close();
    super.dispose();
  }

  void _syncFormToCubit() {
    _cubit.update(
      name: _nameController.text,
      email: _emailController.text,
      age: _ageController.text,
      phone: _phoneController.text,
      condition: _conditionController.text,
      medicalHistory: _medicalHistoryController.text,
    );
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    _syncFormToCubit();
    final (success, patient) = await _cubit.submit();
    if (!mounted) return;

    if (success && patient != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Patient ${patient.name ?? 'added'} created successfully',
          ),
          backgroundColor: AppColors.skyBlue,
        ),
      );
      Navigator.popUntil(context, (route) => route.isFirst);
    } else if (_cubit.state.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_cubit.state.errorMessage!),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<AddPatientCubit, AddPatientModel>(
        builder: (context, state) {
          final form = AddPatientForm(
            formKey: _formKey,
            state: state,
            cubit: _cubit,
            nameController: _nameController,
            emailController: _emailController,
            ageController: _ageController,
            phoneController: _phoneController,
            conditionController: _conditionController,
            medicalHistoryController: _medicalHistoryController,
            onSubmit: _onSubmit,
            onCancel: () => Navigator.pop(context),
          );

          return Scaffold(
            backgroundColor: const Color(0xFFF9FAFB),
            appBar: AppBar(
              title: const Text(
                'Add New Patient',
                style: TextStyle(
                  color: Color(0xFF111827),
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
                onPressed: state.isLoading ? null : () => Navigator.pop(context),
              ),
            ),
            body: SafeArea(
              child: ResponsiveLayout(
                mobile: form,
                tablet: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: form,
                  ),
                ),
                desktop: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: form,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
