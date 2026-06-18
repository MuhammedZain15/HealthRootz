import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:grad_project/core/models/vital_model.dart';
import 'package:grad_project/l10n/app_localizations.dart';

/// Detail screen for a single vital reading, showing the AI Analysis card
/// (prediction / risk level / confidence) plus the recorded vital values.
class VitalDetailPage extends StatelessWidget {
  final VitalModel vital;

  const VitalDetailPage({super.key, required this.vital});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final onSurface = theme.colorScheme.onSurface;

    final recordedAt = vital.createdAt != null
        ? DateTime.tryParse(vital.createdAt!)
        : null;
    final dateText = recordedAt != null
        ? DateFormat('MMM d, yyyy • h:mm a').format(recordedAt)
        : '--';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: Text(l10n.readingDetails)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recorded date/time
              Row(
                children: [
                  Icon(
                    Icons.event_outlined,
                    size: 16,
                    color: onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    dateText,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (vital.hasAiPrediction) ...[
                _AiAnalysisCard(vital: vital),
                const SizedBox(height: 20),
              ],
              _VitalValuesCard(vital: vital),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ── AI Analysis card ─────────────────────────────────────────────────────────

class _AiAnalysisCard extends StatelessWidget {
  final VitalModel vital;

  const _AiAnalysisCard({required this.vital});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final onSurface = theme.colorScheme.onSurface;

    final confidence = (vital.confidence ?? 0).clamp(0.0, 1.0).toDouble();
    final pctText = '${(confidence * 100).toStringAsFixed(1)}%';
    final risk = vital.riskLevel?.trim() ?? '';
    final riskColor = _riskColor(risk);
    final prediction = (vital.prediction?.trim().isNotEmpty ?? false)
        ? vital.prediction!.trim()
        : '--';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.access_time_rounded,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                l10n.aiAnalysis,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Diagnosis + Risk level
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.diagnosis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      prediction,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    l10n.riskLevel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (risk.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: riskColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _riskLabel(l10n, risk),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: riskColor,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          // AI confidence
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.aiConfidence,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: onSurface.withValues(alpha: 0.7),
                ),
              ),
              Text(
                pctText,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: confidence,
              minHeight: 8,
              backgroundColor: onSurface.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _riskColor(String level) {
    switch (level.toLowerCase()) {
      case 'low':
        return const Color(0xFF16A34A); // green
      case 'medium':
        return const Color(0xFFF59E0B); // amber
      case 'high':
        return const Color(0xFFEF4444); // red
      default:
        return const Color(0xFF6B7280); // grey
    }
  }

  String _riskLabel(AppLocalizations l10n, String level) {
    switch (level.toLowerCase()) {
      case 'low':
        return l10n.riskLow;
      case 'medium':
        return l10n.riskMedium;
      case 'high':
        return l10n.riskHigh;
      default:
        return level.toUpperCase();
    }
  }
}

// ── Vital values card ──────────────────────────────────────────────────────

class _VitalValuesCard extends StatelessWidget {
  final VitalModel vital;

  const _VitalValuesCard({required this.vital});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final onSurface = theme.colorScheme.onSurface;

    // Build rows only for present (non-null, non-zero) values.
    final metrics = <Widget>[];
    final hr = vital.heartRate;
    if (hr != null && hr != 0) {
      metrics.add(_metricRow(
        context, Icons.favorite, const Color(0xFFEF4444), l10n.heartRate,
        '$hr bpm',
      ));
    }
    final ox = vital.oxygenLevel;
    if (ox != null && ox != 0) {
      metrics.add(_metricRow(
        context, Icons.air, const Color(0xFF0891B2), l10n.spo2, '$ox %',
      ));
    }
    final temp = vital.temperature;
    if (temp != null && temp != 0) {
      metrics.add(_metricRow(
        context, Icons.thermostat, const Color(0xFFF97316), l10n.temperature,
        '$temp °C',
      ));
    }
    final bp = vital.bloodPressure;
    if (bp != null && bp.trim().isNotEmpty) {
      metrics.add(_metricRow(
        context, Icons.bloodtype, const Color(0xFF3B82F6), l10n.bloodPressure,
        bp.trim(),
      ));
    }

    if (metrics.isEmpty) {
      metrics.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            l10n.noData,
            style: TextStyle(color: onSurface.withValues(alpha: 0.6)),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.vitalsCheck,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: onSurface,
            ),
          ),
          const SizedBox(height: 6),
          ...metrics,
        ],
      ),
    );
  }

  Widget _metricRow(
    BuildContext context,
    IconData icon,
    Color color,
    String label,
    String value,
  ) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: onSurface.withValues(alpha: 0.75),
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

// commit update
 