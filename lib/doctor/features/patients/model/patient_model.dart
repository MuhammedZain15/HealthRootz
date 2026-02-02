

class Patient {
  final String id;
  final String name;
  final int age;
  final String status;
  final int heartRate;
  final int emgReading;
  final String? email;
  final String? phone;
  final String? bloodType;
  final String? allergies;
  final DateTime? lastVisit;
  final String? address;

  Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.status,
    required this.heartRate,
    required this.emgReading,
    this.email,
    this.phone,
    this.bloodType,
    this.allergies,
    this.lastVisit,
    this.address,
  });

  String get initials {
    final parts = name.split(' ');
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}