import 'package:flutter/material.dart';
import 'package:grad_project/shared/widgets/responsive_layout.dart';
import 'widgets/alert_card.dart';

class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "Alerts",
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: ResponsiveLayout(
            mobile: _buildAlertsList(context, 1),
            tablet: _buildAlertsList(context, 2),
            desktop: _buildAlertsList(context, 3),
          ),
        ),
      ),
    );
  }

  Widget _buildAlertsList(BuildContext context, int crossAxisCount) {
    final alerts = [
      {
        'title': 'Hydration Reminder',
        'message':
            'Drink more water throughout the day to maintain optimal health',
        'dateTime': 'Jan 26, 2025 at 5:23 PM',
        'icon': Icons.water_drop_rounded,
        'bgColor': const Color(0xFFE0F2FE),
        'iconColor': const Color(0xFF0EA5E9),
      },
      {
        'title': 'Caffeine Intake',
        'message':
            'Consider reducing caffeine consumption for better heart health',
        'dateTime': 'Jan 26, 2025 at 2:23 PM',
        'icon': Icons.coffee_rounded,
        'bgColor': const Color(0xFFFEF3C7),
        'iconColor': const Color(0xFFD97706),
      },
      {
        'title': 'Physical Activity',
        'message': 'Perfect time for a quick 15-minute walk!',
        'dateTime': 'Jan 26, 2025 at 11:45 AM',
        'icon': Icons.directions_walk_rounded,
        'bgColor': const Color(0xFFDCFCE7),
        'iconColor': const Color(0xFF16A34A),
      },
      {
        'title': 'Sleep Pattern',
        'message':
            'Your sleep last night was slightly below average. Try to sleep early tonight.',
        'dateTime': 'Jan 26, 2025 at 8:00 AM',
        'icon': Icons.nights_stay_rounded,
        'bgColor': const Color(0xFFF3E8FF),
        'iconColor': const Color(0xFF9333EA),
      },
      {
        'title': 'Medication Reminder',
        'message': 'Time to take your scheduled medications.',
        'dateTime': 'Jan 25, 2025 at 9:00 PM',
        'icon': Icons.medication_rounded,
        'bgColor': const Color(0xFFFEE2E2),
        'iconColor': const Color(0xFFEF4444),
      },
    ];

    if (crossAxisCount == 1) {
      return ListView.separated(
        itemCount: alerts.length,
        padding: const EdgeInsets.only(bottom: 20),
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final alert = alerts[index];
          return AlertCard(
            title: alert['title'] as String,
            message: alert['message'] as String,
            dateTime: alert['dateTime'] as String,
            icon: alert['icon'] as IconData,
            iconBgColor: alert['bgColor'] as Color,
            iconColor: alert['iconColor'] as Color,
            onGotIt: () {},
            onClose: () {},
          );
        },
      );
    } else {
      return GridView.builder(
        itemCount: alerts.length,
        padding: const EdgeInsets.only(bottom: 20),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
        ),
        itemBuilder: (context, index) {
          final alert = alerts[index];
          return AlertCard(
            title: alert['title'] as String,
            message: alert['message'] as String,
            dateTime: alert['dateTime'] as String,
            icon: alert['icon'] as IconData,
            iconBgColor: alert['bgColor'] as Color,
            iconColor: alert['iconColor'] as Color,
            onGotIt: () {},
            onClose: () {},
          );
        },
      );
    }
  }
}
