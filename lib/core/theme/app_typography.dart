import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  // Primary font — Space Grotesk
  static TextStyle get displayLarge => GoogleFonts.spaceGrotesk(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.0,
    color: AppColors.textPrimary,
  );

  static TextStyle get displayMedium => GoogleFonts.spaceGrotesk(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  static TextStyle get displaySmall => GoogleFonts.spaceGrotesk(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodyLarge => GoogleFonts.spaceGrotesk(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodyMedium => GoogleFonts.spaceGrotesk(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodySmall => GoogleFonts.spaceGrotesk(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static TextStyle get labelLarge => GoogleFonts.spaceGrotesk(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: AppColors.textPrimary,
  );

  static TextStyle get labelSmall => GoogleFonts.spaceGrotesk(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
  );

  static TextStyle mono({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.textPrimary,
  }) =>
    GoogleFonts.jetBrainsMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );

  // Legacy font methods (for compatibility)
  static TextStyle inter({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.textPrimary,
    double? letterSpacing,
    double? height,
  }) =>
    GoogleFonts.spaceGrotesk(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );

  static TextStyle outfit({
    double fontSize = 24,
    FontWeight fontWeight = FontWeight.w700,
    Color color = AppColors.textPrimary,
    double? letterSpacing,
  }) =>
    GoogleFonts.spaceGrotesk(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );

  static TextStyle orbitron({
    double fontSize = 18,
    FontWeight fontWeight = FontWeight.w600,
    Color color = AppColors.textPrimary,
    double? letterSpacing,
  }) =>
    GoogleFonts.spaceGrotesk(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );

  static TextStyle exo({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.textPrimary,
    double? letterSpacing,
    double? height,
  }) =>
    GoogleFonts.spaceGrotesk(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
}
