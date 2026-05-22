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
  static const String patientMe = '/patients/me';
  static String patientById(String id) => '/patients/$id';
  static String addNote(String id) => '/patients/$id/notes';

  // ─── Alerts ────────────────────────────────────────────────────────
  static const String alerts = '/alerts';
  static String alertById(String id) => '/alerts/$id';

  // ─── Appointments ──────────────────────────────────────────────────
  static const String appointments = '/appointments';
  static const String appointmentSlots = '/appointments/slots';
  static String appointmentById(String id) => '/appointments/$id';

  // ─── Reports ───────────────────────────────────────────────────────
  static const String reports = '/reports';
  static String reportById(String id) => '/reports/$id';

  // ─── Chat ──────────────────────────────────────────────────────────
  static const String chat = '/messages';
  static String chatMessages(String patientId) => '/messages/$patientId';
  static String markAsRead(String patientId) => '/messages/$patientId/read';

  // ─── Dashboard ─────────────────────────────────────────────────────
  static const String dashboardSummary = '/dashboard/stats';
}
