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
  final String? gender;
  final String? condition;
  final String? medicalHistory;

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
    this.gender,
    this.condition,
    this.medicalHistory,
  });

  String get initials {
    final parts = name.split(' ');
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}

final List<Patient> patients = [
  Patient(
    id: '1',
    name: 'David Thompson',
    age: 54,
    status: 'Normal',
    heartRate: 72,
    emgReading: 45,
    email: 'david.thompson@email.com',
    phone: '+1 (555) 678-9012',
    bloodType: 'A-',
    allergies: 'None',
    lastVisit: DateTime(2025, 12, 27),
    address: '654 Pine St, Manhattan, NY 10002',
  ),
  Patient(
    id: '2',
    name: 'Sarah Mitchell',
    age: 62,
    status: 'Warning',
    heartRate: 95,
    emgReading: 78,
    email: 'sarah.mitchell@email.com',
    phone: '+1 (555) 234-5678',
    bloodType: 'O+',
    allergies: 'Penicillin',
    lastVisit: DateTime(2026, 1, 15),
    address: '123 Oak Ave, Brooklyn, NY 11201',
  ),
  Patient(
    id: '3',
    name: 'Michael Chen',
    age: 39,
    status: 'Normal',
    heartRate: 68,
    emgReading: 50,
    email: 'michael.chen@email.com',
    phone: '+1 (555) 345-6789',
    bloodType: 'B+',
    allergies: 'None',
    lastVisit: DateTime(2026, 1, 20),
    address: '789 Maple Dr, Queens, NY 11354',
  ),
  Patient(
    id: '4',
    name: 'Emily Rodriguez',
    age: 47,
    status: 'Critical',
    heartRate: 110,
    emgReading: 85,
    email: 'emily.rodriguez@email.com',
    phone: '+1 (555) 456-7890',
    bloodType: 'AB-',
    allergies: 'Latex, Aspirin',
    lastVisit: DateTime(2026, 2, 1),
    address: '456 Elm St, Bronx, NY 10451',
  ),
];
