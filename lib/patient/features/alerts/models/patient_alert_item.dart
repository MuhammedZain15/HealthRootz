import 'package:flutter/material.dart';

/// UI model for patient-side alert cards.
class PatientAlertItem {
  final String id;
  final String title;
  final String message;
  final String dateTimeLabel;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final bool isResolved;

  const PatientAlertItem({
    required this.id,
    required this.title,
    required this.message,
    required this.dateTimeLabel,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    this.isResolved = false,
  });
}

// commit update
 