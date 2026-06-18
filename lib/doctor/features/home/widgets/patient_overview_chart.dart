import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';




class PatientOverviewChart extends StatefulWidget {

  const PatientOverviewChart({Key? key}) : super(key: key);

  @override
  State<PatientOverviewChart> createState() => _PatientOverviewChartState();
}

class _PatientOverviewChartState extends State<PatientOverviewChart> {
  int touchedIndex = 3; // Default to Emma W.



  @override
  Widget build(BuildContext context) {
    // Static vitals data (real sample)
    final List<Map<String, dynamic>> vitals = [
      {'time': '00:00', 'bp': 120, 'hr': 72},
      {'time': '04:00', 'bp': 118, 'hr': 68},
      {'time': '08:00', 'bp': 122, 'hr': 75},
      {'time': '12:00', 'bp': 125, 'hr': 80},
      {'time': '16:00', 'bp': 121, 'hr': 76},
      {'time': '20:00', 'bp': 119, 'hr': 70},
      {'time': '23:59', 'bp': 120, 'hr': 0},
    ];
    final names = vitals.map((v) => v['time'] as String).toList();
    final bpRatings = vitals.map((v) => (v['bp'] as num).toDouble()).toList();
    final hrRatings = vitals.map((v) => (v['hr'] as num).toDouble()).toList();

        return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
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
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 130,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => Colors.white,
                    tooltipBorder: BorderSide(color: Colors.grey.withOpacity(0.2)),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        // Show both BP and HR in tooltip based on rod index
                        if (rodIndex == 0) {
                          return BarTooltipItem(
                            '${names[groupIndex]}: ${rod.toY.toInt()} BP',
                            const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            children: [],
                          );
                        } else {
                          return BarTooltipItem(
                            '${names[groupIndex]}: ${rod.toY.toInt()} HR',
                            const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            children: [],
                          );
                        }
                    },
                  ),
                  touchCallback: (FlTouchEvent event, barTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          barTouchResponse == null ||
                          barTouchResponse.spot == null) {
                        // Keep the last touched index visible
                        return;
                      }
                      touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
                    });
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                          if (value < 0 || value >= names.length) return const SizedBox();
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              names[value.toInt()],
                              style: const TextStyle(color: Colors.grey, fontSize: 10),
                            ),
                          );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    axisNameWidget: const Text("BP (mmHg)", style: TextStyle(fontSize: 10)),
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
                barGroups: List.generate(names.length, (i) {
                  return _makeGroupData(i, bpRatings[i], hrRatings[i], isSelected: touchedIndex == i);
                }),
              ),
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

  BarChartGroupData _makeGroupData(int x, double bp, double hr, {bool isSelected = false}) {
    return BarChartGroupData(
      x: x,
      showingTooltipIndicators: isSelected ? [0, 1] : [],
      barRods: [
        // BP rod
        BarChartRodData(
          toY: bp,
          color: Colors.blue,
          width: 12,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
          backDrawRodData: BackgroundBarChartRodData(
            show: isSelected,
            toY: 130,
            color: Colors.blue.withOpacity(0.2),
          ),
        ),
        // HR rod
        BarChartRodData(
          toY: hr,
          color: Colors.red,
          width: 12,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
          backDrawRodData: BackgroundBarChartRodData(
            show: isSelected,
            toY: 130,
            color: Colors.red.withOpacity(0.2),
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

// commit update
 