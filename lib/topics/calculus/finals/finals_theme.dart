import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calculus_system/theme/theme_provider.dart';

// ─────────────────────────────────────────────────────────────
// FINALS THEME
//
// Dark slate aesthetic matching the app-wide dark mode.
// ─────────────────────────────────────────────────────────────

class FinalsTheme {
  // ── Brand colors — white/ice for dark mode ────────────────
  static const Color primary   = Color(0xFFE9ECEF);
  static const Color secondary = Color(0xFF0C0C09);
  static const Color tertiary  = Color(0xFF16A34A);
  static const Color danger    = Color(0xFFFF6B6B);

  // ── Surface / card — delegates to ThemeProvider ───────────
  static Color surface(BuildContext context) =>
      context.watch<ThemeProvider>().surface;

  static Color card(BuildContext context) =>
      context.watch<ThemeProvider>().card;

  static Color cardSecondary(BuildContext context) =>
      context.watch<ThemeProvider>().cardSecondary;

  static Color textPrimary(BuildContext context) =>
      context.watch<ThemeProvider>().textPrimary;

  static Color textSecondary(BuildContext context) =>
      context.watch<ThemeProvider>().textSecondary;

  static Color shadowColor(BuildContext context) =>
      context.watch<ThemeProvider>().shadowColor;

  static bool isLight(BuildContext context) =>
      context.watch<ThemeProvider>().isLight;

  // ── Typography ────────────────────────────────────────────
  static TextStyle titleStyle(BuildContext context, {bool responsive = false}) =>
      TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: textPrimary(context),
        letterSpacing: -0.4,
      );

  static TextStyle subtitleStyle(BuildContext context,
          {bool responsive = false}) =>
      TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: textSecondary(context),
        height: 1.4,
      );

  static TextStyle labelStyle(BuildContext context,
          {bool responsive = false}) =>
      TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
        color: primary.withValues(alpha: 0.8),
      );

  // ── Gradients ─────────────────────────────────────────────
  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFFE9ECEF), Color(0xFFDEE2E6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient cardGlow({bool hovered = false}) => LinearGradient(
        colors: [
          primary.withValues(alpha: hovered ? 0.18 : 0.10),
          secondary.withValues(alpha: hovered ? 0.08 : 0.04),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
}
