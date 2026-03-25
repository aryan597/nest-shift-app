import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand colors from the landing page ref
  static const Color primaryGold = Color(0xFFEBA352); // The golden/amber accent
  static const Color primaryGoldDark = Color(0xFFA16D31);
  static const Color accentBlue = Color(0xFF4A90E2); // Small blue accents on the hardware
  
  static const Color successGreen = Color(0xFF4CAF50);
  
  // Base background 
  static const Color backgroundBase = Color(0xFF09090B); // Very deep almost black
  static const Color surfaceBase = Color(0xFF121215); // Slightly elevated dark
  static const Color surfaceElevated = Color(0xFF1A1A1E); // More elevated
  
  // Restored properties for legacy components
  static const Color primaryStatusOn = successGreen;
  static const Color primaryStatusOff = Color(0xFFE53935);
  static const Color energyHigh = Color(0xFFFF5252);
  static const Color shadowDark = Colors.black;
  static const Color shadowLight = Colors.white12;
  static const List<BoxShadow> skeuomorphicOutset = [];
  
  // Text colors
  static const Color textHighEmphasis = Color(0xFFFFFFFF);
  static const Color textMediumEmphasis = Color(0xFFA0A0A5);
  static const Color textLowEmphasis = Color(0xFF6B6B70);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundBase,
      primaryColor: primaryGold,
      colorScheme: const ColorScheme.dark(
        primary: primaryGold,
        secondary: accentBlue,
        surface: surfaceBase,
      ),
      textTheme: GoogleFonts.outfitTextTheme(
        ThemeData.dark().textTheme
      ).copyWith(
        displayLarge: GoogleFonts.outfit(fontSize: 48, fontWeight: FontWeight.w700, color: textHighEmphasis, letterSpacing: -1),
        headlineLarge: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w600, color: textHighEmphasis, letterSpacing: -0.5),
        headlineMedium: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w500, color: textHighEmphasis),
        titleMedium: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w500, color: textHighEmphasis),
        bodyLarge: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w400, color: textMediumEmphasis),
        bodyMedium: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w400, color: textMediumEmphasis),
      ),
      dividerColor: Colors.white.withOpacity(0.05),
    );
  }

  // Sleek Premium Decorations (Flat with subtle glowing borders instead of heavy skeuomorphic)
  static BoxDecoration get panelDecoration {
    return BoxDecoration(
      color: surfaceBase,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.5),
          offset: const Offset(0, 10),
          blurRadius: 20,
        )
      ]
    );
  }

  // Golden Glow Decoration
  static BoxDecoration get activePanelDecoration {
    return BoxDecoration(
      color: surfaceElevated,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: primaryGold.withOpacity(0.3), width: 1),
      boxShadow: [
        BoxShadow(
          color: primaryGold.withOpacity(0.1),
          offset: const Offset(0, 0),
          blurRadius: 15,
          spreadRadius: 2,
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.8),
          offset: const Offset(0, 10),
          blurRadius: 20,
        )
      ]
    );
  }
}
