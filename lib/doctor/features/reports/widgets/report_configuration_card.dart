import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:grad_project/doctor/features/patients/model/patient_model.dart';
import 'package:grad_project/doctor/features/reports/model/report_data.dart';

class ReportConfigurationCard extends StatelessWidget {
  final Patient? selectedPatient;
  final DateTime startDate;
  final DateTime endDate;
  final ExportFormat format;
  final ValueChanged<Patient?> onPatientChanged;
  final ValueChanged<ExportFormat> onFormatChanged;
  final VoidCallback onGenerate;

  const ReportConfigurationCard({
    super.key,
    required this.selectedPatient,
    required this.startDate,
    required this.endDate,
    required this.format,
    required this.onPatientChanged,
    required this.onFormatChanged,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM/yyyy');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.description_outlined, size: 20),
              SizedBox(width: 10),
              Text(
                'Report Configuration',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Select Patient',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: selectedPatient?.id,
            hint: const Text('Choose a patient...'),
            decoration: _inputDecoration(),
            items: patients
                .map((p) => DropdownMenuItem(value: p.id, child: Text(p.name)))
                .toList(),
            onChanged: (id) {
              if (id == null) return;
              final next = patients.firstWhere((p) => p.id == id);
              onPatientChanged(next);
            },
          ),
          const SizedBox(height: 14),
          const Text(
            'Start Date',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          TextFormField(
            readOnly: true,
            decoration: _inputDecoration(
              prefixIcon: const Icon(Icons.calendar_today_outlined),
              hintText: df.format(startDate),
            ),
          ),
          const SizedBox(height: 14),
          const Text('End Date', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          TextFormField(
            readOnly: true,
            decoration: _inputDecoration(
              prefixIcon: const Icon(Icons.calendar_today_outlined),
              hintText: df.format(endDate),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Export Format',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _FormatButton(
                  text: 'PDF',
                  selected: format == ExportFormat.pdf,
                  onTap: () => onFormatChanged(ExportFormat.pdf),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _FormatButton(
                  text: 'CSV',
                  selected: format == ExportFormat.csv,
                  onTap: () => onFormatChanged(ExportFormat.csv),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: selectedPatient == null ? null : onGenerate,
              icon: const Icon(Icons.download),
              label: const Text(
                'Generate & Download Report',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1D4ED8),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFD1D5DB),
                disabledForegroundColor: const Color(0xFF6B7280),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({Widget? prefixIcon, String? hintText}) {
    return InputDecoration(
      prefixIcon: prefixIcon,
      hintText: hintText,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.black.withOpacity(0.06)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.black.withOpacity(0.06)),
      ),
    );
  }
}

class _FormatButton extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _FormatButton({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1D4ED8) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? const Color(0xFF1D4ED8) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF1F2937),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
