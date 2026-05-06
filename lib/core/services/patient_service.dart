import 'package:dio/dio.dart';

import '../models/patient_model.dart';
import '../network/api_client.dart';
import '../network/api_constants.dart';
import '../network/api_response.dart';

/// Handles all Patient CRUD endpoints.
class PatientService {
  final Dio _dio = ApiClient.instance.dio;

  // ─── Create Patient ────────────────────────────────────────────────

  Future<ApiResponse<PatientModel>> createPatient(PatientModel patient) async {
    try {
      final response = await _dio.post(
        ApiConstants.patients,
        data: patient.toJson(),
      );
      return ApiResponse(
        success: true,
        data: PatientModel.fromJson(response.data),
      );
    } on DioException catch (e) {
      return ApiResponse(success: false, message: _extractError(e));
    }
  }

  // ─── Get All Patients ──────────────────────────────────────────────

  Future<ApiResponse<List<PatientModel>>> getAllPatients() async {
    try {
      final response = await _dio.get(ApiConstants.patients);
      final List data = response.data is List ? response.data : response.data['data'] ?? [];
      final patients = data.map((e) => PatientModel.fromJson(e)).toList();
      return ApiResponse(success: true, data: patients);
    } on DioException catch (e) {
      return ApiResponse(success: false, message: _extractError(e));
    }
  }

  // ─── Get Patient By ID ─────────────────────────────────────────────

  Future<ApiResponse<PatientModel>> getPatientById(String id) async {
    try {
      final response = await _dio.get(ApiConstants.patientById(id));
      return ApiResponse(
        success: true,
        data: PatientModel.fromJson(response.data),
      );
    } on DioException catch (e) {
      return ApiResponse(success: false, message: _extractError(e));
    }
  }

  // ─── Get Patient Details ───────────────────────────────────────────

  Future<ApiResponse<Map<String, dynamic>>> getPatientDetails(
      String id) async {
    try {
      final response = await _dio.get(ApiConstants.patientDetails(id));
      return ApiResponse(success: true, data: response.data);
    } on DioException catch (e) {
      return ApiResponse(success: false, message: _extractError(e));
    }
  }

  // ─── Update Patient ────────────────────────────────────────────────

  Future<ApiResponse<PatientModel>> updatePatient(
      String id, Map<String, dynamic> updates) async {
    try {
      final response = await _dio.put(
        ApiConstants.patientById(id),
        data: updates,
      );
      return ApiResponse(
        success: true,
        data: PatientModel.fromJson(response.data),
      );
    } on DioException catch (e) {
      return ApiResponse(success: false, message: _extractError(e));
    }
  }

  // ─── Delete Patient ────────────────────────────────────────────────

  Future<ApiResponse<void>> deletePatient(String id) async {
    try {
      await _dio.delete(ApiConstants.patientById(id));
      return ApiResponse(success: true);
    } on DioException catch (e) {
      return ApiResponse(success: false, message: _extractError(e));
    }
  }

  // ─── Delete All Patients ───────────────────────────────────────────

  Future<ApiResponse<void>> deleteAllPatients() async {
    try {
      await _dio.delete(
        ApiConstants.patients,
        queryParameters: {'confirm': 'true'},
      );
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
