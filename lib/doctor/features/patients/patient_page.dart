import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grad_project/patient/features/patient/viewmodel/patient_cubit.dart';
import 'cubit/doctor_patients_cubit.dart';
import 'widgets/patient_list.dart';

class PatientPage extends StatelessWidget {
  const PatientPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DoctorPatientsCubit(context.read<PatientCubit>())..loadPatients(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(child: const PatientList()),
      ),
    );
  }
}

// commit update
 