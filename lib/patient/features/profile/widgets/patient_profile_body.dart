import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:grad_project/patient/features/appointments/cubit/patient_appointments_cubit.dart';
import 'package:grad_project/patient/features/appointments/cubit/patient_appointments_state.dart';
import 'package:grad_project/patient/features/history/history_page.dart';
import 'package:grad_project/patient/features/profile/models/patient_profile_model.dart';
import 'package:grad_project/patient/features/profile/widgets/profile_header_card.dart';
import 'package:grad_project/patient/features/profile/widgets/profile_info_card.dart';
import 'package:grad_project/patient/features/profile/widgets/profile_logout_button.dart';
import 'package:grad_project/patient/features/profile/widgets/profile_section_title.dart';
import 'package:grad_project/patient/features/history/data/measurement_model.dart';
import 'package:grad_project/core/services/report_service.dart';

// ── Emergency Contact Model ──────────────────────────────────────────────────

class EmergencyContact {
  final String name;
  final String phone;

  const EmergencyContact({required this.name, required this.phone});

  Map<String, dynamic> toJson() => {'name': name, 'phone': phone};

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
    );
  }
}

// ── Profile Body (StatefulWidget) ────────────────────────────────────────────

/// Profile sections driven by [PatientProfileModel] (MVVM state).
class PatientProfileBody extends StatefulWidget {
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
  State<PatientProfileBody> createState() => _PatientProfileBodyState();
}

class _PatientProfileBodyState extends State<PatientProfileBody> {
  static const _prefsKey = 'emergency_contacts';

