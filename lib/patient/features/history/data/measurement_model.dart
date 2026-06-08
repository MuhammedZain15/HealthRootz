import 'package:flutter/material.dart';

enum MeasurementType { bloodOxygen, heartRate, emg }

class MeasurementPoint {
  final DateTime time;
  final double value;
  const MeasurementPoint(this.time, this.value);
}

class MeasurementRecord {
  final MeasurementType type;
  final String unit;
  final DateTime dateTime;
  final String status;
  final String recommendation;
  final List<MeasurementPoint> dataPoints;
  final String duration;

  const MeasurementRecord({
    required this.type,
    required this.unit,
    required this.dateTime,
    required this.status,
    required this.recommendation,
    this.dataPoints = const [],
    this.duration = "5 minutes",
  });

  String get title {
    switch (type) {
      case MeasurementType.bloodOxygen:
        return "Blood Oxygen";
      case MeasurementType.heartRate:
        return "Heart Rate";
      case MeasurementType.emg:
        return "EMG Activity";
    }
  }

  double get currentValue => dataPoints.isNotEmpty ? dataPoints.last.value : 0;

  double get averageValue {
    if (dataPoints.isEmpty) return 0;
    return dataPoints.map((e) => e.value).reduce((a, b) => a + b) /
        dataPoints.length;
  }

  double get maxValue {
    if (dataPoints.isEmpty) return 0;
    return dataPoints.map((e) => e.value).reduce((a, b) => a > b ? a : b);
  }

  double get minValue {
    if (dataPoints.isEmpty) return 0;
    return dataPoints.map((e) => e.value).reduce((a, b) => a < b ? a : b);
  }

  Color get themeColor {
    switch (type) {
      case MeasurementType.bloodOxygen:
        return const Color(0xFF22C55E); // green
      case MeasurementType.heartRate:
        return const Color(0xFFEF4444); // red
      case MeasurementType.emg:
        return const Color(0xFF3B82F6); // blue
    }
  }

  IconData get icon {
    switch (type) {
      case MeasurementType.bloodOxygen:
        return Icons.bubble_chart;
      case MeasurementType.heartRate:
        return Icons.favorite;
      case MeasurementType.emg:
        return Icons.waves;
    }
  }
}

class MeasurementStore {
  static final ValueNotifier<List<MeasurementRecord>>
  records = ValueNotifier<List<MeasurementRecord>>([
    MeasurementRecord(
      type: MeasurementType.heartRate,
      unit: "BPM",
      dateTime: DateTime(2026, 2, 4, 14, 30),
      status: "Normal",
      recommendation:
      "Your heart rate looks stable. Keep a balanced routine and stay hydrated.",
      dataPoints: [
        MeasurementPoint(DateTime(2026, 2, 4, 14, 25), 72),
        MeasurementPoint(DateTime(2026, 2, 4, 14, 26), 75),
        MeasurementPoint(DateTime(2026, 2, 4, 14, 27), 78),
        MeasurementPoint(DateTime(2026, 2, 4, 14, 28), 80),
        MeasurementPoint(DateTime(2026, 2, 4, 14, 29), 82),
        MeasurementPoint(DateTime(2026, 2, 4, 14, 30), 78),
      ],
    ),
    MeasurementRecord(
      type: MeasurementType.emg,
      unit: "µV",
      dateTime: DateTime(2026, 2, 4, 11, 15),
      status: "Normal",
      recommendation: "EMG activity is within normal range for resting muscle.",
      dataPoints: [
        MeasurementPoint(DateTime(2026, 2, 4, 11, 10), 80),
        MeasurementPoint(DateTime(2026, 2, 4, 11, 11), 85),
        MeasurementPoint(DateTime(2026, 2, 4, 11, 12), 82),
        MeasurementPoint(DateTime(2026, 2, 4, 11, 13), 88),
        MeasurementPoint(DateTime(2026, 2, 4, 11, 14), 84),
        MeasurementPoint(DateTime(2026, 2, 4, 11, 15), 85),
      ],
    ),
    MeasurementRecord(
      type: MeasurementType.bloodOxygen,
      unit: "%",
      dateTime: DateTime(2026, 1, 30, 14, 38),
      status: "Normal",
      recommendation:
      "Your blood oxygen level is healthy. Continue maintaining good respiratory health.",
      dataPoints: [
        MeasurementPoint(DateTime(2026, 1, 30, 14, 33), 97),
        MeasurementPoint(DateTime(2026, 1, 30, 14, 34), 98),
        MeasurementPoint(DateTime(2026, 1, 30, 14, 35), 98),
        MeasurementPoint(DateTime(2026, 1, 30, 14, 36), 99),
        MeasurementPoint(DateTime(2026, 1, 30, 14, 37), 98),
        MeasurementPoint(DateTime(2026, 1, 30, 14, 38), 98),
      ],
    ),
  ]);

  static void add(MeasurementRecord record) {
    final list = List<MeasurementRecord>.from(records.value);
    list.insert(0, record);
    records.value = list;
  }
}