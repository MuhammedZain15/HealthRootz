import 'package:flutter/material.dart';
import 'package:grad_project/patient/features/profile/models/patient_profile_model.dart';
import 'package:grad_project/patient/features/profile/widgets/profile_header_card.dart';
import 'package:grad_project/patient/features/profile/widgets/profile_info_card.dart';
import 'package:grad_project/patient/features/profile/widgets/profile_logout_button.dart';
import 'package:grad_project/patient/features/profile/widgets/profile_medication_card.dart';
import 'package:grad_project/patient/features/profile/widgets/profile_section_title.dart';

/// Profile sections driven by [PatientProfileModel] (MVVM state).
class PatientProfileBody extends StatelessWidget {
  final PatientProfileModel profile;
  final VoidCallback onLogout;
  final VoidCallback onEdit;

  const PatientProfileBody({
    super.key,
    required this.profile,
    required this.onLogout,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveProfileLayout(
      mobile: _mobileColumn(),
      tabletDesktop: _tabletDesktopRow(),
    );
  }

  Widget _mobileColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(),
        const SizedBox(height: 18),
        _personalSection(),
        const SizedBox(height: 18),
        _medicalSection(),
        const SizedBox(height: 18),
        _medicationSection(),
        const SizedBox(height: 18),
        _emergencySection(),
        const SizedBox(height: 18),
        _settingsSection(),
        const SizedBox(height: 16),
        ProfileLogoutButton(onPressed: onLogout),
      ],
    );
  }

  Widget _tabletDesktopRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              const SizedBox(height: 24),
              _personalSection(),
              const SizedBox(height: 24),
              _settingsSection(),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _medicalSection(),
              const SizedBox(height: 24),
              _medicationSection(),
              const SizedBox(height: 24),
              _emergencySection(),
              const SizedBox(height: 32),
              ProfileLogoutButton(onPressed: onLogout),
            ],
          ),
        ),
      ],
    );
  }

  Widget _header() {
    return ProfileHeaderCard(
      name: profile.name ?? 'Loading...',
      email: profile.email ?? 'Loading...',
      onEdit: onEdit,
    );
  }

  Widget _personalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ProfileSectionTitle(title: 'Personal Information'),
        const SizedBox(height: 12),
        ProfileInfoCard(
          items: [
            ProfileInfoItem(
              title: 'Full Name',
              value: profile.name ?? '—',
              icon: Icons.person_outline,
              iconBg: const Color(0xFFEFF6FF),
              iconColor: const Color(0xFF38B6FF),
            ),
            ProfileInfoItem(
              title: 'Email',
              value: profile.email ?? '—',
              icon: Icons.email_outlined,
              iconBg: const Color(0xFFEFFDF9),
              iconColor: const Color(0xFF10B981),
            ),
            ProfileInfoItem(
              title: 'Phone',
              value: profile.phone ?? '—',
              icon: Icons.phone_outlined,
              iconBg: const Color(0xFFF5F0FF),
              iconColor: const Color(0xFF8B5CF6),
            ),
            ProfileInfoItem(
              title: 'Age',
              value: profile.age != null
                  ? '${profile.age} years old'
                  : 'Not provided',
              icon: Icons.calendar_month_outlined,
              iconBg: const Color(0xFFFFF6E7),
              iconColor: const Color(0xFFF97316),
            ),
            ProfileInfoItem(
              title: 'Address',
              value: profile.address ?? '—',
              icon: Icons.location_on_outlined,
              iconBg: const Color(0xFFF1FFF5),
              iconColor: const Color(0xFF16A34A),
            ),
          ],
        ),
      ],
    );
  }

  Widget _medicalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ProfileSectionTitle(title: 'Medical Information'),
        const SizedBox(height: 12),
        ProfileInfoCard(
          items: [
            ProfileInfoItem(
              title: 'Gender',
              value: profile.gender ?? '—',
              icon: Icons.wc_outlined,
              iconBg: const Color(0xFFEFF6FF),
              iconColor: const Color(0xFF3B82F6),
            ),
            ProfileInfoItem(
              title: 'Medical History',
              value: profile.medicalHistory ?? 'None',
              icon: Icons.history,
              iconBg: const Color(0xFFFFF1F2),
              iconColor: const Color(0xFFEF4444),
              multiline: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _medicationSection() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileSectionTitle(title: 'Current Medications'),
        SizedBox(height: 12),
        ProfileMedicationCard(
          title: 'Aspirin 81mg',
          subtitle: 'Take once daily  •  Ongoing',
          nextDose: 'Next dose: 8:00 AM',
          tint: Color(0xFFF0FDF4),
          accent: Color(0xFF22C55E),
        ),
        SizedBox(height: 12),
        ProfileMedicationCard(
          title: 'Lisinopril 10mg',
          subtitle: 'Take once daily  •  3 months',
          nextDose: 'Next dose: 8:00 AM',
          tint: Color(0xFFF8F0FF),
          accent: Color(0xFF8B5CF6),
        ),
      ],
    );
  }

  Widget _emergencySection() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileSectionTitle(title: 'Emergency Contacts'),
        SizedBox(height: 12),
        ProfileInfoCard(
          items: [
            ProfileInfoItem(
              title: 'Primary Contact',
              value: 'Family Member\n+1 (555) 987-6543',
              icon: Icons.warning_amber_outlined,
              iconBg: Color(0xFFFFF1F2),
              iconColor: Color(0xFFEF4444),
              multiline: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _settingsSection() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileSectionTitle(title: 'Settings'),
        SizedBox(height: 12),
        ProfileInfoCard(
          items: [
            ProfileInfoItem(
              title: 'Notifications',
              value: 'Manage notification preferences',
              icon: Icons.notifications_none,
              iconBg: Color(0xFFEFF6FF),
              iconColor: Color(0xFF38B6FF),
            ),
          ],
        ),
      ],
    );
  }
}

/// Simple responsive wrapper without importing full ResponsiveLayout.
class ResponsiveProfileLayout extends StatelessWidget {
  final Widget mobile;
  final Widget tabletDesktop;

  const ResponsiveProfileLayout({
    super.key,
    required this.mobile,
    required this.tabletDesktop,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final child = width >= 700 ? tabletDesktop : mobile;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        width >= 700 ? 24 : 18,
        width >= 700 ? 24 : 18,
        width >= 700 ? 24 : 18,
        width >= 700 ? 32 : 24,
      ),
      child: child,
    );
  }
}
