import 'package:dio/dio.dart';

import '../network/api_client.dart';
import '../network/api_constants.dart';
import '../network/api_response.dart';

class DeviceService {
  final Dio _dio = ApiClient.instance.dio;

  DeviceService._();
  static final DeviceService instance = DeviceService._();

  /// Starts a device by id. Optional payload can include patientId and code.
  Future<ApiResponse<void>> startDevice(
    String deviceId, {
    String? patientId,
    String? code,
  }) async {
    try {
      final payload = <String, dynamic>{};
      if (patientId != null) payload['patientId'] = patientId;
      if (code != null) payload['code'] = code;

      await _dio.post(ApiConstants.startDevice(deviceId), data: payload);
      return ApiResponse(success: true);
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? (e.response!.data['message']?.toString() ?? e.message)
          : e.message ?? 'Network error';
      return ApiResponse(success: false, message: message);
    }
  }
}

// commit update
 