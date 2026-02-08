import 'package:flutter/material.dart';
import 'package:grad_project/patient/features/home/blood_oxygen_screen.dart';
import 'package:grad_project/patient/features/home/doctor_notes/doctor_notes_screen.dart';
import 'package:grad_project/patient/features/home/emg_screen.dart';
import 'package:grad_project/app_colors.dart';
import 'package:grad_project/patient/features/home/widgets.dart';
import 'package:grad_project/shared/widgets/responsive_layout.dart';
import 'appointment/choose_doctor_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ResponsiveLayout(
            mobile: _buildMobileLayout(context),
            tablet: _buildTabletDesktopLayout(context),
            desktop: _buildTabletDesktopLayout(context),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          "Welcome back, Mohamed Zaini",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        SizedBox(height: 4),
        Text(
          "Track your health metrics and stay informed",
          style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        Icon(icon, color: AppColors.skyBlue),
      ],
    );
  }

  Widget _buildReadings(BuildContext context) {
    return Column(
      children: [
        _buildSectionTitle("Latest Readings", Icons.show_chart),
        const SizedBox(height: 16),
        SensorReadingCard(
          title: "EMG Activity",
          value: "85",
          unit: "μV",
          status: "Active",
          icon: Icons.graphic_eq,
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
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, {int crossAxisCount = 2}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1,
          children: [
            QuickActionCard(
              title: "Make\nAppointment",
              icon: Icons.calendar_today_outlined,
              color: const Color(0xFF9333EA),
              bgColor: const Color(0xFFF3E8FF),
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
              color: const Color(0xFF16A34A),
              bgColor: const Color(0xFFDCFCE7),
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
              color: const Color(0xFFDC2626),
              bgColor: const Color(0xFFFEE2E2),
              onTap: () {},
            ),
            QuickActionCard(
              title: "AI Chat",
              icon: Icons.chat_bubble_outline,
              color: AppColors.skyBlue,
              bgColor: Colors.white12,
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentMeasurements() {
    return Column(
      children: [
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
        const RecentMeasurementCard(
          title: "Heart Rate",
          value: "78",
          unit: "BPM",
          date: "Jan 26, 2025",
          time: "7:23 PM",
          indicatorColor: Color(0xFF22C55E),
        ),
        const RecentMeasurementCard(
          title: "EMG Activity",
          value: "85",
          unit: "μV",
          date: "Jan 26, 2025",
          time: "6:45 PM",
          indicatorColor: AppColors.lightSeaGreen,
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        _buildHeader(),
        const SizedBox(height: 32),
        _buildReadings(context),
        const SizedBox(height: 32),
        _buildQuickActions(context),
        const SizedBox(height: 32),
        _buildRecentMeasurements(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTabletDesktopLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        _buildHeader(),
        const SizedBox(height: 32),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  _buildReadings(context),
                  const SizedBox(height: 32),
                  _buildRecentMeasurements(),
                ],
              ),
            ),
            const SizedBox(width: 32),
            Expanded(
              flex: 2,
              child: _buildQuickActions(context, crossAxisCount: 1),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
