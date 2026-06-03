import 'package:grad_project/core/models/report_model.dart';

enum ExportFormat { pdf, csv }

/// Local UI model for report metrics — used by the PDF generator.
/// Populated from [ApiReport] via [fromApiReport].
class ReportData {
  final int heartRateAvg;
  final int heartRateMin;
  final int heartRateMax;
  final int heartRateAbnormal;
  final int emgAvg;
  final int emgMin;
  final int emgMax;
  final int emgAbnormal;
  final List<String> analysis;
  final String recommendation;
  final String doctorNotes;
  final String doctorName;
  final DateTime doctorNoteDate;

  const ReportData({
    required this.heartRateAvg,
    required this.heartRateMin,
    required this.heartRateMax,
    required this.heartRateAbnormal,
    required this.emgAvg,
    required this.emgMin,
    required this.emgMax,
    required this.emgAbnormal,
    required this.analysis,
    required this.recommendation,
    required this.doctorNotes,
    required this.doctorName,
    required this.doctorNoteDate,
  });

  /// Creates a [ReportData] from a server [ApiReport].
  ///
  /// Vitals fields are not returned by the current API, so we use
  /// placeholder zeros; the PDF will still render the notes & recommendations.
  factory ReportData.fromApiReport(ApiReport report) {
    // Parse AI recommendation lines as bullet-point analysis items
    final analysis = report.aiRecommendation.isNotEmpty
        ? report.aiRecommendation
            .split('.')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList()
        : <String>['No AI analysis available for this period.'];

    return ReportData(
      heartRateAvg: 0,
      heartRateMin: 0,
      heartRateMax: 0,
      heartRateAbnormal: 0,
      emgAvg: 0,
      emgMin: 0,
      emgMax: 0,
      emgAbnormal: 0,
      analysis: analysis,
      recommendation: report.aiRecommendation,
      doctorNotes: report.doctorNotes,
      doctorName: report.patientName ?? 'Doctor',
      doctorNoteDate: report.createdAt,
    );
  }
}
