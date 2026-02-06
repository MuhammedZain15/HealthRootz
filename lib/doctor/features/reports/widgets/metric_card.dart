import 'package:flutter/material.dart';

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final String minMax;
  final String abnormal;
  final Color tint;
  final Color accent;

  const MetricCard({
    super.key,
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
          Text(subtitle, style: TextStyle(color: accent.withOpacity(0.8))),
          const SizedBox(height: 8),
          Text(minMax, style: const TextStyle(color: Color(0xFF374151))),
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
