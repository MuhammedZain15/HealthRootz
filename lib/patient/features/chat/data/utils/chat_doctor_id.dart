// lib/patient/features/chat/data/utils/chat_doctor_id.dart

/// Legacy placeholder used before real doctor assignment was implemented.
/// Must never be written to Firestore -- doctor app queries by JWT user id.
const String kLegacyPlaceholderDoctorId = 'dr_sarah_johnson';

const String kDoctorAssignmentMissingMessage =
    'Doctor assignment missing. Please contact support.';

/// Returns true when [id] is safe to use as Firestore doctorId.
bool isResolvableDoctorId(String? id) {
  if (id == null) return false;
  final trimmed = id.trim();
  return trimmed.isNotEmpty && trimmed != kLegacyPlaceholderDoctorId;
}
