import 'package:flutter/material.dart';
import 'package:grad_project/patient/features/home/blood_oxygen_screen.dart';
import 'package:grad_project/patient/features/home/emg_screen.dart';
import 'package:grad_project/app_colors.dart';

import 'package:grad_project/patient/features/home/widgets.dart';

import 'package:grad_project/patient/features/appointment/choose_doctor_screen.dart';
import 'package:grad_project/patient/features/doctor_notes/doctor_notes_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Light grey background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              // Header
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome back, Mohamed Zaini",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Track your health metrics and stay informed",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Latest Readings
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Latest Readings",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  Icon(Icons.show_chart, color: AppColors.skyBlue),
                ],
              ),

              const SizedBox(height: 16),

              SensorReadingCard(
                title: "EMG Activity",
                value: "85",
                unit: "μV",
                status: "Active",
                icon: Icons.graphic_eq, // Sound wave / activity icon
                color: AppColors.lightSeaGreen,
                lastReadingTime: "6:45 PM",
                onStartMeasurement: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EmgScreen()),
                  );
                },
              ),

              SensorReadingCard(
                title: "Blood Oxygen Level",
                value: "98",
                unit: "%",
                status: "Normal",
                icon: Icons.water_drop,
                color: AppColors.skyBlue,
                lastReadingTime: "7:23 PM",
                onStartMeasurement: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BloodOxygenScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // Quick Actions
              const Text(
                "Quick Actions",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  QuickActionCard(
                    title: "Make\nAppointment",
                    icon: Icons.calendar_today_outlined,
                    color: const Color(0xFF9333EA), // Purple
                    bgColor: const Color(0xFFF3E8FF), // Light Purple
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChooseDoctorScreen(),
                        ),
                      );
                    },
                  ),
                  QuickActionCard(
                    title: "Doctor Notes",
                    icon: Icons.description_outlined,
                    color: const Color(0xFF16A34A), // Green
                    bgColor: const Color(0xFFDCFCE7), // Light Green
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DoctorNotesScreen(),
                        ),
                      );
                    },
                  ),
                  QuickActionCard(
                    title: "Health Alerts",
                    icon: Icons.notifications_outlined,
                    color: const Color(0xFFDC2626), // Red
                    bgColor: const Color(0xFFFEE2E2), // Light Red
                    onTap: () {},
                  ),
                  QuickActionCard(
                    title: "AI Chat",
                    icon: Icons.chat_bubble_outline,
                    color:
                        Colors.white, // White icon/text triggers blue card bg
                    bgColor: Colors.white.withOpacity(0.2),
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Recent Measurements
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Recent Measurements",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      "View All",
                      style: TextStyle(
                        color: AppColors.skyBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              // const SizedBox(height: 8),
              const RecentMeasurementCard(
                title: "Heart Rate",
                value: "78",
                unit: "BPM",
                date: "Jan 26, 2025",
                time: "7:23 PM",
                indicatorColor: Color(0xFF22C55E), // Green
              ),
              const RecentMeasurementCard(
                title: "EMG Activity",
                value: "85",
                unit: "μV",
                date: "Jan 26, 2025",
                time: "6:45 PM",
                indicatorColor: AppColors.lightSeaGreen, // Lime Green
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
