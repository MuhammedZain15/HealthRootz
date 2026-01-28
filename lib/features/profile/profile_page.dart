import 'package:flutter/material.dart';
import 'package:grad_project/app_colors.dart';
import 'package:grad_project/features/auth/widgets/custom_button.dart';
import 'edit_profile_card.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool notificationsEnabled = true;
  bool englishLangEnabled = true;
  int bottomIndex = 3;

  // Visible profile data
  String name = 'Mohamed Zain';
  String email = 'muhammedzain1504@gmail.com';
  String age = '15';
  String medicalDetails = 'No known conditions';

  // Open edit dialog
  void _openEditDialog() {
    EditProfileCard.show(
      context,
      initialName: name,
      initialAge: age,
      initialMedical: medicalDetails,
      onSave: (String newName, String newAge, String newMedical) {
        setState(() {
          name = newName;
          age = newAge;
          medicalDetails = newMedical;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF1F7FF),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;
          final isWide = maxWidth > 600;
          final horizontalPadding = isWide ? maxWidth * 0.15 : 16.0;

          return Padding(
            padding: const EdgeInsets.only(top: 50.0),
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Profile Card
                      Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: isWide ? 36 : 28,
                                backgroundColor: Colors.blue.shade300,
                                child: Text(
                                  name.isNotEmpty
                                      ? name
                                            .split(' ')
                                            .map(
                                              (s) => s.isNotEmpty ? s[0] : '',
                                            )
                                            .take(2)
                                            .join()
                                      : 'U',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: TextStyle(
                                        fontSize: isWide ? 18 : 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      email,
                                      style: TextStyle(
                                        fontSize: isWide ? 14 : 12,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: _openEditDialog,
                                    icon: const Icon(Icons.edit, size: 18),
                                    label: const Text('Edit'),
                                    style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      backgroundColor: Colors.grey.shade100,
                                      foregroundColor: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: const [
                                  Icon(
                                    Icons.person_outline,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Personal Information",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 20),
                              _infoRow('Age', '$age years'),
                              const SizedBox(height: 8),
                              // Medical details shown under as multi-line, professional style
                              const SizedBox(height: 12),
                              Text(
                                'Medical Details',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFF),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                padding: const EdgeInsets.all(12),
                                child: Text(
                                  medicalDetails,
                                  style: const TextStyle(color: Colors.black87),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Settings Card
                      Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: const [
                                  Icon(
                                    Icons.settings_outlined,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Settings',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 20),
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: const Text('Notifications'),
                                trailing: Switch(
                                  inactiveThumbColor: Colors.black54,
                                  activeThumbColor: AppColors.skyBlue,
                                  value: notificationsEnabled,
                                  onChanged: (v) =>
                                      setState(() => notificationsEnabled = v),
                                ),
                              ),
                              const SizedBox(height: 8),
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: const Text('Language'),
                                trailing: Switch(
                                  inactiveThumbColor: Colors.black54,
                                  activeThumbColor: AppColors.skyBlue,
                                  value: englishLangEnabled,
                                  onChanged: (v) =>
                                      setState(() => englishLangEnabled = v),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 60),

                      // Sign out
                      SizedBox(
                        height: 56,
                        child: CustomButton(
                          color: AppColors.skyBlue,
                          text: "Sign Out",
                          onPressed: () {},
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(color: Colors.black54)),
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
