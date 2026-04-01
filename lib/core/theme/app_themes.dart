import 'package:flutter/material.dart';

enum AppThemeType { midnight, ocean, forest, sunset, neon, aurora, monochrome, oceanBlue }

enum CardStyle { glass, flat, neumorphic, bordered }

class ThemeStyle {
  final CardStyle cardStyle;
  final double cardRadius;
  final double cardElevation;
  final double cardBorderWidth;
  final bool hasGlow;
  final double glowIntensity;
  final double iconSize;
  final double iconPadding;
  final double buttonRadius;
  final bool hasGradientOverlay;
  final BorderRadius? buttonBorderRadius;

  const ThemeStyle({
    this.cardStyle = CardStyle.glass,
    this.cardRadius = 16,
    this.cardElevation = 0,
    this.cardBorderWidth = 1,
    this.hasGlow = false,
    this.glowIntensity = 0.3,
    this.iconSize = 24,
    this.iconPadding = 12,
    this.buttonRadius = 12,
    this.hasGradientOverlay = false,
    this.buttonBorderRadius,
  });
}

class AppTheme {
  final String id;
  final String name;
  final String description;
  final Brightness brightness;
  final Color background;
  final Color surface;
  final Color surfaceRaised;
  final Color primary;
  final Color accent;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color border;
  final List<Color> gradient;
  final ThemeStyle style;

  const AppTheme({
    required this.id,
    required this.name,
    required this.description,
    required this.brightness,
    required this.background,
    required this.surface,
    required this.surfaceRaised,
    required this.primary,
    required this.accent,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.border,
    required this.gradient,
    this.style = const ThemeStyle(),
  });

