import 'package:flutter/material.dart';
import '../../data/measurement_model.dart';

class MeasurementDetailStats extends StatelessWidget {
  final MeasurementRecord record;

  const MeasurementDetailStats({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.8,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _StatTile(
          label: "Current",
          value: "${record.currentValue.toInt()} ${record.unit}",
        ),
        _StatTile(
          label: "Status",
          value: record.status,
          valueColor: record.status.toLowerCase() == "normal"
              ? const Color(0xFF22C55E)
              : Colors.orange,
        ),
        _StatTile(label: "Duration", value: record.duration),
        _StatTile(
          label: "Average",
          value: "${record.averageValue.toInt()} ${record.unit}",
        ),
        _StatTile(
          label: "Max",
          value: "${record.maxValue.toInt()} ${record.unit}",
        ),
        _StatTile(
          label: "Min",
          value: "${record.minValue.toInt()} ${record.unit}",
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _StatTile({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: valueColor ?? Colors.black,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
