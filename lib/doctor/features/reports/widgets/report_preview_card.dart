import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:grad_project/doctor/features/patients/model/patient_model.dart';
import 'package:grad_project/doctor/features/reports/model/report_data.dart';
import 'package:grad_project/doctor/features/reports/widgets/metric_card.dart';

class ReportPreviewCard extends StatelessWidget {
  final Patient? selectedPatient;
  final DateTime startDate;
  final DateTime endDate;
  final ReportData? data;

  const ReportPreviewCard({
    super.key,
    required this.selectedPatient,
    required this.startDate,
    required this.endDate,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
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
          const Text(
            'Report Preview',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          if (selectedPatient == null)
            _EmptyPreview()
          else
            _ReportPreviewContent(
              patient: selectedPatient!,
              startDate: startDate,
              endDate: endDate,
              data: data,
            ),
        ],
      ),
    );
  }
}

class _EmptyPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: const [
          Icon(
            Icons.insert_drive_file_outlined,
            size: 38,
            color: Color(0xFF9CA3AF),
          ),
          SizedBox(height: 10),
          Text(
            'No Patient Selected',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 6),
          Text(
            'Select a patient and date range to preview the report',
            style: TextStyle(color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }
}

class _ReportPreviewContent extends StatelessWidget {
  final Patient patient;
  final DateTime startDate;
  final DateTime endDate;
  final ReportData? data;

  const _ReportPreviewContent({
    required this.patient,
    required this.startDate,
    required this.endDate,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM/yyyy');
    final report = data;

    if (report == null) {
      return const Text('No data available for this patient.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Medical Report',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text('Patient: ${patient.name}'),
        Text('Report Period: ${df.format(startDate)} to ${df.format(endDate)}'),
        const SizedBox(height: 14),
        MetricCard(
          title: 'Heart Rate',
          value: '${report.heartRateAvg} bpm',
          subtitle: 'Average over period',
          minMax:
              'Min: ${report.heartRateMin} bpm  •  Max: ${report.heartRateMax} bpm',
          abnormal: 'Abnormal readings: ${report.heartRateAbnormal}',
          tint: const Color(0xFFFEE2E2),
          accent: const Color(0xFFDC2626),
        ),
        const SizedBox(height: 12),
        MetricCard(
          title: 'EMG Readings',
          value: '${report.emgAvg} µV',
          subtitle: 'Average over period',
          minMax: 'Min: ${report.emgMin} µV  •  Max: ${report.emgMax} µV',
          abnormal: 'Abnormal readings: ${report.emgAbnormal}',
          tint: const Color(0xFFDBEAFE),
          accent: const Color(0xFF2563EB),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F3FF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE9D5FF)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AI Analysis & Conclusions',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              ...report.analysis.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('•  '),
                      Expanded(child: Text(item)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Color(0xFF5B21B6)),
                    children: [
                      const TextSpan(
                        text: 'AI Recommendations:\n',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      TextSpan(text: report.recommendation),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Doctor's Notes",
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Text(
                report.doctorNotes,
                style: const TextStyle(height: 1.4, color: Color(0xFF374151)),
              ),
              const SizedBox(height: 14),
              Text(
                '${report.doctorName} • ${DateFormat('d/M/yyyy').format(report.doctorNoteDate)}',
                style: const TextStyle(color: Color(0xFF6B7280)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Center(
          child: Text(
            'This is a preview. The actual report will include detailed charts and complete medical data.',
            style: TextStyle(color: Color(0xFF6B7280)),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
