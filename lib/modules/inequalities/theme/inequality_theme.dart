import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/theme_provider.dart';

// ═════════════════════════════════════════════════════════════
// JOASHUA — INEQUALITY MODULE THEME
// ─────────────────────────────────────────────────────────────
// This file is JOASHUA's design space.
// Values are now context-aware to support light/dark mode.
// ═════════════════════════════════════════════════════════════

class InequalityTheme {
  // ── JOASHUA: customize your accent color here ─────────────
  static const Color accentColor = Color(0xFF6C63FF); // violet
  static const Color secondAccent = Color(0xFFA89CFF); // lighter violet
  // ──────────────────────────────────────────────────────────

  // Dynamic values using BuildContext
  static Color surface(BuildContext context) => context.watch<ThemeProvider>().surface;
  static Color card(BuildContext context) => context.watch<ThemeProvider>().card;
  static Color text(BuildContext context) => context.watch<ThemeProvider>().textPrimary;
  static Color textSecondary(BuildContext context) => context.watch<ThemeProvider>().textSecondary;

  static const Map<String, Color> subtypeAccents = {
    'strict': Color(0xFF6C63FF),
    'non_strict': Color(0xFF9B8FFF),
    'absolute': Color(0xFFC4BCFF),
  };

  static TextStyle titleStyle(BuildContext context) => TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        color: text(context),
        letterSpacing: -0.8,
      );

  static TextStyle subtitleStyle(BuildContext context) => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textSecondary(context),
      );
}
