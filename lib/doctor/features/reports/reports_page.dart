import 'package:flutter/material.dart';
import 'package:grad_project/doctor/features/patients/model/patient_model.dart';
import 'package:grad_project/doctor/features/reports/model/report_data.dart';
import 'package:grad_project/doctor/features/reports/widgets/report_configuration_card.dart';
import 'package:grad_project/doctor/features/reports/widgets/report_preview_card.dart';
import 'package:grad_project/doctor/features/reports/services/pdf_generator_service.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  Patient? _selectedPatient;
  ExportFormat _format = ExportFormat.pdf;
  final DateTime _startDate = DateTime(2025, 12, 1);
  final DateTime _endDate = DateTime(2025, 12, 31);
  final PdfGeneratorService _pdfService = PdfGeneratorService();

  void _generateReport() async {
    if (_selectedPatient == null) return;

    final data = fakeReportsData[_selectedPatient!.id];
    if (data == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No data found for this patient')),
      );
      return;
    }

    if (_format == ExportFormat.pdf) {
      await _pdfService.generateAndDownloadPdf(
        data,
        _selectedPatient!,
        _startDate,
        _endDate,
      );
    } else {
      // Handle CSV if implementation is added later
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CSV export is not yet implemented')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Reports & Export',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(
                'Generate and export medical documentation',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 18),
              ReportConfigurationCard(
                selectedPatient: _selectedPatient,
                startDate: _startDate,
                endDate: _endDate,
                format: _format,
                onPatientChanged: (patient) =>
                    setState(() => _selectedPatient = patient),
                onFormatChanged: (format) => setState(() => _format = format),
                onGenerate: _generateReport,
              ),
              const SizedBox(height: 18),
              ReportPreviewCard(
                selectedPatient: _selectedPatient,
                startDate: _startDate,
                endDate: _endDate,
                data: _selectedPatient != null
                    ? fakeReportsData[_selectedPatient!.id]
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
