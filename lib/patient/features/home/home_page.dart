import 'package:flutter/material.dart';

import 'package:grad_project/patient/features/home/widgets.dart';

import 'blood_oxygen_screen.dart';
import 'heart_rate_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final width = media.size.width;
    final height = media.size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.05,
          ),
          child: ListView(
            children: [
              SizedBox(height: height * 0.025),

              /// Header
              Text(
                "Welcome back, Bx!",
                style: TextStyle(
                  fontSize: width * 0.055,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: height * 0.008),
              Text(
                "Track your health metrics and stay informed",
                style: TextStyle(
                  fontSize: width * 0.035,
                  color: Colors.grey,
                ),
              ),

              SizedBox(height: height * 0.035),

              Text(
                "Your Sensors",
                style: TextStyle(
                  fontSize: width * 0.045,
                  fontWeight: FontWeight.w600,
                ),
              ),

              SizedBox(height: height * 0.02),

              /// Cards
              SensorCard(
                isResponsive: true,
                width: width,
                height: height,
                icon: Icons.favorite,
                iconBg: const Color(0xFFFFE9E9),
                iconColor: Colors.red,
                title: "Heart Rate",
                subtitle: "Monitor your heart rate in real-time",
                buttonText: "Start Measurement",
                buttonColor: Colors.red,
                onButtonPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HeartRateScreen(),
                    ),
                  );
                },
              ),

              SizedBox(height: height * 0.02),

              SensorCard(
                isResponsive: true,
                width: width,
                height: height,
                icon: Icons.show_chart,
                iconBg: const Color(0xFFE8F0FF),
                iconColor: Colors.blue,
                title: "Blood Oxygen",
                subtitle: "Track your oxygen saturation levels",
                buttonText: "Start Measurement",
                buttonColor: Colors.blue,
                onButtonPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BloodOxygenScreen(),
                    ),
                  );
                },
              ),

              SizedBox(height: height * 0.04),

              /// Recent Measurements
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Recent Measurements",
                    style: TextStyle(
                      fontSize: width * 0.045,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "View All",
                    style: TextStyle(
                      fontSize: width * 0.035,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),

              SizedBox(height: height * 0.02),

              RecentMeasurementCard(
                width: width,
                height: height,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
