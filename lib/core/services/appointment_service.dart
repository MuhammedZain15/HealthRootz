import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/appointment_model.dart';
import '../network/api_client.dart';
import '../network/api_constants.dart';
import '../network/api_response.dart';

/// Handles all Appointment CRUD endpoints.
class AppointmentService {
  final Dio _dio = ApiClient.instance.dio;

  Future<ApiResponse<AppointmentModel>> createAppointment({
    required String patientId,
    required String dateIso,
    required String reason,
  }) async {
    final requestBody = {
      'patientId': patientId,
      'date': dateIso,
      'reason': reason,
    };
    debugPrint('[Booking] POST ${ApiConstants.appointments} request body: $requestBody');

    try {
      final response = await _dio.post(
        ApiConstants.appointments,
        data: requestBody,
      );
      debugPrint(
        '[Booking] POST ${ApiConstants.appointments} raw response: ${response.data}',
      );
      debugPrint('[Booking] Booking saved successfully');
      return ApiResponse(
        success: true,
        data: AppointmentModel.fromJson(
          _unwrapMap(response.data) ?? <String, dynamic>{},
        ),
      );
    } on DioException catch (e) {
      final message = _extractError(e);
      debugPrint('[Booking] POST ${ApiConstants.appointments} error: $message');
      debugPrint('[Booking] Error response data: ${e.response?.data}');
      return ApiResponse(success: false, message: message);
    }
  }

  Future<ApiResponse<List<AppointmentModel>>> getAllAppointments() async {
    try {
      final response = await _dio.get(ApiConstants.appointments);
      final list = _unwrapList(response.data);
      final appointments = list
          .whereType<Map>()
          .map((e) => AppointmentModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      return ApiResponse(success: true, data: appointments);
    } on DioException catch (e) {
      return ApiResponse(success: false, message: _extractError(e));
    }
  }

  Future<ApiResponse<List<String>>> getAvailableSlots({
    required String date,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.appointmentSlots,
        queryParameters: {'date': date},
      );
      return ApiResponse(success: true, data: _parseSlots(response.data));
    } on DioException catch (e) {
      return ApiResponse(success: false, message: _extractError(e));
    }
  }

  Future<ApiResponse<AppointmentModel>> getAppointmentById(String id) async {
    try {
      final response = await _dio.get(ApiConstants.appointmentById(id));
      return ApiResponse(
        success: true,
        data: AppointmentModel.fromJson(
          _unwrapMap(response.data) ?? <String, dynamic>{},
        ),
      );
    } on DioException catch (e) {
      return ApiResponse(success: false, message: _extractError(e));
    }
  }

  Future<ApiResponse<AppointmentModel>> updateAppointment(
    String id,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await _dio.put(
        ApiConstants.appointmentById(id),
        data: updates,
      );
      return ApiResponse(
        success: true,
        data: AppointmentModel.fromJson(
          _unwrapMap(response.data) ?? <String, dynamic>{},
        ),
      );
    } on DioException catch (e) {
      return ApiResponse(success: false, message: _extractError(e));
    }
  }

  Future<ApiResponse<void>> deleteAppointment(String id) async {
    try {
      await _dio.delete(ApiConstants.appointmentById(id));
      return ApiResponse(success: true);
    } on DioException catch (e) {
      return ApiResponse(success: false, message: _extractError(e));
    }
  }

  List<String> _parseSlots(dynamic body) {
    dynamic raw = body;
    if (body is Map) {
      final map = Map<String, dynamic>.from(body);
      raw = map['data'] ?? map['slots'] ?? body;
      if (raw is Map) {
        raw = raw['slots'] ?? raw['availableSlots'] ?? raw;
      }
    }

    if (raw is List) {
      return raw.map((e) {
        if (e is String) return e;
        if (e is Map) {
          return (e['time'] ?? e['slot'] ?? e['label'])?.toString() ?? '';
        }
        return e.toString();
      }).where((s) => s.isNotEmpty).toList();
    }
    return [];
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

// commit update
 