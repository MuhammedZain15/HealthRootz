import 'package:flutter/material.dart';
import 'package:grad_project/core/models/report_model.dart';
import 'package:grad_project/core/services/report_service.dart';
import 'package:grad_project/doctor/features/patients/model/patient_model.dart';
import 'package:grad_project/doctor/features/patients/view_models/doctor_patients_view_model.dart';
import 'package:grad_project/doctor/features/reports/model/report_data.dart';
import 'package:grad_project/doctor/features/reports/services/pdf_generator_service.dart';
import 'package:grad_project/doctor/features/reports/widgets/report_configuration_card.dart';
import 'package:grad_project/doctor/features/reports/widgets/report_list_tile.dart';
import 'package:grad_project/doctor/features/reports/widgets/report_preview_card.dart';
import 'package:grad_project/patient/features/patient/data/repositories/patient_repository_impl.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  // ── Services ──────────────────────────────────────────────────────────────
  final ReportService _reportService = ReportService.instance;
  final PdfGeneratorService _pdfService = PdfGeneratorService();
  final DoctorPatientsViewModel _patientsVm = DoctorPatientsViewModel();

  // ── Patients ──────────────────────────────────────────────────────────────
  List<Patient> _patients = [];
  bool _isPatientsLoading = false;

  // ── Report list ───────────────────────────────────────────────────────────
  List<ApiReport> _reports = [];
  bool _isReportsLoading = false;
  String? _reportsError;

  // ── Selected/previewed report ─────────────────────────────────────────────
  ApiReport? _previewReport;

  // ── Configuration form state ───────────────────────────────────────────────
  Patient? _selectedPatient;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();
  ExportFormat _format = ExportFormat.pdf;
  String _title = '';
  String _doctorNotes = '';
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _loadPatients();
    _loadReports();
  }

  // ── Data loaders ──────────────────────────────────────────────────────────

  Future<void> _loadPatients() async {
    setState(() => _isPatientsLoading = true);
    try {
      await _fetchAndSetPatients();
    } catch (_) {
      // ignore — dropdown will just be empty
    } finally {
      if (mounted) setState(() => _isPatientsLoading = false);
    }
  }

  Future<void> _fetchAndSetPatients() async {
    final repository = PatientRepositoryImpl();
    final result = await repository.getPatients();
    result.fold(
      (failure) => throw Exception(failure.message),
      (apiPatients) {
        if (mounted) {
          setState(() {
            _patients = apiPatients.map((p) => _patientsVm.mapToUiPatient(p)).toList();
          });
        }
      },
    );
  }

  Future<void> _loadReports() async {
    setState(() {
      _isReportsLoading = true;
      _reportsError = null;
    });
    try {
      final reports = await _reportService.getReports();
      if (mounted) {
        setState(() {
          _reports = reports;
          // Auto-preview the most recent report
          if (reports.isNotEmpty && _previewReport == null) {
            _previewReport = reports.first;
          }
        });
      }
    } catch (e) {
      if (mounted) setState(() => _reportsError = e.toString());
    } finally {
      if (mounted) setState(() => _isReportsLoading = false);
    }
  }

  // ── Generate report ───────────────────────────────────────────────────────

  Future<void> _generateReport() async {
    if (_selectedPatient == null) return;

    if (_title.trim().isEmpty) {
      _showSnack('Please enter a report title.');
      return;
    }

    setState(() => _isGenerating = true);
    try {
      final newReport = await _reportService.generateReport(
        patientId: _selectedPatient!.id,
        title: _title.trim(),
        startDate: _startDate,
        endDate: _endDate,
        doctorNotes: _doctorNotes.trim(),
      );

      if (!mounted) return;
      setState(() {
        _reports.insert(0, newReport);
        _previewReport = newReport;
      });

      _showSnack('✅ Report generated successfully!');

      // Also export as PDF locally if that format is chosen
      if (_format == ExportFormat.pdf) {
        final data = ReportData.fromApiReport(newReport);
        await _pdfService.generateAndDownloadPdf(
          data,
          _selectedPatient!,
          _startDate,
          _endDate,
        );
      }
    } catch (e) {
      if (mounted) _showSnack('Error: ${e.toString()}', isError: true);
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadReports,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Page header ────────────────────────────────────────
                Text(
                  'Reports & Export',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Generate and export medical documentation',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),

                // ── Configuration card ─────────────────────────────────
                ReportConfigurationCard(
                  patients: _patients,
                  isPatientsLoading: _isPatientsLoading,
                  selectedPatient: _selectedPatient,
                  startDate: _startDate,
                  endDate: _endDate,
                  format: _format,
                  isGenerating: _isGenerating,
                  onPatientChanged: (p) =>
                      setState(() => _selectedPatient = p),
                  onStartDateChanged: (d) =>
                      setState(() => _startDate = d),
                  onEndDateChanged: (d) => setState(() => _endDate = d),
                  onFormatChanged: (f) => setState(
                    () => _format = f,
                  ),
                  onTitleChanged: (t) => _title = t,
                  onDoctorNotesChanged: (n) => _doctorNotes = n,
                  onGenerate: _generateReport,
                ),
                const SizedBox(height: 20),

                // ── Preview card ───────────────────────────────────────
                ReportPreviewCard(report: _previewReport),
                const SizedBox(height: 20),

                // ── Previous reports list ──────────────────────────────
                _buildReportsList(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReportsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Previous Reports',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            if (_isReportsLoading)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_reportsError != null)
          _ErrorBanner(
            message: _reportsError!,
            onRetry: _loadReports,
          )
        else if (!_isReportsLoading && _reports.isEmpty)
          _EmptyReports()
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _reports.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final report = _reports[index];
              return ReportListTile(
                report: report,
                onTap: () => setState(() => _previewReport = report),
              );
            },
          ),
      ],
    );
  }
}

// ── Helper widgets ─────────────────────────────────────────────────────────

class _EmptyReports extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: const Column(
        children: [
          Icon(Icons.folder_open_outlined, size: 44, color: Color(0xFFD1D5DB)),
          SizedBox(height: 10),
          Text(
            'No reports yet',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF374151),
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Generate your first report using the form above.',
            style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBanner({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFDC2626)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Color(0xFFDC2626), fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}



// commit update
 