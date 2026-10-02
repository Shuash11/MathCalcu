import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calculus_system/theme/theme_provider.dart';

// ─────────────────────────────────────────────────────────────
// FINALS THEME
//
// Mode-aware finals theme: statics delegate to mode-aware ThemeProvider tokens; renders in light AND dark.
// ─────────────────────────────────────────────────────────────

class FinalsTheme {
  // ── Brand colors — white/ice for dark mode ────────────────
  static const Color primary = Color(0xFFE9ECEF);
  static const Color secondary = Color(0xFF0C0C09);
  static const Color tertiary = Color(0xFF16A34A);
  static const Color danger = Color(0xFFFF6B6B);

  // ── Surface / card — delegates to ThemeProvider ───────────
  static Color surface(BuildContext context) =>
      context.watch<ThemeProvider>().surface;

  static Color card(BuildContext context) =>
      context.watch<ThemeProvider>().card;

  /// Reads the card token from a gesture callback, where listening is invalid.
  static Color cardForEvent(BuildContext context) =>
      context.read<ThemeProvider>().card;

  static Color cardSecondary(BuildContext context) =>
      context.watch<ThemeProvider>().cardSecondary;

  static Color textPrimary(BuildContext context) =>
      context.watch<ThemeProvider>().textPrimary;

  static Color textSecondary(BuildContext context) =>
      context.watch<ThemeProvider>().textSecondary;

  /// Context-aware semantic accents. Static legacy colors cannot meet contrast
  /// requirements on both the light and dark application surfaces.
  static Color primaryFor(BuildContext context) =>
      context.watch<ThemeProvider>().accentColor;

  static Color secondaryFor(BuildContext context) =>
      context.watch<ThemeProvider>().textPrimary;

  static Color onPrimaryFor(BuildContext context) =>
      context.watch<ThemeProvider>().surface;

  /// Context-aware semantic danger accent. Static #FF6B6B fails light mode
  /// (2.78:1 vs light card). errorColor is WCAG-AA on [card] in both modes.
  static Color dangerFor(BuildContext context) =>
      context.watch<ThemeProvider>().errorColor;

  static Color tertiaryFor(BuildContext context) =>
      context.watch<ThemeProvider>().tertiaryColor;

  /// Event-time variants (callback contexts): read without subscribing —
  /// safe outside build. Build-time code should use dangerFor/onErrorFor.
  static Color dangerNow(BuildContext context) =>
      Provider.of<ThemeProvider>(context, listen: false).errorColor;

  static Color onErrorNow(BuildContext context) =>
      Provider.of<ThemeProvider>(context, listen: false).onErrorColor;

  static Color shadowColor(BuildContext context) =>
      context.watch<ThemeProvider>().shadowColor;

  static bool isLight(BuildContext context) =>
      context.watch<ThemeProvider>().isLight;

  // ── Typography ────────────────────────────────────────────
  static TextStyle titleStyle(BuildContext context,
          {bool responsive = false}) =>
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
        color: textSecondary(context),
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
