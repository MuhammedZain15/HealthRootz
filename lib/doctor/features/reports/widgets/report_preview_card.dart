import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:grad_project/core/models/report_model.dart';

/// Shows a read-only preview of a single [ApiReport] returned from the API.
///
/// Used on the doctor side after a report is generated or selected from
/// the list.
class ReportPreviewCard extends StatelessWidget {
  /// The report to preview. When null, shows an empty placeholder.
  final ApiReport? report;

  const ReportPreviewCard({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
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
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 12),
          report == null ? const _EmptyPreview() : _ReportContent(report: report!),
        ],
      ),
    );
  }
}

// ── Empty state ──────────────────────────────────────────────────────────────

class _EmptyPreview extends StatelessWidget {
  const _EmptyPreview();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          const Icon(Icons.insert_drive_file_outlined,
              size: 40, color: Color(0xFF9CA3AF)),
          const SizedBox(height: 10),
          Text(
            'No Report Selected',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Generate or select a report to see its preview here.',
            style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Report content ───────────────────────────────────────────────────────────

class _ReportContent extends StatelessWidget {
  final ApiReport report;
  const _ReportContent({required this.report});

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd MMM yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Title & patient ──────────────────────────────────────────
        Text(
          report.title,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        if (report.patientName != null)
          _InfoRow(
            icon: Icons.person_outline,
            text: report.patientName!,
          ),
        _InfoRow(
          icon: Icons.date_range_outlined,
          text:
              '${df.format(report.startDate)}  →  ${df.format(report.endDate)}',
        ),
        const SizedBox(height: 16),

        // ── AI Recommendation ────────────────────────────────────────
        if (report.aiRecommendation.isNotEmpty) ...[
          _SectionBox(
            color: const Color(0xFFF5F3FF),
            borderColor: const Color(0xFFE9D5FF),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.auto_awesome_outlined,
                        size: 16, color: Color(0xFF7C3AED)),
                    SizedBox(width: 6),
                    Text(
                      'AI Recommendation',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF5B21B6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  report.aiRecommendation,
                  style: const TextStyle(
                    color: Color(0xFF5B21B6),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],

        // ── Doctor's notes ───────────────────────────────────────────
        if (report.doctorNotes.isNotEmpty) ...[
          _SectionBox(
            color: Theme.of(context).colorScheme.surface,
            borderColor: Theme.of(context).dividerColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.edit_note_outlined,
                        size: 18, color: Color(0xFF374151)),
                    SizedBox(width: 6),
                    Text(
                      "Doctor's Notes",
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  report.doctorNotes,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Generated: ${DateFormat('d MMM yyyy, h:mm a').format(report.createdAt)}',
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        // ── Footer note ──────────────────────────────────────────────
        const Center(
          child: Text(
            'This preview reflects the data saved on the server.',
            style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

// ── Helper widgets ───────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: const Color(0xFF6B7280)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionBox extends StatelessWidget {
  final Color color;
  final Color borderColor;
  final Widget child;
  const _SectionBox(
      {required this.color, required this.borderColor, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: child,
    );
  }
}
