import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  // Display font — Orbitron
  static TextStyle orbitron({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w700,
    Color color = AppColors.textPrimary,
    double? letterSpacing,
  }) =>
      GoogleFonts.orbitron(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing ?? 0.5,
      );

  // Body font — Exo 2
  static TextStyle exo({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.textPrimary,
    double? letterSpacing,
    double? height,
  }) =>
      GoogleFonts.exo2(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );

  // Data font — JetBrains Mono
  static TextStyle mono({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.textPrimary,
    double? letterSpacing,
  }) =>
      GoogleFonts.jetBrainsMono(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
      );

  // Named presets
  static TextStyle get displayLarge => orbitron(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 2);
  static TextStyle get displayMedium => orbitron(fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: 1.5);
  static TextStyle get displaySmall => orbitron(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 1);

  static TextStyle get bodyLarge => exo(fontSize: 16, fontWeight: FontWeight.w500);
  static TextStyle get bodyMedium => exo(fontSize: 14, fontWeight: FontWeight.w400);
  static TextStyle get bodySmall => exo(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textSecondary);

  static TextStyle get labelLarge => exo(fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.5);
  static TextStyle get labelSmall => exo(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textMuted, letterSpacing: 0.8);

  static TextStyle get dataLarge => mono(fontSize: 24, fontWeight: FontWeight.w700);
  static TextStyle get dataMedium => mono(fontSize: 16, fontWeight: FontWeight.w500);
  static TextStyle get dataSmall => mono(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textMuted);
}
