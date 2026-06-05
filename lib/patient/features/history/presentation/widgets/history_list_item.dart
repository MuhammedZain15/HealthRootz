import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:grad_project/core/models/vital_model.dart';
import 'package:grad_project/app_colors.dart';

class HistoryListItem extends StatelessWidget {
  final VitalModel vital;
  final VoidCallback onTap;

  const HistoryListItem({super.key, required this.vital, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final DateTime date = vital.createdAt != null 
        ? DateTime.tryParse(vital.createdAt!) ?? DateTime.now() 
        : DateTime.now();
    final df = DateFormat("MMM d, yyyy");
    final tf = DateFormat("h:mm a");

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.skyBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.favorite_rounded, color: AppColors.skyBlue, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Vitals Check",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "${df.format(date)} • ${tf.format(date)}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.grey,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildVitalMetric(Icons.favorite, "Heart Rate", "${vital.heartRate ?? '--'} bpm", Colors.redAccent)),
                Expanded(child: _buildVitalMetric(Icons.bloodtype, "Blood Press.", vital.bloodPressure ?? '--', Colors.blueAccent)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildVitalMetric(Icons.thermostat, "Temperature", "${vital.temperature ?? '--'} °C", Colors.orangeAccent)),
                Expanded(child: _buildVitalMetric(Icons.air, "Oxygen Lvl", "${vital.oxygenLevel ?? '--'} %", Colors.green)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVitalMetric(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color.withOpacity(0.7)),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
