import 'package:flutter/material.dart';

enum ActivityType {
  medication,
  vitals,
  alert,
  followUp,
}

class Activity {
  final ActivityType type;
  final String title;
  final String description;
  final DateTime timestamp;

  Activity({
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
  });

  IconData get icon {
    switch (type) {
      case ActivityType.medication:
        return Icons.water_drop;
      case ActivityType.vitals:
        return Icons.favorite;
      case ActivityType.alert:
        return Icons.warning;
      case ActivityType.followUp:
        return Icons.calendar_today;
    }
  }

  Color get iconColor {
    switch (type) {
      case ActivityType.medication:
        return Colors.blue;
      case ActivityType.vitals:
        return Colors.red;
      case ActivityType.alert:
        return Colors.orange;
      case ActivityType.followUp:
        return Colors.blue;
    }
  }

  Color get backgroundColor {
    switch (type) {
      case ActivityType.medication:
        return Colors.blue.shade50;
      case ActivityType.vitals:
        return Colors.red.shade50;
      case ActivityType.alert:
        return Colors.orange.shade50;
      case ActivityType.followUp:
        return Colors.blue.shade50;
    }
  }
}
