import 'package:flutter/material.dart';
import 'package:grad_project/app_colors.dart';
import 'package:grad_project/patient/features/alerts/alert_page.dart';
import 'package:grad_project/patient/features/history/history_page.dart';
import 'package:grad_project/patient/features/home/home_page.dart';
import 'package:grad_project/patient/features/profile/profile_page.dart';
import 'package:grad_project/patient/layout/buttom_sheet.dart';
import 'package:grad_project/patient/layout/patient_widgets.dart';

class AppLayout extends StatefulWidget {
  const AppLayout({super.key});

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    HistoryPage(),
    AlertsPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double bottomBarHeight = size.height * 0.08;

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showActionBottomSheet(context),
        shape: const CircleBorder(),
        backgroundColor: AppColors.skyBlue,
        elevation: 0, // عشان ما يطلعش ظل تحت الفلوتينج يبقا مسطح كدا
        child: Icon(Icons.add, color: Colors.white, size: size.width * 0.08),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.white,
        padding: EdgeInsets.zero,
        height: bottomBarHeight > 60 ? bottomBarHeight : 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            PatientNavItem(
              index: 0,
              selectedIndex: _selectedIndex,
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
              label: 'Home',
              width: size.width,
              onItemTapped: _onItemTapped,
            ),
            PatientNavItem(
              index: 1,
              selectedIndex: _selectedIndex,
              icon: Icons.history_outlined,
              activeIcon: Icons.history,
              label: 'History',
              width: size.width,
              onItemTapped: _onItemTapped,
            ),
            SizedBox(width: size.width * 0.1),
            PatientNavItem(
              index: 2,
              selectedIndex: _selectedIndex,
              icon: Icons.notifications_none,
              activeIcon: Icons.notifications,
              label: 'Alerts',
              width: size.width,
              onItemTapped: _onItemTapped,
            ),
            PatientNavItem(
              index: 3,
              selectedIndex: _selectedIndex,
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              label: 'Profile',
              width: size.width,
              onItemTapped: _onItemTapped,
            ),
          ],
        ),
      ),
    );
  }
}
