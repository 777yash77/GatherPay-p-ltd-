import 'package:flutter/material.dart';

class AppTheme {
  static const Color ink = Color(0xFF172033);
  static const Color coral = Color(0xFFFF8A6B);
  static const Color mint = Color(0xFFB7F5D1);
  static const Color peach = Color(0xFFFFE7CC);
  static const Color cloud = Color(0xFFF7F8FC);
  static const Color slate = Color(0xFF70819A);
  static const Color cardBorder = Color(0xFFE2E8F0);

  static ThemeData get theme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: cloud,
      colorScheme: const ColorScheme.light(
        primary: ink,
        secondary: coral,
        tertiary: mint,
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: ink,
        onSurface: ink,
      ),
      fontFamily: 'Georgia',
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: ink,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: const BorderSide(color: cardBorder),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: Colors.white,
        selectedColor: ink,
        secondarySelectedColor: coral,
        labelStyle: const TextStyle(color: ink, fontWeight: FontWeight.w600),
        secondaryLabelStyle: const TextStyle(color: Colors.white),
        side: const BorderSide(color: cardBorder),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: const TextStyle(color: slate),
        labelStyle: const TextStyle(color: slate),
        prefixIconColor: ink,
        suffixIconColor: ink,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: coral, width: 1.4),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ink,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: coral,
        foregroundColor: ink,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ink,
        behavior: SnackBarBehavior.floating,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      textTheme: base.textTheme.copyWith(
        headlineLarge: const TextStyle(
          color: ink,
          fontWeight: FontWeight.w700,
          fontSize: 34,
          letterSpacing: -0.8,
        ),
        headlineMedium: const TextStyle(
          color: ink,
          fontWeight: FontWeight.w700,
          fontSize: 28,
        ),
        titleLarge: const TextStyle(
          color: ink,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
        titleMedium: const TextStyle(
          color: ink,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        bodyLarge: const TextStyle(
          color: ink,
          fontSize: 16,
          height: 1.4,
        ),
        bodyMedium: const TextStyle(
          color: slate,
          fontSize: 14,
          height: 1.45,
        ),
      ),
    );
  }
}
