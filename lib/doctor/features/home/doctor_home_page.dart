import 'package:flutter/material.dart';
import 'package:grad_project/doctor/features/home/widgets/stat_card.dart';
import 'package:grad_project/doctor/features/home/widgets/patient_overview_chart.dart';
import 'package:grad_project/doctor/features/home/widgets/anomaly_chart.dart';
import 'package:grad_project/doctor/features/home/widgets/recent_alerts.dart';
import 'package:grad_project/doctor/features/home/widgets/quick_actions.dart';

class DoctorHomePage extends StatelessWidget {
  final String doctorName;

  const DoctorHomePage({super.key, required this.doctorName});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isSmallScreen = screenWidth < 360;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: screenHeight * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header
              Text(
                "Good Morning, $doctorName",
                style: TextStyle(
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF111827),
                ),
              ),
              SizedBox(height: screenHeight * 0.005),
              Text(
                "Here's your patient overview for today",
                style: TextStyle(
                  fontSize: screenWidth * 0.035,
                  color: Colors.grey[600],
                ),
              ),

              SizedBox(height: screenHeight * 0.03),

              /// Stats Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: screenWidth > 600 ? 4 : 2,
                crossAxisSpacing: screenWidth * 0.04,
                mainAxisSpacing: screenWidth * 0.04,
                childAspectRatio: isSmallScreen ? 0.8 : 1.0, // Increased height by reducing ratio
                children: const [
                  StatCard(
                    icon: Icons.people_outline,
                    iconColor: Colors.blue,
                    iconBgColor: Color(0xFFEFF6FF),
                    value: "1,234",
                    title: "Total Patients",
                    trendText: "12% from last month",
                    trendColor: Colors.green,
                    trendIcon: Icons.trending_up,
                  ),
                  StatCard(
                    icon: Icons.warning_amber_rounded,
                    iconColor: Colors.orange,
                    iconBgColor: Color(0xFFFFF7ED),
                    value: "18",
                    title: "Active Alerts",
                    trendText: "3 new today",
                    trendColor: Colors.red,
                    trendIcon: Icons.trending_up,
                  ),
                  StatCard(
                    icon: Icons.favorite_border,
                    iconColor: Colors.red,
                    iconBgColor: Color(0xFFFEF2F2),
                    value: "5",
                    title: "Critical Cases",
                    trendText: "2 urgent",
                    trendColor: Colors.red,
                  ),
                  StatCard(
                    icon: Icons.psychology_outlined,
                    iconColor: Colors.purple,
                    iconBgColor: Color(0xFFFAF5FF),
                    value: "24",
                    title: "AI Anomalies Detected",
                    trendText: "8% this week",
                    trendColor: Colors.green,
                    trendIcon: Icons.trending_down,
                  ),
                ],
              ),

              SizedBox(height: screenHeight * 0.03),

              /// Patient Overview Chart
              const PatientOverviewChart(),

              SizedBox(height: screenHeight * 0.03),

              /// Anomaly Chart
              const AnomalyChart(),

              SizedBox(height: screenHeight * 0.03),

              /// Recent Alerts
              const RecentAlerts(),

              SizedBox(height: screenHeight * 0.03),

              /// Quick Actions
              const QuickActions(),

              SizedBox(height: screenHeight * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}
