/// Shared model representing a report returned by the HealthRootz API.
///
/// Maps to the JSON shape produced by:
///   GET  /api/reports/
///   POST /api/reports/
class ApiReport {
  final String id;
  final String? patientId;
  final String? patientName;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final String doctorNotes;
  final String aiRecommendation;
  final DateTime createdAt;

  const ApiReport({
    required this.id,
    this.patientId,
    this.patientName,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.doctorNotes,
    required this.aiRecommendation,
    required this.createdAt,
  });

  factory ApiReport.fromJson(Map<String, dynamic> json) {
    // The backend may nest patient info inside a `patient` sub-object
    final patient = json['patient'] as Map<String, dynamic>?;

    return ApiReport(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      patientId: patient?['_id']?.toString() ??
          patient?['id']?.toString() ??
          json['patientId']?.toString(),
      patientName:
          patient?['name']?.toString() ?? json['patientName']?.toString(),
      title: json['title']?.toString() ?? 'Health Report',
      startDate: _parseDate(json['startDate']),
      endDate: _parseDate(json['endDate']),
      doctorNotes: json['doctorNotes']?.toString() ?? '',
      aiRecommendation: json['aiRecommendation']?.toString() ?? '',
      createdAt: _parseDate(json['createdAt'] ?? json['startDate']),
    );
  }

  Map<String, dynamic> toJson() => {
        'patientId': patientId,
        'title': title,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'doctorNotes': doctorNotes,
        'aiRecommendation': aiRecommendation,
      };

  static DateTime _parseDate(dynamic raw) {
    if (raw == null) return DateTime.now();
    if (raw is DateTime) return raw;
    try {
      return DateTime.parse(raw.toString());
    } catch (_) {
      return DateTime.now();
    }
  }
}

// commit update
 