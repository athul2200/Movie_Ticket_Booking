import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors based on Figma design
  static const Color primaryRed = Color(0xFFC01C1C); // Bright, branding red
  static const Color darkRed = Color(0xFF8B0000);
  static const Color lightRed = Color(0xFFFDECEC); // Used for active sidebar background
  static const Color background = Color(0xFFF9F9F9); // Light off-white
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF374151);
  static const Color textLight = Color(0xFF4B5563);
  static const Color borderLight = Color(0xFFD1D5DB);
  
  // Status Colors
  static const Color successGreen = Color(0xFF059669);
  static const Color successGreenBg = Color(0xFFD1FAE5);
  static const Color warningYellow = Color(0xFFD97706);
  static const Color warningYellowBg = Color(0xFFFEF3C7);
  static const Color errorRed = Color(0xFFDC2626);
  static const Color errorRedBg = Color(0xFFFEE2E2);

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryRed,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.light(
        primary: primaryRed,
        secondary: primaryRed,
        surface: cardColor,
        error: errorRed,
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.bold),
        displaySmall: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.bold),
        headlineMedium: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w800, fontSize: 28),
        headlineSmall: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 24),
        titleLarge: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 20),
        titleMedium: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 16),
        titleSmall: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 14),
        bodyLarge: GoogleFonts.inter(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
        bodyMedium: GoogleFonts.inter(color: textSecondary, fontSize: 14, fontWeight: FontWeight.w500),
        bodySmall: GoogleFonts.inter(color: textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: cardColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textPrimary),
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: borderLight, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: borderLight,
        thickness: 1,
        space: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryRed,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
    );
  }
}
