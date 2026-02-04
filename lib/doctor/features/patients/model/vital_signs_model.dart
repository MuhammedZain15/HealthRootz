
class VitalSigns {
  final int heartRate; // bpm
  final String bloodPressure; // e.g., "120/80"
  final double temperature; // °F
  final int oxygenLevel; // %
  final int emgReading; // µV
  final DateTime timestamp;

  VitalSigns({
    required this.heartRate,
    required this.bloodPressure,
    required this.temperature,
    required this.oxygenLevel,
    required this.emgReading,
    required this.timestamp,
  });
}
