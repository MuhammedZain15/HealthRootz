import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:grad_project/core/cubit/language_cubit.dart';
import 'package:grad_project/core/cubit/theme_cubit.dart';
import 'package:grad_project/l10n/app_localizations.dart';
import 'package:grad_project/patient/features/appointments/cubit/patient_appointments_cubit.dart';
import 'package:grad_project/patient/features/appointments/cubit/patient_appointments_state.dart';
import 'package:grad_project/patient/features/history/history_page.dart';
import 'package:grad_project/patient/features/history/cubit/patient_vitals_cubit.dart';
import 'package:grad_project/patient/features/profile/models/patient_profile_model.dart';
import 'package:grad_project/patient/features/profile/widgets/profile_logout_button.dart';
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
///
/// UI is rebuilt around four sections — gradient header, info-card grid,
/// emergency contacts, and settings — while all data loading, persistence,
/// and cubit wiring from the previous design is preserved unchanged.
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
  // ── Brand palette ────────────────────────────────────────────────────────
  static const _primary = Color(0xFF1A65EB);
  static const _primaryDark = Color(0xFF0D47A1);

  /// Returns a per-user SharedPreferences key so each patient's
  /// emergency contacts are stored separately.
  String get _prefsKey {
    final email = widget.profile.email;
    if (email == null || email.trim().isEmpty) {
      return 'emergency_contacts_unknown';
    }
    return 'emergency_contacts_${email.trim()}';
  }

  List<EmergencyContact> _contacts = [];
  String _lastMedicalEntry = 'Loading...';
  String? _loadedForEmail; // tracks which email the contacts were loaded for

  @override
  void initState() {
    super.initState();
    _loadContacts();
    _loadLastMedicalEntry();
    MeasurementStore.records.addListener(_onRecordsChanged);
  }

  @override
  void didUpdateWidget(PatientProfileBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload contacts when the email first becomes available
    // (profile loads asynchronously; email is null on first render).
    final newEmail = widget.profile.email;
    if (newEmail != null && newEmail.isNotEmpty && newEmail != _loadedForEmail) {
      _loadContacts();
    }
  }

  void _onRecordsChanged() => _loadLastMedicalEntry();

  @override
  void dispose() {
    MeasurementStore.records.removeListener(_onRecordsChanged);
    super.dispose();
  }

  // ── Persistence ──────────────────────────────────────────────────────────

  Future<void> _loadContacts() async {
    final key = _prefsKey; // capture before async gap
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    List<EmergencyContact> loaded = [];
    if (raw != null && raw.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
        loaded = decoded
            .map((e) => EmergencyContact.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        // Corrupted data — start fresh
      }
    }
    if (mounted) {
      setState(() {
        _contacts = loaded;
        _loadedForEmail = widget.profile.email;
      });
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
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = width >= 700 ? 24.0 : 16.0;
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(context, width),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  20,
                  horizontalPadding,
                  28,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle(context, l10n.personalInfo),
                    const SizedBox(height: 12),
                    _infoGrid(context),
                    const SizedBox(height: 24),
                    _sectionTitle(context, l10n.medicalInformation),
                    const SizedBox(height: 12),
                    _medicalAndVisits(context),
                    const SizedBox(height: 24),
                    _sectionTitle(context, l10n.emergencyContacts),
                    const SizedBox(height: 12),
                    _emergencySection(context),
                    const SizedBox(height: 24),
                    _sectionTitle(context, l10n.settings),
                    const SizedBox(height: 12),
                    _settingsSection(context),
                    const SizedBox(height: 24),
                    ProfileLogoutButton(onPressed: widget.onLogout),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Section title ──────────────────────────────────────────────────────────

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  // ── 1. Gradient Header ─────────────────────────────────────────────────────

  Widget _header(BuildContext context, double width) {
    final avatarRadius = (width * 0.12).clamp(40.0, 56.0);
    final name = widget.profile.name ?? AppLocalizations.of(context).loading;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_primary, _primaryDark],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Stack(
        children: [
          // Edit button (preserves onEdit functionality)
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              tooltip: AppLocalizations.of(context).edit,
              onPressed: widget.onEdit,
              icon: const Icon(Icons.edit_outlined, color: Colors.white),
            ),
          ),
          Column(
            children: [
              // Avatar
              CircleAvatar(
                radius: avatarRadius,
                backgroundColor: Colors.white,
                child: Text(
                  _initials(widget.profile.name),
                  style: TextStyle(
                    color: _primary,
                    fontSize: avatarRadius * 0.7,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              // Name
              Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              // age • blood type • gender
              Text(
                _headerSubInfo(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds initials from the patient's name for the avatar.
  String _initials(String? name) {
    final trimmed = (name ?? '').trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      final p = parts.first;
      return (p.length >= 2 ? p.substring(0, 2) : p).toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  /// "age • blood type • gender" row. Blood type has no backing model field
  /// yet, so it renders as a placeholder until the data is available.
  String _headerSubInfo() {
    final age = widget.profile.age;
    final gender = widget.profile.gender;
    final ageText = age != null ? '$age yrs' : '—';
    final genderText = (gender != null && gender.isNotEmpty) ? gender : '—';
    const bloodText = '—'; // no bloodType field on PatientProfileModel
    return '$ageText   •   $bloodText   •   $genderText';
  }

  // ── 2. Info Card Grid ──────────────────────────────────────────────────────

  Widget _infoGrid(BuildContext context) {
    final profile = widget.profile;
    final l10n = AppLocalizations.of(context);
    // Note: dateOfBirth, nationalId and insurance have no fields on
    // PatientProfileModel yet, so they fall back to "Not provided".
    final cards = <_InfoCardData>[
      _InfoCardData(
        icon: Icons.phone_outlined,
        iconColor: const Color(0xFF8B5CF6),
        iconBg: const Color(0xFFF5F0FF),
        label: l10n.phone,
        value: _valueOr(l10n, profile.phone),
      ),
      _InfoCardData(
        icon: Icons.email_outlined,
        iconColor: const Color(0xFF10B981),
        iconBg: const Color(0xFFEFFDF9),
        label: l10n.email,
        value: _valueOr(l10n, profile.email),
      ),
      _InfoCardData(
        icon: Icons.cake_outlined,
        iconColor: const Color(0xFFF97316),
        iconBg: const Color(0xFFFFF6E7),
        label: l10n.dateOfBirth,
        value: _valueOr(l10n, null),
      ),
      _InfoCardData(
        icon: Icons.badge_outlined,
        iconColor: const Color(0xFF3B82F6),
        iconBg: const Color(0xFFEFF6FF),
        label: l10n.nationalId,
        value: _valueOr(l10n, null),
      ),
      _InfoCardData(
        icon: Icons.location_on_outlined,
        iconColor: const Color(0xFF16A34A),
        iconBg: const Color(0xFFF1FFF5),
        label: l10n.address,
        value: _valueOr(l10n, profile.address),
      ),
      _InfoCardData(
        icon: Icons.health_and_safety_outlined,
        iconColor: const Color(0xFFEF4444),
        iconBg: const Color(0xFFFFF1F2),
        label: l10n.insurance,
        value: _valueOr(l10n, null),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 12.0;
        final cardWidth = (constraints.maxWidth - gap) / 2;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: cards
              .map((c) => SizedBox(width: cardWidth, child: _InfoCard(data: c)))
              .toList(),
        );
      },
    );
  }

  String _valueOr(AppLocalizations l10n, String? value) {
    if (value == null || value.trim().isEmpty) return l10n.notProvided;
    return value;
  }

  // ── Medical History + Recent Visits (kept as nav cards) ────────────────────

  Widget _medicalAndVisits(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final appointmentsState = context.watch<PatientAppointmentsCubit>().state;
    final visitsCount = appointmentsState is PatientAppointmentsLoaded
        ? context.read<PatientAppointmentsCubit>().visitsCount
        : 0;
    final visitLabel = visitsCount > 0
        ? '$visitsCount ${l10n.visits}'
        : l10n.noVisitsYet;

    return Column(
      children: [
        _NavCard(
          icon: Icons.history,
          iconColor: const Color(0xFFEF4444),
          iconBg: const Color(0xFFFFF1F2),
          label: l10n.medicalHistory,
          value: _lastMedicalEntry,
          onTap: () => _openHistory(context),
        ),
        const SizedBox(height: 10),
        _NavCard(
          icon: Icons.calendar_today_outlined,
          iconColor: const Color(0xFF22C55E),
          iconBg: const Color(0xFFF0FDF4),
          label: l10n.recentVisits,
          value: visitLabel,
          onTap: () => _openHistory(context),
        ),
      ],
    );
  }

  void _openHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => PatientAppointmentsCubit()..loadAppointments(),
            ),
            // HistoryPage reads a PatientVitalsCubit from context; provide one
            // for this pushed route (outside AppLayout's provider scope).
            BlocProvider(create: (_) => PatientVitalsCubit()..loadVitals()),
          ],
          child: const HistoryPage(),
        ),
      ),
    );
  }

  // ── 3. Emergency Section (colored left border) ─────────────────────────────

  Widget _emergencySection(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: const Border(
          left: BorderSide(color: Color(0xFFEF4444), width: 5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_contacts.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1F2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.contact_phone_outlined,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.noEmergencyContacts,
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
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
          // Add Contact button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => _showAddContactOptions(context),
              icon: const Icon(Icons.add, size: 20),
              label: Text(
                l10n.addContact,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Lets the user choose how to add a contact, preserving both the
  /// manual-entry and pick-from-phone flows behind a single button.
  void _showAddContactOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: Color(0xFF3B82F6)),
              title: Text(AppLocalizations.of(ctx).addManually),
              onTap: () {
                Navigator.pop(ctx);
                _showAddManuallySheet(context);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.contacts_outlined,
                color: Color(0xFF8B5CF6),
              ),
              title: Text(AppLocalizations.of(ctx).addFromContacts),
              onTap: () {
                Navigator.pop(ctx);
                _pickFromContacts();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── Add Manually Bottom Sheet ──────────────────────────────────────────

  void _showAddManuallySheet(BuildContext context) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

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
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
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
                Text(
                  l10n.addEmergencyContact,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 20),
                // Name field
                TextField(
                  controller: nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: l10n.name,
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: Color(0xFF6B7280),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: theme.dividerColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: theme.dividerColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: Color(0xFF3B82F6),
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                  ),
                ),
                const SizedBox(height: 14),
                // Phone field
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: l10n.phone,
                    prefixIcon: const Icon(
                      Icons.phone_outlined,
                      color: Color(0xFF6B7280),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: theme.dividerColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: theme.dividerColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: Color(0xFF3B82F6),
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
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
                    label: Text(
                      l10n.saveContact,
                      style: const TextStyle(
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
    final l10n = AppLocalizations.of(context); // capture before async gaps
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
                SnackBar(
                  content: Text(l10n.translate('no_phone_number')),
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
            content: Text(l10n.translate('contacts_permission_denied')),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: l10n.translate('open_settings'),
              textColor: Colors.white,
              onPressed: () => openAppSettings(),
            ),
          ),
        );
      }
    }
  }

  // ── 4. Settings Section ────────────────────────────────────────────────────

  Widget _settingsSection(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final themeCubit = context.watch<ThemeCubit>();
    final languageCubit = context.watch<LanguageCubit>();
    final isDark = themeCubit.isDark;
    final isArabic = languageCubit.isArabic;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Dark / Light Mode ──────────────────────────────────
          ListTile(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFFFF6E7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFFF97316),
              ),
            ),
            title: Text(
              l10n.theme,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            subtitle: Text(
              isDark ? l10n.darkMode : l10n.lightMode,
              style: const TextStyle(fontSize: 12),
            ),
            trailing: Switch(
              value: isDark,
              activeThumbColor: _primary,
              onChanged: (_) => context.read<ThemeCubit>().toggle(),
            ),
          ),
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: Theme.of(context).dividerColor,
          ),
          // ── Language ──────────────────────────────────────────
          ListTile(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
            ),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.language_outlined,
                color: Color(0xFF3B82F6),
              ),
            ),
            title: Text(
              l10n.language,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            subtitle: Text(
              isArabic ? 'العربية' : 'English',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: GestureDetector(
              onTap: () {
                final next = isArabic
                    ? const Locale('en')
                    : const Locale('ar');
                context.read<LanguageCubit>().setLocale(next);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isArabic ? 'EN' : 'ع',
                  style: const TextStyle(
                    color: _primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Info Card data + widget ────────────────────────────────────────────────

class _InfoCardData {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String value;

  const _InfoCardData({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.value,
  });
}

class _InfoCard extends StatelessWidget {
  final _InfoCardData data;

  const _InfoCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: data.iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(data.icon, color: data.iconColor, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.label,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  data.value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Navigable card (Medical History / Recent Visits) ───────────────────────

class _NavCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _NavCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.5),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
            ],
          ),
        ),
      ),
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
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.warning_amber_outlined,
              color: Color(0xFFEF4444),
              size: 20,
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
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
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
          // Actions — call & WhatsApp preserved from the previous design,
          // plus the delete icon from the new spec.
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
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 17, color: color),
        ),
      ),
    );
  }
}
