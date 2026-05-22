/// Dashboard stats — maps to GET /api/dashboard/stats.
class DashboardSummary {
  final DashboardStats? stats;

  DashboardSummary({this.stats});

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : Map<String, dynamic>.from(json);

    DashboardStats? stats;
    if (data['stats'] is Map) {
      stats = DashboardStats.fromJson(
        Map<String, dynamic>.from(data['stats'] as Map),
      );
    } else if (data.containsKey('totalPatients') ||
        data.containsKey('totalAlerts')) {
      stats = DashboardStats.fromJson(data);
    }

    return DashboardSummary(stats: stats);
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
      totalPatients: parseInt(json['totalPatients']),
      totalAlerts: parseInt(json['totalAlerts']),
      totalAppointments: parseInt(json['totalAppointments']),
      totalReports: parseInt(json['totalReports']),
    );
  }
}
