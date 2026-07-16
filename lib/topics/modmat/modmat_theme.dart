import 'package:flutter/material.dart';

class ModmatTheme {
  static const Color primary = Color(0xFF0D9488);
  static const Color secondary = Color(0xFF14B8A6);
  static const Color accent = Color(0xFF5EEAD4);
  static const Color background = Color(0xFFF0FDFA);
  static const Color card = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);

  static const Color tealLight = Color(0xFFCCFBF1);
  static const Color tealDark = Color(0xFF0F766E);

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

  static BoxDecoration cardDecoration(BuildContext context,
          {bool hovered = false}) =>
      BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hovered
              ? secondary.withValues(alpha: 0.45)
              : primary.withValues(alpha: 0.25),
          width: hovered ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: hovered
                ? secondary.withValues(alpha: 0.2)
                : primary.withValues(alpha: 0.1),
            blurRadius: hovered ? 36 : 22,
            offset: Offset(0, 8),
            spreadRadius: hovered ? 2 : 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: Offset(0, 4),
            spreadRadius: -4,
          ),
        ],
      );

  static BoxDecoration inputDecoration(BuildContext context,
          {bool focused = false, Color? accentColor}) =>
      BoxDecoration(
        color: context.brightness == Brightness.light
            ? Colors.black.withValues(alpha: 0.03)
            : Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: focused
              ? (accentColor ?? primary).withValues(alpha: 0.5)
              : primary.withValues(alpha: 0.2),
          width: focused ? 1.5 : 1,
        ),
      );
}

extension ContextBrightness on BuildContext {
  Brightness get brightness => Theme.of(this).brightness;
}
