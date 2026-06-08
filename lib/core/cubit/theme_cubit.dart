import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  static const _key = 'app_theme_mode';

  /// Seed with [initial] (resolved from prefs before `runApp` to avoid a
  /// flash of the wrong theme on cold start).
  ThemeCubit([super.initial = ThemeMode.light]);

  /// Reads the persisted theme mode. Call this in `main()` before `runApp`
  /// and pass the result to [ThemeCubit]'s constructor.
  static Future<ThemeMode> readSaved() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key) == 'dark' ? ThemeMode.dark : ThemeMode.light;
  }

  /// Load persisted theme after construction (kept for callers that build the
  /// cubit without a preloaded value).
  Future<void> loadSavedTheme() async {
    emit(await readSaved());
  }

  /// Toggle between light and dark.
  Future<void> toggle() async {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    emit(next);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, next == ThemeMode.dark ? 'dark' : 'light');
  }

  bool get isDark => state == ThemeMode.dark;
}