  ThemeData toThemeData() {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: ColorScheme.dark(
        primary: primary,
        secondary: accent,
        surface: surface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textSecondary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceRaised,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintStyle: TextStyle(color: textSecondary),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surface,
        contentTextStyle: TextStyle(color: textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

class AppThemes {
  AppThemes._();

  static const midnight = AppTheme(
    id: 'midnight',
    name: 'Midnight',
    description: 'Default dark theme with purple accents',
    brightness: Brightness.dark,
    background: Color(0xFF0F0F1A),
    surface: Color(0xFF1A1A2E),
    surfaceRaised: Color(0xFF252542),
    primary: Color(0xFF6C63FF),
    accent: Color(0xFF00D9C0),
    textPrimary: Color(0xFFEAEAF2),
    textSecondary: Color(0xFF9898B0),
    textMuted: Color(0xFF6A6A80),
    border: Color(0xFF3A3A55),
    gradient: [Color(0xFF6C63FF), Color(0xFF00D9C0)],
    style: ThemeStyle(
      cardStyle: CardStyle.glass,
      cardRadius: 16,
      cardBorderWidth: 1,
      hasGlow: true,
      glowIntensity: 0.4,
      iconSize: 24,
      iconPadding: 12,
      buttonRadius: 12,
      hasGradientOverlay: true,
    ),
  );

  static const ocean = AppTheme(
    id: 'ocean',
    name: 'Ocean',
    description: 'Deep blue ocean vibes',
    brightness: Brightness.dark,
    background: Color(0xFF0A1628),
    surface: Color(0xFF0F2137),
    surfaceRaised: Color(0xFF152840),
    primary: Color(0xFF00B4D8),
    accent: Color(0xFF90E0EF),
    textPrimary: Color(0xFFE8F4F8),
    textSecondary: Color(0xFF8AB4C4),
    textMuted: Color(0xFF5A8A9A),
    border: Color(0xFF1A3A50),
    gradient: [Color(0xFF0077B6), Color(0xFF00B4D8)],
    style: ThemeStyle(
      cardStyle: CardStyle.flat,
      cardRadius: 20,
      cardBorderWidth: 0,
      hasGlow: false,
      iconSize: 22,
      iconPadding: 14,
      buttonRadius: 16,
    ),
  );

  static const forest = AppTheme(
    id: 'forest',
    name: 'Forest',
    description: 'Nature inspired greens',
    brightness: Brightness.dark,
    background: Color(0xFF0D1A0F),
    surface: Color(0xFF152118),
    surfaceRaised: Color(0xFF1A2B1E),
    primary: Color(0xFF2ECC71),
    accent: Color(0xFF58D68D),
    textPrimary: Color(0xFFE8F5E9),
    textSecondary: Color(0xFF8BC49A),
    textMuted: Color(0xFF5A8A6A),
    border: Color(0xFF1A3020),
    gradient: [Color(0xFF27AE60), Color(0xFF2ECC71)],
    style: ThemeStyle(
      cardStyle: CardStyle.neumorphic,
      cardRadius: 24,
      cardElevation: 4,
      cardBorderWidth: 0,
      hasGlow: false,
      iconSize: 26,
      iconPadding: 10,
      buttonRadius: 20,
    ),
  );

  static const sunset = AppTheme(
    id: 'sunset',
    name: 'Sunset',
    description: 'Warm orange and pink tones',
    brightness: Brightness.dark,
    background: Color(0xFF1A0F0F),
    surface: Color(0xFF2A1818),
    surfaceRaised: Color(0xFF3A2222),
    primary: Color(0xFFFF6B6B),
    accent: Color(0xFFFFAB76),
    textPrimary: Color(0xFFFFF0E8),
    textSecondary: Color(0xFFCCA8A8),
    textMuted: Color(0xFF8A6868),
    border: Color(0xFF4A2828),
    gradient: [Color(0xFFFF6B6B), Color(0xFFFFAB76)],
    style: ThemeStyle(
      cardStyle: CardStyle.bordered,
      cardRadius: 12,
      cardBorderWidth: 2,
      hasGlow: true,
      glowIntensity: 0.5,
      iconSize: 28,
      iconPadding: 8,
      buttonRadius: 8,
      hasGradientOverlay: true,
    ),
  );

  static const neon = AppTheme(
    id: 'neon',
    name: 'Neon',
    description: 'High contrast cyberpunk',
    brightness: Brightness.dark,
    background: Color(0xFF0A0A0A),
    surface: Color(0xFF151515),
    surfaceRaised: Color(0xFF1F1F1F),
    primary: Color(0xFF00FF88),
    accent: Color(0xFFFF00FF),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFAAAAAA),
    textMuted: Color(0xFF666666),
    border: Color(0xFF2A2A2A),
    gradient: [Color(0xFF00FF88), Color(0xFFFF00FF)],
    style: ThemeStyle(
      cardStyle: CardStyle.bordered,
      cardRadius: 4,
      cardBorderWidth: 1,
      hasGlow: true,
      glowIntensity: 0.8,
      iconSize: 20,
      iconPadding: 16,
      buttonRadius: 4,
    ),
  );

  static const aurora = AppTheme(
    id: 'aurora',
    name: 'Aurora',
    description: 'Northern lights inspired',
    brightness: Brightness.dark,
    background: Color(0xFF0F0F1E),
    surface: Color(0xFF171730),
    surfaceRaised: Color(0xFF1F1F44),
    primary: Color(0xFF8B5CF6),
    accent: Color(0xFF06B6D4),
    textPrimary: Color(0xFFEEEEFF),
    textSecondary: Color(0xFF9999CC),
    textMuted: Color(0xFF6666AA),
    border: Color(0xFF2A2A50),
    gradient: [Color(0xFF8B5CF6), Color(0xFF06B6D4), Color(0xFF10B981)],
    style: ThemeStyle(
      cardStyle: CardStyle.glass,
      cardRadius: 18,
      cardBorderWidth: 1,
      hasGlow: true,
      glowIntensity: 0.6,
      iconSize: 24,
      iconPadding: 12,
      buttonRadius: 14,
      hasGradientOverlay: true,
    ),
  );

  static const monochrome = AppTheme(
    id: 'monochrome',
    name: 'Mono',
    description: 'Clean black & white',
    brightness: Brightness.dark,
    background: Color(0xFF000000),
    surface: Color(0xFF111111),
    surfaceRaised: Color(0xFF1A1A1A),
    primary: Color(0xFFFFFFFF),
    accent: Color(0xFF888888),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFF888888),
    textMuted: Color(0xFF555555),
    border: Color(0xFF2A2A2A),
    gradient: [Color(0xFFFFFFFF), Color(0xFF888888)],
    style: ThemeStyle(
      cardStyle: CardStyle.flat,
      cardRadius: 0,
      cardBorderWidth: 0,
      hasGlow: false,
      iconSize: 24,
      iconPadding: 12,
      buttonRadius: 0,
    ),
  );

  static const oceanBlue = AppTheme(
    id: 'ocean_blue',
    name: 'Ocean Blue',
    description: 'Classic navy blue',
    brightness: Brightness.dark,
    background: Color(0xFF0D1B2A),
    surface: Color(0xFF1B263B),
    surfaceRaised: Color(0xFF233554),
    primary: Color(0xFF4DABF7),
    accent: Color(0xFF74C0FC),
    textPrimary: Color(0xFFE9ECEF),
    textSecondary: Color(0xFFADB5BD),
    textMuted: Color(0xFF6C757D),
    border: Color(0xFF2D3E50),
    gradient: [Color(0xFF228BE6), Color(0xFF4DABF7)],
    style: ThemeStyle(
      cardStyle: CardStyle.glass,
      cardRadius: 16,
      cardBorderWidth: 1,
      hasGlow: false,
      iconSize: 22,
      iconPadding: 14,
      buttonRadius: 12,
    ),
  );

  static List<AppTheme> get all => [
    midnight,
    ocean,
    forest,
    sunset,
    neon,
    aurora,
    monochrome,
    oceanBlue,
  ];

  static AppTheme getById(String id) {
    return all.firstWhere(
      (t) => t.id == id,
      orElse: () => midnight,
    );
  }
}