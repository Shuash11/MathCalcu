import 'package:flutter/material.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:provider/provider.dart';

/// Midpoint Module Theme
/// Clean white/frost aesthetic - minimal and precise
abstract class MidpointTheme {
  // Brand / Accent Colors
  static Color accent(BuildContext context) =>
      context.watch<ThemeProvider>().isLight
          ? const Color(0xFF334155) // Slate 800 - Dark for light mode contrast
          : const Color(0xFFE9ECEF); // Light Ice for dark mode

  static Color accentLight(BuildContext context) =>
      context.watch<ThemeProvider>().isLight
          ? const Color(0xFF64748B)
          : const Color(0xFFF8F9FA);

  static Color accentDark(BuildContext context) =>
      context.watch<ThemeProvider>().isLight
          ? const Color(0xFF0F172A)
          : const Color(0xFFDEE2E6);

  // Background Colors
  static Color surface(BuildContext context) =>
      context.watch<ThemeProvider>().surface;
  static Color card(BuildContext context) =>
      context.watch<ThemeProvider>().card;

  // Text Colors
  static Color text(BuildContext context) =>
      context.watch<ThemeProvider>().textPrimary;

  // Alpha Variants (Converted to reactive getters)
  static Color accent70(BuildContext context) =>
      accent(context).withValues(alpha: 0.7);
  static Color accent50(BuildContext context) =>
      accent(context).withValues(alpha: 0.5);
  static Color accent30(BuildContext context) =>
      accent(context).withValues(alpha: 0.3);
  static Color accent15(BuildContext context) =>
      accent(context).withValues(alpha: 0.15);
  static Color accent10(BuildContext context) =>
      accent(context).withValues(alpha: 0.1);
  static Color accent06(BuildContext context) =>
      accent(context).withValues(alpha: 0.06);

  static Color text70(BuildContext context) =>
      text(context).withValues(alpha: 0.7);
  static Color text50(BuildContext context) =>
      text(context).withValues(alpha: 0.5);
  static Color text40(BuildContext context) =>
      text(context).withValues(alpha: 0.4);
  static Color text30(BuildContext context) =>
      text(context).withValues(alpha: 0.3);
  static Color text20(BuildContext context) =>
      text(context).withValues(alpha: 0.2);

  // Semantic Colors
  static const Color error = Color(0xFFFF6B6B);
  static Color errorBg(BuildContext context) =>
      context.watch<ThemeProvider>().isLight
          ? const Color(0xFFFEF2F2)
          : const Color(0xFF2A1010);

  // Shadows
  static List<BoxShadow> accentShadow(BuildContext context) => [
        BoxShadow(
          color: accent30(context),
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
      ];

  // Gradients
  static LinearGradient resultGradient(BuildContext context) => LinearGradient(
        colors: [accent15(context), accent06(context)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  // Border Radius
  static const double radiusSm = 8.0;
  static const double radiusMd = 10.0;
  static const double radiusLg = 12.0;
  static const double radiusXl = 14.0;
  static const double radius2xl = 18.0;

  // Spacing
  static const double spaceXs = 6.0;
  static const double spaceSm = 8.0;
  static const double spaceMd = 10.0;
  static const double spaceLg = 12.0;
  static const double spaceXl = 14.0;
  static const double space2xl = 16.0;
  static const double space3xl = 20.0;
  static const double space4xl = 24.0;
  static const double space5xl = 28.0;
  static const double space6xl = 40.0;

  // Typography
  static TextStyle headerTitle(BuildContext context) => TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: text(context),
        letterSpacing: -0.5,
      );

  static TextStyle headerSubtitle(BuildContext context) => TextStyle(
        fontSize: 12,
        color: accent70(context),
      );

  static TextStyle inputLabel(BuildContext context) => TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: text40(context),
        letterSpacing: 0.8,
      );

  static TextStyle inputText(BuildContext context) => TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: text(context),
      );

  static TextStyle inputHint(BuildContext context) => TextStyle(
        color: text20(context),
        fontSize: 18,
      );

  static TextStyle modeButtonActive(BuildContext context) => TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: surface(context),
      );

  static TextStyle modeButtonInactive(BuildContext context) => TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: text30(context),
      );

  static TextStyle formulaText(BuildContext context) => TextStyle(
        fontSize: 13,
        color: text50(context),
        fontWeight: FontWeight.w500,
      );

  static TextStyle pointLabel(BuildContext context) => TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: accent50(context),
        letterSpacing: 1.2,
      );

  static TextStyle resultLabel(BuildContext context) => TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: accent50(context),
        letterSpacing: 1.4,
      );

  static TextStyle resultValue(BuildContext context) => TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: text(context),
        letterSpacing: -1.0,
      );

  static TextStyle resultFormula(BuildContext context) => TextStyle(
        fontSize: 12,
        color: text50(context),
        fontWeight: FontWeight.w500,
        height: 1.4,
      );

  static TextStyle calculateButton(BuildContext context) => TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: surface(context),
        letterSpacing: 0.3,
      );

  static const TextStyle errorText = TextStyle(
    color: error,
    fontSize: 14,
  );

  // Decoration Helpers
  static BoxDecoration cardDecoration(BuildContext context) => BoxDecoration(
        color: card(context),
        borderRadius: BorderRadius.circular(radiusLg),
        border: Border.all(color: accent10(context)),
      );

  static BoxDecoration inputDecoration(BuildContext context) => BoxDecoration(
        color: card(context),
        borderRadius: BorderRadius.circular(radiusLg),
        border: Border.all(color: accent15(context), width: 1),
      );

  static BoxDecoration formulaHintDecoration(BuildContext context) =>
      BoxDecoration(
        color: accent06(context),
        borderRadius: BorderRadius.circular(radiusMd),
        border: Border.all(color: accent10(context)),
      );

  static BoxDecoration resultCardDecoration(BuildContext context) =>
      BoxDecoration(
        gradient: resultGradient(context),
        borderRadius: BorderRadius.circular(radius2xl),
        border: Border.all(color: accent30(context)),
      );

  static BoxDecoration errorDecoration(BuildContext context) => BoxDecoration(
        color: errorBg(context),
        borderRadius: BorderRadius.circular(radiusXl),
        border: Border.all(color: const Color(0x4DFF6B6B)),
      );

  static BoxDecoration headerIconDecoration(
          BuildContext context, Color alphaColor) =>
      BoxDecoration(
        color: alphaColor,
        borderRadius: BorderRadius.circular(radiusLg),
        border: Border.all(color: accent15(context)),
      );

  // Animation Durations
  static const Duration modeSwitchDuration = Duration(milliseconds: 180);
}
