import 'package:dio/dio.dart';

import '../models/alert_model.dart';
import '../network/api_client.dart';
import '../network/api_constants.dart';
import '../network/api_response.dart';

/// Handles Alerts CRUD — GET/POST /api/alerts, PUT/DELETE /api/alerts/:id.
class AlertService {
  final Dio _dio = ApiClient.instance.dio;

  Future<ApiResponse<List<AlertModel>>> getAllAlerts() async {
    try {
      final response = await _dio.get(ApiConstants.alerts);
      final list = _unwrapList(response.data);
      final alerts = list
          .whereType<Map>()
          .map((e) => AlertModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      return ApiResponse(success: true, data: alerts);
    } on DioException catch (e) {
      return ApiResponse(success: false, message: _extractError(e));
    }
  }

  Future<ApiResponse<AlertModel>> createAlert({
    required String patientId,
    required String message,
    required String type,
    String? description,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.alerts,
        data: {
          'patientId': patientId,
          'message': message,
          'type': type,
          if (description != null) 'description': description,
        },
      );
      return ApiResponse(
        success: true,
        data: AlertModel.fromJson(
          _unwrapMap(response.data) ?? <String, dynamic>{},
        ),
      );
    } on DioException catch (e) {
      return ApiResponse(success: false, message: _extractError(e));
    }
  }

  Future<ApiResponse<AlertModel>> updateAlert(
    String id,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await _dio.put(
        ApiConstants.alertById(id),
        data: updates,
      );
      return ApiResponse(
        success: true,
        data: AlertModel.fromJson(
          _unwrapMap(response.data) ?? <String, dynamic>{},
        ),
      );
    } on DioException catch (e) {
      return ApiResponse(success: false, message: _extractError(e));
    }
  }

  Future<ApiResponse<void>> deleteAlert(String id) async {
    try {
      await _dio.delete(ApiConstants.alertById(id));
      return ApiResponse(success: true);
    } on DioException catch (e) {
      return ApiResponse(success: false, message: _extractError(e));
    }
  }

  Map<String, dynamic>? _unwrapMap(dynamic body) {
    if (body is Map<String, dynamic>) {
      if (body['data'] is Map<String, dynamic>) {
        return body['data'] as Map<String, dynamic>;
      }
      return body;
    }
    if (body is Map) {
      final map = Map<String, dynamic>.from(body);
      if (map['data'] is Map) {
        return Map<String, dynamic>.from(map['data'] as Map);
      }
      return map;
    }
    return null;
  }

  List<dynamic> _unwrapList(dynamic body) {
    if (body is List) return body;
    if (body is Map) {
      final map = Map<String, dynamic>.from(body);
      if (map['data'] is List) return map['data'] as List;
    }
    return [];
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
