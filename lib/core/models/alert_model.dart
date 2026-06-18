/// Alert model — maps to Alerts CRUD endpoints.
class AlertModel {
  final String? id;
  final String? patientId;
  final String? patientName;
  final String? message;
  final String? type;
  final String? description;
  final bool? isResolved;
  final String? createdAt;
  final String? updatedAt;

  AlertModel({
    this.id,
    this.patientId,
    this.patientName,
    this.message,
    this.type,
    this.description,
    this.isResolved,
    this.createdAt,
    this.updatedAt,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) {
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
      if (value is Map) return value['name'] as String?;
      return null;
    }

    final rawPatient = data['patientId'] ?? data['patient'] ?? json['patientId'];

    bool? parseResolved(dynamic value) {
      if (value == null) return null;
      if (value is bool) return value;
      return value.toString().toLowerCase() == 'true';
    }

    return AlertModel(
      id: (data['_id'] ?? data['id'] ?? json['_id'] ?? json['id']) as String?,
      patientId: parsePatientId(rawPatient),
      patientName: parsePatientName(rawPatient) ??
          (data['patientName'] ?? json['patientName']) as String?,
      message: (data['message'] ?? json['message']) as String?,
      type: (data['type'] ?? json['type']) as String?,
      description: (data['description'] ?? json['description']) as String?,
      isResolved: parseResolved(data['isResolved'] ?? json['isResolved']),
      createdAt: (data['createdAt'] ?? json['createdAt']) as String?,
      updatedAt: (data['updatedAt'] ?? json['updatedAt']) as String?,
    );
  }

  Map<String, dynamic> toCreateJson({
    required String patientId,
    required String message,
    required String type,
    String? description,
  }) {
    return {
      'patientId': patientId,
      'message': message,
      'type': type,
      'description': ?description,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      if (patientId != null) 'patientId': patientId,
      if (message != null) 'message': message,
      if (type != null) 'type': type,
      if (description != null) 'description': description,
      if (isResolved != null) 'isResolved': isResolved,
    };
  }
}

// commit update
 