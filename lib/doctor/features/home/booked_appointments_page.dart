import 'package:flutter/material.dart';

class BookedAppointmentsPage extends StatelessWidget {
  const BookedAppointmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text("Booked Appointments", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) {
          final appointments = [
            {'name': 'John Smith', 'time': '09:00 AM', 'type': 'Check-up', 'date': 'Today'},
            {'name': 'Sarah Johnson', 'time': '10:30 AM', 'type': 'Follow-up', 'date': 'Today'},
            {'name': 'Michael Brown', 'time': '01:00 PM', 'type': 'Consultation', 'date': 'Today'},
            {'name': 'Emma Wilson', 'time': '03:30 PM', 'type': 'Check-up', 'date': 'Tomorrow'},
            {'name': 'David Lee', 'time': '11:00 AM', 'type': 'Surgery Follow-up', 'date': 'Tomorrow'},
          ];
          final appt = appointments[index];
          
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.calendar_today, color: Colors.blue, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(appt['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text("${appt['type']} • ${appt['date']}", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                    ],
                  ),
                ),
                Text(
                  appt['time']!,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
