import 'package:flutter/material.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:provider/provider.dart';

// ═════════════════════════════════════════════════════════════
// SLOPE MODULE THEME
// ─────────────────────────────────────────────────────────────
// Clean, modern design matching Solver & Inequality modules
// ═════════════════════════════════════════════════════════════

class SlopeTheme {
  // ── Unique accent color for slope module ──────────────────
  static const Color accentColor = Color(0xFFFF1493); // deep pink
  static const Color secondAccent = Color(0xFFFF69B4); // hot pink
  // ──────────────────────────────────────────────────────────

  static Color cardColor(BuildContext context) => context.watch<ThemeProvider>().card;
  static Color surface(BuildContext context) => context.watch<ThemeProvider>().surface;
  static Color textPrimary(BuildContext context) => context.watch<ThemeProvider>().textPrimary;
  static Color textSecondary(BuildContext context) => context.watch<ThemeProvider>().textSecondary;

  static TextStyle titleStyle(BuildContext context) => TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        color: textPrimary(context),
        letterSpacing: -0.8,
      );

  static TextStyle subtitleStyle(BuildContext context) => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textSecondary(context),
      );

  static TextStyle labelStyle(BuildContext context) => TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: textSecondary(context).withValues(alpha: 0.7),
        letterSpacing: 0.5,
      );

  static TextStyle resultStyle(BuildContext context) => TextStyle(
        fontSize: 42,
        fontWeight: FontWeight.w800,
        color: textPrimary(context),
        height: 1,
      );
}
