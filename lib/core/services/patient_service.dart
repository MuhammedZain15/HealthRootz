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
        data: PatientModel.fromJson(
          _unwrapMap(response.data) ?? <String, dynamic>{},
        ),
      );
    } on DioException catch (e) {
      return ApiResponse(success: false, message: _extractError(e));
    }
  }

  // ─── Get All Patients ──────────────────────────────────────────────

  Future<ApiResponse<List<PatientModel>>> getAllPatients() async {
    try {
      final response = await _dio.get(ApiConstants.patients);
      final list = _unwrapList(response.data);
      final patients = list
          .whereType<Map>()
          .map((e) => PatientModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
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
        data: PatientModel.fromJson(
          _unwrapMap(response.data) ?? <String, dynamic>{},
        ),
      );
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
        data: PatientModel.fromJson(
          _unwrapMap(response.data) ?? <String, dynamic>{},
        ),
      );
    } on DioException catch (e) {
      return ApiResponse(success: false, message: _extractError(e));
    }
  }

  // ─── Delete Patient ────────────────────────────────────────────────

/*  Future<ApiResponse<void>> deletePatient(String id) async {
    try {
      await _dio.delete(ApiConstants.patientById(id));
      return ApiResponse(success: true);
    } on DioException catch (e) {
      return ApiResponse(success: false, message: _extractError(e));
    }
  }*/

  // ─── Get Current Patient Profile ───────────────────────────────────

  Future<ApiResponse<PatientModel>> getMe() async {
    try {
      final response = await _dio.get(ApiConstants.patientMe);
      return ApiResponse(
        success: true,
        data: PatientModel.fromJson(
          _unwrapMap(response.data) ?? <String, dynamic>{},
        ),
      );
    } on DioException catch (e) {
      return ApiResponse(success: false, message: _extractError(e));
    }
  }

  // ─── Add Doctor Note ────────────────────────────────────────────────

  Future<ApiResponse<void>> addDoctorNote(String id, String note) async {
    try {
      await _dio.post(
        ApiConstants.addNote(id),
        data: {'text': note},
      );
      return ApiResponse(success: true);
    } on DioException catch (e) {
      return ApiResponse(success: false, message: _extractError(e));
    }
  }

  // ─── Delete All Patients ───────────────────────────────────────────

  /*Future<ApiResponse<void>> deleteAllPatients() async {
    try {
      await _dio.delete(
        ApiConstants.patients,
        queryParameters: {'confirm': 'true'},
      );
      return ApiResponse(success: true);
    } on DioException catch (e) {
      return ApiResponse(success: false, message: _extractError(e));
    }
  }*/

  // ─── Helpers ───────────────────────────────────────────────────────

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
