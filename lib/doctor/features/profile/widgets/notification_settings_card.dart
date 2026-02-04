import 'package:flutter/material.dart';

class NotificationSettingsCard extends StatefulWidget {
  const NotificationSettingsCard({super.key});

  @override
  State<NotificationSettingsCard> createState() => _NotificationSettingsCardState();
}

class _NotificationSettingsCardState extends State<NotificationSettingsCard> {
  bool emailAlerts = true;
  bool criticalAlerts = true;
  bool dailyReports = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.notifications_outlined, size: 20),
              SizedBox(width: 8),
              Text(
                "Notification Settings",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSwitchRow(
            "Email Alerts",
            "Receive email notifications for important alerts",
            emailAlerts,
            (val) => setState(() => emailAlerts = val),
          ),
          const Divider(height: 32),
          _buildSwitchRow(
            "Critical Alerts",
            "Get notified immediately for critical patient conditions",
            criticalAlerts,
            (val) => setState(() => criticalAlerts = val),
          ),
          const Divider(height: 32),
          _buildSwitchRow(
            "Daily Reports",
            "Receive daily summary reports via email",
            dailyReports,
            (val) => setState(() => dailyReports = val),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchRow(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF3B82F6),
        ),
      ],
    );
  }
}
