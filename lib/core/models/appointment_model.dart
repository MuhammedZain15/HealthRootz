/// Appointment model — maps to the Appointments CRUD endpoints.
class AppointmentModel {
  final String? id;
  final String? patientId;
  final String? doctorId;
  final String? date;
  final String? status; // "pending", "approved", etc.
  final String? description;
  final String? createdAt;
  final String? updatedAt;

  AppointmentModel({
    this.id,
    this.patientId,
    this.doctorId,
    this.date,
    this.status,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['_id'] as String?,
      patientId: json['patientId'] as String?,
      doctorId: json['doctorId'] as String?,
      date: json['date'] as String?,
      status: json['status'] as String?,
      description: json['description'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (patientId != null) 'patientId': patientId,
      if (doctorId != null) 'doctorId': doctorId,
      if (date != null) 'date': date,
      if (status != null) 'status': status,
      if (description != null) 'description': description,
    };
  }
}
