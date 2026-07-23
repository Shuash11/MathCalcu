import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calculus_system/theme/theme_provider.dart';

class ModmatTheme {
  static const Color accent = Color(0xFF334155);
  static const Color accentLight = Color(0xFF3D4F6A);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);

  static Color themeAccent(BuildContext context) =>
      context.watch<ThemeProvider>().accentColor;

  static Color surface(BuildContext context) =>
      context.watch<ThemeProvider>().surface;

  static Color card(BuildContext context) =>
      context.watch<ThemeProvider>().card;

  static Color shadowColor(BuildContext context) =>
      context.watch<ThemeProvider>().shadowColor;

  static TextStyle titleStyle(BuildContext context) => TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: -0.5,
        height: 1.2,
      );

  static TextStyle subtitleStyle(BuildContext context) => TextStyle(
        fontSize: 15,
        color: textSecondary,
        height: 1.4,
      );

  static TextStyle buttonStyle(BuildContext context) => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: 0.3,
      );

  static TextStyle cardTitleStyle(BuildContext context) => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: -0.4,
        height: 1.2,
      );

  static TextStyle cardSubtitleStyle(BuildContext context) => TextStyle(
        fontSize: 12,
        color: textSecondary,
        height: 1.3,
      );

  static TextStyle tagStyle(BuildContext context) => TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      );

  /// Card decoration matching the Calculus `_CalculusSectionCard` pattern.
  /// Uses dynamic theme.card, theme.shadowColor, and accent via context.
  static BoxDecoration cardDecoration(
    BuildContext context, {
    required Color accentColor,
    bool hovered = false,
  }) {
    final theme = context.watch<ThemeProvider>();
    return BoxDecoration(
      color: theme.card,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: hovered
            ? accentColor.withValues(alpha: 0.45)
            : accentColor.withValues(alpha: 0.18),
        width: hovered ? 1.5 : 1,
      ),
      boxShadow: [
        BoxShadow(
          color: hovered
              ? accentColor.withValues(alpha: 0.22)
              : accentColor.withValues(alpha: 0.07),
          blurRadius: hovered ? 32 : 20,
          offset: const Offset(0, 8),
          spreadRadius: hovered ? 2 : 0,
        ),
        BoxShadow(
          color: theme.shadowColor,
          blurRadius: 12,
          offset: const Offset(0, 4),
          spreadRadius: -4,
        ),
      ],
    );
  }
}
