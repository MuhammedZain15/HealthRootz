import 'package:dio/dio.dart';

import '../models/dashboard_model.dart';
import '../network/api_client.dart';
import '../network/api_constants.dart';
import '../network/api_response.dart';

/// Handles Dashboard summary endpoint.
class DashboardService {
  final Dio _dio = ApiClient.instance.dio;

  // ─── Get Summary ───────────────────────────────────────────────────

  Future<ApiResponse<DashboardSummary>> getSummary() async {
    try {
      final response = await _dio.get(ApiConstants.dashboardSummary);
      return ApiResponse(
        success: true,
        data: DashboardSummary.fromJson(response.data),
      );
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
