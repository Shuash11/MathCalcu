import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calculus_system/theme/theme_provider.dart';

// ─────────────────────────────────────────────────────────────
// FINALS THEME
//
// Separate theme layer on top of ThemeProvider.
// Uses ThemeProvider for surface base,
// but overrides with Finals-specific Minimal palette.
//
// Primary   : Maroon       →  Color(0xFF7F1D1D)
// Secondary : Dark charcoal→  Color(0xFF0C0C09)
// Tertiary  : Green        →  Color(0xFF16A34A)
// Danger    : Red          →  Color(0xFFDC2626)  ← for badges
// ─────────────────────────────────────────────────────────────

class FinalsTheme {
  // ── Brand colors ──────────────────────────────────────────
  static const Color primary   = Color(0xFF7F1D1D);
  static const Color secondary = Color(0xFF0C0C09);
  static const Color tertiary  = Color(0xFF16A34A);
  static const Color danger    = Color(0xFFDC2626);

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
    colors: [Color(0xFF7F1D1D), Color(0xFF4A0E1A)],
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
