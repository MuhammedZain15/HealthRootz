import 'package:flutter/material.dart';
import 'package:grad_project/app_colors.dart';
import 'package:grad_project/doctor/features/patients/patient_page.dart';
import 'package:grad_project/doctor/features/reports/reports_page.dart';

import 'features/alert/doctor_alert_page.dart';
import 'features/chat/doctor_chat_page.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grad_project/core/cubit/auth_cubit.dart';
import 'package:grad_project/patient/features/patient/data/repositories/patient_repository_impl.dart';
import 'package:grad_project/patient/features/patient/viewmodel/patient_cubit.dart';
import 'features/home/doctor_home_page.dart';
import 'features/profile/doctor_profile_page.dart';
class DoctorAppLayout extends StatelessWidget {
  const DoctorAppLayout({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocProvider<PatientCubit>(
      create: (context) => PatientCubit(
        PatientRepositoryImpl(),
      ),
      child: const _DoctorAppLayoutContent(),
    );
  }
}
class _DoctorAppLayoutContent extends StatefulWidget {
  const _DoctorAppLayoutContent();

  @override
  State<_DoctorAppLayoutContent> createState() => _AppLayoutState();
}
class _AppLayoutState extends State<_DoctorAppLayoutContent> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
  }
  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final user = authState.user;
    final doctorName = user?.name ?? 'Doctor';

    final List<Widget> pages = [
      DoctorHomePage(
        doctorName: doctorName,
        onNavigateToReports: () => _onItemTapped(3),
      ),
      const PatientPage(),
      const DoctorAlertPage(),
      const ReportsPage(),
      const DoctorChatPage(),
      const DoctorProfilePage(),
    ];
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).cardColor,
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
// commit update
 