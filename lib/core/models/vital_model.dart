class VitalModel {
  final String? id;
  final String? patientId;
  final num? heartRate;
  final String? bloodPressure;
  final num? temperature;
  final num? oxygenLevel;
  final String? createdAt;
  final String? updatedAt;

  VitalModel({
    this.id,
    this.patientId,
    this.heartRate,
    this.bloodPressure,
    this.temperature,
    this.oxygenLevel,
    this.createdAt,
    this.updatedAt,
  });

  factory VitalModel.fromJson(Map<String, dynamic> json) {
    final data = json.containsKey('data') && json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    return VitalModel(
      id: (data['_id'] ?? data['id'])?.toString(),
      patientId: data['patientId']?.toString(),
      heartRate: data['heartRate'] as num?,
      bloodPressure: data['bloodPressure']?.toString(),
      temperature: data['temperature'] as num?,
      oxygenLevel: data['oxygenLevel'] as num?,
      createdAt: data['createdAt']?.toString(),
      updatedAt: data['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (patientId != null) 'patientId': patientId,
      if (heartRate != null) 'heartRate': heartRate,
      if (bloodPressure != null) 'bloodPressure': bloodPressure,
      if (temperature != null) 'temperature': temperature,
      if (oxygenLevel != null) 'oxygenLevel': oxygenLevel,
    };
  }
}
