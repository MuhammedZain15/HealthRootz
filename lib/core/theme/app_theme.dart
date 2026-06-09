import 'package:flutter/material.dart';

/// Centralized light & dark themes for the whole app.
///
/// Screens should read colors from `Theme.of(context)` (e.g.
/// `Theme.of(context).scaffoldBackgroundColor`, `Theme.of(context).cardColor`,
/// `Theme.of(context).colorScheme.primary`) instead of hardcoding values, so
/// that toggling [ThemeMode] updates every screen automatically.
class AppTheme {
  AppTheme._();

  // ── Brand colors (theme-independent) ───────────────────────────────────────
  static const Color primary = Color(0xFF1A65EB);
  static const Color accent = Color(0xFF38B6FF);

  // ── Light ──────────────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    const scaffold = Color(0xFFF6F8FB);
    const card = Colors.white;
    const textColor = Color(0xFF111827);
    const unselected = Color(0xFF6B7280);

    final base = ThemeData(useMaterial3: false, brightness: Brightness.light);
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ).copyWith(surface: card, primary: primary);

    return base.copyWith(
      primaryColor: primary,
      scaffoldBackgroundColor: scaffold,
      cardColor: card,
      canvasColor: card,
      dividerColor: const Color(0xFFE5E7EB),
      colorScheme: scheme,
      iconTheme: const IconThemeData(color: textColor),
      appBarTheme: const AppBarTheme(
        backgroundColor: card,
        foregroundColor: textColor,
        elevation: 0.5,
        iconTheme: IconThemeData(color: primary),
        titleTextStyle: TextStyle(
          color: textColor,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: card,
        selectedItemColor: primary,
        unselectedItemColor: unselected,
        type: BottomNavigationBarType.fixed,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF3F4F6),
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
        labelStyle: const TextStyle(color: unselected),
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
          borderSide: const BorderSide(color: primary, width: 2),
        ),
      ),
      textTheme: base.textTheme.apply(
        bodyColor: textColor,
        displayColor: textColor,
      ),
    );
  }

  // ── Dark ───────────────────────────────────────────────────────────────────
  // Palette per the requested inversion spec:
  //   white background  -> 0xFF121212 (scaffold)
  //   card / surface    -> 0xFF2C2C2C
  //   light-grey field  -> 0xFF1E1E1E
  //   dark text         -> white / white70
  static ThemeData get darkTheme {
    const scaffold = Color(0xFF121212);
    const card = Color(0xFF2C2C2C);
    const field = Color(0xFF1E1E1E);
    const textColor = Colors.white;
    const unselected = Colors.white70;
    const borderColor = Color(0xFF3A3A3A);

    final base = ThemeData(useMaterial3: false, brightness: Brightness.dark);
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
    ).copyWith(surface: field, onSurface: textColor, primary: accent);

    return base.copyWith(
      primaryColor: primary,
      scaffoldBackgroundColor: scaffold,
      cardColor: card,
      canvasColor: card,
      dividerColor: borderColor,
      colorScheme: scheme,
      iconTheme: const IconThemeData(color: textColor),
      appBarTheme: const AppBarTheme(
        backgroundColor: card,
        foregroundColor: textColor,
        elevation: 0.5,
        iconTheme: IconThemeData(color: accent),
        titleTextStyle: TextStyle(
          color: textColor,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: card,
        selectedItemColor: accent,
        unselectedItemColor: unselected,
        type: BottomNavigationBarType.fixed,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: field,
        hintStyle: const TextStyle(color: Colors.white54),
        labelStyle: const TextStyle(color: unselected),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: accent, width: 2),
        ),
      ),
      textTheme: base.textTheme.apply(
        bodyColor: textColor,
        displayColor: textColor,
      ),
    );
  }
}
