import 'package:dio/dio.dart';

import '../models/appointment_model.dart';
import '../network/api_client.dart';
import '../network/api_constants.dart';
import '../network/api_response.dart';

/// Handles all Appointment CRUD endpoints.
class AppointmentService {
  final Dio _dio = ApiClient.instance.dio;

  // ─── Create Appointment ────────────────────────────────────────────

  Future<ApiResponse<AppointmentModel>> createAppointment(
      AppointmentModel appointment) async {
    try {
      final response = await _dio.post(
        ApiConstants.appointments,
        data: appointment.toJson(),
      );
      return ApiResponse(
        success: true,
        data: AppointmentModel.fromJson(response.data),
      );
    } on DioException catch (e) {
      return ApiResponse(success: false, message: _extractError(e));
    }
  }

  // ─── Get All Appointments ──────────────────────────────────────────

  Future<ApiResponse<List<AppointmentModel>>> getAllAppointments() async {
    try {
      final response = await _dio.get(ApiConstants.appointments);
      final List data = response.data is List ? response.data : response.data['data'] ?? [];
      final appointments =
          data.map((e) => AppointmentModel.fromJson(e)).toList();
      return ApiResponse(success: true, data: appointments);
    } on DioException catch (e) {
      return ApiResponse(success: false, message: _extractError(e));
    }
  }

  // ─── Get Appointment By ID ─────────────────────────────────────────

  Future<ApiResponse<AppointmentModel>> getAppointmentById(String id) async {
    try {
      final response = await _dio.get(ApiConstants.appointmentById(id));
      return ApiResponse(
        success: true,
        data: AppointmentModel.fromJson(response.data),
      );
    } on DioException catch (e) {
      return ApiResponse(success: false, message: _extractError(e));
    }
  }

  // ─── Update Appointment ────────────────────────────────────────────

  Future<ApiResponse<AppointmentModel>> updateAppointment(
      String id, Map<String, dynamic> updates) async {
    try {
      final response = await _dio.put(
        ApiConstants.appointmentById(id),
        data: updates,
      );
      return ApiResponse(
        success: true,
        data: AppointmentModel.fromJson(response.data),
      );
    } on DioException catch (e) {
      return ApiResponse(success: false, message: _extractError(e));
    }
  }

  // ─── Delete Appointment ────────────────────────────────────────────

  Future<ApiResponse<void>> deleteAppointment(String id) async {
    try {
      await _dio.delete(ApiConstants.appointmentById(id));
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
