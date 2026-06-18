import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:grad_project/core/models/report_model.dart';
import 'package:grad_project/doctor/features/patients/model/patient_model.dart';
import 'package:grad_project/doctor/features/reports/model/report_data.dart';
import 'package:grad_project/doctor/features/reports/services/pdf_generator_service.dart';

/// Read-only detail page a patient sees when tapping a report.
class ReportDetailPage extends StatelessWidget {
  final ApiReport report;

  const ReportDetailPage({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd MMM yyyy');
    final dtf = DateFormat('d MMM yyyy, h:mm a');

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Report Details',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded, color: Color(0xFF1D4ED8)),
            tooltip: 'Export PDF',
            onPressed: () async {
              try {
                final pdfService = PdfGeneratorService();
                final reportData = ReportData.fromApiReport(report);
                final patientObj = Patient(
                  id: report.patientId ?? '',
                  name: report.patientName ?? 'Patient',
                  age: 0,
                  status: 'Normal',
                  heartRate: 0,
                  emgReading: 0,
                );
                await pdfService.generateAndDownloadPdf(
                  reportData,
                  patientObj,
                  report.startDate,
                  report.endDate,
                );
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error exporting PDF: ${e.toString()}')),
                  );
                }
              }
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title card ─────────────────────────────────────────────
            _GradientHeader(report: report, df: df),
            const SizedBox(height: 20),

            // ── Date range ─────────────────────────────────────────────
            _InfoCard(
              title: 'Report Period',
              icon: Icons.date_range_outlined,
              iconColor: const Color(0xFF1D4ED8),
              iconBg: const Color(0xFFEFF6FF),
              content: '${df.format(report.startDate)}  →  ${df.format(report.endDate)}',
            ),
            const SizedBox(height: 14),

            // ── AI Recommendation ──────────────────────────────────────
            if (report.aiRecommendation.isNotEmpty) ...[
              _ContentCard(
                icon: Icons.auto_awesome_outlined,
                iconColor: const Color(0xFF7C3AED),
                iconBg: const Color(0xFFF5F3FF),
                title: 'AI Recommendation',
                titleColor: const Color(0xFF5B21B6),
                backgroundColor: const Color(0xFFF5F3FF),
                borderColor: const Color(0xFFE9D5FF),
                body: report.aiRecommendation,
                bodyColor: const Color(0xFF5B21B6),
              ),
              const SizedBox(height: 14),
            ],

            // ── Doctor's notes ─────────────────────────────────────────
            if (report.doctorNotes.isNotEmpty) ...[
              _ContentCard(
                icon: Icons.edit_note_outlined,
                iconColor: const Color(0xFF0F766E),
                iconBg: const Color(0xFFF0FDF4),
                title: "Doctor's Notes",
                titleColor: const Color(0xFF111827),
                backgroundColor: Colors.white,
                borderColor: const Color(0xFFE5E7EB),
                body: report.doctorNotes,
                bodyColor: const Color(0xFF374151),
              ),
              const SizedBox(height: 14),
            ],

            // ── Footer timestamp ───────────────────────────────────────
            Center(
              child: Text(
                'Generated on ${dtf.format(report.createdAt)}',
                style: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ── Widgets ────────────────────────────────────────────────────────────────

class _GradientHeader extends StatelessWidget {
  final ApiReport report;
  final DateFormat df;
  const _GradientHeader({required this.report, required this.df});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1D4ED8).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Health Report',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            report.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 13, color: Colors.white70),
              const SizedBox(width: 4),
              Text(
                '${df.format(report.startDate)} – ${df.format(report.endDate)}',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String content;

  const _InfoCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  content,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContentCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final Color titleColor;
  final Color backgroundColor;
  final Color borderColor;
  final String body;
  final Color bodyColor;

  const _ContentCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.titleColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.body,
    required this.bodyColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: titleColor,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            body,
            style: TextStyle(color: bodyColor, height: 1.6, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// commit update
 