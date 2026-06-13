class VitalModel {
  final String? id;
  final String? patientId;
  final num? heartRate;
  final String? bloodPressure;
  final num? temperature;
  final num? oxygenLevel;
  final num? emg;
  final String? createdAt;
  final String? updatedAt;

  // AI Analysis (from the backend's `aiPrediction` object).
  final String? prediction;
  final double? confidence;
  final String? riskLevel;

  VitalModel({
    this.id,
    this.patientId,
    this.heartRate,
    this.bloodPressure,
    this.temperature,
    this.oxygenLevel,
    this.emg,
    this.createdAt,
    this.updatedAt,
    this.prediction,
    this.confidence,
    this.riskLevel,
  });

  /// True when the record carries a usable AI prediction.
  bool get hasAiPrediction =>
      (prediction != null && prediction!.trim().isNotEmpty) ||
      confidence != null ||
      (riskLevel != null && riskLevel!.trim().isNotEmpty);

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

    // Reads the first present key and coerces num-or-numeric-string -> num.
    // Avoids a hard `as num?` cast (which throws on String values) and
    // tolerates the different field names the backend / devices use.
    num? readNum(List<String> keys) {
      for (final key in keys) {
        final value = data[key];
        if (value == null) continue;
        if (value is num) return value;
        if (value is String) {
          final parsed = num.tryParse(value.trim());
          if (parsed != null) return parsed;
        }
      }
      return null;
    }

    // Parse the nested AI prediction object, if present.
    final aiRaw = data['aiPrediction'] ?? data['ai_prediction'];
    final ai = aiRaw is Map
        ? Map<String, dynamic>.from(aiRaw)
        : const <String, dynamic>{};
    final confidenceRaw = ai['confidence'];
    double? confidence = confidenceRaw is num
        ? confidenceRaw.toDouble()
        : (confidenceRaw is String ? double.tryParse(confidenceRaw.trim()) : null);
    // The backend stores confidence as a percentage (0–100, e.g. 63, 78) but the
    // UI expects a 0–1 fraction. Normalize so a value > 1 is treated as a percent.
    if (confidence != null && confidence > 1) {
      confidence = confidence / 100.0;
    }

    return VitalModel(
      id: (data['_id'] ?? data['id'])?.toString(),
      patientId: data['patientId']?.toString(),
      heartRate: readNum(['heartRate', 'heart_rate', 'bpm']),
      bloodPressure: (data['bloodPressure'] ?? data['blood_pressure'])
          ?.toString(),
      temperature: readNum(['temperature', 'temp']),
      // SpO2 / blood-oxygen saturation arrives under several names depending
      // on the source (manual vitals vs. oximeter device).
      oxygenLevel: readNum([
        'oxygenLevel',
        'oxygenSaturation',
        'oxygen_saturation',
        'spo2',
        'SpO2',
        'spO2',
        'oxygen',
      ]),
      emg: readNum(['emg', 'emgReading', 'muscleActivity']),
      createdAt: normalizeTimestamp(data['createdAt']),
      updatedAt: normalizeTimestamp(data['updatedAt']),
      prediction: ai['prediction']?.toString(),
      confidence: confidence,
      riskLevel: ai['riskLevel']?.toString(),
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
