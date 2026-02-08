import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:grad_project/app_colors.dart';

class EmgReadingCard extends StatelessWidget {
  final String date;
  final String time;

  const EmgReadingCard({super.key, required this.date, required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.lightSeaGreen.withOpacity(
          0.1,
        ), // Light lime background
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Latest Reading",
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: const [
              Text(
                "85",
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              SizedBox(width: 4),
              Text(
                "µV",
                style: TextStyle(
                  fontSize: 20,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.trending_up, size: 16, color: Color(0xFF22C55E)),
              SizedBox(width: 4),
              Text(
                "Normal Range",
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF22C55E),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "$time - $date",
            style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}

class EmgToggleOption extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const EmgToggleOption({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.lightSeaGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }
}

class EmgStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;

  const EmgStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              textBaseline: TextBaseline.alphabetic,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                if (unit.isNotEmpty) ...[
                  const SizedBox(width: 2),
                  Text(
                    unit,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class EmgChart extends StatelessWidget {
  final bool is24HoursSelected;
  final List<FlSpot> spots;

  const EmgChart({
    super.key,
    required this.is24HoursSelected,
    required this.spots,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              Text(
                is24HoursSelected
                    ? "Readings (24 Hours)"
                    : "Readings (Last Week)",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
              const Icon(
                Icons.calendar_today_outlined,
                size: 20,
                color: Color(0xFF64748B),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(height: 250, child: LineChart(_mainData())),
        ],
      ),
    );
  }

  LineChartData _mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 25, // y-axis lines every 25 units
        verticalInterval: is24HoursSelected ? 4 : 1, // x-axis lines
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: const Color(0xffe7e8ec),
            strokeWidth: 1,
            dashArray: [5, 5],
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: const Color(0xffe7e8ec),
            strokeWidth: 1,
            dashArray: [5, 5],
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: is24HoursSelected ? 4 : 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 25,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: const Border(
          bottom: BorderSide(color: Color(0xffe7e8ec), width: 1),
          left: BorderSide(color: Color(0xffe7e8ec), width: 1),
        ),
      ),
      minX: 0,
      maxX: is24HoursSelected ? 24 : 6,
      minY: 0,
      maxY: 100,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: AppColors.lightSeaGreen,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: Colors.white,
                strokeWidth: 2,
                strokeColor: AppColors.lightSeaGreen,
              );
            },
            checkToShowDot: (spot, barData) {
              // Only modify interaction if needed
              return false;
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.lightSeaGreen.withOpacity(0.3),
                AppColors.lightSeaGreen.withOpacity(0.0),
              ],
            ),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
            return touchedBarSpots.map((barSpot) {
              final flSpot = barSpot;

              String timeLabel = "";
              if (is24HoursSelected) {
                timeLabel = "${flSpot.x.toInt()}:00";
              } else {
                const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                if (flSpot.x.toInt() >= 0 && flSpot.x.toInt() < days.length) {
                  timeLabel = days[flSpot.x.toInt()];
                }
              }

              return LineTooltipItem(
                '$timeLabel\n',
                const TextStyle(
                  color: Color(0xFF1E293B),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                children: [
                  TextSpan(
                    text: 'EMG : ${flSpot.y.toInt()} µV',
                    style: const TextStyle(
                      color: AppColors.lightSeaGreen,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              );
            }).toList();
          },
        ),
        handleBuiltInTouches: true,
      ),
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xFF94A3B8),
      fontWeight: FontWeight.w500,
      fontSize: 12,
    );
    Widget text;
    if (is24HoursSelected) {
      switch (value.toInt()) {
        case 0:
          text = const Text('00:00', style: style);
          break;
        case 4:
          text = const Text('04:00', style: style);
          break;
        case 8:
          text = const Text('08:00', style: style);
          break;
        case 12:
          text = const Text('12:00', style: style);
          break;
        case 16: // 16:00 but space might be tight so skipped or shown
          text = const Text('', style: style);
          break;
        case 20:
          text = const Text('20:00', style: style);
          break;
        default:
          text = const Text('', style: style);
          break;
      }
    } else {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      if (value.toInt() >= 0 && value.toInt() < days.length) {
        text = Text(days[value.toInt()], style: style);
      } else {
        text = const Text('', style: style);
      }
    }

    return text;
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xFF94A3B8),
      fontWeight: FontWeight.w500,
      fontSize: 12,
    );
    String text;
    if (value == 0 ||
        value == 25 ||
        value == 50 ||
        value == 75 ||
        value == 100) {
      text = '${value.toInt()}';
    } else {
      text = '';
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }
}
