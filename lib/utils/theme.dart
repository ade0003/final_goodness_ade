import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const double baseSpacing = 8.0;

  static ThemeData get theme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.indigo,
        brightness: Brightness.light,
        primary: Colors.indigo,
        secondary: Colors.indigoAccent,
        background: Colors.white,
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: Colors.black87,
        onSurface: Colors.black87,
      ),

      textTheme: TextTheme(
        displayLarge: GoogleFonts.dmSans(
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: GoogleFonts.dmSans(
          fontSize: 28,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: GoogleFonts.dmSans(
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: GoogleFonts.dmSans(
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: GoogleFonts.dmMono(
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
        bodyMedium: GoogleFonts.dmMono(
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.dmSans(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: baseSpacing * 3,
            vertical: baseSpacing * 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(baseSpacing),
          ),
        ),
      ),

      // Card Theme
      cardTheme: CardTheme(
        elevation: 2,
        margin: const EdgeInsets.all(baseSpacing),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(baseSpacing),
        ),
      ),
    );
  }
}
