/// Dashboard summary model — maps to GET /api/dashboard/summary.
class DashboardSummary {
  final DashboardStats? stats;
  final List<dynamic>? recentAlerts;
  final List<dynamic>? recentVitals;

  DashboardSummary({
    this.stats,
    this.recentAlerts,
    this.recentVitals,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return DashboardSummary(
      stats: data['stats'] != null
          ? DashboardStats.fromJson(data['stats'])
          : null,
      recentAlerts: data['recentAlerts'] as List<dynamic>?,
      recentVitals: data['recentVitals'] as List<dynamic>?,
    );
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
    return DashboardStats(
      totalPatients: json['totalPatients'] as int?,
      totalAlerts: json['totalAlerts'] as int?,
      totalAppointments: json['totalAppointments'] as int?,
      totalReports: json['totalReports'] as int?,
    );
  }
}
