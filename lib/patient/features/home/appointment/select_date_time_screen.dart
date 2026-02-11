import 'package:flutter/material.dart';
import 'package:grad_project/app_colors.dart';

import 'appointment_widgets.dart';
import 'confirm_booking_screen.dart';

class SelectDateTimeScreen extends StatefulWidget {
  final String doctorName;
  final String specialty;

  const SelectDateTimeScreen({
    super.key,
    required this.doctorName,
    required this.specialty,
  });

  @override
  State<SelectDateTimeScreen> createState() => _SelectDateTimeScreenState();
}

class _SelectDateTimeScreenState extends State<SelectDateTimeScreen> {
  int _selectedDateIndex = -1;
  int _selectedTimeIndex = -1;

  void _checkAndNavigate() {
    if (_selectedDateIndex != -1 && _selectedTimeIndex != -1) {
      // Simulate a small delay for better UX
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          // Determine date/time string based on index (mock logic)
          final days = [
            {'day': 'Mon', 'date': '9 Feb'},
            {'day': 'Tue', 'date': '10 Feb'},
            {'day': 'Wed', 'date': '11 Feb'},
            {'day': 'Thu', 'date': '12 Feb'},
            {'day': 'Fri', 'date': '13 Feb'},
          ];
          final times = [
            "09:00 AM",
            "09:30 AM",
            "10:00 AM",
            "10:30 AM",
            "11:00 AM",
            "11:30 AM",
            "12:00 PM",
            "12:30 PM",
            "01:00 PM",
            "01:30 PM",
            "02:00 PM",
            "02:30 PM",
            "03:00 PM",
            "03:30 PM",
            "04:00 PM",
            "04:30 PM",
            "05:00 PM",
            "05:30 PM",
            "06:00 PM",
            "06:30 PM",
            "07:00 PM",
            "07:30 PM",
            "08:00 PM",
            "08:30 PM",
            "09:00 PM",
            "09:30 PM",
            "10:00 PM",
            "10:30 PM",
            "11:00 PM",
            "11:30 PM",
            "12:00 AM",
          ];

          final dateStr = days[_selectedDateIndex]['date']!;
          final timeStr = times[_selectedTimeIndex];
          // Assuming year 2026 as per context
          final fullDate = "${days[_selectedDateIndex]['day']}, $dateStr, 2026";

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ConfirmBookingScreen(
                doctorName: widget.doctorName,
                specialty: widget.specialty,
                date: fullDate,
                time: timeStr,
              ),
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppointmentHeader(
                title: "Book Appointment",
                subtitle: "Select date & time",
                onBack: () => Navigator.pop(context),
              ),
              const StepProgressBar(
                currentStep: 2,
                totalSteps: 2,
              ), // Step 2 is active
              const SizedBox(height: 32),

              // Selected Doctor Summary
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.skyBlue.withOpacity(0.1),
                      child: Text(
                        widget.doctorName.substring(0, 1),
                        style: TextStyle(
                          color: AppColors.skyBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.doctorName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        Text(
                          widget.specialty,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              DateSelector(
                selectedIndex: _selectedDateIndex,
                onSelected: (index) {
                  setState(() {
                    _selectedDateIndex = index;
                  });
                  _checkAndNavigate();
                },
              ),
              const SizedBox(height: 32),

              TimeSlotGrid(
                selectedIndex: _selectedTimeIndex,
                onSelected: (index) {
                  setState(() {
                    _selectedTimeIndex = index;
                  });
                  _checkAndNavigate();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
