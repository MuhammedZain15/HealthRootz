import 'package:flutter/material.dart';
import 'package:grad_project/app_colors.dart';
import 'package:grad_project/core/models/vital_model.dart';
import '../model/patient_model.dart';

/// Formats a [num] without a trailing `.0` (e.g. 36.0 -> "36", 36.8 -> "36.8").
String _fmtNum(num? value) {
  if (value == null) return '—';
  if (value == value.roundToDouble()) return value.toInt().toString();
  return value.toString();
}

// Patient Header Widget
class PatientHeader extends StatelessWidget {
  final Patient patient;

  const PatientHeader({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.darkBlue,
            child: Text(
              patient.initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${patient.age} years old',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    patient.status,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w500,
                    ),
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

// Vital Sign Card Widget
class VitalSignCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color backgroundColor;
  final Color iconColor;

  const VitalSignCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.backgroundColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: backgroundColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            unit,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// Current Vital Signs Section — reads the patient's latest vitals.
class CurrentVitalSignsSection extends StatelessWidget {
  final VitalModel? latest;
  final bool isLoading;

  const CurrentVitalSignsSection({
    super.key,
    this.latest,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Current Vital Signs',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        if (isLoading && latest == null)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (latest == null)
          _NoVitalsPlaceholder()
        else
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              VitalSignCard(
                icon: Icons.favorite,
                label: 'Heart Rate',
                value: _fmtNum(latest!.heartRate),
                unit: 'bpm',
                backgroundColor: Colors.red.shade50,
                iconColor: Colors.red.shade600,
              ),
              VitalSignCard(
                icon: Icons.show_chart,
                label: 'Blood Pressure',
                value: latest!.bloodPressure ?? '—',
                unit: 'mmHg',
                backgroundColor: Colors.blue.shade50,
                iconColor: Colors.blue.shade600,
              ),
              VitalSignCard(
                icon: Icons.thermostat,
                label: 'Temperature',
                value: _fmtNum(latest!.temperature),
                unit: '°C',
                backgroundColor: Colors.orange.shade50,
                iconColor: Colors.orange.shade600,
              ),
              VitalSignCard(
                icon: Icons.water_drop,
                label: 'Oxygen Level',
                value: _fmtNum(latest!.oxygenLevel),
                unit: '%',
                backgroundColor: Colors.cyan.shade50,
                iconColor: Colors.cyan.shade600,
              ),
            ],
          ),
      ],
    );
  }
}

// Placeholder shown when a patient has no recorded vitals.
class _NoVitalsPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.monitor_heart_outlined,
              size: 32, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text(
            'No vital signs recorded yet',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

// AI Analysis Card — shows the backend's aiPrediction for the latest reading.
class AiAnalysisCard extends StatelessWidget {
  final VitalModel vital;

  const AiAnalysisCard({super.key, required this.vital});

  Color _riskColor(String? level) {
    switch ((level ?? '').toLowerCase()) {
      case 'high':
        return Colors.red.shade600;
      case 'medium':
        return Colors.orange.shade700;
      case 'low':
        return Colors.green.shade600;
      default:
        return AppColors.skyBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final risk = vital.riskLevel;
    final confidence = vital.confidence;
    final accent = _riskColor(risk);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.indigo.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, size: 20, color: Colors.indigo.shade400),
              const SizedBox(width: 8),
              const Text(
                'AI Analysis',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              if (risk != null && risk.trim().isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${risk[0].toUpperCase()}${risk.substring(1)} risk',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: accent,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            (vital.prediction != null && vital.prediction!.trim().isNotEmpty)
                ? vital.prediction!
                : 'No prediction text provided.',
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              color: Colors.black87,
            ),
          ),
          if (confidence != null) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Text(
                  'Confidence',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
                const Spacer(),
                Text(
                  '${(confidence <= 1 ? confidence * 100 : confidence).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: (confidence <= 1 ? confidence : confidence / 100)
                    .clamp(0.0, 1.0)
                    .toDouble(),
                minHeight: 6,
                backgroundColor: Colors.indigo.shade100,
                valueColor: AlwaysStoppedAnimation<Color>(accent),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// EMG Reading Card
class EmgReadingCard extends StatelessWidget {
  final num value;

  const EmgReadingCard({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    final inRange = value >= 20 && value <= 80;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.show_chart, size: 20, color: Colors.purple.shade700),
              const SizedBox(width: 8),
              const Text(
                'Muscle Activity',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Text(
                _fmtNum(value),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade700,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'µV',
                style: TextStyle(fontSize: 14, color: Colors.purple.shade700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Latest reading',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                inRange ? Icons.check_circle : Icons.warning_amber_rounded,
                size: 16,
                color: inRange ? Colors.green.shade600 : Colors.orange.shade700,
              ),
              const SizedBox(width: 6),
              Text(
                inRange
                    ? 'Normal range (20-80 µV)'
                    : 'Outside normal range (20-80 µV)',
                style: TextStyle(
                  fontSize: 12,
                  color:
                      inRange ? Colors.green.shade700 : Colors.orange.shade800,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// commit update
 