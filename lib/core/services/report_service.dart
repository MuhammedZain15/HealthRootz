import 'package:dio/dio.dart';

import '../models/report_model.dart';
import '../network/api_client.dart';
import '../network/api_constants.dart';
import '../network/api_response.dart';

/// Handles all Report CRUD endpoints.
class ReportService {
  final Dio _dio = ApiClient.instance.dio;

  // ─── Create Report ─────────────────────────────────────────────────

  Future<ApiResponse<ReportModel>> createReport(ReportModel report) async {
    try {
      final response = await _dio.post(
        ApiConstants.reports,
        data: report.toJson(),
      );
      return ApiResponse(
        success: true,
        data: ReportModel.fromJson(response.data),
      );
    } on DioException catch (e) {
      return ApiResponse(success: false, message: _extractError(e));
    }
  }

  // ─── Get All Reports ───────────────────────────────────────────────

  Future<ApiResponse<List<ReportModel>>> getAllReports() async {
    try {
      final response = await _dio.get(ApiConstants.reports);
      final List data = response.data is List ? response.data : response.data['data'] ?? [];
      final reports = data.map((e) => ReportModel.fromJson(e)).toList();
      return ApiResponse(success: true, data: reports);
    } on DioException catch (e) {
      return ApiResponse(success: false, message: _extractError(e));
    }
  }

  // ─── Get Report By ID ──────────────────────────────────────────────

  Future<ApiResponse<ReportModel>> getReportById(String id) async {
    try {
      final response = await _dio.get(ApiConstants.reportById(id));
      return ApiResponse(
        success: true,
        data: ReportModel.fromJson(response.data),
      );
    } on DioException catch (e) {
      return ApiResponse(success: false, message: _extractError(e));
    }
  }

  // ─── Update Report ─────────────────────────────────────────────────

  Future<ApiResponse<ReportModel>> updateReport(
      String id, Map<String, dynamic> updates) async {
    try {
      final response = await _dio.put(
        ApiConstants.reportById(id),
        data: updates,
      );
      return ApiResponse(
        success: true,
        data: ReportModel.fromJson(response.data),
      );
    } on DioException catch (e) {
      return ApiResponse(success: false, message: _extractError(e));
    }
  }

  // ─── Delete Report ─────────────────────────────────────────────────

  Future<ApiResponse<void>> deleteReport(String id) async {
    try {
      await _dio.delete(ApiConstants.reportById(id));
      return ApiResponse(success: true);
    } on DioException catch (e) {
      return ApiResponse(success: false, message: _extractError(e));
    }
  }

  // ─── Helpers ───────────────────────────────────────────────────────

  String _extractError(DioException e) {
    if (e.response?.data is Map) {
      return (e.response!.data as Map)['message']?.toString() ??
          e.message ??
          'Unknown error';
    }
    return e.message ?? 'Network error';
  }
}
