import 'package:flutter/material.dart';
import 'package:grad_project/doctor/features/profile/widgets/profile_header.dart';
import 'package:grad_project/doctor/features/profile/widgets/profile_info_card.dart';
import 'package:grad_project/doctor/features/profile/widgets/change_password_card.dart';
import 'package:grad_project/doctor/features/profile/widgets/notification_settings_card.dart';

class DoctorProfilePage extends StatelessWidget {
  final Map<String, String> initialData;
  final Function(Map<String, String>) onProfileUpdate;

  const DoctorProfilePage({
    super.key,
    required this.initialData,
    required this.onProfileUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header Title
              Text(
                "Profile & Settings",
                style: TextStyle(
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Manage your account information and preferences",
                style: TextStyle(
                  fontSize: screenWidth * 0.035,
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: 24),

              /// Display current info from parent
              ProfileHeader(
                name: initialData['name'] ?? "",
                email: initialData['email'] ?? "",
                phone: initialData['phone'] ?? "",
                specialty: initialData['specialty'] ?? "",
                licenseNumber: initialData['licenseNumber'] ?? "",
                address: initialData['address'] ?? "",
              ),

              const SizedBox(height: 24),

              /// Edit info form
              ProfileInfoCard(
                initialData: initialData,
                onSave: (newData) {
                  onProfileUpdate(newData);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile updated successfully!')),
                  );
                },
              ),

              const SizedBox(height: 24),
              const ChangePasswordCard(),
              const SizedBox(height: 24),
              const NotificationSettingsCard(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
