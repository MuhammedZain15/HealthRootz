/// UI model for doctor appointment list cards.
class DoctorAppointmentItem {
  final String id;
  final String patientName;
  final String dateLabel;
  final String timeLabel;
  final String status;
  final String reason;
  final String type;

  const DoctorAppointmentItem({
    required this.id,
    required this.patientName,
    required this.dateLabel,
    required this.timeLabel,
    required this.status,
    required this.reason,
    this.type = 'Consultation',
  });

  String get statusKey => status.toLowerCase();
}

// commit update
 