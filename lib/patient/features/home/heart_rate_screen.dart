import 'dart:async';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class HeartRateScreen extends StatefulWidget {
  const HeartRateScreen({super.key});

  @override
  State<HeartRateScreen> createState() => _HeartRateScreenState();
}

class _HeartRateScreenState extends State<HeartRateScreen> {
  bool isHistorySelected = true;
  bool isMeasuring = false;

  int currentBpm = 72;
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

    timer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      final random = Random();
      // More realistic heartbeat fluctuation
      currentBpm = 70 + (sin(xValue * 0.5) * 5).toInt() + random.nextInt(3);

      xValue += 0.5;
      spots.add(FlSpot(xValue, currentBpm.toDouble()));

      if (spots.length > 30) {
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
                "Heart Rate",
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
                    /// BPM Circle
                    Container(
                      width: width * 0.45,
                      height: width * 0.45,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.red.withOpacity(0.2), width: 8),
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.red, width: 4),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.favorite, color: Colors.red, size: width * 0.08),
                            Text(
                              isMeasuring ? "$currentBpm" : "--",
                              style: TextStyle(
                                fontSize: width * 0.12,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            const Text("BPM", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: height * 0.04),

                    /// Start Button
                    ElevatedButton(
                      onPressed: startMeasurement,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        minimumSize:
                        Size(double.infinity, height * 0.065),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(width * 0.03),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        isMeasuring ? "Measuring..." : "Start Measurement",
                        style: const TextStyle(
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
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    _buildTab("History Graph", true, width),
                    _buildTab("Health Chat", false, width),
                  ],
                ),
              ),

              SizedBox(height: height * 0.03),

              /// Content
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: isHistorySelected
                    ? _buildGraph(width, height)
                    : _buildHealthChat(width, height),
              ),

              SizedBox(height: height * 0.03),

              /// Export Buttons
              Row(
                children: [
                  Expanded(
                    child: _buildExportButton("Export Current", Icons.download, width),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildExportButton("Export All", Icons.file_download, width),
                  ),
                ],
              ),

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
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: selected ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ] : null,
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                fontSize: width * 0.035,
                color: selected ? Colors.black : Colors.grey[600],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGraph(double width, double height) {
    return Container(
      key: const ValueKey("graph"),
      padding: EdgeInsets.only(top: width * 0.06, right: width * 0.06, bottom: width * 0.02, left: width * 0.02),
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
      height: height * 0.35,
      child: LineChart(
        LineChartData(
          minY: 60,
          maxY: 90,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.withOpacity(0.1),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: TextStyle(color: Colors.grey, fontSize: width * 0.025),
                ),
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots.isEmpty ? [const FlSpot(0, 75)] : spots,
              isCurved: true,
              curveSmoothness: 0.5,
              color: Colors.red,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.red.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthChat(double width, double height) {
    return Container(
      key: const ValueKey("chat"),
      padding: EdgeInsets.all(width * 0.05),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.red[50],
                child: const Icon(Icons.support_agent, color: Colors.red),
              ),
              const SizedBox(width: 12),
              const Text(
                "Health Assistant",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(height: 32),
          if (_messages.isEmpty)
             const Padding(
               padding: EdgeInsets.symmetric(vertical: 20),
               child: Center(
                 child: Text(
                   "How can I help you today?",
                   style: TextStyle(color: Colors.grey),
                 ),
               ),
             )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _messages.length,
              itemBuilder: (context, index) => Align(
                alignment: Alignment.centerRight,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(16).copyWith(bottomRight: Radius.zero),
                  ),
                  child: Text(
                    _messages[index],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _chatController,
                  decoration: InputDecoration(
                    hintText: "Type a message...",
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _sendMessage,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.send, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExportButton(String title, IconData icon, double width) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(icon, color: Colors.black, size: width * 0.045),
      label: Text(
        title,
        style: TextStyle(
          color: Colors.black,
          fontSize: width * 0.035,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.withOpacity(0.1)),
        ),
      ),
    );
  }
}
