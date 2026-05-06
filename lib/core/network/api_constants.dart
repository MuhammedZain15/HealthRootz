/// API Constants - Auto-generated from Postman "Health App API" collection.
class ApiConstants {
  ApiConstants._();

  // ─── Base ──────────────────────────────────────────────────────────
  // Change this to your deployed server URL when going to production.
  static const String baseUrl = 'http://192.168.1.2:5000/api';

  // ─── Auth ──────────────────────────────────────────────────────────
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String profile = '/auth/profile';
  static const String forgotPassword = '/auth/forgot-password';
  static String resetPassword(String token) => '/auth/reset-password/$token';

  // ─── Patients ──────────────────────────────────────────────────────
  static const String patients = '/patients';
  static String patientById(String id) => '/patients/$id';
  static String patientDetails(String id) => '/patients/$id/details';

  // ─── Alerts ────────────────────────────────────────────────────────
  static const String alerts = '/alerts';
  static String alertById(String id) => '/alerts/$id';

  // ─── Appointments ──────────────────────────────────────────────────
  static const String appointments = '/appointments';
  static String appointmentById(String id) => '/appointments/$id';

  // ─── Reports ───────────────────────────────────────────────────────
  static const String reports = '/reports';
  static String reportById(String id) => '/reports/$id';

  // ─── Chat ──────────────────────────────────────────────────────────
  static const String chat = '/chat';
  static String chatMessages(String patientId) => '/chat/$patientId';
  static String markAsRead(String patientId) => '/chat/$patientId/read';

  // ─── Dashboard ─────────────────────────────────────────────────────
  static const String dashboardSummary = '/dashboard/summary';
}
