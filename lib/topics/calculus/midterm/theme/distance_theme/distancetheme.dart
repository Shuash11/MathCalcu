import 'package:flutter/material.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:provider/provider.dart';

/// Distance Module Theme
/// Dark slate aesthetic matching the app-wide dark mode
abstract class DistanceTheme {
  // ── Static defaults (dark mode) ─────────────────────────
  static const Color accentDefault = Color(0xFFE9ECEF);
  static const Color accent70Static = Color(0xB3E9ECEF);
  static const Color accent50Static = Color(0x80E9ECEF);
  static const Color accent30Static = Color(0x4DE9ECEF);
  static const Color accent15Static = Color(0x26E9ECEF);
  static const Color accent12Static = Color(0x1FE9ECEF);
  static const Color accent06Static = Color(0x0FE9ECEF);

  // Brand / Accent Colors — context-aware for light/dark switching
  static Color accent(BuildContext context) =>
      context.watch<ThemeProvider>().isLight
          ? const Color(0xFF334155)
          : accentDefault;

  static Color accentLight(BuildContext context) =>
      context.watch<ThemeProvider>().isLight
          ? const Color(0xFF64748B)
          : const Color(0xFFF8F9FA);

  // Background Colors
  static Color surface(BuildContext context) =>
      context.watch<ThemeProvider>().surface;
  static Color card(BuildContext context) =>
      context.watch<ThemeProvider>().card;

  // Text Colors
  static Color text(BuildContext context) =>
      context.watch<ThemeProvider>().textPrimary;

  // Alpha Variants (context-aware for light/dark switching)
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
  static Color text55(BuildContext context) =>
      text(context).withValues(alpha: 0.55);
  static Color text40(BuildContext context) =>
      text(context).withValues(alpha: 0.4);
  static Color text35(BuildContext context) =>
      text(context).withValues(alpha: 0.35);
  static Color text20(BuildContext context) =>
      text(context).withValues(alpha: 0.2);

  // Semantic Colors
  static const Color error = Color(0xFFFF6B6B);
  static Color errorBg(BuildContext context) =>
      context.watch<ThemeProvider>().isLight
          ? const Color(0xFFFFEAEA)
          : const Color(0xFF2A1010);

  // Shadows
  static const List<BoxShadow> accentShadow = [
    BoxShadow(
      color: accent30Static,
      blurRadius: 20,
      offset: Offset(0, 6),
    ),
  ];

  // Gradients
  static const LinearGradient resultGradient = LinearGradient(
    colors: [accent15Static, accent06Static],
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
  static TextStyle headerTitle(BuildContext context,
          {bool responsive = false}) =>
      TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: text(context),
        letterSpacing: -0.5,
      );

  static const TextStyle headerSubtitle = TextStyle(
    fontSize: 12,
    color: accent70Static,
  );

  static TextStyle inputLabel(BuildContext context,
          {bool responsive = false}) =>
      TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: text40(context),
        letterSpacing: 0.8,
      );

  static TextStyle inputText(BuildContext context,
          {bool responsive = false}) =>
      TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: text(context),
      );

  static TextStyle inputHint(BuildContext context,
          {bool responsive = false}) =>
      TextStyle(
        color: text20(context),
        fontSize: 18,
      );

  static const TextStyle modeButtonActive = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static TextStyle modeButtonInactive(BuildContext context,
          {bool responsive = false}) =>
      TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: text35(context),
      );

  static TextStyle formulaText(BuildContext context,
          {bool responsive = false}) =>
      TextStyle(
        fontSize: 13,
        color: text55(context),
        fontWeight: FontWeight.w500,
      );

  static const TextStyle pointLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: accent70Static,
    letterSpacing: 1.2,
  );

  static const TextStyle resultLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: accent70Static,
    letterSpacing: 1.4,
  );

  static TextStyle resultValue(BuildContext context,
          {bool responsive = false}) =>
      TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: text(context),
        letterSpacing: -1.0,
      );

  static TextStyle resultFormula(BuildContext context,
          {bool responsive = false}) =>
      TextStyle(
        fontSize: 12,
        color: text55(context),
        fontWeight: FontWeight.w500,
        height: 1.4,
      );

  static const TextStyle calculateButton = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: Color(0xFF1A1A2E),
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

  static BoxDecoration formulaHintDecoration = BoxDecoration(
    color: accent06Static,
    borderRadius: BorderRadius.circular(radiusMd),
    border: Border.all(color: accent12Static),
  );

  static BoxDecoration resultCardDecoration = BoxDecoration(
    gradient: resultGradient,
    borderRadius: BorderRadius.circular(radius2xl),
    border: Border.all(color: accent30Static),
  );

  static BoxDecoration errorDecoration(BuildContext context) => BoxDecoration(
        color: errorBg(context),
        borderRadius: BorderRadius.circular(radiusXl),
        border: Border.all(color: const Color(0x4DFF6B6B)),
      );

  static BoxDecoration headerIconDecoration(Color alphaColor) => BoxDecoration(
        color: alphaColor,
        borderRadius: BorderRadius.circular(radiusLg),
        border: Border.all(color: accent15Static),
      );

  // Animation Durations
  static const Duration modeSwitchDuration = Duration(milliseconds: 180);
}
