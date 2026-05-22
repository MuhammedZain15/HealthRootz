import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubit/doctor_patients_cubit.dart';
import 'widgets/patient_list.dart';

class PatientPage extends StatelessWidget {
  const PatientPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DoctorPatientsCubit()..loadPatients(),
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: SafeArea(child: const PatientList()),
      ),
    );
  }
}
