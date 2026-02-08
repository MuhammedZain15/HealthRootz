import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:grad_project/app_colors.dart';
import 'package:grad_project/patient/features/alerts/alert_page.dart';
import 'package:grad_project/patient/features/history/history_page.dart';
import 'package:grad_project/patient/features/home/home_page.dart';
import 'package:grad_project/patient/features/profile/profile_page.dart';
import 'package:grad_project/patient/layout/buttom_sheet.dart';

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
        elevation: 0,
        child: Icon(
          Icons.chat_bubble,
          color: Colors.white,
          size: size.width * 0.08,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        itemCount: 4,
        tabBuilder: (int index, bool isActive) {
          final color = isActive ? AppColors.skyBlue : const Color(0xff6B7280);
          final double iconSize = size.width * 0.07;
          IconData icon;
          String label;

          switch (index) {
            case 0:
              icon = isActive ? Icons.home : Icons.home_outlined;
              label = 'Home';
              break;
            case 1:
              icon = isActive ? Icons.history : Icons.history_outlined;
              label = 'History';
              break;
            case 2:
              icon = isActive ? Icons.notifications : Icons.notifications_none;
              label = 'Alerts';
              break;
            case 3:
              icon = isActive ? Icons.person : Icons.person_outline;
              label = 'Profile';
              break;
            default:
              icon = Icons.error;
              label = '';
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: iconSize, color: color),
              const SizedBox(height: 2), // Reduced spacing
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: size.width * 0.03, // Consistent with previous
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          );
        },
        activeIndex: _selectedIndex,
        gapLocation: GapLocation.center,

        notchSmoothness: NotchSmoothness.sharpEdge,
        onTap: (index) => setState(() => _selectedIndex = index),
        height: bottomBarHeight > 60 ? bottomBarHeight : 60,
        backgroundColor: Colors.white,
        elevation: 8, // Added some elevation for better visibility
      ),
    );
  }
}
