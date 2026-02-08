import 'package:flutter/material.dart';
import 'widgets/profile_header_card.dart';
import 'widgets/profile_info_card.dart';
import 'widgets/profile_logout_button.dart';
import 'widgets/profile_medication_card.dart';
import 'widgets/profile_section_title.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final String name = 'Mohamed Zaini';
  final String email = 'mohamed.zaini@email.com';
  final String phone = '+1 (555) 789-1234';
  final String dateOfBirth = 'March 15, 1992';
  final String address = 'Cairo, Egypt';
  final String bloodType = 'A+';
  final String height = '178 cm';
  final String weight = '75 kg';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileHeaderCard(name: name, email: email, onEdit: () {}),
              const SizedBox(height: 18),
              const ProfileSectionTitle(title: 'Personal Information'),
              const SizedBox(height: 12),
              ProfileInfoCard(
                items: [
                  ProfileInfoItem(
                    title: 'Full Name',
                    value: name,
                    icon: Icons.person_outline,
                    iconBg: const Color(0xFFEFF6FF),
                    iconColor: const Color(0xFF38B6FF),
                  ),
                  ProfileInfoItem(
                    title: 'Email',
                    value: email,
                    icon: Icons.email_outlined,
                    iconBg: const Color(0xFFEFFDF9),
                    iconColor: const Color(0xFF10B981),
                  ),
                  ProfileInfoItem(
                    title: 'Phone',
                    value: phone,
                    icon: Icons.phone_outlined,
                    iconBg: const Color(0xFFF5F0FF),
                    iconColor: const Color(0xFF8B5CF6),
                  ),
                  ProfileInfoItem(
                    title: 'Date of Birth',
                    value: dateOfBirth,
                    icon: Icons.calendar_month_outlined,
                    iconBg: const Color(0xFFFFF6E7),
                    iconColor: const Color(0xFFF97316),
                  ),
                  ProfileInfoItem(
                    title: 'Address',
                    value: address,
                    icon: Icons.location_on_outlined,
                    iconBg: const Color(0xFFF1FFF5),
                    iconColor: const Color(0xFF16A34A),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const ProfileSectionTitle(title: 'Medical Information'),
              const SizedBox(height: 12),
              ProfileInfoCard(
                items: [
                  ProfileInfoItem(
                    title: 'Blood Type',
                    value: bloodType,
                    icon: Icons.favorite_border,
                    iconBg: const Color(0xFFFFF1F2),
                    iconColor: const Color(0xFFEF4444),
                  ),
                  ProfileInfoItem(
                    title: 'Height',
                    value: height,
                    icon: Icons.monitor_heart_outlined,
                    iconBg: const Color(0xFFEFF6FF),
                    iconColor: const Color(0xFF3B82F6),
                  ),
                  ProfileInfoItem(
                    title: 'Weight',
                    value: weight,
                    icon: Icons.monitor_weight_outlined,
                    iconBg: const Color(0xFFEFF2FF),
                    iconColor: const Color(0xFF6366F1),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const ProfileSectionTitle(title: 'Current Medications'),
              const SizedBox(height: 12),
              const ProfileMedicationCard(
                title: 'Aspirin 81mg',
                subtitle: 'Take once daily  •  Ongoing',
                nextDose: 'Next dose: 8:00 AM',
                tint: Color(0xFFF0FDF4),
                accent: Color(0xFF22C55E),
              ),
              const SizedBox(height: 12),
              const ProfileMedicationCard(
                title: 'Lisinopril 10mg',
                subtitle: 'Take once daily  •  3 months',
                nextDose: 'Next dose: 8:00 AM',
                tint: Color(0xFFF8F0FF),
                accent: Color(0xFF8B5CF6),
              ),
              const SizedBox(height: 18),
              const ProfileSectionTitle(title: 'Emergency Contacts'),
              const SizedBox(height: 12),
              const ProfileInfoCard(
                items: [
                  ProfileInfoItem(
                    title: 'Primary Contact',
                    value: 'Family Member\n+1 (555) 987-6543',
                    icon: Icons.warning_amber_outlined,
                    iconBg: Color(0xFFFFF1F2),
                    iconColor: Color(0xFFEF4444),
                    multiline: true,
                  ),
                  ProfileInfoItem(
                    title: 'Dr. Sarah Johnson',
                    value: 'Cardiologist\n+1 (555) 123-4567',
                    icon: Icons.person_add_alt_1_outlined,
                    iconBg: Color(0xFFFFF6E7),
                    iconColor: Color(0xFFF97316),
                    multiline: true,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const ProfileSectionTitle(title: 'Settings'),
              const SizedBox(height: 12),
              const ProfileInfoCard(
                items: [
                  ProfileInfoItem(
                    title: 'Notifications',
                    value: 'Manage notification preferences',
                    icon: Icons.notifications_none,
                    iconBg: Color(0xFFEFF6FF),
                    iconColor: Color(0xFF38B6FF),
                  ),
                  ProfileInfoItem(
                    title: 'Privacy & Security',
                    value: 'Control your data and privacy',
                    icon: Icons.shield_outlined,
                    iconBg: Color(0xFFEFFDF9),
                    iconColor: Color(0xFF10B981),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ProfileLogoutButton(onPressed: () {}),
            ],
          ),
        ),
      ),
    );
  }
}
