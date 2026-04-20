import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BrutalistTheme {
  // ── Neutrals — warm cream ────────────────────────────────────────
  static const Color background   = Color(0xFFFAF5F2); // warm cream
  static const Color surface      = Color(0xFFFFFFFF);
  static const Color black        = Color(0xFF1A1A1A); // warm near-black
  static const Color white        = Color(0xFFFFFFFF);
  static const Color textMuted    = Color(0xFFA89890); // warm taupe
  static const Color border       = Color(0xFFEDE0D8); // warm border

  // ── Primary — deep sage green ────────────────────────────────────
  static const Color primary      = Color(0xFF3A6B36);
  static const Color primaryLight = Color(0xFFC8DEC4); // pastel sage (A1 cards)

  // ── Secondary — coral (CTA buttons) ──────────────────────────────
  static const Color secondary      = Color(0xFFE07860); // warm coral
  static const Color secondaryLight = Color(0xFFF5D5CC); // pastel blush (A2 cards)

  // ── Accent — warm brown / coral ───────────────────────────────────
  static const Color accent      = Color(0xFF7A5C4A); // warm brown
  static const Color accentLight = Color(0xFFF5C4B8); // pastel coral (B2 cards)

  // ─── Light theme ──────────────────────────────────────────────────
  static ThemeData get lightTheme {
    final base = ThemeData.light();
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: secondary,
        surface: surface,
        onSurface: black,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.poppins(
          color: black, fontSize: 40, fontWeight: FontWeight.w700,
        ),
        headlineMedium: GoogleFonts.poppins(
          color: black, fontSize: 22, fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.poppins(
          color: black, fontSize: 15, fontWeight: FontWeight.w400,
        ),
        bodyMedium: GoogleFonts.poppins(
          color: textMuted, fontSize: 13, fontWeight: FontWeight.w400,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: black,
        elevation: 0,
        centerTitle: false,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        surfaceTintColor: Colors.transparent,
        shape: const Border(bottom: BorderSide(color: border, width: 1)),
        iconTheme: const IconThemeData(color: black, size: 24),
        actionsIconTheme: const IconThemeData(color: black, size: 24),
        titleTextStyle: GoogleFonts.poppins(
          color: black, fontSize: 18, fontWeight: FontWeight.w700,
        ),
      ),
      dividerColor: border,
      cardColor: surface,
      chipTheme: ChipThemeData(
        backgroundColor: background,
        selectedColor: primaryLight,
        side: const BorderSide(color: border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        labelStyle: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
      ),
    );
  }

  // ─── Dark theme ────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    final base = ThemeData.dark();
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0F172A), // slate-900
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: Color(0xFF1E293B), // slate-800
        onSurface: Color(0xFFF1F5F9), // slate-100
      ),
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.poppins(
          color: const Color(0xFFF1F5F9), fontSize: 40, fontWeight: FontWeight.w700,
        ),
        headlineMedium: GoogleFonts.poppins(
          color: const Color(0xFFF1F5F9), fontSize: 22, fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.poppins(
          color: const Color(0xFFF1F5F9), fontSize: 15, fontWeight: FontWeight.w400,
        ),
        bodyMedium: GoogleFonts.poppins(
          color: const Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.w400,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: const Color(0xFFF1F5F9),
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        shape: const Border(bottom: BorderSide(color: Color(0xFF334155), width: 1)),
        iconTheme: const IconThemeData(color: Color(0xFFF1F5F9), size: 24),
        actionsIconTheme: const IconThemeData(color: Color(0xFFF1F5F9), size: 24),
        titleTextStyle: GoogleFonts.poppins(
          color: const Color(0xFFF1F5F9), fontSize: 18, fontWeight: FontWeight.w700,
        ),
      ),
      dividerColor: const Color(0xFF334155),
      cardColor: const Color(0xFF1E293B),
    );
  }
}

extension BrutalistContext on BuildContext {
  Color get bBorder => Theme.of(this).colorScheme.onSurface;
  Color get bBg     => Theme.of(this).colorScheme.surface;
  Color get bMuted  => Theme.of(this).brightness == Brightness.dark
      ? const Color(0xFF64748B)
      : BrutalistTheme.textMuted;
  Color get bSubtle => Theme.of(this).brightness == Brightness.dark
      ? const Color(0xFF334155)
      : BrutalistTheme.border;
}

/// Smooth fade + slide-up page transition — use instead of MaterialPageRoute.
Route<T> smoothRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (_, __, ___) => page,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (_, animation, __, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.04),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

/// 5 pastel card colours — muted, soft, easy on the eyes.
///
/// A1 sage · A2 periwinkle · B1 lavender · B2 peach · C1 blush
Color levelColor(String levels, {int fallbackIndex = 0}) {
  final upper = levels.toUpperCase();
  if (upper.contains('A1')) return const Color(0xFFC8DEC4); // pastel sage
  if (upper.contains('A2')) return const Color(0xFFF5D5CC); // pastel blush
  if (upper.contains('B1')) return const Color(0xFFF5E4CC); // warm peach
  if (upper.contains('B2')) return const Color(0xFFF5C4B8); // pastel coral
  if (upper.contains('C1')) return const Color(0xFFE8C4BC); // deeper blush
  return fallbackIndex % 2 == 0
      ? const Color(0xFFC8DEC4)
      : const Color(0xFFF5D5CC);
}
