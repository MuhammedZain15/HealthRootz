import 'package:flutter/material.dart';
import 'package:grad_project/app_colors.dart';
import 'package:grad_project/doctor/features/patients/widgets/doctor_notes_widgets.dart';
import 'package:grad_project/doctor/features/patients/widgets/patient_info_widgets.dart';
import 'package:grad_project/doctor/features/patients/widgets/vital_signs_widgets.dart';
import 'package:grad_project/patient/features/auth/widgets/custom_button.dart';
import 'model/patient_model.dart';

import 'widgets/vital_signs_chart.dart';
import 'package:grad_project/shared/widgets/responsive_layout.dart';

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
              child: ResponsiveLayout(
                mobile: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _buildPatientContent(
                      heartRateData,
                      bloodPressureData,
                    ),
                  ),
                ),
                tablet: _buildTabletDesktopLayout(
                  heartRateData,
                  bloodPressureData,
                ),
                desktop: _buildTabletDesktopLayout(
                  heartRateData,
                  bloodPressureData,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletDesktopLayout(
    List<double> heartRateData,
    List<double> bloodPressureData,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PatientHeader(patient: patient),
                    const SizedBox(height: 20),
                    CurrentVitalSignsSection(),
                    const SizedBox(height: 20),
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
                    VitalSignsChart(
                      heartRateData: heartRateData,
                      bloodPressureData: bloodPressureData,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // Right Column
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PatientInformationSection(patient: patient),
                    const SizedBox(height: 20),
                    const RecentActivitySection(),
                    const SizedBox(height: 20),
                    const DoctorNotesSection(),
                    const SizedBox(height: 20),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPatientContent(
    List<double> heartRateData,
    List<double> bloodPressureData,
  ) {
    return [
      PatientHeader(patient: patient),
      const SizedBox(height: 20),
      CurrentVitalSignsSection(),
      const SizedBox(height: 20),
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
      VitalSignsChart(
        heartRateData: heartRateData,
        bloodPressureData: bloodPressureData,
      ),
      const SizedBox(height: 20),
      PatientInformationSection(patient: patient),
      const SizedBox(height: 20),
      const RecentActivitySection(),
      const SizedBox(height: 20),
      const DoctorNotesSection(),
      const SizedBox(height: 20),
      _buildActionButtons(),
    ];
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: "Chat",
            onPressed: () {},
            color: AppColors.skyBlue,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: CustomButton(
            text: "Schedule Visit",
            onPressed: () {},
            filled: false,
            color: AppColors.skyBlue,
          ),
        ),
      ],
    );
  }
}
