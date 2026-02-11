import 'package:flutter/material.dart';
import 'package:grad_project/patient/features/home/appointment/select_date_time_screen.dart';

import 'appointment_widgets.dart';

class ChooseDoctorScreen extends StatelessWidget {
  const ChooseDoctorScreen({super.key});

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
                title: "Book Appointment",
                subtitle: "Choose your doctor",
                onBack: () => Navigator.pop(context),
              ),
              const StepProgressBar(currentStep: 1, totalSteps: 2),
              const SizedBox(height: 32),
              const Text(
                "Select a Doctor",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 16),
              DoctorCard(
                name: "Dr. Sarah Johnson",
                specialty: "Cardiologist",
                imagePath: "assets/doctor1.png", // Placeholder
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SelectDateTimeScreen(
                        doctorName: "Dr. Sarah Johnson",
                        specialty: "Cardiologist",
                      ),
                    ),
                  );
                },
              ),
              DoctorCard(
                name: "Dr. Michael Chen",
                specialty: "Neurologist",
                imagePath: "assets/doctor2.png", // Placeholder
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SelectDateTimeScreen(
                        doctorName: "Dr. Michael Chen",
                        specialty: "Neurologist",
                      ),
                    ),
                  );
                },
              ),
              DoctorCard(
                name: "Dr. Emily Rodriguez",
                specialty: "General Physician",
                imagePath: "assets/doctor3.png", // Placeholder
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SelectDateTimeScreen(
                        doctorName: "Dr. Emily Rodriguez",
                        specialty: "General Physician",
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