  List<EmergencyContact> _contacts = [];
  String _lastMedicalEntry = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadContacts();
    _loadLastMedicalEntry();
    MeasurementStore.records.addListener(_onRecordsChanged);
  }

  void _onRecordsChanged() => _loadLastMedicalEntry();

  @override
  void dispose() {
    MeasurementStore.records.removeListener(_onRecordsChanged);
    super.dispose();
  }

  // ── Persistence ──────────────────────────────────────────────────────────

  Future<void> _loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
        setState(() {
          _contacts = decoded
              .map((e) => EmergencyContact.fromJson(e as Map<String, dynamic>))
              .toList();
        });
      } catch (_) {
        // Corrupted data — start fresh
        _contacts = [];
      }
    }
  }

  Future<void> _loadLastMedicalEntry() async {
    String result = 'None';

    // Get last sensor reading
    final records = MeasurementStore.records.value;
    DateTime? lastRecordTime;
    if (records.isNotEmpty) {
      final last = records.last;
      lastRecordTime = last.dateTime;
      result = '${last.title}: ${last.currentValue}';
    }

    // Get last report
    try {
      final reports = await ReportService.instance.getReports();
      if (reports.isNotEmpty) {
        final lastReport = reports.first; // already sorted by date desc
        if (lastRecordTime == null ||
            lastReport.endDate.isAfter(lastRecordTime)) {
          result = lastReport.title;
        }
      }
    } catch (_) {}

    if (mounted) setState(() => _lastMedicalEntry = result);
  }

  Future<void> _saveContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_contacts.map((c) => c.toJson()).toList());
    await prefs.setString(_prefsKey, encoded);
  }

  void _addContact(EmergencyContact contact) {
    setState(() => _contacts.add(contact));
    _saveContacts();
  }

  void _deleteContact(int index) {
    setState(() => _contacts.removeAt(index));
    _saveContacts();
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return ResponsiveProfileLayout(
      mobile: _mobileColumn(context),
      tabletDesktop: _tabletDesktopRow(context),
    );
  }

  Widget _mobileColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(),
        const SizedBox(height: 18),
        _personalSection(),
        const SizedBox(height: 18),
        _medicalSection(context),
        const SizedBox(height: 18),
        _recentVisitsSection(context),
        const SizedBox(height: 18),
        _emergencySection(context),
        const SizedBox(height: 18),
        _settingsSection(),
        const SizedBox(height: 16),
        ProfileLogoutButton(onPressed: widget.onLogout),
      ],
    );
  }

  Widget _tabletDesktopRow(BuildContext context) {
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
              _medicalSection(context),
              const SizedBox(height: 24),
              _recentVisitsSection(context),
              const SizedBox(height: 24),
              _emergencySection(context),
              const SizedBox(height: 32),
              ProfileLogoutButton(onPressed: widget.onLogout),
            ],
          ),
        ),
      ],
    );
  }

  Widget _header() {
    return ProfileHeaderCard(
      name: widget.profile.name ?? 'Loading...',
      email: widget.profile.email ?? 'Loading...',
      onEdit: widget.onEdit,
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
              value: widget.profile.name ?? '—',
              icon: Icons.person_outline,
              iconBg: const Color(0xFFEFF6FF),
              iconColor: const Color(0xFF38B6FF),
            ),
            ProfileInfoItem(
              title: 'Email',
              value: widget.profile.email ?? '—',
              icon: Icons.email_outlined,
              iconBg: const Color(0xFFEFFDF9),
              iconColor: const Color(0xFF10B981),
            ),
            ProfileInfoItem(
              title: 'Phone',
              value: widget.profile.phone ?? '—',
              icon: Icons.phone_outlined,
              iconBg: const Color(0xFFF5F0FF),
              iconColor: const Color(0xFF8B5CF6),
            ),
            ProfileInfoItem(
              title: 'Age',
              value: widget.profile.age != null
                  ? '${widget.profile.age} years old'
                  : 'Not provided',
              icon: Icons.calendar_month_outlined,
              iconBg: const Color(0xFFFFF6E7),
              iconColor: const Color(0xFFF97316),
            ),
            ProfileInfoItem(
              title: 'Address',
              value: widget.profile.address ?? '—',
              icon: Icons.location_on_outlined,
              iconBg: const Color(0xFFF1FFF5),
              iconColor: const Color(0xFF16A34A),
            ),
          ],
        ),
      ],
    );
  }

  Widget _medicalSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ProfileSectionTitle(title: 'Medical Information'),
        const SizedBox(height: 12),
        ProfileInfoCard(
          items: [
            ProfileInfoItem(
              title: 'Gender',
              value: widget.profile.gender ?? '—',
              icon: Icons.wc_outlined,
              iconBg: const Color(0xFFEFF6FF),
              iconColor: const Color(0xFF3B82F6),
            ),
            ProfileInfoItem(
              title: 'Medical History',
              value: _lastMedicalEntry,
              icon: Icons.history,
              iconBg: const Color(0xFFFFF1F2),
              iconColor: const Color(0xFFEF4444),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) =>
                          PatientAppointmentsCubit()..loadAppointments(),
                      child: const HistoryPage(),
                    ),
                  ),
                );
              },
              trailing: const Icon(
                Icons.chevron_right,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _recentVisitsSection(BuildContext context) {
    final appointmentsState = context.watch<PatientAppointmentsCubit>().state;
    final visitsCount = appointmentsState is PatientAppointmentsLoaded
        ? context.read<PatientAppointmentsCubit>().visitsCount
        : 0;
    final visitLabel = visitsCount > 0
        ? '$visitsCount visit${visitsCount == 1 ? '' : 's'}'
        : 'No visits yet';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ProfileSectionTitle(title: 'Recent Visits'),
        const SizedBox(height: 12),
        ProfileInfoCard(
          items: [
            ProfileInfoItem(
              title: 'Visits',
              value: visitLabel,
              icon: Icons.calendar_today_outlined,
              iconBg: const Color(0xFFF0FDF4),
              iconColor: const Color(0xFF22C55E),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) =>
                          PatientAppointmentsCubit()..loadAppointments(),
                      child: const HistoryPage(),
                    ),
                  ),
                );
              },
              trailing: const Icon(
                Icons.chevron_right,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Emergency Section ──────────────────────────────────────────────────

  Widget _emergencySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ProfileSectionTitle(title: 'Emergency Contacts'),
        const SizedBox(height: 12),
        // Contact list
        if (_contacts.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28),
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
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.contact_phone_outlined,
                    color: Color(0xFFEF4444),
                    size: 26,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'No emergency contacts yet',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Add contacts for quick access in emergencies',
                  style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
                ),
              ],
            ),
          )
        else
          ..._contacts.asMap().entries.map(
            (entry) => Padding(
              padding: EdgeInsets.only(
                bottom: entry.key < _contacts.length - 1 ? 10 : 0,
              ),
              child: _EmergencyContactTile(
                contact: entry.value,
                onDelete: () => _deleteContact(entry.key),
              ),
            ),
          ),
        const SizedBox(height: 14),
        // Action buttons
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: Icons.edit_outlined,
                label: 'Add Manually',
                color: const Color(0xFF3B82F6),
                onTap: () => _showAddManuallySheet(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionButton(
                icon: Icons.contacts_outlined,
                label: 'Add from Contacts',
                color: const Color(0xFF8B5CF6),
                onTap: () => _pickFromContacts(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Add Manually Bottom Sheet ──────────────────────────────────────────

  void _showAddManuallySheet(BuildContext context) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Add Emergency Contact',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 20),
                // Name field
                TextField(
                  controller: nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: Color(0xFF6B7280),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: Color(0xFF3B82F6),
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                  ),
                ),
                const SizedBox(height: 14),
                // Phone field
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone',
                    prefixIcon: const Icon(
                      Icons.phone_outlined,
                      color: Color(0xFF6B7280),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: Color(0xFF3B82F6),
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                  ),
                ),
                const SizedBox(height: 22),
                // Save button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final name = nameCtrl.text.trim();
                      final phone = phoneCtrl.text.trim();
                      if (name.isEmpty || phone.isEmpty) return;
                      _addContact(EmergencyContact(name: name, phone: phone));
                      Navigator.pop(ctx);
                    },
                    icon: const Icon(Icons.save_outlined, size: 20),
                    label: const Text(
                      'Save Contact',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22C55E),
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
          ),
        );
      },
    );
  }

  // ── Pick from Phone Contacts ───────────────────────────────────────────

  Future<void> _pickFromContacts() async {
    if (await FlutterContacts.requestPermission(readonly: true)) {
      final contact = await FlutterContacts.openExternalPick();
      if (contact != null) {
        final fullContact = await FlutterContacts.getContact(contact.id);
        if (fullContact != null) {
          final name = fullContact.displayName;
          final phone = fullContact.phones.isNotEmpty
              ? fullContact.phones.first.number
              : '';
          if (phone.isNotEmpty) {
            _addContact(EmergencyContact(name: name, phone: phone));
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Selected contact has no phone number'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Contacts permission denied. Please enable it in settings.',
            ),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Settings',
              textColor: Colors.white,
              onPressed: () => openAppSettings(),
            ),
          ),
        );
      }
    }
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

