import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/patient_model.dart';
import '../model/activity_model.dart';

// Patient Info Row
class PatientInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const PatientInfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

// Patient Information Section
class PatientInformationSection extends StatelessWidget {
  final Patient patient;

  const PatientInformationSection({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Patient Information',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          PatientInfoRow(label: 'Email', value: patient.email ?? 'N/A'),
          Divider(color: Colors.grey.shade200, height: 1),
          PatientInfoRow(label: 'Phone', value: patient.phone ?? 'N/A'),
          Divider(color: Colors.grey.shade200, height: 1),
          PatientInfoRow(label: 'Gender', value: patient.gender ?? 'N/A'),
          Divider(color: Colors.grey.shade200, height: 1),
          PatientInfoRow(
            label: 'Condition',
            value: patient.condition ?? 'N/A',
          ),
          Divider(color: Colors.grey.shade200, height: 1),
          PatientInfoRow(
            label: 'Medical History',
            value: patient.medicalHistory ?? 'N/A',
          ),
          Divider(color: Colors.grey.shade200, height: 1),
          PatientInfoRow(label: 'Blood Type', value: patient.bloodType ?? 'N/A'),
          Divider(color: Colors.grey.shade200, height: 1),
          PatientInfoRow(label: 'Allergies', value: patient.allergies ?? 'N/A'),
          Divider(color: Colors.grey.shade200, height: 1),
          PatientInfoRow(
            label: 'Last Visit',
            value: patient.lastVisit != null
                ? DateFormat('yyyy-MM-dd').format(patient.lastVisit!)
                : 'N/A',
          ),
        ],
      ),
    );
  }
}

// Activity Timeline Item
class ActivityTimelineItem extends StatelessWidget {
  final Activity activity;

  const ActivityTimelineItem({super.key, required this.activity});

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else {
      return DateFormat('MMM d, yyyy').format(timestamp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: activity.backgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(activity.icon, size: 20, color: activity.iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity.description,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 12, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      _formatTimestamp(activity.timestamp),
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Recent Activity Section
class RecentActivitySection extends StatelessWidget {
  const RecentActivitySection({super.key});

  @override
  Widget build(BuildContext context) {
    final activities = [
      Activity(
        type: ActivityType.medication,
        title: 'Medication taken',
        description: 'Lisinopril 10mg - Blood pressure medication',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Activity(
        type: ActivityType.vitals,
        title: 'Vitals recorded',
        description: 'Blood pressure: 120/80, Heart rate: 72 bpm',
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      Activity(
        type: ActivityType.alert,
        title: 'Alert generated',
        description: 'Heart rate spike detected - resolved',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Activity(
        type: ActivityType.followUp,
        title: 'Follow-up scheduled',
        description: 'Next appointment scheduled for Feb 15, 2026',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Activity',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          ...activities.map((activity) => ActivityTimelineItem(activity: activity)),
        ],
      ),
    );
  }
}
