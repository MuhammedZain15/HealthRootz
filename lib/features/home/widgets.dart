import 'package:flutter/material.dart';

class SensorCard extends StatelessWidget {
  final bool isResponsive;
  final double width;
  final double height;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String buttonText;
  final Color buttonColor;
  final VoidCallback? onButtonPressed;

  const SensorCard({
    super.key,
    required this.isResponsive,
    required this.width,
    required this.height,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.buttonColor,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(width * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(width * 0.04),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: width * 0.04,
            offset: Offset(0, height * 0.01),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: width * 0.12,
                height: width * 0.12,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(width * 0.03),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: width * 0.06,
                ),
              ),
              SizedBox(width: width * 0.03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: width * 0.04,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: height * 0.005),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: width * 0.033,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: height * 0.02),

          SizedBox(
            width: double.infinity,
            height: height * 0.055,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(width * 0.03),
                ),
              ),
              onPressed: onButtonPressed,
              child: Text(
                buttonText,
                style: TextStyle(
                  fontSize: width * 0.035,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RecentMeasurementCard extends StatelessWidget {
  final double width;
  final double height;

  const RecentMeasurementCard({
    super.key,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(width * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(width * 0.04),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: width * 0.04,
            offset: Offset(0, height * 0.01),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: width * 0.015,
            height: height * 0.05,
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(width * 0.01),
            ),
          ),
          SizedBox(width: width * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Heart Rate",
                  style: TextStyle(
                    fontSize: width * 0.038,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: height * 0.005),
                Text(
                  "82 BPM",
                  style: TextStyle(
                    fontSize: width * 0.034,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: width * 0.035,
                    color: Colors.grey,
                  ),
                  SizedBox(width: width * 0.01),
                  Text(
                    "2:19 PM",
                    style: TextStyle(
                      fontSize: width * 0.03,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              SizedBox(height: height * 0.005),
              Text(
                "Jan 25, 2026",
                style: TextStyle(
                  fontSize: width * 0.03,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
