import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grad_project/app_colors.dart';
import 'package:grad_project/patient/features/home/appointment/cubit/patient_booking_cubit.dart';
import 'package:grad_project/patient/features/home/appointment/models/patient_booking_model.dart';
import 'package:grad_project/patient/features/appointments/cubit/patient_appointments_cubit.dart';

import 'appointment_widgets.dart';

class ConfirmBookingScreen extends StatefulWidget {
  const ConfirmBookingScreen({super.key});

  @override
  State<ConfirmBookingScreen> createState() => _ConfirmBookingScreenState();
}

class _ConfirmBookingScreenState extends State<ConfirmBookingScreen> {
  final TextEditingController _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _onBookingSuccess(BuildContext context) async {
    debugPrint('[Booking] UI: success state received, refreshing appointments');

    final messenger = ScaffoldMessenger.of(context);
    try {
      await context.read<PatientAppointmentsCubit>().loadAppointments();
      debugPrint('[Booking] UI: appointments list refreshed');
    } catch (e) {
      debugPrint('[Booking] UI: could not refresh appointments — $e');
    }

    if (!mounted) return;

    Navigator.of(context).popUntil((route) => route.isFirst);
    debugPrint('[Booking] UI: navigated back to AppLayout');

    messenger.showSnackBar(
      const SnackBar(
        content: Text('Appointment booked successfully!'),
        backgroundColor: AppColors.skyBlue,
      ),
    );
    debugPrint('[Booking] UI: confirmation snackbar shown');
  }

  Future<void> _handleConfirm(
    PatientBookingCubit cubit,
    PatientBookingModel state,
  ) async {
    debugPrint(
      '[Booking] UI: confirm pressed — patientId=${state.patientId}, '
      'date=${state.selectedDate?.apiDate}, slot=${state.selectedSlotLabel}, '
      'reason="${state.reason}"',
    );

    final success = await cubit.confirmBooking();

    if (!mounted) return;

    final after = cubit.state;
    debugPrint(
      '[Booking] UI: confirmBooking finished — success=$success, '
      'isSuccess=${after.isSuccess}, error=${after.errorMessage}',
    );

    if (!after.isSuccess && after.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(after.errorMessage!),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PatientBookingCubit, PatientBookingModel>(
      listenWhen: (previous, current) =>
          !previous.isSuccess && current.isSuccess,
      listener: (context, state) {
        if (state.isSuccess) {
          _onBookingSuccess(context);
        }
      },
      builder: (context, state) {
        final cubit = context.read<PatientBookingCubit>();

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        AppointmentHeader(
                          title: 'Book Appointment',
                          subtitle: (state.doctorName ?? '').isNotEmpty
                              ? 'Confirm booking'
                              : 'Step 3 — Confirm booking',
                          onBack: () => Navigator.pop(context),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  color: AppColors.skyBlue,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  color: AppColors.skyBlue,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFDCFCE7),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Color(0xFF16A34A),
                                  size: 32,
                                ),
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'Confirm Your Appointment',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 32),
                              _buildDetailRow(
                                icon: Icons.medical_services_outlined,
                                label: 'Doctor',
                                value:
                                    state.doctorName ?? 'General appointment',
                                subValue: state.specialty,
                              ),
                              const SizedBox(height: 24),
                              _buildDetailRow(
                                icon: Icons.calendar_today_outlined,
                                label: 'Date',
                                value: cubit.formatSelectedDate(),
                              ),
                              const SizedBox(height: 24),
                              _buildDetailRow(
                                icon: Icons.access_time,
                                label: 'Time',
                                value: state.selectedSlotLabel ?? '',
                              ),
                              const SizedBox(height: 24),
                              TextField(
                                controller: _reasonController,
                                onChanged: cubit.setReason,
                                maxLines: 2,
                                decoration: InputDecoration(
                                  labelText: 'Reason',
                                  hintText: 'e.g. Routine checkup',
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                              if (state.errorMessage != null) ...[
                                const SizedBox(height: 16),
                                Text(
                                  state.errorMessage!,
                                  style: TextStyle(
                                    color: Colors.red.shade700,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
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
                      onPressed: state.isBooking
                          ? null
                          : () => _handleConfirm(cubit, state),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.skyBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: state.isBooking
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Confirm Appointment',
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

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    String? subValue,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.skyBlue, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                if (subValue != null && subValue.isNotEmpty)
                  Text(
                    subValue,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// commit update
 