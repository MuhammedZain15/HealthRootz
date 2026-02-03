import 'package:flutter/material.dart';
import 'package:grad_project/doctor/features/alert/widgets/alert_card.dart';
import 'package:grad_project/doctor/features/alert/widgets/summary_card.dart';

import 'model/alert_model.dart';
import 'model/constants.dart';

class DoctorAlertPage extends StatefulWidget {
  const DoctorAlertPage({super.key});

  @override
  State<DoctorAlertPage> createState() => _DoctorAlertPageState();
}

class _DoctorAlertPageState extends State<DoctorAlertPage> {
  late List<DoctorAlert> _localAlerts;

  @override
  void initState() {
    super.initState();
    _localAlerts = List.from(alerts);
  }

  void _markAsSolved(int index) {
    setState(() {
      final oldAlert = _localAlerts[index];
      _localAlerts[index] = DoctorAlert(
        id: oldAlert.id,
        patient: oldAlert.patient,
        type: oldAlert.type,
        severity: AlertSeverity.resolved,
        message: oldAlert.message,
        time: oldAlert.time,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Title
              const Text(
                'Alerts Center',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D1B34),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Monitor all patient alerts and critical events',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),

              // Summary Cards
              const Row(
                children: [
                  SummaryCard(
                    count: '2',
                    label: 'Critical Alerts',
                    countColor: Color(0xFFD32F2F),
                    // Red
                    backgroundColor: Color(0xFFFFF0F0),
                    borderColor: Color(0xFFFFCCC7),
                  ),
                  SizedBox(width: 12),
                  SummaryCard(
                    count: '3',
                    label: 'Warning Alerts',
                    countColor: Color(0xFFF57F17),
                    // Dark Chartreuse/Orange
                    backgroundColor: Color(0xFFFFFBE6),
                    borderColor: Color(0xFFFFE58F),
                  ),
                  SizedBox(width: 12),
                  SummaryCard(
                    count: '2',
                    label: 'Resolved',
                    countColor: Color(0xFF4A628A),
                    // Dark Blue/Grey
                    backgroundColor: Color(0xFFF0F5FF),
                    borderColor: Color(0xFFD6E4FF),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Filter Button & Count
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.filter_list,
                      size: 18,
                      color: Colors.black87,
                    ),
                    label: const Text(
                      "All Alerts",
                      style: TextStyle(color: Colors.black87),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                "Showing ${_localAlerts.length} of ${_localAlerts.length} alerts",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 12),
              // List of Alerts
              Expanded(
                child: ListView.builder(
                  itemCount: _localAlerts.length,
                  itemBuilder: (context, index) {
                    return AlertCard(
                      alert: _localAlerts[index],
                      onMarkSolved: () => _markAsSolved(index),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
