import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grad_project/core/cubit/auth_cubit.dart';
import 'package:grad_project/patient/features/home/appointment/cubit/patient_booking_cubit.dart';
import 'package:grad_project/patient/features/patient/viewmodel/patient_cubit.dart';
import 'package:grad_project/patient/features/home/appointment/select_date_time_screen.dart';

import 'appointment_widgets.dart';

class ChooseDoctorScreen extends StatefulWidget {
  const ChooseDoctorScreen({super.key});

  @override
  State<ChooseDoctorScreen> createState() => _ChooseDoctorScreenState();
}

class _ChooseDoctorScreenState extends State<ChooseDoctorScreen> {
  late final PatientBookingCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = PatientBookingCubit(context.read<PatientCubit>());
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  void _openBooking(BuildContext context, String name, String specialty) {
    final patientId = context.read<AuthCubit>().user?.id;
    _cubit.initializeDoctor(
      doctorName: name,
      specialty: specialty,
      patientId: patientId,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: _cubit,
          child: const SelectDateTimeScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppointmentHeader(
                title: 'Book Appointment',
                subtitle: 'Choose your doctor',
                onBack: () => Navigator.pop(context),
              ),
              const StepProgressBar(currentStep: 1, totalSteps: 2),
              const SizedBox(height: 32),
              const Text(
                'Select a Doctor',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 16),
              DoctorCard(
                name: 'Dr. Sarah Johnson',
                specialty: 'Cardiologist',
                imagePath: 'assets/doctor1.png',
                onTap: () => _openBooking(
                  context,
                  'Dr. Sarah Johnson',
                  'Cardiologist',
                ),
              ),
              DoctorCard(
                name: 'Dr. Michael Chen',
                specialty: 'Neurologist',
                imagePath: 'assets/doctor2.png',
                onTap: () =>
                    _openBooking(context, 'Dr. Michael Chen', 'Neurologist'),
              ),
              DoctorCard(
                name: 'Dr. Emily Rodriguez',
                specialty: 'General Physician',
                imagePath: 'assets/doctor3.png',
                onTap: () => _openBooking(
                  context,
                  'Dr. Emily Rodriguez',
                  'General Physician',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
