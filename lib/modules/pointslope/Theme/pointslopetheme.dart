import 'package:calculus_system/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PSTheme {
  PSTheme._();

  // ── Core Colors ──────────────────────────
  static const Color deepViolet = Color(0xFF7C3AED);
  static const Color electricPurple = Color(0xFFA855F7);
  static const Color softLavender = Color(0xFFC4B5FD);
  static const Color neonMagenta = Color(0xFFE879F9);
  static const Color cyanAccent = Color(0xFFA5F3FC);

  // Dynamic Theme Integration
  static Color surface(BuildContext context) =>
      context.watch<ThemeProvider>().surface;
  static Color bgDark(BuildContext context) =>
      context.watch<ThemeProvider>().surface;
  static Color cardBg(BuildContext context) =>
      context.watch<ThemeProvider>().card;
  static Color textPrimary(BuildContext context) =>
      context.watch<ThemeProvider>().textPrimary;
  static Color textSecondary(BuildContext context) =>
      context.watch<ThemeProvider>().textSecondary;
  static Color shadowColor(BuildContext context) =>
      context.watch<ThemeProvider>().shadowColor;
  static bool isLight(BuildContext context) =>
      context.watch<ThemeProvider>().isLight;

  // ── Semantic Alphas ───────────────────────
  static Color glowMagenta(double opacity) =>
      neonMagenta.withValues(alpha: opacity);
  static Color glowPurple(double opacity) =>
      electricPurple.withValues(alpha: opacity);
  static Color glowViolet(double opacity) =>
      deepViolet.withValues(alpha: opacity);
  static Color lavenderFaded(double opacity) =>
      softLavender.withValues(alpha: opacity);

  // ── Gradients ────────────────────────────
  static LinearGradient cardGradient(BuildContext context) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [cardBg(context), surface(context)],
      );

  static const LinearGradient dividerGradient = LinearGradient(
    colors: [
      Colors.transparent,
      electricPurple,
      neonMagenta,
      Colors.transparent,
    ],
    stops: [0, 0.3, 0.7, 1],
  );

  static LinearGradient iconBoxGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      deepViolet.withValues(alpha: 0.3),
      electricPurple.withValues(alpha: 0.1),
    ],
  );

  static LinearGradient resultBannerGradient(BuildContext context,
          {bool active = false}) =>
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          deepViolet.withValues(alpha: active ? 0.2 : 0.1),
          neonMagenta.withValues(alpha: active ? 0.1 : 0.05),
        ],
      );

  // ── Box Shadows ───────────────────────────
  static List<BoxShadow> cardShadow(BuildContext context, [double s = 1]) => [
        BoxShadow(
          color: deepViolet.withValues(alpha: 0.15),
          blurRadius: 24 * s,
          offset: Offset(0, 8 * s),
        ),
        BoxShadow(
          color: shadowColor(context),
          blurRadius: 16 * s,
          offset: Offset(0, -4 * s),
        ),
      ];

  static List<BoxShadow> iconBoxShadow([double s = 1]) => [
        BoxShadow(
          color: electricPurple.withValues(alpha: 0.15),
          blurRadius: 16 * s,
          offset: Offset(0, 4 * s),
        ),
      ];

  static List<BoxShadow> focusedInputShadow([double s = 1]) => [
        BoxShadow(
          color: electricPurple.withValues(alpha: 0.12),
          blurRadius: 16 * s,
        ),
      ];

  static List<BoxShadow> resultActiveShadow([double s = 1]) => [
        BoxShadow(
          color: neonMagenta.withValues(alpha: 0.1),
          blurRadius: 24 * s,
        ),
      ];

  // ── Border Radii ──────────────────────────
  static const double radiusCard = 20;
  static const double radiusInner = 14;
  static const double radiusChip = 12;
  static const double radiusInput = 10;
  static const double radiusIconBox = 14;
  static const double radiusBadge = 8;
  static const double radiusStatChip = 10;

  // ── Text Styles (with optional scale factor) ───────────
  static TextStyle titleStyle(BuildContext context, [double s = 1]) => TextStyle(
        fontSize: 18 * s,
        fontWeight: FontWeight.w600,
        color: textPrimary(context),
        letterSpacing: -0.4 * s,
      );

  static TextStyle subtitleStyle(BuildContext context, [double s = 1]) => TextStyle(
        fontSize: 13 * s,
        color: isLight(context)
            ? deepViolet.withValues(alpha: 0.7)
            : softLavender.withValues(alpha: 0.5),
      );

  static TextStyle monoCaptionStyle(BuildContext context, [double s = 1]) => TextStyle(
        fontSize: 11 * s,
        letterSpacing: 1.5 * s,
        color: isLight(context)
            ? deepViolet.withValues(alpha: 0.6)
            : softLavender.withValues(alpha: 0.5),
        fontFamily: 'monospace',
      );

  static TextStyle formulaStyle(BuildContext context, [double s = 1]) => TextStyle(
        fontSize: 22 * s,
        color: isLight(context) ? deepViolet : softLavender,
        fontStyle: FontStyle.italic,
      );

  static TextStyle highlightVarStyle([double s = 1]) => TextStyle(
        fontSize: 22 * s,
        color: neonMagenta,
        fontWeight: FontWeight.bold,
        fontStyle: FontStyle.normal,
        shadows: [
          Shadow(color: Color(0x66E879F9), blurRadius: 10 * s),
        ],
      );

  static TextStyle resultEquationStyle(BuildContext context, [double s = 1]) => TextStyle(
        fontSize: 20 * s,
        color: isLight(context) ? deepViolet : softLavender,
        fontStyle: FontStyle.italic,
        letterSpacing: 0.5 * s,
      );

  static TextStyle placeholderStyle(BuildContext context, [double s = 1]) => TextStyle(
        fontSize: 14 * s,
        fontStyle: FontStyle.italic,
        color: isLight(context)
            ? deepViolet.withValues(alpha: 0.3)
            : softLavender.withValues(alpha: 0.25),
      );

  static TextStyle inputTextStyle(BuildContext context, [double s = 1]) => TextStyle(
        fontSize: 16 * s,
        color: textPrimary(context),
      );

  static TextStyle inputHintStyle(BuildContext context, [double s = 1]) => TextStyle(
        color: isLight(context)
            ? deepViolet.withValues(alpha: 0.3)
            : softLavender.withValues(alpha: 0.25),
      );

  static TextStyle statChipLabelStyle(BuildContext context, [double s = 1]) => TextStyle(
        fontSize: 9 * s,
        letterSpacing: 0.8 * s,
        color: isLight(context)
            ? deepViolet.withValues(alpha: 0.6)
            : softLavender.withValues(alpha: 0.5),
        fontFamily: 'monospace',
      );

  static TextStyle statChipValueStyle(BuildContext context, [double s = 1]) => TextStyle(
        fontSize: 13 * s,
        color: isLight(context) ? deepViolet : softLavender,
        fontStyle: FontStyle.italic,
      );

  static TextStyle statChipEmptyStyle(BuildContext context, [double s = 1]) => TextStyle(
        fontSize: 13 * s,
        color: isLight(context)
            ? deepViolet.withValues(alpha: 0.2)
            : softLavender.withValues(alpha: 0.2),
        fontStyle: FontStyle.italic,
      );

  static TextStyle badgeKeyStyle([double s = 1]) => TextStyle(
        fontSize: 12 * s,
        color: neonMagenta,
        fontWeight: FontWeight.bold,
        fontFamily: 'monospace',
      );

  static TextStyle badgeValueStyle(BuildContext context, [double s = 1]) => TextStyle(
        fontSize: 12 * s,
        color: isLight(context) ? deepViolet : softLavender,
        fontFamily: 'monospace',
      );

  static TextStyle inputLabelStyle(BuildContext context, [double s = 1]) => TextStyle(
        fontSize: 11 * s,
        letterSpacing: 1.2 * s,
        color: electricPurple.withValues(alpha: 0.7),
        fontFamily: 'monospace',
      );

  static TextStyle inputVarStyle([double s = 1]) => TextStyle(
        fontSize: 14 * s,
        color: neonMagenta,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(color: neonMagenta.withValues(alpha: 0.3), blurRadius: 6 * s),
        ],
      );
}