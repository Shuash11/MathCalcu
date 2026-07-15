import 'package:calculus_system/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ═════════════════════════════════════════════════════════════
// INEQUALITY MODULE THEME
// Dark slate aesthetic matching the app-wide dark mode
// ═════════════════════════════════════════════════════════════

class InequalityTheme {
  // ── Accent colors — maroon for dark mode ───────────────
  static const Color accentColor = Color(0xFF7F1D1D);
  static const Color secondAccent = Color(0xFF7F1D1D);

  // Dynamic values using BuildContext
  static Color surface(BuildContext context) =>
      context.watch<ThemeProvider>().surface;
  static Color card(BuildContext context) =>
      context.watch<ThemeProvider>().card;
  static Color text(BuildContext context) =>
      context.watch<ThemeProvider>().textPrimary;
  static Color textSecondary(BuildContext context) =>
      context.watch<ThemeProvider>().textSecondary;

  static const Map<String, Color> subtypeAccents = {
    'strict': Color(0xFF7F1D1D),
    'non_strict': Color(0xFF7F1D1D),
    'absolute': Color(0xFF7F1D1D),
  };

  static TextStyle titleStyle(BuildContext context,
          {bool responsive = false}) =>
      TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        color: text(context),
        letterSpacing: -0.8,
      );

  static TextStyle subtitleStyle(BuildContext context,
          {bool responsive = false}) =>
      TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textSecondary(context),
      );
}
