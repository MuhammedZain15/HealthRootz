import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:grad_project/patient/features/home/emg_widgets.dart';

class EmgScreen extends StatefulWidget {
  const EmgScreen({super.key});

  @override
  State<EmgScreen> createState() => _EmgScreenState();
}

class _EmgScreenState extends State<EmgScreen> {
  bool is24HoursSelected = true;

  // Mock data for 24 Hours - matching the curve in screenshot
  final List<FlSpot> spots24h = [
    const FlSpot(0, 45),
    const FlSpot(2, 43),
    const FlSpot(4, 42), // dip
    const FlSpot(6, 50),
    const FlSpot(8, 75), // sharp rise
    const FlSpot(10, 82),
    const FlSpot(12, 85), // peak
    const FlSpot(14, 80),
    const FlSpot(16, 73),
    const FlSpot(18, 69),
    const FlSpot(20, 66),
    const FlSpot(22, 65),
    const FlSpot(24, 63),
  ];

  // Mock data for Last Week
  final List<FlSpot> spotsWeek = [
    const FlSpot(0, 60), // Mon
    const FlSpot(1, 70), // Tue
    const FlSpot(2, 85), // Wed
    const FlSpot(3, 65), // Thu
    const FlSpot(4, 55), // Fri
    const FlSpot(5, 45), // Sat
    const FlSpot(6, 50), // Sun
  ];

  List<FlSpot> get currentSpots => is24HoursSelected ? spots24h : spotsWeek;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "Back",
          style: TextStyle(color: Color(0xFF1E293B), fontSize: 16),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
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
              const Text(
                "EMG Activity",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const Text(
                "Reading Details",
                style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 20),

              // Main Reading Card
              const EmgReadingCard(time: "7:23 PM", date: "Feb 6, 2026"),
              const SizedBox(height: 24),

              // Time Range Toggle
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    EmgToggleOption(
                      text: "Last 24 Hours",
                      isSelected: is24HoursSelected,
                      onTap: () {
                        setState(() {
                          is24HoursSelected = true;
                        });
                      },
                    ),
                    EmgToggleOption(
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
              EmgChart(
                is24HoursSelected: is24HoursSelected,
                spots: currentSpots,
              ),
              const SizedBox(height: 24),

              // Stats Row
              Row(
                children: const [
                  EmgStatCard(title: "Minimum", value: "42", unit: "µV"),
                  SizedBox(width: 12),
                  EmgStatCard(title: "Average", value: "68", unit: "µV"),
                  SizedBox(width: 12),
                  EmgStatCard(title: "Maximum", value: "85", unit: "µV"),
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
