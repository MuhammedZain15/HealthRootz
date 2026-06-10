import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grad_project/app_colors.dart';
import 'package:grad_project/patient/features/patient/viewmodel/patient_cubit.dart';
import 'package:grad_project/patient/features/patient/viewmodel/patient_state.dart';
import 'package:grad_project/patient/features/home/widgets.dart';
import 'package:grad_project/patient/features/ai_chat/ai_sessions_screen.dart';
import 'package:grad_project/core/cubit/auth_cubit.dart';
import 'appointment/select_date_time_screen.dart';
import 'package:grad_project/patient/features/home/doctor_notes/doctor_notes_screen.dart';

typedef VoidCallbackString = void Function();

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PatientCubit, PatientState>(
      builder: (context, state) {
        String greeting = 'Welcome back';
        if (state is PatientLoaded) {
          final name = state.patient.name.trim();
          if (name.isNotEmpty) greeting = 'Welcome back, $name';
        } else if (state is PatientLoading || state is PatientInitial) {
          greeting = 'Welcome back...';
        } else if (state is PatientError) {
          final authName = context.read<AuthCubit>().state.user?.name;
          if (authName != null && authName.isNotEmpty) {
            greeting = 'Welcome back, $authName';
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (state is PatientLoading || state is PatientInitial)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: LinearProgressIndicator(minHeight: 2),
              ),
            Text(
              greeting,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Track your health metrics and stay informed',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        );
      },
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  const SectionTitle({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        Icon(icon, color: AppColors.skyBlue),
      ],
    );
  }
}

class ReadingsSection extends StatelessWidget {
  final String emgActivity;
  final String emgStatus;
  final String oxygenValue;
  final String oxygenStatus;
  final String heartRateValue;
  final String heartRateStatus;
  final VoidCallback onStartMeasurement;

  const ReadingsSection({
    super.key,
    required this.emgActivity,
    required this.emgStatus,
    required this.oxygenValue,
    required this.oxygenStatus,
    required this.heartRateValue,
    required this.heartRateStatus,
    required this.onStartMeasurement,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: 'Latest Readings', icon: Icons.show_chart),
        const SizedBox(height: 16),
        
        // Start Measurement Button
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: onStartMeasurement,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.play_circle_fill, color: Colors.white, size: 22),
            label: const Text(
              'Start Measurement',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),

        // EMG Activity Card
        PatientMetricCard(
          title: 'EMG Activity',
          value: emgActivity,
          status: emgStatus,
          icon: Icons.waves_rounded,
          iconColor: const Color(0xFF4F46E5),
          iconBgColor: const Color(0xFFEEF2FF),
        ),

        // SpO2 Card (Blood Oxygen Saturation)
        PatientMetricCard(
          title: 'SpO2',
          value: oxygenValue,
          status: oxygenStatus,
          icon: Icons.air,
          iconColor: const Color(0xFF0891B2),
          iconBgColor: const Color(0xFFCFFAFE),
        ),

        // Heart Rate Card
        PatientMetricCard(
          title: 'Heart Rate',
          value: heartRateValue,
          status: heartRateStatus,
          icon: Icons.favorite,
          iconColor: const Color(0xFFEF4444),
          iconBgColor: const Color(0xFFFEE2E2),
        ),
      ],
    );
  }
}

class QuickActionsSection extends StatelessWidget {
  final VoidCallback? onNavigateToAlerts;
  const QuickActionsSection({super.key, this.onNavigateToAlerts});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
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
              title: 'Make\nAppointment',
              icon: Icons.calendar_today_outlined,
              color: const Color(0xFF9333EA),
              bgColor: const Color(0xFFF3E8FF),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SelectDateTimeScreen()),
              ),
            ),
            QuickActionCard(
              title: 'Doctor Notes',
              icon: Icons.description_outlined,
              color: const Color(0xFF16A34A),
              bgColor: const Color(0xFFDCFCE7),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DoctorNotesScreen()),
              ),
            ),
            QuickActionCard(
              title: 'Health Alerts',
              icon: Icons.notifications_outlined,
              color: const Color(0xFFDC2626),
              bgColor: const Color(0xFFFEE2E2),
              onTap: onNavigateToAlerts ?? () {},
            ),
            QuickActionCard(
              title: 'AI Chat',
              icon: Icons.chat_bubble_outline,
              color: AppColors.skyBlue,
              bgColor: AppColors.skyBlue.withValues(alpha: 0.12),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AiSessionsScreen()),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class RecentMeasurementsSection extends StatelessWidget {
  final String heartRateValue;
  final String heartRateTime;
  final String emgValue;
  final String emgTime;
  final String oxygenValue;
  final String oxygenTime;

  const RecentMeasurementsSection({
    super.key,
    required this.heartRateValue,
    required this.heartRateTime,
    required this.emgValue,
    required this.emgTime,
    required this.oxygenValue,
    required this.oxygenTime,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Measurements',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'View All',
                style: TextStyle(
                  color: AppColors.skyBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        RecentMeasurementCard(
          title: 'Heart Rate',
          value: heartRateValue,
          unit: 'BPM',
          date: heartRateTime,
          time: heartRateTime,
          indicatorColor: const Color(0xFF22C55E),
        ),
        RecentMeasurementCard(
          title: 'EMG Activity',
          value: emgValue,
          unit: 'μV',
          date: emgTime,
          time: emgTime,
          indicatorColor: AppColors.lightSeaGreen,
        ),
        RecentMeasurementCard(
          title: 'SpO2',
          value: oxygenValue,
          unit: '%',
          date: oxygenTime,
          time: oxygenTime,
          indicatorColor: const Color(0xFF0891B2),
        ),
      ],
    );
  }
}
