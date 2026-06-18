import 'package:flutter/material.dart';

class HistorySummaryCards extends StatelessWidget {
  final int readingsCount;
  final int visitsCount;
  final int thisWeekCount;

  const HistorySummaryCards({
    super.key,
    required this.readingsCount,
    required this.visitsCount,
    required this.thisWeekCount,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _SummaryCard(
            icon: Icons.show_chart,
            count: readingsCount.toString(),
            label: "Readings",
            color: Colors.blue,
          ),
          const SizedBox(width: 12),
          _SummaryCard(
            icon: Icons.calendar_today,
            count: visitsCount.toString(),
            label: "Visits",
            color: Colors.purple,
          ),
          const SizedBox(width: 12),
          _SummaryCard(
            icon: Icons.access_time,
            count: thisWeekCount.toString(),
            label: "This Week",
            color: Colors.green,
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String count;
  final String label;
  final Color color;

  const _SummaryCard({
    required this.icon,
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 110,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
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
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            count,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// commit update
 