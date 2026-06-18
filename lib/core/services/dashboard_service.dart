import 'package:dio/dio.dart';

import '../models/dashboard_model.dart';
import '../network/api_client.dart';
import '../network/api_constants.dart';
import '../network/api_response.dart';

/// Handles Dashboard stats endpoint.
class DashboardService {
  final Dio _dio = ApiClient.instance.dio;

  Future<ApiResponse<DashboardSummary>> getStats() async {
    try {
      final response = await _dio.get(ApiConstants.dashboardSummary);
      final body = response.data;
      if (body is Map) {
        return ApiResponse(
          success: true,
          data: DashboardSummary.fromJson(Map<String, dynamic>.from(body)),
        );
      }
      return ApiResponse(
        success: false,
        message: 'Invalid dashboard response',
      );
    } on DioException catch (e) {
      return ApiResponse(success: false, message: _extractError(e));
    }
  }

  String _extractError(DioException e) {
    if (e.response?.data is Map) {
      return (e.response!.data as Map)['message']?.toString() ??
          e.message ??
          'Unknown error';
    }
    return e.message ?? 'Network error';
  }
}

// commit update
 