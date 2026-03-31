import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../theme/theme_provider.dart';

class YITheme {
  // ── Palette (Static Fallbacks) ──────────────────────────
  static const Color forestGreen = Color(0xFF059669);
  static const Color emeraldConst = Color(0xFF10B981);
  static const Color mintConst = Color(0xFF6EE7B7);
  static const Color goldConst = Color(0xFFF59E0B);

  // Dynamic Theme Integration
  static bool isLight(BuildContext context) => context.watch<ThemeProvider>().isLight;
  static Color surface(BuildContext context) => context.watch<ThemeProvider>().surface;
  static Color cardBg(BuildContext context) => context.watch<ThemeProvider>().card;
  static Color textPrimary(BuildContext context) => context.watch<ThemeProvider>().textPrimary;
  static Color textSecondary(BuildContext context) => context.watch<ThemeProvider>().textSecondary;
  static Color shadowColor(BuildContext context) => context.watch<ThemeProvider>().shadowColor;

  // ── Dynamic Accent Colors ───────────────────────────────
  static Color emerald(BuildContext context) => isLight(context) ? const Color(0xFF059669) : const Color(0xFF10B981);
  static Color gold(BuildContext context) => isLight(context) ? const Color(0xFFD97706) : const Color(0xFFF59E0B);
  static Color mint(BuildContext context) => isLight(context) ? const Color(0xFF10B981) : const Color(0xFF6EE7B7);
  static Color forest(BuildContext context) => isLight(context) ? const Color(0xFF064E3B) : const Color(0xFF059669);

  // ── Gradients ──────────────────────────────────────────
  static LinearGradient cardGradient(BuildContext context) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      cardBg(context),
      surface(context),
    ],
  );

  static LinearGradient glowGradient(BuildContext context) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      emerald(context).withValues(alpha: 0.12),
      gold(context).withValues(alpha: 0.08),
    ],
  );

  // ── Text styles ────────────────────────────────────────
  static TextStyle titleStyle(BuildContext context) => TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimary(context),
    letterSpacing: -0.5,
  );

  static TextStyle subtitleStyle(BuildContext context) => TextStyle(
    fontSize: 13,
    color: isLight(context) ? emerald(context).withValues(alpha: 0.8) : mint(context).withValues(alpha: 0.7),
    height: 1.3,
  );

  static TextStyle inputLabelStyle(BuildContext context) => TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: isLight(context) ? forest(context).withValues(alpha: 0.7) : mint(context).withValues(alpha: 0.5),
    letterSpacing: 1.2,
  );

  static TextStyle inputVarStyle(BuildContext context) => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: isLight(context) ? emerald(context) : mint(context),
  );

  static TextStyle inputTextStyle(BuildContext context) => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: textPrimary(context),
    fontFamily: 'monospace',
  );

  static TextStyle formulaStyle(BuildContext context) => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: textPrimary(context),
    fontFamily: 'monospace',
  );

  static TextStyle resultEquationStyle(BuildContext context) => TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: isLight(context) ? emerald(context) : mint(context),
    fontFamily: 'monospace',
  );

  static TextStyle badgeKeyStyle(BuildContext context) => TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: isLight(context) ? forest(context).withValues(alpha: 0.7) : mint(context).withValues(alpha: 0.5),
  );

  static TextStyle badgeValueStyle(BuildContext context) => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: textPrimary(context),
  );

  // Radius
  static const double radiusCard = 20.0;
  static const double radiusInner = 16.0;
  static const double radiusInput = 12.0;
  static const double radiusBadge = 10.0;

  // Shadows
  static List<BoxShadow> cardShadow(BuildContext context) => [
    BoxShadow(
      color: emerald(context).withValues(alpha: isLight(context) ? 0.08 : 0.15),
      blurRadius: 30,
      offset: const Offset(0, 10),
    ),
    BoxShadow(
      color: shadowColor(context),
      blurRadius: 20,
      offset: const Offset(0, -5),
    ),
  ];

  static List<BoxShadow> inputGlow(BuildContext context) => [
    BoxShadow(
      color: emerald(context).withValues(alpha: 0.3),
      blurRadius: 12,
      spreadRadius: 2,
    ),
  ];
}