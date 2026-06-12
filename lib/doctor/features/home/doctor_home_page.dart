import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grad_project/doctor/features/home/cubit/doctor_dashboard_cubit.dart';
import 'package:grad_project/doctor/features/home/models/doctor_dashboard_model.dart';
import 'package:grad_project/doctor/features/home/widgets/stat_card.dart';
import 'package:grad_project/doctor/features/home/widgets/patient_overview_chart.dart';
import 'package:grad_project/doctor/features/home/widgets/anomaly_chart.dart';
import 'package:grad_project/doctor/features/home/widgets/recent_alerts.dart';
import 'package:grad_project/doctor/features/home/widgets/quick_actions.dart';
import 'package:grad_project/shared/widgets/responsive_layout.dart';

class DoctorHomePage extends StatefulWidget {
  final String doctorName;
  final VoidCallback? onNavigateToReports;

  const DoctorHomePage({
    super.key, 
    required this.doctorName,
    this.onNavigateToReports,
  });

  @override
  State<DoctorHomePage> createState() => _DoctorHomePageState();
}

class _DoctorHomePageState extends State<DoctorHomePage> {
  late final DoctorDashboardCubit _dashboardCubit;

  @override
  void initState() {
    super.initState();
    _dashboardCubit = DoctorDashboardCubit();
    Future.microtask(_dashboardCubit.loadStats);
  }

  @override
  void dispose() {
    _dashboardCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _dashboardCubit,
      child: BlocBuilder<DoctorDashboardCubit, DoctorDashboardModel>(
        builder: (context, state) {
          final mediaQuery = MediaQuery.of(context);
          final screenWidth = mediaQuery.size.width;
          final screenHeight = mediaQuery.size.height;
          final isDesktop = ResponsiveLayout.isDesktop(context);
          final isTablet = ResponsiveLayout.isTablet(context);
          final crossAxisCount = (isDesktop || isTablet) ? 4 : 2;
          final stats = state.stats;

          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: state.isLoading && stats == null
                      ? const Center(child: CircularProgressIndicator())
                      : state.errorMessage != null && stats == null
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    state.errorMessage!,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: _dashboardCubit.retry,
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _dashboardCubit.loadStats,
                              child: SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.05,
                                  vertical: screenHeight * 0.02,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Good Morning, ${widget.doctorName}',
                                      style: TextStyle(
                                        fontSize:
                                            isDesktop ? 32 : screenWidth * 0.06,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                    ),
                                    SizedBox(height: screenHeight * 0.005),
                                    Text(
                                      "Here's your patient overview for today",
                                      style: TextStyle(
                                        fontSize:
                                            isDesktop ? 16 : screenWidth * 0.035,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    SizedBox(height: screenHeight * 0.03),
                                    GridView.count(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      crossAxisCount: crossAxisCount,
                                      crossAxisSpacing: screenWidth * 0.04,
                                      mainAxisSpacing: screenWidth * 0.04,
                                      childAspectRatio:
                                          ResponsiveLayout.isMobile(context) &&
                                                  screenWidth < 360
                                              ? 0.8
                                              : 1.0,
                                      children: [
                                        StatCard(
                                          icon: Icons.people_outline,
                                          iconColor: Colors.blue,
                                          iconBgColor: const Color(0xFFEFF6FF),
                                          value:
                                              '${stats?.totalPatients ?? 0}',
                                          title: 'Total Patients',
                                          trendText: 'Active',
                                          trendColor: Colors.green,
                                          trendIcon: Icons.trending_up,
                                        ),
                                        StatCard(
                                          icon: Icons.warning_amber_rounded,
                                          iconColor: Colors.orange,
                                          iconBgColor: const Color(0xFFFFF7ED),
                                          value: '${stats?.totalAlerts ?? 0}',
                                          title: 'Active Alerts',
                                          trendText: 'Requires Attention',
                                          trendColor: Colors.red,
                                          trendIcon: Icons.trending_up,
                                        ),
                                        StatCard(
                                          icon: Icons.calendar_today_outlined,
                                          iconColor: Colors.green,
                                          iconBgColor: const Color(0xFFF0FDF4),
                                          value:
                                              '${stats?.totalAppointments ?? 0}',
                                          title: 'Appointments',
                                          trendText: 'Scheduled',
                                          trendColor: Colors.green,
                                          trendIcon: Icons.calendar_month,
                                        ),
                                        StatCard(
                                          icon: Icons.insert_drive_file_outlined,
                                          iconColor: Colors.purple,
                                          iconBgColor: const Color(0xFFFAF5FF),
                                          value: '${stats?.totalReports ?? 0}',
                                          title: 'Total Reports',
                                          trendText: 'Available',
                                          trendColor: Colors.purple,
                                          trendIcon: Icons.analytics_outlined,
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: screenHeight * 0.03),
                                    PatientOverviewChart(),
                                    SizedBox(height: screenHeight * 0.03),
                                    const AnomalyChart(),
                                    SizedBox(height: screenHeight * 0.03),
                                    RecentAlerts(alerts: state.recentAlerts ?? []),
                                    SizedBox(height: screenHeight * 0.03),
                                    QuickActions(
                                      onGenerateReportTapped: widget.onNavigateToReports,
                                    ),
                                    SizedBox(height: screenHeight * 0.05),
                                  ],
                                ),
                              ),
                            ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
