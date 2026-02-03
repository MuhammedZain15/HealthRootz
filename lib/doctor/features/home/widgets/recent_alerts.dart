import 'package:flutter/material.dart';

class RecentAlerts extends StatelessWidget {
  const RecentAlerts({super.key});

  @override
  Widget build(BuildContext context) {
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
          _buildAlertItem(
            name: "John Smith",
            message: "Blood pressure elevated: 180/110",
            time: "5 mins ago",
            iconColor: Colors.red,
            bgColor: Colors.red.withOpacity(0.05),
          ),
          const SizedBox(height: 12),
          _buildAlertItem(
            name: "Sarah Johnson",
            message: "Heart rate abnormal: 125 bpm",
            time: "12 mins ago",
            iconColor: Colors.orange,
            bgColor: Colors.orange.withOpacity(0.05),
          ),
          const SizedBox(height: 12),
          _buildAlertItem(
            name: "Michael Brown",
            message: "Temperature spike detected",
            time: "1 hour ago",
            iconColor: Colors.blue,
            bgColor: Colors.blue.withOpacity(0.05),
          ),
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
