import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grad_project/core/cubit/language_cubit.dart';
import 'package:grad_project/core/cubit/theme_cubit.dart';
import 'package:grad_project/l10n/app_localizations.dart';

/// Theme + language preferences for the doctor profile.
///
/// Mirrors the patient profile settings: a dark/light switch and an
/// English/Arabic toggle wired to [ThemeCubit] and [LanguageCubit].
class PreferencesCard extends StatelessWidget {
  const PreferencesCard({super.key});

  static const _primary = Color(0xFF3B82F6);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = context.watch<ThemeCubit>().isDark;
    final isArabic = context.watch<LanguageCubit>().isArabic;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune, size: 20),
              const SizedBox(width: 8),
              Text(
                l10n.settings,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Theme
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
              color: _primary,
            ),
            title: Text(
              l10n.theme,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(isDark ? l10n.darkMode : l10n.lightMode),
            trailing: Switch(
              value: isDark,
              activeThumbColor: _primary,
              onChanged: (_) => context.read<ThemeCubit>().toggle(),
            ),
          ),
          const Divider(height: 8),
          // Language
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.language_outlined, color: _primary),
            title: Text(
              l10n.language,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(isArabic ? 'العربية' : 'English'),
            trailing: GestureDetector(
              onTap: () => context.read<LanguageCubit>().setLocale(
                    isArabic ? const Locale('en') : const Locale('ar'),
                  ),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: _primary.withOpacity(0.08),
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
