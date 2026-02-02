import 'package:flutter/material.dart';
import '../model/patient_model.dart';
import '../patient_details_page.dart';
import 'patient_card.dart';

class PatientList extends StatefulWidget {
  const PatientList({super.key});

  @override
  State<PatientList> createState() => _PatientListState();
}

class _PatientListState extends State<PatientList> {
  final TextEditingController _searchController = TextEditingController();
  String _statusFilter = 'All';

  final List<Patient> _patients = [
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

  List<Patient> get _filtered {
    final q = _searchController.text.toLowerCase();
    return _patients.where((p) {
      final matchQuery = p.name.toLowerCase().contains(q);
      final matchStatus =
          _statusFilter == 'All' ||
          p.status.toLowerCase() == _statusFilter.toLowerCase();
      return matchQuery && matchStatus;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _setFilter(String value) {
    setState(() {
      _statusFilter = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;
    final textTheme = Theme.of(context).textTheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        final horizontalPadding = isWide ? 24.0 : 12.0;
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Patients List',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'View and manage all patient records',
                style: textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              // Search + filter row
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Search',
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  DropdownButton<String>(
                    borderRadius: BorderRadius.circular(12),
                    dropdownColor: Colors.white,
                    value: _statusFilter,
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All Status'),),
                      DropdownMenuItem(value: 'Normal', child: Text('Normal')),
                      DropdownMenuItem(
                        value: 'Warning',
                        child: Text('Warning'),
                      ),
                      DropdownMenuItem(
                        value: 'Critical',
                        child: Text('Critical'),
                      ),
                    ],
                    onChanged: (v) => _setFilter(v ?? 'All'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // List
              Expanded(
                child: list.isEmpty
                    ? Center(
                        child: Text(
                          'No patients found',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      )
                    : ListView.separated(
                        itemCount: list.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final patient = list[index];
                          return PatientCard(
                            patient: patient,
                            onViewDetails: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PatientDetailsPage(
                                    patient: patient,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
