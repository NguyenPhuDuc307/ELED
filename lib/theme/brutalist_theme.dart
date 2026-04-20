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
  Color get bBorder => Theme.of(this).colorScheme.onSurface;
  Color get bBg => Theme.of(this).colorScheme.surface;
}

/// Returns a card background color based on Oxford level string (e.g. "A1", "B2").
/// Falls back to alternating primary/accent if level is unrecognized.
Color levelColor(String levels, {int fallbackIndex = 0}) {
  final upper = levels.toUpperCase();
  if (upper.contains('A1')) return BrutalistTheme.primary;
  if (upper.contains('A2')) return BrutalistTheme.accent;
  if (upper.contains('B1')) return const Color(0xFFB8A9FF); // soft purple
  if (upper.contains('B2')) return const Color(0xFFFFB347); // soft orange
  if (upper.contains('C1')) return BrutalistTheme.secondary;
  return fallbackIndex % 2 == 0 ? BrutalistTheme.primary : BrutalistTheme.accent;
}
