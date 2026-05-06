import 'package:flutter/material.dart';
import 'package:grad_project/core/models/dashboard_model.dart';
import 'package:grad_project/core/services/dashboard_service.dart';
import 'package:grad_project/doctor/features/home/widgets/stat_card.dart';
import 'package:grad_project/doctor/features/home/widgets/patient_overview_chart.dart';
import 'package:grad_project/doctor/features/home/widgets/anomaly_chart.dart';
import 'package:grad_project/doctor/features/home/widgets/recent_alerts.dart';
import 'package:grad_project/doctor/features/home/widgets/quick_actions.dart';
import 'package:grad_project/shared/widgets/responsive_layout.dart';

class DoctorHomePage extends StatefulWidget {
  final String doctorName;

  const DoctorHomePage({super.key, required this.doctorName});

  @override
  State<DoctorHomePage> createState() => _DoctorHomePageState();
}

class _DoctorHomePageState extends State<DoctorHomePage> {
  final DashboardService _dashboardService = DashboardService();
  DashboardSummary? _summary;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _dashboardService.getSummary();

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result.success && result.data != null) {
          _summary = result.data;
        } else {
          _errorMessage = result.message ?? "Failed to load dashboard data";
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final isTablet = ResponsiveLayout.isTablet(context);

    final crossAxisCount = (isDesktop || isTablet) ? 4 : 2;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _fetchDashboardData,
                              child: const Text("Retry"),
                            )
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.05,
                          vertical: screenHeight * 0.02,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// Header
                            Text(
                              "Good Morning, ${widget.doctorName}",
                              style: TextStyle(
                                fontSize: isDesktop ? 32 : screenWidth * 0.06,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF111827),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.005),
                            Text(
                              "Here's your patient overview for today",
                              style: TextStyle(
                                fontSize: isDesktop ? 16 : screenWidth * 0.035,
                                color: Colors.grey[600],
                              ),
                            ),
          
                            SizedBox(height: screenHeight * 0.03),
          
                            /// Stats Grid
                            GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: screenWidth * 0.04,
                              mainAxisSpacing: screenWidth * 0.04,
                              childAspectRatio:
                                  ResponsiveLayout.isMobile(context) && screenWidth < 360
                                  ? 0.8
                                  : 1.0,
                              children: [
                                StatCard(
                                  icon: Icons.people_outline,
                                  iconColor: Colors.blue,
                                  iconBgColor: const Color(0xFFEFF6FF),
                                  value: "${_summary?.stats?.totalPatients ?? 0}",
                                  title: "Total Patients",
                                  trendText: "Active",
                                  trendColor: Colors.green,
                                  trendIcon: Icons.trending_up,
                                ),
                                StatCard(
                                  icon: Icons.warning_amber_rounded,
                                  iconColor: Colors.orange,
                                  iconBgColor: const Color(0xFFFFF7ED),
                                  value: "${_summary?.stats?.totalAlerts ?? 0}",
                                  title: "Active Alerts",
                                  trendText: "Requires Attention",
                                  trendColor: Colors.red,
                                  trendIcon: Icons.trending_up,
                                ),
                                StatCard(
                                  icon: Icons.calendar_today_outlined,
                                  iconColor: Colors.green,
                                  iconBgColor: const Color(0xFFF0FDF4),
                                  value: "${_summary?.stats?.totalAppointments ?? 0}",
                                  title: "Appointments",
                                  trendText: "Scheduled",
                                  trendColor: Colors.green,
                                  trendIcon: Icons.calendar_month,
                                ),
                                StatCard(
                                  icon: Icons.insert_drive_file_outlined,
                                  iconColor: Colors.purple,
                                  iconBgColor: const Color(0xFFFAF5FF),
                                  value: "${_summary?.stats?.totalReports ?? 0}",
                                  title: "Total Reports",
                                  trendText: "Available",
                                  trendColor: Colors.purple,
                                  trendIcon: Icons.analytics_outlined,
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
        ),
      ),
    );
  }
}

