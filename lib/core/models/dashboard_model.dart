import 'alert_model.dart';

/// Dashboard stats — maps to GET /api/dashboard/stats.
class DashboardSummary {
  final DashboardStats? stats;
  final List<AlertModel>? recentAlerts;

  DashboardSummary({this.stats, this.recentAlerts});

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : Map<String, dynamic>.from(json);

    DashboardStats? stats;
    if (data['stats'] is Map) {
      stats = DashboardStats.fromJson(
        Map<String, dynamic>.from(data['stats'] as Map),
      );
    } else {
      stats = DashboardStats.fromJson(data);
    }

    List<AlertModel>? recentAlerts;
    if (data['recentAlerts'] is List) {
      recentAlerts = (data['recentAlerts'] as List)
          .map((e) => AlertModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }

    return DashboardSummary(stats: stats, recentAlerts: recentAlerts);
  }
}

class DashboardStats {
  final int? totalPatients;
  final int? totalAlerts;
  final int? totalAppointments;
  final int? totalReports;

  DashboardStats({
    this.totalPatients,
    this.totalAlerts,
    this.totalAppointments,
    this.totalReports,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      return int.tryParse(value.toString());
    }

    return DashboardStats(
      totalPatients: parseInt(json['totalPatients']) ?? parseInt(json['patients']),
      totalAlerts: parseInt(json['totalAlerts']) ?? parseInt(json['activeAlerts']),
      totalAppointments: parseInt(json['totalAppointments']) ?? parseInt(json['pendingAppointments']),
      totalReports: parseInt(json['totalReports']) ?? parseInt(json['criticalCases']),
    );
  }
}
