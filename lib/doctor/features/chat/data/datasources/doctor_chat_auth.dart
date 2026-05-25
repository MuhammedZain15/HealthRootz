// lib/doctor/features/chat/data/datasources/doctor_chat_auth.dart
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DoctorChatAuthException implements Exception {
  DoctorChatAuthException(this.message);
  final String message;
}

class DoctorChatAuth {
  DoctorChatAuth._();

  /// Same key used by [TokenStorage] after login.
  static const String tokenKey = 'auth_token';
  static const String roleKey = 'user_role';
  static const String expectedRole = 'doctor';

  static Future<String> requireToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(tokenKey);
    final role = prefs.getString(roleKey);

    if (token == null || token.isEmpty) {
      throw DoctorChatAuthException('Doctor auth token is missing.');
    }
    if (role != expectedRole) {
      throw DoctorChatAuthException(
        'Doctor auth token is invalid. Expected role "$expectedRole" but found "$role".',
      );
    }
    return token;
  }

  static DioException toDioException(DoctorChatAuthException error) {
    return DioException(
      requestOptions: RequestOptions(path: '/messages'),
      message: error.message,
      type: DioExceptionType.cancel,
    );
  }
}
