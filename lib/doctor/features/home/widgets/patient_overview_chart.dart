import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PatientOverviewChart extends StatelessWidget {
  const PatientOverviewChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Patient Overview (Last 24 Hours)",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: Stack(
              children: [
                BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 100,
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const titles = ['John S.', 'Sarah J.', 'Mike B.', 'Emma W.', 'David L.'];
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                titles[value.toInt()],
                                style: const TextStyle(color: Colors.grey, fontSize: 10),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        axisNameWidget: const Text("Health Rating", style: TextStyle(fontSize: 10)),
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            if (value % 25 == 0) {
                              return Text(value.toInt().toString(), style: const TextStyle(color: Colors.grey, fontSize: 10));
                            }
                            return const SizedBox();
                          },
                        ),
                      ),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Colors.grey.withOpacity(0.1),
                        strokeWidth: 1,
                        dashArray: [5, 5],
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: [
                      _makeGroupData(0, 85, Colors.black),
                      _makeGroupData(1, 62, Colors.black),
                      _makeGroupData(2, 78, Colors.black),
                      _makeGroupData(3, 92, Colors.black, isSelected: true),
                      _makeGroupData(4, 58, Colors.black),
                    ],
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 150,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
                    ),
                    child: const Column(
                      children: [
                        Text("Emma W.", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        Text("rating : 92", style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildPatientRating('John S.', '85%', Colors.green, true),
              _buildPatientRating('Sarah J.', '62%', Colors.orange, false),
              _buildPatientRating('Mike B.', '78%', Colors.green, true),
              _buildPatientRating('Emma W.', '92%', Colors.green, true),
              _buildPatientRating('David L.', '58%', Colors.red, false),
            ],
          )
        ],
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y, Color color, {bool isSelected = false}) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 30,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
          backDrawRodData: BackgroundBarChartRodData(
            show: isSelected,
            toY: 100,
            color: Colors.grey.withOpacity(0.2),
          ),
        ),
      ],
    );
  }

  Widget _buildPatientRating(String name, String rating, Color color, bool isUp) {
    return Column(
      children: [
        Stack(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(color: isUp ? Colors.green : Colors.red, shape: BoxShape.circle),
                child: Icon(isUp ? Icons.arrow_upward : Icons.arrow_downward, color: Colors.white, size: 10),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(name, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Text(rating, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}
