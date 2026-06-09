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
    final data =
        json.containsKey('data') && json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    String? normalizeTimestamp(Object? value) {
      if (value == null) return null;
      // ISO string
      if (value is String && value.isNotEmpty) return value;
      // Epoch milliseconds
      if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value).toIso8601String();
      }
      // Map with seconds/nanoseconds (e.g. Firestore)
      if (value is Map) {
        final seconds = value['seconds'] ?? value['sec'] ?? value['_seconds'];
        final nanos =
            value['nanoseconds'] ?? value['nanos'] ?? value['_nanoseconds'];
        if (seconds is int) {
          final ms = seconds * 1000 + (nanos is int ? (nanos ~/ 1000000) : 0);
          return DateTime.fromMillisecondsSinceEpoch(ms).toIso8601String();
        }
      }
      // Fallback to string representation
      return value.toString();
    }

    return VitalModel(
      id: (data['_id'] ?? data['id'])?.toString(),
      patientId: data['patientId']?.toString(),
      heartRate: data['heartRate'] as num?,
      bloodPressure: data['bloodPressure']?.toString(),
      temperature: data['temperature'] as num?,
      oxygenLevel: data['oxygenLevel'] as num?,
      createdAt: normalizeTimestamp(data['createdAt']),
      updatedAt: normalizeTimestamp(data['updatedAt']),
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
