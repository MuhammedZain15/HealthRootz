import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:grad_project/app_colors.dart';
import 'package:grad_project/l10n/app_localizations.dart';
import 'package:grad_project/patient/features/alerts/alert_page.dart';
import 'package:grad_project/patient/features/history/history_page.dart';
import 'package:grad_project/patient/features/home/home_page.dart';
import 'package:grad_project/patient/features/profile/profile_page.dart';
import 'package:grad_project/patient/layout/buttom_sheet.dart';
import 'package:grad_project/shared/widgets/responsive_layout.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grad_project/patient/features/patient/data/repositories/patient_repository_impl.dart';
import 'package:grad_project/patient/features/patient/viewmodel/patient_cubit.dart';
import 'package:grad_project/patient/features/appointments/cubit/patient_appointments_cubit.dart';

class AppLayout extends StatelessWidget {
  const AppLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PatientCubit>(
          create: (context) => PatientCubit(
            PatientRepositoryImpl(),
          )..fetchMe(),
        ),
        BlocProvider<PatientAppointmentsCubit>(
          create: (context) => PatientAppointmentsCubit()..loadAppointments(),
        ),
      ],
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

  List<Widget> get _pages => [
    HomePage(
      onNavigateToAlerts: () => setState(() => _selectedIndex = 2),
    ),
    const HistoryPage(),
    const AlertsPage(),
    const ProfilePage(),
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
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showActionBottomSheet(context),
        shape: const CircleBorder(),
        backgroundColor: AppColors.skyBlue,
        elevation: 0,
        child: Icon(
          Icons.chat_bubble,
          color: theme.colorScheme.onPrimary,
          size: size.width * 0.08,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        itemCount: 4,
        tabBuilder: (int index, bool isActive) {
          final color = isActive
              ? theme.colorScheme.primary
              : theme.bottomNavigationBarTheme.unselectedItemColor ??
                    const Color(0xff6B7280);
          final double iconSize = size.width * 0.07;
          IconData icon;
          String label;

          switch (index) {
            case 0:
              icon = isActive ? Icons.home : Icons.home_outlined;
              label = l10n.home;
              break;
            case 1:
              icon = isActive ? Icons.history : Icons.history_outlined;
              label = l10n.history;
              break;
            case 2:
              icon = isActive ? Icons.notifications : Icons.notifications_none;
              label = l10n.alerts;
              break;
            case 3:
              icon = isActive ? Icons.person : Icons.person_outline;
              label = l10n.profile;
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
        backgroundColor: theme.bottomNavigationBarTheme.backgroundColor ??
            theme.cardColor,
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
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final primary = theme.colorScheme.primary;
    final unselected =
        theme.bottomNavigationBarTheme.unselectedItemColor ??
        const Color(0xff6B7280);
    return NavigationRail(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) => setState(() => _selectedIndex = index),
      labelType: NavigationRailLabelType.all,
      backgroundColor:
          theme.bottomNavigationBarTheme.backgroundColor ?? theme.cardColor,
      selectedIconTheme: IconThemeData(color: primary),
      unselectedIconTheme: IconThemeData(color: unselected),
      selectedLabelTextStyle: TextStyle(
        color: primary,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelTextStyle: TextStyle(color: unselected),
      leading: Column(
        children: [
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () => showActionBottomSheet(context),
            backgroundColor: AppColors.skyBlue,
            elevation: 0,
            child: Icon(Icons.chat_bubble, color: theme.colorScheme.onPrimary),
          ),
          const SizedBox(height: 16),
        ],
      ),
      destinations: [
        NavigationRailDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home),
          label: Text(l10n.home),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.history_outlined),
          selectedIcon: const Icon(Icons.history),
          label: Text(l10n.history),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.notifications_none),
          selectedIcon: const Icon(Icons.notifications),
          label: Text(l10n.alerts),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.person_outline),
          selectedIcon: const Icon(Icons.person),
          label: Text(l10n.profile),
        ),
      ],
    );
  }
}
