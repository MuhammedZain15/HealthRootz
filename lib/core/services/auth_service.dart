import 'package:dio/dio.dart';

import '../models/forgot_password_result.dart';
import '../models/user_model.dart';
import '../network/api_client.dart';
import '../network/api_constants.dart';
import '../network/api_response.dart';
import '../network/token_storage.dart';

/// Handles Register, Login, Profile, Forgot/Reset Password.
class AuthService {
  final Dio _dio = ApiClient.instance.dio;

  // ─── Register ──────────────────────────────────────────────────────

  Future<ApiResponse<UserModel>> register({
    required String name,
    required String email,
    required String password,
    required String role, // "doctor" or "patient"
    String? phone,
    String? address,
    String? specialty,
    String? licenseNumber,
    int? age,
    String? gender,
    String? medicalHistory,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'role': role,
          'phone': ?phone,
          'address': ?address,
          'specialty': ?specialty,
          'licenseNumber': ?licenseNumber,
          'age': ?age,
          'gender': ?gender,
          'medicalHistory': ?medicalHistory,
        },
      );

      final user = UserModel.fromJson(response.data);

      // Persist token & user info
      if (user.token != null) await TokenStorage.saveToken(user.token!);
      if (user.id != null) await TokenStorage.saveUserId(user.id!);
      if (user.role != null) await TokenStorage.saveRole(user.role!);

      return ApiResponse(success: true, data: user);
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: _extractError(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  // ─── Login ─────────────────────────────────────────────────────────

  Future<ApiResponse<UserModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      final user = UserModel.fromJson(response.data);

      // Persist token & user info
      if (user.token != null) await TokenStorage.saveToken(user.token!);
      if (user.id != null) await TokenStorage.saveUserId(user.id!);
      if (user.role != null) await TokenStorage.saveRole(user.role!);

      return ApiResponse(success: true, data: user);
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: _extractError(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  // ─── Profile ───────────────────────────────────────────────────────

  Future<ApiResponse<UserModel>> getProfile() async {
    try {
      final response = await _dio.get(ApiConstants.profile);
      final user = UserModel.fromJson(response.data);
      return ApiResponse(success: true, data: user);
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: _extractError(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  // ─── Update Profile ────────────────────────────────────────────────
  
  Future<ApiResponse<UserModel>> updateProfile(Map<String, dynamic> updates) async {
    try {
      final response = await _dio.put(
        ApiConstants.profile,
        data: updates,
      );
      final user = UserModel.fromJson(response.data);
      return ApiResponse(success: true, data: user);
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: _extractError(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  // ─── Forgot Password ──────────────────────────────────────────────

  Future<ApiResponse<ForgotPasswordResult>> forgotPassword({
    required String email,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.forgotPassword,
        data: {'email': email},
      );
      return ApiResponse(
        success: true,
        data: ForgotPasswordResult.fromResponse(response.data),
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: _extractError(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  // ─── Reset Password ───────────────────────────────────────────────

  Future<ApiResponse<String>> resetPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.put(
        ApiConstants.resetPassword(resetToken),
        data: {'password': newPassword},
      );
      final body = response.data;
      final message = body is Map
          ? (body['message'] ??
                  (body['data'] is Map
                      ? (body['data'] as Map)['message']
                      : null) ??
                  'Password reset successfully')
              .toString()
          : 'Password reset successfully';
      return ApiResponse(success: true, data: message);
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: _extractError(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  // ─── Logout (local) ───────────────────────────────────────────────

  Future<void> logout() async {
    await TokenStorage.clearAll();
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

// commit update
 