import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'nestshift_colors.dart';

class NestShiftTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: NestShiftColors.background,
      primaryColor: NestShiftColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: NestShiftColors.primary,
        secondary: NestShiftColors.secondary,
        surface: NestShiftColors.surface,
        background: NestShiftColors.background,
        error: NestShiftColors.error,
        onPrimary: NestShiftColors.background,
        onSecondary: NestShiftColors.textPrimary,
        onSurface: NestShiftColors.textPrimary,
        onBackground: NestShiftColors.textPrimary,
        onError: NestShiftColors.textPrimary,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme,
      ).copyWith(
        displayLarge: GoogleFonts.inter(fontSize: 84, fontWeight: FontWeight.w900, color: NestShiftColors.textPrimary, letterSpacing: -2),
        displayMedium: GoogleFonts.inter(fontSize: 48, fontWeight: FontWeight.w800, color: NestShiftColors.textPrimary, letterSpacing: -1),
        titleLarge: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: NestShiftColors.textPrimary),
        bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: NestShiftColors.textPrimary),
        bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.normal, color: NestShiftColors.textSecondary),
        labelSmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w900, color: NestShiftColors.primary, letterSpacing: 2),
      ),
      useMaterial3: true,
    );
  }
}
