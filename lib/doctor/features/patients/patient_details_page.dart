import 'package:flutter/material.dart';
import 'package:grad_project/app_colors.dart';
import 'package:grad_project/doctor/features/patients/widgets/doctor_notes_widgets.dart';
import 'package:grad_project/doctor/features/patients/widgets/patient_info_widgets.dart';
import 'package:grad_project/doctor/features/patients/widgets/vital_signs_widgets.dart';
import 'package:grad_project/patient/features/auth/widgets/custom_button.dart';
import 'model/patient_model.dart';

import 'widgets/vital_signs_chart.dart';

class PatientDetailsPage extends StatelessWidget {
  final Patient patient;

  const PatientDetailsPage({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    // Sample chart data (24 data points for 24 hours)
    final heartRateData = [
      68.0,
      70.0,
      69.0,
      72.0,
      71.0,
      70.0,
      68.0,
      69.0,
      70.0,
      71.0,
      72.0,
      70.0,
      69.0,
      68.0,
      70.0,
      71.0,
      70.0,
      69.0,
      68.0,
      70.0,
      69.0,
      70.0,
      71.0,
      70.0,
    ];
    final bloodPressureData = [
      105.0,
      108.0,
      110.0,
      120.0,
      118.0,
      115.0,
      112.0,
      110.0,
      108.0,
      110.0,
      112.0,
      115.0,
      118.0,
      120.0,
      118.0,
      115.0,
      112.0,
      110.0,
      108.0,
      110.0,
      112.0,
      115.0,
      118.0,
      120.0,
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Patient Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.skyBlue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.chat_bubble,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Patient Header
                    PatientHeader(patient: patient),
                    const SizedBox(height: 20),

                    // Current Vital Signs
                    CurrentVitalSignsSection(),
                    const SizedBox(height: 20),

                    // EMG Sensor Reading
                    const Text(
                      'EMG Sensor Reading',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    EmgReadingCard(value: patient.emgReading),
                    const SizedBox(height: 20),

                    // Vital Signs History Chart
                    VitalSignsChart(
                      heartRateData: heartRateData,
                      bloodPressureData: bloodPressureData,
                    ),
                    const SizedBox(height: 20),

                    // Patient Information
                    PatientInformationSection(patient: patient),
                    const SizedBox(height: 20),

                    // Recent Activity
                    const RecentActivitySection(),

                    const SizedBox(height: 20),

                    // Doctor's Notes
                    const DoctorNotesSection(),
                    const SizedBox(height: 20),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: "Chat",
                            onPressed: () {},
                            color: AppColors.skyBlue,
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          child: CustomButton(
                            text: "Schedule Visit",
                            onPressed: () {},
                            filled: false,
                            color: AppColors.skyBlue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
