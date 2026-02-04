import 'package:flutter/material.dart';
import 'package:grad_project/app_colors.dart';
import 'package:grad_project/doctor/features/patients/patient_page.dart';
import 'package:grad_project/doctor/features/reports/reports_page.dart';

import 'features/alert/doctor_alert_page.dart';
import 'features/chat/doctor_chat_page.dart';

import 'features/home/doctor_home_page.dart';
import 'features/profile/doctor_profile_page.dart';

class DoctorAppLayout extends StatefulWidget {
  const DoctorAppLayout({super.key});

  @override
  State<DoctorAppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<DoctorAppLayout> {
  int _selectedIndex = 0;

  // Profile State
  String name = "Dr. Anderson";
  String email = "anderson@healthrootz.com";
  String phone = "+1 (555) 123-4567";
  String specialty = "Cardiology";
  String licenseNumber = "MD-123456";
  String address = "123 Medical Center, New York, NY 10001";

  void _updateProfile(Map<String, String> newData) {
    setState(() {
      name = newData['name'] ?? name;
      email = newData['email'] ?? email;
      phone = newData['phone'] ?? phone;
      specialty = newData['specialty'] ?? specialty;
      licenseNumber = newData['licenseNumber'] ?? licenseNumber;
      address = newData['address'] ?? address;
    });
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      DoctorHomePage(doctorName: name),
      const PatientPage(),
      const DoctorAlertPage(),
      const ReportsPage(),
      const DoctorChatPage(),
      DoctorProfilePage(
        initialData: {
          'name': name,
          'email': email,
          'phone': phone,
          'specialty': specialty,
          'licenseNumber': licenseNumber,
          'address': address,
        },
        onProfileUpdate: _updateProfile,
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(

        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.skyBlue,
        unselectedItemColor: const Color(0xff6B7280),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outlined),
            activeIcon: Icon(Icons.people),
            label: 'Patients',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none),
            activeIcon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insert_drive_file_outlined),
            activeIcon: Icon(Icons.insert_drive_file),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.messenger_outline),
            activeIcon: Icon(Icons.messenger),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
