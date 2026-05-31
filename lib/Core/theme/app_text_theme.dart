import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// All text styles in the app use Nunito via this class.
/// Use AppTextTheme.of(context) to access context-aware styles,
/// or the static getters directly in non-widget code.
class AppTextTheme {
  static TextTheme get textTheme => GoogleFonts.nunitoTextTheme().copyWith(
        // --- Display ---
        displayLarge: GoogleFonts.nunito(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.nunito(
          fontSize: 28,
          fontWeight: FontWeight.w700,
        ),
        displaySmall: GoogleFonts.nunito(
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),

        // --- Headline ---
        headlineLarge: GoogleFonts.nunito(
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
        headlineMedium: GoogleFonts.nunito(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: GoogleFonts.nunito(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),

        // --- Title ---
        titleLarge: GoogleFonts.nunito(
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: GoogleFonts.nunito(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: GoogleFonts.nunito(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),

        // --- Body ---
        bodyLarge: GoogleFonts.nunito(
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        bodySmall: GoogleFonts.nunito(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),

        // --- Label ---
        labelLarge: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
        labelMedium: GoogleFonts.nunito(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        labelSmall: GoogleFonts.nunito(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      );

  // Convenience getters for use directly in widgets
  static TextStyle get h1 => GoogleFonts.nunito(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
      );

  static TextStyle get h2 => GoogleFonts.nunito(
        fontSize: 22,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get h3 => GoogleFonts.nunito(
        fontSize: 18,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get h4 => GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get subtitle => GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF6B7280),
      );

  static TextStyle get body => GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get bodyBold => GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get caption => GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF9CA3AF),
      );

  static TextStyle get button => GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
      );

  static TextStyle get label => GoogleFonts.nunito(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF374151),
      );

  static TextStyle get hint => GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF9CA3AF),
      );
}
