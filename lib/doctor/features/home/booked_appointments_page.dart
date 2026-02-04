import 'package:flutter/material.dart';
import 'package:grad_project/doctor/features/home/model/constant.dart';
import 'package:grad_project/doctor/features/home/widgets/appointment_card.dart';
import 'package:grad_project/doctor/features/home/widgets/appointment_filters.dart';

class BookedAppointmentsPage extends StatefulWidget {
  const BookedAppointmentsPage({super.key});

  @override
  State<BookedAppointmentsPage> createState() => _BookedAppointmentsPageState();
}

class _BookedAppointmentsPageState extends State<BookedAppointmentsPage> {
  int _selectedFilterIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          "Appointments",
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "Manage upcoming, pending, and completed patient appointments",
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ),
                const SizedBox(height: 20),
                AppointmentFilters(
                  selectedIndex: _selectedFilterIndex,
                  filters: filters,
                  onSelected: (index) {
                    setState(() {
                      _selectedFilterIndex = index;
                    });
                  },
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                return AppointmentCard(data: appointments[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
