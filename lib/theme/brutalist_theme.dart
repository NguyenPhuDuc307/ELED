import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BrutalistTheme {
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color primary = Color(0xFFE2F040); // Neon yellow
  static const Color secondary = Color(0xFFFF5252); // Neon red
  static const Color accent = Color(0xFF40E0D0); // Turquoise

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: white,
      primaryColor: primary,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: secondary,
        surface: white,
        onSurface: black,
      ),
      textTheme: GoogleFonts.spaceMonoTextTheme(ThemeData.light().textTheme).copyWith(
        displayLarge: GoogleFonts.spaceMono(
          color: black,
          fontSize: 48,
          fontWeight: FontWeight.w800,
        ),
        headlineMedium: GoogleFonts.spaceMono(
          color: black,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: GoogleFonts.spaceMono(
          color: black,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: white,
        foregroundColor: black,
        elevation: 0,
        centerTitle: false,
        shape: Border(
          bottom: BorderSide(color: black, width: 4),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: black,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: black,
        onSurface: white,
      ),
      textTheme: GoogleFonts.spaceMonoTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.spaceMono(
          color: white,
          fontSize: 48,
          fontWeight: FontWeight.w800,
        ),
        headlineMedium: GoogleFonts.spaceMono(
          color: white,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: GoogleFonts.spaceMono(
          color: white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: black,
        foregroundColor: white,
        elevation: 0,
        centerTitle: false,
        shape: Border(
          bottom: BorderSide(color: white, width: 4),
        ),
      ),
    );
  }
}

extension BrutalistContext on BuildContext {
  /// Represents the dynamic "Black" border/text color (White in dark mode)
  Color get bBorder => Theme.of(this).colorScheme.onSurface;
  /// Represents the dynamic "White" background color (Black in dark mode)
  Color get bBg => Theme.of(this).colorScheme.surface;
}
