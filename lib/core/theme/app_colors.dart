import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ─── GLASSMORPHISM BASE COLORS ─────────────────────────────────────────────
  // Vibrant dark background with colorful undertones
  static const Color background = Color(0xFF0F0F1A);
  static const Color surface = Color(0xFF1A1A2E);
  static const Color surfaceRaised = Color(0xFF252542);
  static const Color surfaceElevated = Color(0xFF2D2D4A);
  static const Color panel = Color(0xFF1E1E35);
  static const Color raised = Color(0xFF252540);
  static const Color overlay = Color(0xFF2A2A45);

  // ─── VIBRANT ACCENT COLORS ─────────────────────────────────────────────────
  // Main primary - Electric Indigo/Purple
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF8B83FF);
  static const Color primaryDark = Color(0xFF4A42CC);
  
  // Secondary accent - Teal/Cyan
  static const Color accent = Color(0xFF00D9C0);
  static const Color accentLight = Color(0xFF33E3D0);
  static const Color accentDark = Color(0xFF00A896);
  
  // Tertiary accent - Warm coral/orange
  static const Color accentWarm = Color(0xFFFF6B6B);
  static const Color accentWarmLight = Color(0xFFFF8E8E);
  static const Color accentWarmDark = Color(0xFFCC5555);
  
  // Status colors - Vibrant
  static const Color success = Color(0xFF51CF66);
  static const Color successLight = Color(0xFF72CF86);
  static const Color warning = Color(0xFFFFA94D);
  static const Color warningLight = Color(0xFFFFBC7A);
  static const Color error = Color(0xFFFF6B6B);
  static const Color errorLight = Color(0xFFFF8E8E);
  
  // Additional fun colors for cards/UI
  static const Color pink = Color(0xFFFF6B9D);
  static const Color blue = Color(0xFF4DABFF);
  static const Color purple = Color(0xFF9775FA);
  static const Color yellow = Color(0xFFFFD43B);

  // ─── TEXT COLORS ─────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFEAEAF2);
  static const Color textSecondary = Color(0xFF9898B0);
  static const Color textMuted = Color(0xFF6A6A80);

  // ─── GLASSMORPHISM ELEMENTS ─────────────────────────────────────────────
  // Translucent glass effect colors
  static const Color border = Color(0xFF3A3A55);
  static const Color divider = Color(0xFF252540);
  static const Color glassBorder = Color(0x30FFFFFF);
  static const Color glassBorderLight = Color(0x15FFFFFF);
  
  // Glass overlay colors for frosted effect
  static const Color glassOverlay = Color(0x10FFFFFF);
  static const Color glassHighlight = Color(0x08FFFFFF);

  // ─── GLOW COLORS ─────────────────────────────────────────────────────────
  // Vibrant glow effects for neon look
  static const Color glowIndigo = Color(0xFF6C63FF);
  static const Color glowTeal = Color(0xFF00D9C0);
  static const Color glowPink = Color(0xFFFF6B9D);
  static const Color glowPurple = Color(0xFF9775FA);
  static const Color glowAmber = Color(0xFFFFA94D);
  static const Color glowRed = Color(0xFFFF6B6B);
  static const Color glowGreen = Color(0xFF51CF66);
  static const Color glowBlue = Color(0xFF4DABFF);

  // ─── SHADOWS & DEPTH ─────────────────────────────────────────────────────
  static const Color shadowLight = Color(0x15FFFFFF);
  static const Color shadowDark = Color(0xFF000000);
  static const Color shadowIndigo = Color(0x406C63FF);
  static const Color shadowTeal = Color(0x4000D9C0);
  
  // ─── GRADIENT PRESETS ───────────────────────────────────────────────────
  // Useful gradient combinations
  static const List<Color> gradientPrimary = [primary, accent];
  static const List<Color> gradientSunset = [accentWarm, primary];
  static const List<Color> gradientOcean = [accent, blue];
  static const List<Color> gradientAurora = [primary, purple, pink];
  static const List<Color> gradientFire = [accentWarm, warning];
  
  // Glass gradient for cards
  static const List<Color> gradientGlass = [Color(0xFF252542), Color(0xFF1A1A2E)];
  static const List<Color> gradientGlassLight = [Color(0xFF2D2D4A), Color(0xFF252542)];
}
