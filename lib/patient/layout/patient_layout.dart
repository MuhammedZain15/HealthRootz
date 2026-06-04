import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:grad_project/app_colors.dart';
import 'package:grad_project/patient/features/alerts/alert_page.dart';
import 'package:grad_project/patient/features/history/history_page.dart';
import 'package:grad_project/patient/features/home/home_page.dart';
import 'package:grad_project/patient/features/profile/profile_page.dart';
import 'package:grad_project/patient/layout/buttom_sheet.dart';
import 'package:grad_project/shared/widgets/responsive_layout.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grad_project/patient/features/patient/data/repositories/patient_repository_impl.dart';
import 'package:grad_project/patient/features/patient/viewmodel/patient_cubit.dart';

class AppLayout extends StatelessWidget {
  const AppLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PatientCubit>(
      create: (context) => PatientCubit(
        PatientRepositoryImpl(),
      )..fetchMe(),
      child: const _AppLayoutContent(),
    );
  }
}

class _AppLayoutContent extends StatefulWidget {
  const _AppLayoutContent();

  @override
  State<_AppLayoutContent> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<_AppLayoutContent> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    HistoryPage(),
    AlertsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _buildMobileLayout(context),
      tablet: _buildTabletDesktopLayout(context),
      desktop: _buildTabletDesktopLayout(context),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
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
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: size.width * 0.03,
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
        elevation: 8,
      ),
    );
  }

  Widget _buildTabletDesktopLayout(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _buildNavigationRail(),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: IndexedStack(index: _selectedIndex, children: _pages),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationRail() {
    return NavigationRail(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) => setState(() => _selectedIndex = index),
      labelType: NavigationRailLabelType.all,
      backgroundColor: Colors.white,
      selectedIconTheme: const IconThemeData(color: AppColors.skyBlue),
      unselectedIconTheme: const IconThemeData(color: Color(0xff6B7280)),
      selectedLabelTextStyle: const TextStyle(
        color: AppColors.skyBlue,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelTextStyle: const TextStyle(color: Color(0xff6B7280)),
      leading: Column(
        children: [
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () => showActionBottomSheet(context),
            backgroundColor: AppColors.skyBlue,
            elevation: 0,
            child: const Icon(Icons.chat_bubble, color: Colors.white),
          ),
          const SizedBox(height: 16),
        ],
      ),
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: Text('Home'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.history_outlined),
          selectedIcon: Icon(Icons.history),
          label: Text('History'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.notifications_none),
          selectedIcon: Icon(Icons.notifications),
          label: Text('Alerts'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: Text('Profile'),
        ),
      ],
    );
  }
}
