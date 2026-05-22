/// Appointment model — maps to Appointments CRUD endpoints.
class AppointmentModel {
  final String? id;
  final String? patientId;
  final String? patientName;
  final String? doctorId;
  final String? date;
  final String? status;
  final String? reason;
  final String? description;
  final String? createdAt;
  final String? updatedAt;

  AppointmentModel({
    this.id,
    this.patientId,
    this.patientName,
    this.doctorId,
    this.date,
    this.status,
    this.reason,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    final data = json.containsKey('data') && json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    String? parsePatientId(dynamic value) {
      if (value == null) return null;
      if (value is String) return value;
      if (value is Map) {
        return (value['_id'] ?? value['id'])?.toString();
      }
      return value.toString();
    }

    String? parsePatientName(dynamic value) {
      if (value is Map) {
        return value['name'] as String?;
      }
      return null;
    }

    final rawPatient = data['patientId'] ?? data['patient'] ?? json['patientId'];

    return AppointmentModel(
      id: (data['_id'] ?? data['id'] ?? json['_id'] ?? json['id']) as String?,
      patientId: parsePatientId(rawPatient),
      patientName: parsePatientName(rawPatient) ??
          (data['patientName'] ?? json['patientName']) as String?,
      doctorId: (data['doctorId'] ?? json['doctorId'])?.toString(),
      date: (data['date'] ?? json['date']) as String?,
      status: (data['status'] ?? json['status']) as String?,
      reason: (data['reason'] ?? json['reason']) as String?,
      description: (data['description'] ?? json['description']) as String?,
      createdAt: (data['createdAt'] ?? json['createdAt']) as String?,
      updatedAt: (data['updatedAt'] ?? json['updatedAt']) as String?,
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      if (patientId != null) 'patientId': patientId,
      if (date != null) 'date': date,
      if (reason != null) 'reason': reason,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      if (patientId != null) 'patientId': patientId,
      if (doctorId != null) 'doctorId': doctorId,
      if (date != null) 'date': date,
      if (status != null) 'status': status,
      if (reason != null) 'reason': reason,
      if (description != null) 'description': description,
    };
  }
}
