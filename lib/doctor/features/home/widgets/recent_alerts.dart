import 'package:flutter/material.dart';
import 'package:grad_project/core/models/alert_model.dart';

class RecentAlerts extends StatelessWidget {
  final List<AlertModel> alerts;

  const RecentAlerts({super.key, required this.alerts});

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) {
      return const SizedBox();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Recent Alerts",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {},
                child: const Text("View All", style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...alerts.take(3).map((alert) {
            Color iconColor;
            Color bgColor;

            final type = alert.type?.toLowerCase() ?? '';
            if (type.contains('critical') || type.contains('high')) {
              iconColor = Colors.red;
              bgColor = Colors.red.withOpacity(0.05);
            } else if (type.contains('warning') || type.contains('abnormal')) {
              iconColor = Colors.orange;
              bgColor = Colors.orange.withOpacity(0.05);
            } else {
              iconColor = Colors.blue;
              bgColor = Colors.blue.withOpacity(0.05);
            }

            String timeString = "Just now";
            if (alert.createdAt != null) {
              try {
                final date = DateTime.parse(alert.createdAt!).toLocal();
                timeString = "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
              } catch (_) {}
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _buildAlertItem(
                name: alert.patientName ?? "Unknown Patient",
                message: alert.message ?? "No message",
                time: timeString,
                iconColor: iconColor,
                bgColor: bgColor,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAlertItem({
    required String name,
    required String message,
    required String time,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.warning_amber_rounded, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
