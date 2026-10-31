import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:booking/core/constants/app_constants.dart';

/// ============================================================
/// App Theme — Colors, Typography & ThemeData
/// All values extracted from Figma design
/// ============================================================

class AppColors {
  // ── Primary brand colour — Golden Yellow ─────────────────────────
  static const Color primary     = Color(0xFFFFC107); // #FFC107 Golden Yellow
  static const Color primaryDark = Color(0xFFFBC02D); // Darker gold
  static const Color highlightGold = Color(0xFFFFD740); // #FFD740 Bright Gold (hover/focus)

  // ── Backgrounds ──────────────────────────────────────────────────
  static const Color background          = Color(0xFF000000); // Primary black
  static const Color secondaryBackground = Color(0xFF0D0D0D); // Auth screen bg
  static const Color surface             = Color(0xFF1E1E1E); // Cards / Owner panels
  static const Color cardBackground      = Color(0xFF2C2C2C);

  // ── Auth input field colours ──────────────────────────────────────
  static const Color inputBg     = Color(0xFF050505); // Input fill
  static const Color inputBorder = Color(0xFF8C7535); // Muted Gold border
  static const Color placeholder = Color(0xFFC6AD65); // Warm Gold hint text

  // ── Text colours ─────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFBDBDBD);
  static const Color textWhite     = Color(0xFFFFFFFF);
  static const Color textBlack     = Color(0xFF000000);
  static const Color textOnYellow  = Color(0xFF000000);
  static const Color textOnWhite   = Color(0xFF000000);
  static const Color textOnDark    = Color(0xFFFFFFFF);
  static const Color textHint      = Color(0xFF757575);

  /// Returns the contrasting text colour for a given background.
  static Color textOn(Color background) {
    return background.computeLuminance() > 0.45 ? textBlack : textWhite;
  }

  // ── Accent colours ───────────────────────────────────────────────
  static const Color starYellow  = Color(0xFFFFD700);
  static const Color greenAccent = Color(0xFF4CAF50);

  // ── UI element colours ───────────────────────────────────────────
  static const Color divider       = Color(0xFF424242);
  static const Color chipOutline   = Color(0xFF424242);
  static const Color chipSelectedBg = Color(0xFFFFC107);
  static const Color shadowColor   = Color(0x1A000000);

  // ── Genre tag colours ────────────────────────────────────────────
  static const Color genreTagBg   = Color(0xCC2A2A2A);
  static const Color genreTagText = Color(0xFFFFC107);

  // ── Bottom nav ───────────────────────────────────────────────────
  static const Color navInactive = Color(0xFF757575);
  static const Color navActive   = Color(0xFFFFC107);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        primary: AppColors.primary,
        onPrimary: AppColors.textOnYellow,
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
          color: AppColors.textPrimary,
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
          color: AppColors.textPrimary,
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
      // ── Input fields (auth screens inherit this automatically) ───
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        hintStyle: GoogleFonts.poppins(
          color: AppColors.placeholder,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: GoogleFonts.poppins(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
        errorStyle: GoogleFonts.poppins(
          color: Colors.redAccent,
          fontSize: 11,
        ),
      ),
      // ── Elevated buttons (gold with black text) ───────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textBlack,
          disabledBackgroundColor: AppColors.inputBorder,
          disabledForegroundColor: AppColors.textBlack,
          elevation: 0,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      // ── Bottom navigation ─────────────────────────────────────────
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
