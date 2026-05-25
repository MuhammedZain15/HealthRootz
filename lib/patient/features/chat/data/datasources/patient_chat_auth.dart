// lib/patient/features/chat/data/datasources/patient_chat_auth.dart
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PatientChatAuthException implements Exception {
  PatientChatAuthException(this.message);
  final String message;
}

class PatientChatAuth {
  PatientChatAuth._();

  /// Same key used by [TokenStorage] after login.
  static const String tokenKey = 'auth_token';
  static const String roleKey = 'user_role';
  static const String expectedRole = 'patient';

  static Future<String> requireToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(tokenKey);
    final role = prefs.getString(roleKey);

    if (token == null || token.isEmpty) {
      throw PatientChatAuthException('Patient auth token is missing.');
    }
    if (role != expectedRole) {
      throw PatientChatAuthException(
        'Patient auth token is invalid. Expected role "$expectedRole" but found "$role".',
      );
    }
    return token;
  }

  static DioException toDioException(PatientChatAuthException error) {
    return DioException(
      requestOptions: RequestOptions(path: '/messages'),
      message: error.message,
      type: DioExceptionType.cancel,
    );
  }
}
