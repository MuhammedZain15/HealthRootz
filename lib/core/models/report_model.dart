/// Report model — maps to the Reports CRUD endpoints.
class ReportModel {
  final String? id;
  final String? patientId;
  final String? title;
  final String? description;
  final String? status; // "draft", "final"
  final String? startDate;
  final String? endDate;
  final String? createdAt;
  final String? updatedAt;

  ReportModel({
    this.id,
    this.patientId,
    this.title,
    this.description,
    this.status,
    this.startDate,
    this.endDate,
    this.createdAt,
    this.updatedAt,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['_id'] as String?,
      patientId: json['patientId'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      status: json['status'] as String?,
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (patientId != null) 'patientId': patientId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (status != null) 'status': status,
      if (startDate != null) 'startDate': startDate,
      if (endDate != null) 'endDate': endDate,
    };
  }
}
