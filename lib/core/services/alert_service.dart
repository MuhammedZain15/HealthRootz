import 'package:dio/dio.dart';

import '../models/alert_model.dart';
import '../network/api_client.dart';
import '../network/api_constants.dart';
import '../network/api_response.dart';

/// Handles all Alert CRUD endpoints.
class AlertService {
  final Dio _dio = ApiClient.instance.dio;

  // ─── Create Alert ──────────────────────────────────────────────────

  Future<ApiResponse<AlertModel>> createAlert(AlertModel alert) async {
    try {
      final response = await _dio.post(
        ApiConstants.alerts,
        data: alert.toJson(),
      );
      return ApiResponse(
        success: true,
        data: AlertModel.fromJson(response.data),
      );
    } on DioException catch (e) {
      return ApiResponse(success: false, message: _extractError(e));
    }
  }

  // ─── Get All Alerts ────────────────────────────────────────────────

  Future<ApiResponse<List<AlertModel>>> getAllAlerts() async {
    try {
      final response = await _dio.get(ApiConstants.alerts);
      final List data = response.data is List ? response.data : response.data['data'] ?? [];
      final alerts = data.map((e) => AlertModel.fromJson(e)).toList();
      return ApiResponse(success: true, data: alerts);
    } on DioException catch (e) {
      return ApiResponse(success: false, message: _extractError(e));
    }
  }

  // ─── Get Alert By ID ───────────────────────────────────────────────

  Future<ApiResponse<AlertModel>> getAlertById(String id) async {
    try {
      final response = await _dio.get(ApiConstants.alertById(id));
      return ApiResponse(
        success: true,
        data: AlertModel.fromJson(response.data),
      );
    } on DioException catch (e) {
      return ApiResponse(success: false, message: _extractError(e));
    }
  }

  // ─── Update Alert ──────────────────────────────────────────────────

  Future<ApiResponse<AlertModel>> updateAlert(
      String id, Map<String, dynamic> updates) async {
    try {
      final response = await _dio.put(
        ApiConstants.alertById(id),
        data: updates,
      );
      return ApiResponse(
        success: true,
        data: AlertModel.fromJson(response.data),
      );
    } on DioException catch (e) {
      return ApiResponse(success: false, message: _extractError(e));
    }
  }

  // ─── Delete Alert ──────────────────────────────────────────────────

  Future<ApiResponse<void>> deleteAlert(String id) async {
    try {
      await _dio.delete(ApiConstants.alertById(id));
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
