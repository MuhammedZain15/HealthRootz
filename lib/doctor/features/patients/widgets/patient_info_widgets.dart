import 'package:flutter/material.dart';
import '../model/patient_model.dart';

// Patient Info Row
class PatientInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const PatientInfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

// Patient Information Section
class PatientInformationSection extends StatelessWidget {
  final Patient patient;

  const PatientInformationSection({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Patient Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          PatientInfoRow(label: 'Email', value: patient.email ?? 'N/A'),
          Divider(color: Theme.of(context).dividerColor, height: 1),
          PatientInfoRow(label: 'Phone', value: patient.phone ?? 'N/A'),
          Divider(color: Theme.of(context).dividerColor, height: 1),
          PatientInfoRow(label: 'Gender', value: patient.gender ?? 'N/A'),
          Divider(color: Theme.of(context).dividerColor, height: 1),
          PatientInfoRow(
            label: 'Condition',
            value: patient.condition ?? 'N/A',
          ),
          Divider(color: Theme.of(context).dividerColor, height: 1),
          PatientInfoRow(
            label: 'Medical History',
            value: patient.medicalHistory ?? 'N/A',
          ),
        ],
      ),
    );
  }
}

// commit update
 