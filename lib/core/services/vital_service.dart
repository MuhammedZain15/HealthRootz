import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/vital_model.dart';
import '../network/api_client.dart';
import '../network/api_constants.dart';
import '../network/api_response.dart';

/// Handles all Vitals CRUD endpoints.
class VitalService {
  final Dio _dio = ApiClient.instance.dio;

  Future<ApiResponse<List<VitalModel>>> getAllVitals() async {
    try {
      final response = await _dio.get(ApiConstants.vitals);
      debugPrint(
        '[VitalService] GET ${ApiConstants.vitals} -> ${response.statusCode}',
      );
      debugPrint('[VitalService] raw body: ${response.data}');
      final list = _unwrapList(response.data);
      debugPrint('[VitalService] unwrapped list length=${list.length}');
      final vitals = list
          .whereType<Map>()
          .map((e) => VitalModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      if (vitals.isNotEmpty) {
        final f = vitals.first;
        debugPrint(
          '[VitalService] parsed[0]: hr=${f.heartRate} spo2=${f.oxygenLevel} '
          'temp=${f.temperature} bp=${f.bloodPressure} pid=${f.patientId} '
          'createdAt=${f.createdAt}',
        );
      }
      return ApiResponse(success: true, data: vitals);
    } on DioException catch (e) {
      debugPrint('[VitalService] ERROR: ${_extractError(e)}');
      return ApiResponse(success: false, message: _extractError(e));
    }
  }

  Future<ApiResponse<VitalModel>> createVital(VitalModel vital) async {
    try {
      final response = await _dio.post(
        ApiConstants.vitals,
        data: vital.toJson(),
      );
      return ApiResponse(
        success: true,
        data: VitalModel.fromJson(
          _unwrapMap(response.data) ?? <String, dynamic>{},
        ),
      );
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
