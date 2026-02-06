import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:grad_project/doctor/features/patients/model/patient_model.dart';

enum ExportFormat { pdf, csv }

class ReportData {
  final int heartRateAvg;
  final int heartRateMin;
  final int heartRateMax;
  final int heartRateAbnormal;
  final int emgAvg;
  final int emgMin;
  final int emgMax;
  final int emgAbnormal;
  final List<String> analysis;
  final String recommendation;
  final String doctorNotes;
  final String doctorName;
  final DateTime doctorNoteDate;

  const ReportData({
    required this.heartRateAvg,
    required this.heartRateMin,
    required this.heartRateMax,
    required this.heartRateAbnormal,
    required this.emgAvg,
    required this.emgMin,
    required this.emgMax,
    required this.emgAbnormal,
    required this.analysis,
    required this.recommendation,
    required this.doctorNotes,
    required this.doctorName,
    required this.doctorNoteDate,
  });
}

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  Patient? _selectedPatient;
  ExportFormat _format = ExportFormat.pdf;
  DateTime _startDate = DateTime(2025, 12, 1);
  DateTime _endDate = DateTime(2025, 12, 31);

  final Map<String, ReportData> _reports = {
    '1': ReportData(
      heartRateAvg: 72,
      heartRateMin: 60,
      heartRateMax: 96,
      heartRateAbnormal: 1,
      emgAvg: 45,
      emgMin: 35,
      emgMax: 70,
      emgAbnormal: 1,
      analysis: [
        'Patient vitals remain within acceptable ranges for most of the period',
        'One instance of elevated heart rate detected during evening hours',
        'EMG readings show consistent patterns with one minor spike',
        'Overall risk assessment: Low',
      ],
      recommendation:
          'Continue current treatment plan. Monitor evening heart rate trends. Schedule follow-up in 2 weeks.',
      doctorNotes:
          'Patient has shown steady progress over the monitoring period. Vital signs are generally stable with occasional fluctuations that appear to correlate with physical activity and stress levels. EMG readings indicate normal muscle function with no significant abnormalities detected. Recommended continuation of current medication regimen and routine exercise. Follow-up appointment scheduled for comprehensive evaluation.',
      doctorName: 'Dr. Thompson',
      doctorNoteDate: DateTime(2026, 1, 5),
    ),
    '2': ReportData(
      heartRateAvg: 95,
      heartRateMin: 72,
      heartRateMax: 118,
      heartRateAbnormal: 4,
      emgAvg: 78,
      emgMin: 52,
      emgMax: 110,
      emgAbnormal: 3,
      analysis: [
        'Heart rate elevated above baseline on multiple days',
        'EMG readings show increased muscle tension during late hours',
        'Potential correlation with reported stress levels',
        'Overall risk assessment: Moderate',
      ],
      recommendation:
          'Adjust activity schedule. Consider stress management plan. Recheck vitals in 1 week.',
      doctorNotes:
          'Patient reports feeling anxious with periodic palpitations. Heart rate readings indicate multiple episodes of tachycardia. Recommend lifestyle adjustments and monitoring. Discussed potential medication review if symptoms persist. Follow-up planned for next week.',
      doctorName: 'Dr. Anderson',
      doctorNoteDate: DateTime(2026, 1, 12),
    ),
    '3': ReportData(
      heartRateAvg: 68,
      heartRateMin: 58,
      heartRateMax: 85,
      heartRateAbnormal: 0,
      emgAvg: 50,
      emgMin: 38,
      emgMax: 72,
      emgAbnormal: 1,
      analysis: [
        'Heart rate stable throughout the period',
        'EMG readings show consistent muscle function',
        'One minor EMG spike on Dec 15 at 2:30 PM',
        'Overall risk assessment: Low',
      ],
      recommendation:
          'Maintain current routine. No immediate changes required.',
      doctorNotes:
          'Patient maintains good overall health indicators. No significant concerns noted. Continue current wellness plan and routine check-ins.',
      doctorName: 'Dr. Chen',
      doctorNoteDate: DateTime(2026, 1, 18),
    ),
    '4': ReportData(
      heartRateAvg: 110,
      heartRateMin: 88,
      heartRateMax: 132,
      heartRateAbnormal: 5,
      emgAvg: 85,
      emgMin: 60,
      emgMax: 120,
      emgAbnormal: 4,
      analysis: [
        'Frequent elevated heart rate readings detected',
        'EMG shows repeated high-activity spikes',
        'Symptoms may correlate with limited recovery',
        'Overall risk assessment: Moderate to high',
      ],
      recommendation:
          'Immediate review recommended. Limit exertion and follow clinician guidance.',
      doctorNotes:
          'Multiple abnormal readings noted over the monitoring period. Recommend closer supervision and potential adjustment to treatment plan. Patient advised to reduce activity levels and report any worsening symptoms promptly.',
      doctorName: 'Dr. Rodriguez',
      doctorNoteDate: DateTime(2026, 2, 1),
    ),
  };

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM/yyyy');

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

              _buildCard(
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
                      value: _selectedPatient?.id,
                      hint: const Text('Choose a patient...'),
                      decoration: _inputDecoration(),
                      items: patients
                          .map(
                            (p) => DropdownMenuItem(
                              value: p.id,
                              child: Text(p.name),
                            ),
                          )
                          .toList(),
                      onChanged: (id) {
                        if (id == null) return;
                        final next = patients.firstWhere((p) => p.id == id);
                        setState(() => _selectedPatient = next);
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
                        hintText: df.format(_startDate),
                      ),
                    ),
                    const SizedBox(height: 14),

                    const Text(
                      'End Date',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      readOnly: true,
                      decoration: _inputDecoration(
                        prefixIcon: const Icon(Icons.calendar_today_outlined),
                        hintText: df.format(_endDate),
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
                            selected: _format == ExportFormat.pdf,
                            onTap: () => setState(() => _format = ExportFormat.pdf),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _FormatButton(
                            text: 'CSV',
                            selected: _format == ExportFormat.csv,
                            onTap: () => setState(() => _format = ExportFormat.csv),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _selectedPatient == null ? null : () {},
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
              ),

              const SizedBox(height: 18),

              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Report Preview',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 12),
                    if (_selectedPatient == null)
                      _EmptyPreview()
                    else
                      _ReportPreview(
                        patient: _selectedPatient!,
                        startDate: _startDate,
                        endDate: _endDate,
                        data: _reports[_selectedPatient!.id],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
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

  Widget _buildCard({required Widget child}) {
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
      child: child,
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
          Icon(Icons.insert_drive_file_outlined, size: 38, color: Color(0xFF9CA3AF)),
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

class _ReportPreview extends StatelessWidget {
  final Patient patient;
  final DateTime startDate;
  final DateTime endDate;
  final ReportData? data;

  const _ReportPreview({
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

        _MetricCard(
          title: 'Heart Rate',
          value: '${report.heartRateAvg} bpm',
          subtitle: 'Average over period',
          minMax: 'Min: ${report.heartRateMin} bpm  •  Max: ${report.heartRateMax} bpm',
          abnormal: 'Abnormal readings: ${report.heartRateAbnormal}',
          tint: const Color(0xFFFEE2E2),
          accent: const Color(0xFFDC2626),
        ),
        const SizedBox(height: 12),
        _MetricCard(
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

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final String minMax;
  final String abnormal;
  final Color tint;
  final Color accent;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.minMax,
    required this.abnormal,
    required this.tint,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.insert_drive_file, color: accent, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.w800, color: accent),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: accent,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(color: accent.withOpacity(0.8)),
          ),
          const SizedBox(height: 8),
          Text(
            minMax,
            style: const TextStyle(color: Color(0xFF374151)),
          ),
          const SizedBox(height: 4),
          Text(
            abnormal,
            style: TextStyle(color: accent, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
