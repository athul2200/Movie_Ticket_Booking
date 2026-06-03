import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ============================================================
/// App Theme — Colors, Typography & ThemeData
/// All values extracted from Figma design
/// ============================================================

class AppColors {
  // Primary brand color (CinePremium red)
  static const Color primary = Color(0xFFE50914);
  static const Color primaryDark = Color(0xFFC00710);

  // Backgrounds
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF5F5F5);
  static const Color cardBackground = Color(0xFFF0F0F0);

  // Text colors
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textHint = Color(0xFFBDBDBD);

  // Accent colors
  static const Color starYellow = Color(0xFFFFD700);
  static const Color greenAccent = Color(0xFF4CAF50);

  // UI element colors
  static const Color divider = Color(0xFFE0E0E0);
  static const Color chipOutline = Color(0xFFE0E0E0);
  static const Color chipSelectedBg = Color(0xFFE50914);
  static const Color shadowColor = Color(0x1A000000);

  // Genre tag colors (dark translucent)
  static const Color genreTagBg = Color(0xCC2A2A2A);
  static const Color genreTagText = Color(0xFFFFFFFF);

  // Bottom nav
  static const Color navInactive = Color(0xFF9E9E9E);
  static const Color navActive = Color(0xFFE50914);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        onPrimary: AppColors.textWhite,
        surface: AppColors.background,
        onSurface: AppColors.textPrimary,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        // Hero title on banner
        headlineLarge: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: AppColors.textWhite,
        ),
        // Section headers
        headlineMedium: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        // Card titles / subtitles
        titleMedium: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleSmall: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        // Body text
        bodyLarge: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
        bodySmall: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
        // Labels (chips, badges)
        labelLarge: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textWhite,
        ),
        labelMedium: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
        labelSmall: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.background,
        selectedItemColor: AppColors.navActive,
        unselectedItemColor: AppColors.navInactive,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
      ),
    );
  }
}
