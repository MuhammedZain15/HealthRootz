import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:grad_project/doctor/features/patients/model/patient_model.dart';
import 'package:grad_project/doctor/features/reports/model/report_data.dart';

/// Lets the doctor configure a new report before generating it.
///
/// All fields map directly to the POST /api/reports/ body:
///   patientId, title, startDate, endDate, doctorNotes, aiRecommendation
class ReportConfigurationCard extends StatefulWidget {
  /// Live list of patients fetched from the API.
  final List<Patient> patients;
  final bool isPatientsLoading;

  final Patient? selectedPatient;
  final DateTime startDate;
  final DateTime endDate;
  final ExportFormat format;

  final ValueChanged<Patient?> onPatientChanged;
  final ValueChanged<DateTime> onStartDateChanged;
  final ValueChanged<DateTime> onEndDateChanged;
  final ValueChanged<ExportFormat> onFormatChanged;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onDoctorNotesChanged;

  /// Called when the user taps "Generate & Download Report".
  final VoidCallback onGenerate;
  final bool isGenerating;

  const ReportConfigurationCard({
    super.key,
    required this.patients,
    this.isPatientsLoading = false,
    required this.selectedPatient,
    required this.startDate,
    required this.endDate,
    required this.format,
    required this.onPatientChanged,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
    required this.onFormatChanged,
    required this.onTitleChanged,
    required this.onDoctorNotesChanged,
    required this.onGenerate,
    this.isGenerating = false,
  });

  @override
  State<ReportConfigurationCard> createState() =>
      _ReportConfigurationCardState();
}

class _ReportConfigurationCardState extends State<ReportConfigurationCard> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  final _df = DateFormat('dd/MM/yyyy');

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(
    BuildContext context, {
    required DateTime initial,
    required ValueChanged<DateTime> onPicked,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) onPicked(picked);
  }

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
          // ── Header ─────────────────────────────────────────────────
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

          // ── Patient selector ───────────────────────────────────────
          const Text(
            'Select Patient',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          widget.isPatientsLoading
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : DropdownButtonFormField<String>(
                  value: widget.selectedPatient?.id,
                  hint: const Text('Choose a patient...'),
                  decoration: _inputDecoration(),
                  items: widget.patients
                      .map(
                        (p) => DropdownMenuItem(value: p.id, child: Text(p.name)),
                      )
                      .toList(),
                  onChanged: (id) {
                    if (id == null) return;
                    final next =
                        widget.patients.firstWhere((p) => p.id == id);
                    widget.onPatientChanged(next);
                  },
                ),
          const SizedBox(height: 14),

          // ── Report title ───────────────────────────────────────────
          const Text(
            'Report Title',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _titleController,
            onChanged: widget.onTitleChanged,
            decoration: _inputDecoration(
              hintText: 'e.g. Weekly Health Summary',
              prefixIcon: const Icon(Icons.title_outlined),
            ),
          ),
          const SizedBox(height: 14),

          // ── Date range ─────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Start Date',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _pickDate(
                        context,
                        initial: widget.startDate,
                        onPicked: widget.onStartDateChanged,
                      ),
                      child: AbsorbPointer(
                        child: TextFormField(
                          readOnly: true,
                          decoration: _inputDecoration(
                            prefixIcon: const Icon(
                              Icons.calendar_today_outlined,
                            ),
                            hintText: _df.format(widget.startDate),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'End Date',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _pickDate(
                        context,
                        initial: widget.endDate,
                        onPicked: widget.onEndDateChanged,
                      ),
                      child: AbsorbPointer(
                        child: TextFormField(
                          readOnly: true,
                          decoration: _inputDecoration(
                            prefixIcon: const Icon(
                              Icons.calendar_today_outlined,
                            ),
                            hintText: _df.format(widget.endDate),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Doctor notes ───────────────────────────────────────────
          const Text(
            "Doctor's Notes",
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _notesController,
            onChanged: widget.onDoctorNotesChanged,
            maxLines: 3,
            decoration: _inputDecoration(
              hintText: 'Enter clinical observations...',
            ),
          ),
          const SizedBox(height: 16),

          // ── Export format ──────────────────────────────────────────
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
                  selected: widget.format == ExportFormat.pdf,
                  onTap: () => widget.onFormatChanged(ExportFormat.pdf),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _FormatButton(
                  text: 'CSV',
                  selected: widget.format == ExportFormat.csv,
                  onTap: () => widget.onFormatChanged(ExportFormat.csv),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Generate button ────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed:
                  (widget.selectedPatient == null || widget.isGenerating)
                      ? null
                      : widget.onGenerate,
              icon: widget.isGenerating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.cloud_upload_outlined),
              label: Text(
                widget.isGenerating
                    ? 'Generating...'
                    : 'Generate & Save Report',
                style: const TextStyle(fontWeight: FontWeight.w800),
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
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.black.withOpacity(0.06)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.black.withOpacity(0.06)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1D4ED8)),
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1D4ED8) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? const Color(0xFF1D4ED8)
                : const Color(0xFFE5E7EB),
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
