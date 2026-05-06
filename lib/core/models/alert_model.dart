/// Alert model — maps to the Alerts CRUD endpoints.
class AlertModel {
  final String? id;
  final String? patientId;
  final String? type; // "critical", "warning", etc.
  final String? description;
  final bool? isResolved;
  final String? createdAt;
  final String? updatedAt;

  AlertModel({
    this.id,
    this.patientId,
    this.type,
    this.description,
    this.isResolved,
    this.createdAt,
    this.updatedAt,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['_id'] as String?,
      patientId: json['patientId'] as String?,
      type: json['type'] as String?,
      description: json['description'] as String?,
      isResolved: json['isResolved'] as bool?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (patientId != null) 'patientId': patientId,
      if (type != null) 'type': type,
      if (description != null) 'description': description,
      if (isResolved != null) 'isResolved': isResolved,
    };
  }
}
