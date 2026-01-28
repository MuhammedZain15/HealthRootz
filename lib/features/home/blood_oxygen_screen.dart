import 'dart:async';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BloodOxygenScreen extends StatefulWidget {
  const BloodOxygenScreen({super.key});

  @override
  State<BloodOxygenScreen> createState() => _BloodOxygenScreenState();
}

class _BloodOxygenScreenState extends State<BloodOxygenScreen> {
  bool isHistorySelected = true;
  bool isMeasuring = false;

  int currentSpo2 = 98;
  final List<FlSpot> spots = [];
  Timer? timer;
  double xValue = 0;

  final TextEditingController _chatController = TextEditingController();
  final List<String> _messages = [];

  @override
  void dispose() {
    timer?.cancel();
    _chatController.dispose();
    super.dispose();
  }

  void startMeasurement() {
    if (isMeasuring) return;

    setState(() {
      isMeasuring = true;
      spots.clear();
      xValue = 0;
    });

    timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      final random = Random();
      // SpO2 usually stays between 95-100
      currentSpo2 = 95 + random.nextInt(6);

      xValue += 1;
      spots.add(FlSpot(xValue, currentSpo2.toDouble()));

      if (spots.length > 20) {
        spots.removeAt(0);
      }

      setState(() {});
    });
  }

  void _sendMessage() {
    if (_chatController.text.isNotEmpty) {
      setState(() {
        _messages.add(_chatController.text);
        _chatController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: width * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header
              Text(
                "Blood Oxygen",
                style: TextStyle(
                  fontSize: width * 0.06,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: height * 0.03),

              /// Measurement Card
              Container(
                padding: EdgeInsets.all(width * 0.06),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(width * 0.05),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    /// SpO2 Circle
                    Container(
                      width: width * 0.45,
                      height: width * 0.45,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.blue, width: 8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isMeasuring ? "$currentSpo2" : "--",
                            style: TextStyle(
                              fontSize: width * 0.12,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const Text("% SpO2"),
                        ],
                      ),
                    ),

                    SizedBox(height: height * 0.04),

                    /// Start Button
                    ElevatedButton(
                      onPressed: startMeasurement,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize:
                        Size(double.infinity, height * 0.065),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(width * 0.03),
                        ),
                      ),
                      child: const Text(
                        "Start Measurement",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: height * 0.03),

              /// Tabs
              Row(
                children: [
                  _buildTab("History Graph", true, width),
                  _buildTab("Health Chat", false, width),
                ],
              ),

              SizedBox(height: height * 0.03),

              /// Content
              isHistorySelected
                  ? _buildGraph(width, height)
                  : _buildHealthChat(width, height),

              SizedBox(height: height * 0.05),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String text, bool history, double width) {
    final selected = history == isHistorySelected;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => isHistorySelected = history),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: width * 0.035,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGraph(double width, double height) {
    return Container(
      padding: EdgeInsets.all(width * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(width * 0.04),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      height: height * 0.3,
      child: LineChart(
        LineChartData(
          minY: 90,
          maxY: 100,
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              dotData: FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthChat(double width, double height) {
    return Container(
      padding: EdgeInsets.all(width * 0.05),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(width * 0.04),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Ask me anything about your blood oxygen!",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (_messages.isNotEmpty)
            Column(
              children: _messages.map((msg) => Align(
                alignment: Alignment.centerRight,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(msg),
                ),
              )).toList(),
            ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _chatController,
                  decoration: InputDecoration(
                    hintText: "Describe your symptoms...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.blue),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