// ── Emergency Contact Tile ─────────────────────────────────────────────────

class _EmergencyContactTile extends StatelessWidget {
  final EmergencyContact contact;
  final VoidCallback onDelete;

  const _EmergencyContactTile({required this.contact, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
      child: Row(
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.warning_amber_outlined,
              color: Color(0xFFEF4444),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          // Name & phone
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  contact.phone,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          // Action buttons
          _CircleAction(
            icon: Icons.phone,
            color: const Color(0xFF22C55E),
            tooltip: 'Call',
            onTap: () {
              final uri = Uri(scheme: 'tel', path: contact.phone);
              launchUrl(uri);
            },
          ),
          const SizedBox(width: 6),
          _CircleAction(
            icon: Icons.chat,
            color: const Color(0xFF22C55E),
            tooltip: 'WhatsApp',
            onTap: () {
              final digits = contact.phone.replaceAll(RegExp(r'\D'), '');
              final uri = Uri.parse(
                'https://wa.me/$digits?text=${Uri.encodeComponent('🚨 Emergency! I need help !')}',
              );
              launchUrl(uri, mode: LaunchMode.externalApplication);
            },
          ),
          const SizedBox(width: 6),
          _CircleAction(
            icon: Icons.delete_outline,
            color: const Color(0xFFEF4444),
            tooltip: 'Delete',
            onTap: onDelete,
          ),
        ],
      ),
    );
  }
}

// ── Small circular icon button ─────────────────────────────────────────────

class _CircleAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _CircleAction({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}

// ── Action Button (Add Manually / Add from Contacts) ───────────────────────

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
