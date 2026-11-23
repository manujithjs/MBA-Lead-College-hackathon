import 'package:flutter/material.dart';

class AppColors {
  static const Color navy = Color(0xFF0F172A);
  static const Color darkNavy = Color(0xFF0D1B2A);
  static const Color cardNavy = Color(0xFF162544);
  static const Color cardBorderNavy = Color(0xFF22375C);
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color teal = Color(0xFF0D9488);
  static const Color emerald = Color(0xFF10B981);
  static const Color emeraldDark = Color(0xFF047857);
  static const Color amber = Color(0xFFD97706);
  static const Color red = Color(0xFFDC2626);
  static const Color indigo = Color(0xFF4F46E5);
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color border = Color(0xFFE2E8F0);
  static const Color textMuted = Color(0xFF64748B);

  // Template specific colors
  static const Color addressOrange = Color(0xFFF97316);
  static const Color addressBlue = Color(0xFF3B82F6);
  static const Color addressGreen = Color(0xFF22C55E);
  static const Color chipServiceBg = Color(0xFFEEF2FF);
  static const Color chipServiceText = Color(0xFF4338CA);
  static const Color chipStatusBg = Color(0xFFFEF3C7);
  static const Color chipStatusText = Color(0xFFD97706);
  static const Color infoYellowBg = Color(0xFFFFFBEB);
  static const Color infoYellowBorder = Color(0xFFFDE68A);
  static const Color infoYellowText = Color(0xFFB45309);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlue,
        primary: AppColors.primaryBlue,
        secondary: AppColors.teal,
        surface: AppColors.surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.navy,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.background,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.primaryBlue, width: 1.5),
        ),
      ),
    );
  }
}
