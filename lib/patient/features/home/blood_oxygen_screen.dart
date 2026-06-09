import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:grad_project/patient/features/home/oxygen_widgets.dart';

class BloodOxygenScreen extends StatefulWidget {
  const BloodOxygenScreen({super.key});

  @override
  State<BloodOxygenScreen> createState() => _BloodOxygenScreenState();
}

class _BloodOxygenScreenState extends State<BloodOxygenScreen> {
  bool is24HoursSelected = true;

  // Mock data for 24 Hours
  final List<FlSpot> spots24h = [
    const FlSpot(0, 97),
    const FlSpot(2, 96),
    const FlSpot(4, 96),
    const FlSpot(6, 96.5),
    const FlSpot(8, 97.5),
    const FlSpot(10, 98.2),
    const FlSpot(12, 99),
    const FlSpot(14, 98.5),
    const FlSpot(16, 98),
    const FlSpot(18, 97.8),
    const FlSpot(20, 97.5),
    const FlSpot(22, 97.2),
    const FlSpot(24, 97),
  ];

  // Mock data for Last Week
  final List<FlSpot> spotsWeek = [
    const FlSpot(0, 96), // Mon
    const FlSpot(1, 97), // Tue
    const FlSpot(2, 98), // Wed
    const FlSpot(3, 97.5), // Thu
    const FlSpot(4, 98.5), // Fri
    const FlSpot(5, 99), // Sat
    const FlSpot(6, 98), // Sun
  ];

  List<FlSpot> get currentSpots => is24HoursSelected ? spots24h : spotsWeek;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Back",
          style: TextStyle(color: onSurface, fontSize: 16),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: width * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Title
              Text(
                "Blood Oxygen Level",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: onSurface,
                ),
              ),
              Text(
                "Reading Details",
                style: TextStyle(
                  fontSize: 14,
                  color: onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 20),

              // Main Reading Card
              const OxygenReadingCard(time: "7:23 PM", date: "Feb 6, 2026"),
              const SizedBox(height: 24),

              // Time Range Toggle
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                ),
                child: Row(
                  children: [
                    OxygenToggleOption(
                      text: "Last 24 Hours",
                      isSelected: is24HoursSelected,
                      onTap: () {
                        setState(() {
                          is24HoursSelected = true;
                        });
                      },
                    ),
                    OxygenToggleOption(
                      text: "Last Week",
                      isSelected: !is24HoursSelected,
                      onTap: () {
                        setState(() {
                          is24HoursSelected = false;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Chart Card
              OxygenChart(
                is24HoursSelected: is24HoursSelected,
                spots: currentSpots,
              ),
              const SizedBox(height: 24),

              // Stats Row
              Row(
                children: const [
                  OxygenStatCard(title: "Minimum", value: "96%"),
                  SizedBox(width: 12),
                  OxygenStatCard(title: "Average", value: "98%"),
                  SizedBox(width: 12),
                  OxygenStatCard(title: "Maximum", value: "99%"),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
