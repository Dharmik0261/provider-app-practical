import 'package:flutter/material.dart';

class AppTheme {
  // Brand colors
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF4B39EF);
  static const Color accent = Color(0xFFFF5964);
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF212529);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color error = Color(0xFFDC3545);
  static const Color success = Color(0xFF28A745);

  // Gradient definitions
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, Color(0xFFFF8E95)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Box Shadows
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> intenseShadow = [
    BoxShadow(
      color: primary.withOpacity(0.2),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
  ];

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: accent,
        surface: surface,
        error: error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: error, width: 2),
        ),
        hintStyle: const TextStyle(color: textSecondary, fontSize: 14),
        labelStyle: const TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: primary,
          elevation: 2,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
