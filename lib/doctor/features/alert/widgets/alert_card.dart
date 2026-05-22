import 'package:flutter/material.dart';
import 'package:grad_project/app_colors.dart';
import 'package:grad_project/doctor/features/alert/model/alert_model.dart';
import 'package:grad_project/doctor/features/alert/models/doctor_alert_item.dart';
import 'package:grad_project/doctor/features/patients/patient_details_page.dart';
import 'package:grad_project/shared/widgets/custom_button.dart';
import 'package:intl/intl.dart';

class AlertCard extends StatelessWidget {
  final DoctorAlertItem alert;
  final bool isBusy;
  final VoidCallback? onMarkSolved;

  const AlertCard({
    super.key,
    required this.alert,
    this.isBusy = false,
    this.onMarkSolved,
  });

  Color _getBackgroundColor() {
    switch (alert.severity) {
      case AlertSeverity.critical:
        return const Color(0xFFFFF0F0); // Light Red
      case AlertSeverity.warning:
        return const Color(0xFFFFFBE6); // Light Yellow
      case AlertSeverity.resolved:
        return Colors.white;
    }
  }

  Color _getBorderColor() {
    switch (alert.severity) {
      case AlertSeverity.critical:
        return const Color(0xFFFFCCC7);
      case AlertSeverity.warning:
        return const Color(0xFFFFE58F);
      case AlertSeverity.resolved:
        return Colors.grey.shade300;
    }
  }

  Color _getBadgeColor() {
    switch (alert.severity) {
      case AlertSeverity.critical:
        return Colors.red;
      case AlertSeverity.warning:
        return Colors.orange;
      case AlertSeverity.resolved:
        return const Color(
          0xFF4A628A,
        ); // Using darkBlue for resolved badge background
    }
  }

  IconData _getIcon() {
    switch (alert.type) {
      case AlertType.heartRate:
        return Icons.favorite_border;
      case AlertType.bloodPressure:
        return Icons.show_chart;
      case AlertType.temperature:
        return Icons.thermostat;
      default:
        return Icons.warning_amber_rounded;
    }
  }

  Color _getIconColor() {
    switch (alert.severity) {
      case AlertSeverity.critical:
        return Colors.red;
      case AlertSeverity.warning:
        return Colors.orange;
      case AlertSeverity.resolved:
        return const Color(0xFF4A628A);
    }
  }

  Color _getIconBackgroundColor() {
    switch (alert.severity) {
      case AlertSeverity.critical:
        return Colors.red.withOpacity(0.1);
      case AlertSeverity.warning:
        return Colors.orange.withOpacity(0.1);
      case AlertSeverity.resolved:
        return const Color(0xFF4A628A).withOpacity(0.1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        border: Border.all(color: _getBorderColor()),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getIconBackgroundColor(),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_getIcon(), color: _getIconColor(), size: 20),
                ),
                const SizedBox(width: 12),

                // Name and details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            alert.patientName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getBadgeColor(),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              alert.severity.name.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            "Alert Type: ",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          Text(
                            alert.type == AlertType.heartRate
                                ? "Heart Rate"
                                : alert.type == AlertType.bloodPressure
                                ? "Blood Pressure"
                                : alert.type == AlertType.temperature
                                ? "Temperature"
                                : "General",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        alert.message,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('yyyy-MM-dd hh:mm a').format(alert.time),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Button Row
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: "View Patient",
                    filled: true,

                    color: AppColors.skyBlue,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PatientDetailsPage(
                                patientId: alert.patientId,
                                preview: alert.toPatientPreview(),
                              ),
                        ),
                      );
                    },
                  ),
                ),
                if (alert.severity != AlertSeverity.resolved) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: "Mark Solved",
                      filled: false,
                      color: AppColors.skyBlue,
                      onPressed: isBusy ? null : onMarkSolved,
                    ),

                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
