import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grad_project/patient/features/patient/viewmodel/patient_cubit.dart';
import 'package:grad_project/doctor/features/home/booked_appointments_page.dart';
import 'package:grad_project/doctor/features/home/add_patient_page.dart';

class QuickActions extends StatelessWidget {
  final VoidCallback? onGenerateReportTapped;
  
  const QuickActions({super.key, this.onGenerateReportTapped});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Quick Actions",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildActionButton(
            label: "Add New Patient",
            onPressed: () {
              final patientCubit = context.read<PatientCubit>();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider.value(
                    value: patientCubit,
                    child: const AddPatientPage(),
                  ),
                ),
              );
            },
            isPrimary: true,
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            label: "View Booked Appointments",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BookedAppointmentsPage(),
                ),
              );
            },
            isPrimary: false,
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            label: "Generate Report",
            onPressed: onGenerateReportTapped ?? () {},
            isPrimary: false,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? Colors.blue : Colors.white,
          foregroundColor: isPrimary ? Colors.white : Colors.black,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isPrimary
                ? BorderSide.none
                : BorderSide(color: Colors.grey.withOpacity(0.2)),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
    );
  }
}
