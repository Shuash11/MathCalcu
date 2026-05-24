import 'package:flutter/material.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:provider/provider.dart';

/// Distance Module Theme
/// Centralized colors and styles for the Distance calculator UI
abstract class DistanceTheme {
  // Brand / Accent Colors
  static const Color accent = Color(0xFFFF6B35);

  // Background Colors
  static Color surface(BuildContext context) =>
      context.watch<ThemeProvider>().surface;
  static Color card(BuildContext context) =>
      context.watch<ThemeProvider>().card;

  // Text Colors
  static Color text(BuildContext context) =>
      context.watch<ThemeProvider>().textPrimary;

  // Alpha Variants (pre-calculated for performance)
  static const Color accent70 = Color(0xB3FF6B35); // 70% opacity
  static const Color accent30 = Color(0x4DFF6B35); // 30% opacity
  static const Color accent25 = Color(0x40FF6B35); // 25% opacity
  static const Color accent15 = Color(0x26FF6B35); // 15% opacity
  static const Color accent12 = Color(0x1FFF6B35); // 12% opacity
  static const Color accent06 = Color(0x0FFF6B35); // 6% opacity
  static const Color accent04 = Color(0x0DFF6B35); // 4% opacity

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
      context.watch<ThemeProvider>().isLight ? const Color(0xFFFFEAEA) : const Color(0xFF2A1010);
  static const Color errorBorder = Color(0x4DFF6B6B); // 30% opacity error

  // Shadows
  static const List<BoxShadow> accentShadow = [
    BoxShadow(
      color: accent30,
      blurRadius: 20,
      offset: Offset(0, 6),
    ),
  ];

  // Gradients
  static LinearGradient resultGradient = const LinearGradient(
    colors: [accent15, accent04],
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

  static const TextStyle headerSubtitle = TextStyle(
    fontSize: 12,
    color: accent70,
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

  static const TextStyle modeButtonActive = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static TextStyle modeButtonInactive(BuildContext context) => TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: text35(context),
      );

  static TextStyle formulaText(BuildContext context) => TextStyle(
        fontSize: 13,
        color: text55(context),
        fontWeight: FontWeight.w500,
      );

  static const TextStyle pointLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: accent70,
    letterSpacing: 1.2,
  );

  static const TextStyle resultLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: accent70,
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
        color: text55(context),
        fontWeight: FontWeight.w500,
        height: 1.4,
      );

  static const TextStyle calculateButton = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: Colors.white,
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
        border: Border.all(color: accent12),
      );

  static BoxDecoration inputDecoration(BuildContext context) => BoxDecoration(
        color: card(context),
        borderRadius: BorderRadius.circular(radiusLg),
        border: Border.all(color: accent15, width: 1),
      );

  static BoxDecoration formulaHintDecoration = BoxDecoration(
    color: accent06,
    borderRadius: BorderRadius.circular(radiusMd),
    border: Border.all(color: accent12),
  );

  static BoxDecoration resultCardDecoration = BoxDecoration(
    gradient: resultGradient,
    borderRadius: BorderRadius.circular(radius2xl),
    border: Border.all(color: accent30),
  );

  static BoxDecoration errorDecoration(BuildContext context) => BoxDecoration(
    color: errorBg(context),
    borderRadius: BorderRadius.circular(radiusXl),
    border: Border.all(color: errorBorder),
  );

  static BoxDecoration headerIconDecoration(Color alphaColor) => BoxDecoration(
        color: alphaColor,
        borderRadius: BorderRadius.circular(radiusLg),
        border: Border.all(color: accent25),
      );

  // Animation Durations
  static const Duration modeSwitchDuration = Duration(milliseconds: 180);
}
