import 'package:flutter/material.dart';

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
              _buildHeaderCard(),
              const SizedBox(height: 18),
              const _SectionTitle(title: 'Personal Information'),
              const SizedBox(height: 12),
              _InfoCard(
                items: [
                  InfoItem(
                    title: 'Full Name',
                    value: name,
                    icon: Icons.person_outline,
                    iconBg: const Color(0xFFEFF6FF),
                    iconColor: const Color(0xFF38B6FF),
                  ),
                  InfoItem(
                    title: 'Email',
                    value: email,
                    icon: Icons.email_outlined,
                    iconBg: const Color(0xFFEFFDF9),
                    iconColor: const Color(0xFF10B981),
                  ),
                  InfoItem(
                    title: 'Phone',
                    value: phone,
                    icon: Icons.phone_outlined,
                    iconBg: const Color(0xFFF5F0FF),
                    iconColor: const Color(0xFF8B5CF6),
                  ),
                  InfoItem(
                    title: 'Date of Birth',
                    value: dateOfBirth,
                    icon: Icons.calendar_month_outlined,
                    iconBg: const Color(0xFFFFF6E7),
                    iconColor: const Color(0xFFF97316),
                  ),
                  InfoItem(
                    title: 'Address',
                    value: address,
                    icon: Icons.location_on_outlined,
                    iconBg: const Color(0xFFF1FFF5),
                    iconColor: const Color(0xFF16A34A),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const _SectionTitle(title: 'Medical Information'),
              const SizedBox(height: 12),
              _InfoCard(
                items: [
                  InfoItem(
                    title: 'Blood Type',
                    value: bloodType,
                    icon: Icons.favorite_border,
                    iconBg: const Color(0xFFFFF1F2),
                    iconColor: const Color(0xFFEF4444),
                  ),
                  InfoItem(
                    title: 'Height',
                    value: height,
                    icon: Icons.monitor_heart_outlined,
                    iconBg: const Color(0xFFEFF6FF),
                    iconColor: const Color(0xFF3B82F6),
                  ),
                  InfoItem(
                    title: 'Weight',
                    value: weight,
                    icon: Icons.monitor_weight_outlined,
                    iconBg: const Color(0xFFEFF2FF),
                    iconColor: const Color(0xFF6366F1),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const _SectionTitle(title: 'Current Medications'),
              const SizedBox(height: 12),
              _MedicationCard(
                title: 'Aspirin 81mg',
                subtitle: 'Take once daily  •  Ongoing',
                nextDose: 'Next dose: 8:00 AM',
                tint: const Color(0xFFF0FDF4),
                accent: const Color(0xFF22C55E),
              ),
              const SizedBox(height: 12),
              _MedicationCard(
                title: 'Lisinopril 10mg',
                subtitle: 'Take once daily  •  3 months',
                nextDose: 'Next dose: 8:00 AM',
                tint: const Color(0xFFF8F0FF),
                accent: const Color(0xFF8B5CF6),
              ),
              const SizedBox(height: 18),
              const _SectionTitle(title: 'Emergency Contacts'),
              const SizedBox(height: 12),
              _InfoCard(
                items: const [
                  InfoItem(
                    title: 'Primary Contact',
                    value: 'Family Member\n+1 (555) 987-6543',
                    icon: Icons.warning_amber_outlined,
                    iconBg: Color(0xFFFFF1F2),
                    iconColor: Color(0xFFEF4444),
                    multiline: true,
                  ),
                  InfoItem(
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
              const _SectionTitle(title: 'Settings'),
              const SizedBox(height: 12),
              _InfoCard(
                items: const [
                  InfoItem(
                    title: 'Notifications',
                    value: 'Manage notification preferences',
                    icon: Icons.notifications_none,
                    iconBg: Color(0xFFEFF6FF),
                    iconColor: Color(0xFF38B6FF),
                  ),
                  InfoItem(
                    title: 'Privacy & Security',
                    value: 'Control your data and privacy',
                    icon: Icons.shield_outlined,
                    iconBg: Color(0xFFEFFDF9),
                    iconColor: Color(0xFF10B981),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _LogoutButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: const BoxDecoration(
                  color: Color(0xFF38B6FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_outline, color: Colors.white, size: 44),
              ),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(Icons.edit, color: Color(0xFF38B6FF), size: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: const TextStyle(color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.edit, size: 18),
              label: const Text(
                'Edit Profile',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF38B6FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
    );
  }
}

class InfoItem {
  final String title;
  final String value;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final bool multiline;

  const InfoItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    this.multiline = false,
  });
}

class _InfoCard extends StatelessWidget {
  final List<InfoItem> items;

  const _InfoCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: items
            .map(
              (item) => Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      crossAxisAlignment: item.multiline
                          ? CrossAxisAlignment.start
                          : CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: item.iconBg,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(item.icon, color: item.iconColor, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: const TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.value,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF111827),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (item != items.last)
                    Divider(height: 1, color: Colors.grey.shade200),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}

class _MedicationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String nextDose;
  final Color tint;
  final Color accent;

  const _MedicationCard({
    required this.title,
    required this.subtitle,
    required this.nextDose,
    required this.tint,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.medication_outlined, color: accent, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.alarm, size: 16, color: Color(0xFFEF4444)),
                    const SizedBox(width: 6),
                    Text(
                      nextDose,
                      style: const TextStyle(color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.logout),
        label: const Text(
          'Logout',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFDC2626),
          side: const BorderSide(color: Color(0xFFFCA5A5)),
          backgroundColor: const Color(0xFFFEF2F2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
