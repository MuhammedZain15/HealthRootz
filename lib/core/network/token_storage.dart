import 'package:shared_preferences/shared_preferences.dart';

/// Handles secure storage of the JWT authentication token.
class TokenStorage {
  TokenStorage._();

  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _roleKey = 'user_role';

  static String _assignedDoctorKey(String patientId) =>
      'assigned_doctor_id_$patientId';

  // ─── Token ─────────────────────────────────────────────────────────

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // ─── User ID ───────────────────────────────────────────────────────

  static Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  // ─── Role ──────────────────────────────────────────────────────────

  static Future<void> saveRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roleKey, role);
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  // ─── Assigned doctor (per patient, for Firestore chat sync) ───────

  static Future<void> saveAssignedDoctorId(
    String patientId,
    String doctorId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_assignedDoctorKey(patientId), doctorId);
  }

  static Future<String?> getAssignedDoctorId(String patientId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_assignedDoctorKey(patientId));
  }

  static Future<void> removeAssignedDoctorId(String patientId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_assignedDoctorKey(patientId));
  }

  // ─── Clear All ─────────────────────────────────────────────────────

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_roleKey);
  }
}
