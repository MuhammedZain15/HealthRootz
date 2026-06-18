import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageCubit extends Cubit<Locale> {
  static const _key = 'app_locale';

  /// Seed with [initial] (resolved from prefs before `runApp` to avoid a
  /// flash of the wrong language on cold start).
  LanguageCubit([super.initial = const Locale('en')]);

  /// Reads the persisted locale. Call this in `main()` before `runApp` and
  /// pass the result to [LanguageCubit]'s constructor.
  static Future<Locale> readSaved() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key) == 'ar'
        ? const Locale('ar')
        : const Locale('en');
  }

  /// Load persisted locale after construction (kept for callers that build the
  /// cubit without a preloaded value).
  Future<void> loadSavedLanguage() async {
    emit(await readSaved());
  }

  /// Switch to the given locale.
  Future<void> setLocale(Locale locale) async {
    emit(locale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, locale.languageCode);
  }

  bool get isArabic => state.languageCode == 'ar';
}

// commit update
 