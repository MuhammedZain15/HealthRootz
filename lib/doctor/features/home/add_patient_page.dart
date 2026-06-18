import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grad_project/patient/features/patient/viewmodel/patient_cubit.dart';
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
    _cubit = AddPatientCubit(context.read<PatientCubit>());
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
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Patient Created'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name: ${patient.name}'),
              const SizedBox(height: 8),
              Text('Email: ${patient.email}'),
              const SizedBox(height: 8),
              Text('Password: ${patient.password ?? "Not provided by server"}'),
              const SizedBox(height: 16),
              const Text(
                'Please share these credentials with the patient.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text('Close'),
            ),
          ],
        ),
      );
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
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              title: Text(
                'Add New Patient',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Theme.of(context).cardColor,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back,
                    color: Theme.of(context).colorScheme.onSurface),
                onPressed: state.isLoading
                    ? null
                    : () => Navigator.pop(context),
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

// commit update
 