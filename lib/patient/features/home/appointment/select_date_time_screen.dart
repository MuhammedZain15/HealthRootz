import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grad_project/app_colors.dart';
import 'package:grad_project/patient/features/appointments/cubit/patient_appointments_cubit.dart';
import 'package:grad_project/patient/features/home/appointment/confirm_booking_screen.dart';
import 'package:grad_project/patient/features/home/appointment/cubit/patient_booking_cubit.dart';
import 'package:grad_project/patient/features/home/appointment/models/patient_booking_model.dart';
import 'package:grad_project/patient/features/patient/viewmodel/patient_cubit.dart';

import 'appointment_widgets.dart';

class SelectDateTimeScreen extends StatelessWidget {
  const SelectDateTimeScreen({super.key});

  static String _initial(String? name) {
    final n = (name ?? 'D').replaceAll('Dr. ', '').trim();
    return n.isEmpty ? 'D' : n[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PatientBookingCubit, PatientBookingModel>(
      builder: (context, state) {
        final cubit = context.read<PatientBookingCubit>();
        final dayMaps = state.dateOptions
            .map((d) => {'day': d.dayLabel, 'date': d.dateLabel})
            .toList();

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppointmentHeader(
                          title: 'Book Appointment',
                          subtitle: (state.doctorName ?? '').isNotEmpty
                              ? 'Select date & time'
                              : 'Step 1 — Select date & time',
                          onBack: () => Navigator.pop(context),
                        ),
                        StepProgressBar(
                          currentStep: (state.doctorName ?? '').isNotEmpty ? 2 : 1,
                          totalSteps: (state.doctorName ?? '').isNotEmpty ? 2 : 3,
                        ),
                        if ((state.doctorName ?? '').isNotEmpty) ...[
                          const SizedBox(height: 32),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor:
                                      AppColors.skyBlue.withValues(alpha: 0.1),
                                  child: Text(
                                    _initial(state.doctorName),
                                    style: TextStyle(
                                      color: AppColors.skyBlue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      state.doctorName ?? '',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                    Text(
                                      state.specialty ?? '',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 32),
                        DateSelector(
                          days: dayMaps,
                          selectedIndex: state.selectedDateIndex,
                          onSelected: cubit.selectDate,
                        ),
                        const SizedBox(height: 32),
                        TimeSlotGrid(
                          slots: state.availableSlots,
                          selectedIndex: state.selectedSlotIndex,
                          onSelected: cubit.selectSlot,
                          isLoading: state.isLoadingSlots,
                        ),
                        if (state.errorMessage != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            state.errorMessage!,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: state.canContinue
                          ? () {
                              final patientCubit = context.read<PatientCubit>();
                              final appointmentsCubit =
                                  context.read<PatientAppointmentsCubit>();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MultiBlocProvider(
                                    providers: [
                                      BlocProvider.value(value: cubit),
                                      BlocProvider.value(value: patientCubit),
                                      BlocProvider.value(
                                        value: appointmentsCubit,
                                      ),
                                    ],
                                    child: const ConfirmBookingScreen(),
                                  ),
                                ),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.skyBlue,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
