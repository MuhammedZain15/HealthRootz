import 'package:dio/dio.dart';
import 'package:grad_project/core/models/report_model.dart';
import 'package:grad_project/core/network/api_client.dart';
import 'package:grad_project/core/network/api_constants.dart';

/// Service for the Reports endpoints:
///   GET  /api/reports/         – fetch all reports for the logged-in user
///   POST /api/reports/         – doctor generates a new report
///   GET  /api/reports/export   – export reports (returns raw data)
class ReportService {
  ReportService._();
  static final ReportService instance = ReportService._();

  Dio get _dio => ApiClient.instance.dio;

  // ────────────────────────────────────────────────────────────────────
  // GET /api/reports/
  // ────────────────────────────────────────────────────────────────────
  /// Returns all reports visible to the currently authenticated user.
  /// Doctors see all reports they generated; patients see their own.
  Future<List<ApiReport>> getReports() async {
    try {
      final response = await _dio.get(ApiConstants.reports);
      final body = response.data;

      // Support both { data: [...] } and plain list shapes
      final List<dynamic> raw;
      if (body is List) {
        raw = body;
      } else if (body is Map && body['data'] is List) {
        raw = body['data'] as List;
      } else {
        raw = [];
      }

      return raw
          .map((e) => ApiReport.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ────────────────────────────────────────────────────────────────────
  // POST /api/reports/
  // ────────────────────────────────────────────────────────────────────
  /// Doctor calls this to generate and persist a new report.
  Future<ApiReport> generateReport({
    required String patientId,
    required String title,
    required DateTime startDate,
    required DateTime endDate,
    required String doctorNotes,
    String aiRecommendation = '',
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.reports,
        data: {
          'patientId': patientId,
          'title': title,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
          'doctorNotes': doctorNotes,
          'aiRecommendation': aiRecommendation,
        },
      );

      final body = response.data;
      final Map<String, dynamic> reportJson =
          body is Map && body['data'] is Map
              ? body['data'] as Map<String, dynamic>
              : body as Map<String, dynamic>;

      return ApiReport.fromJson(reportJson);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ────────────────────────────────────────────────────────────────────
  // GET /api/reports/export
  // ────────────────────────────────────────────────────────────────────
  /// Returns raw response data suitable for export (PDF bytes or JSON).
  Future<dynamic> exportReports() async {
    try {
      final response = await _dio.get(
        ApiConstants.reportsExport,
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ────────────────────────────────────────────────────────────────────
  // Error helper
  // ────────────────────────────────────────────────────────────────────
  Exception _handleError(DioException e) {
    final message = e.response?.data?['message']?.toString() ??
        e.response?.data?.toString() ??
        e.message ??
        'An unexpected error occurred';
    return Exception(message);
  }
}
