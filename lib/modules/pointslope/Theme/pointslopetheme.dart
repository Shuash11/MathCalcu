import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../theme/theme_provider.dart';

class PSTheme {
  PSTheme._();

  // ── Core Colors ──────────────────────────
  static const Color deepViolet     = Color(0xFF7C3AED);
  static const Color electricPurple = Color(0xFFA855F7);
  static const Color softLavender   = Color(0xFFC4B5FD);
  static const Color neonMagenta    = Color(0xFFE879F9);
  static const Color cyanAccent     = Color(0xFFA5F3FC);

  // Dynamic Theme Integration
  static Color surface(BuildContext context) => context.watch<ThemeProvider>().surface;
  static Color bgDark(BuildContext context) => context.watch<ThemeProvider>().surface;
  static Color cardBg(BuildContext context) => context.watch<ThemeProvider>().card;
  static Color textPrimary(BuildContext context) => context.watch<ThemeProvider>().textPrimary;
  static Color textSecondary(BuildContext context) => context.watch<ThemeProvider>().textSecondary;
  static Color shadowColor(BuildContext context) => context.watch<ThemeProvider>().shadowColor;
  static bool isLight(BuildContext context) => context.watch<ThemeProvider>().isLight;

  // ── Semantic Alphas ───────────────────────
  static Color glowMagenta(double opacity) => neonMagenta.withValues(alpha: opacity);
  static Color glowPurple(double opacity) => electricPurple.withValues(alpha: opacity);
  static Color glowViolet(double opacity) => deepViolet.withValues(alpha: opacity);
  static Color lavenderFaded(double opacity) => softLavender.withValues(alpha: opacity);

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

  static LinearGradient resultBannerGradient(BuildContext context, {bool active = false}) =>
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          deepViolet.withValues(alpha: active ? 0.2 : 0.1),
          neonMagenta.withValues(alpha: active ? 0.1 : 0.05),
        ],
      );

  // ── Box Shadows ───────────────────────────
  static List<BoxShadow> cardShadow(BuildContext context) => [
    BoxShadow(
      color: deepViolet.withValues(alpha: 0.15),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: shadowColor(context),
      blurRadius: 16,
      offset: const Offset(0, -4),
    ),
  ];

  static List<BoxShadow> iconBoxShadow = [
    BoxShadow(
      color: electricPurple.withValues(alpha: 0.15),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> focusedInputShadow = [
    BoxShadow(
      color: electricPurple.withValues(alpha: 0.12),
      blurRadius: 16,
    ),
  ];

  static List<BoxShadow> resultActiveShadow = [
    BoxShadow(
      color: neonMagenta.withValues(alpha: 0.1),
      blurRadius: 24,
    ),
  ];

  // ── Border Radii ──────────────────────────
  static const double radiusCard    = 20;
  static const double radiusInner   = 14;
  static const double radiusChip    = 12;
  static const double radiusInput   = 10;
  static const double radiusIconBox = 14;
  static const double radiusBadge   = 8;
  static const double radiusStatChip= 10;

  // ── Text Styles ───────────────────────────
  static TextStyle titleStyle(BuildContext context) => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary(context),
    letterSpacing: -0.4,
  );

  static TextStyle subtitleStyle(BuildContext context) => TextStyle(
    fontSize: 13,
    color: isLight(context) ? deepViolet.withValues(alpha: 0.7) : softLavender.withValues(alpha: 0.5),
  );

  static TextStyle monoCaptionStyle(BuildContext context) => TextStyle(
    fontSize: 11,
    letterSpacing: 1.5,
    color: isLight(context) ? deepViolet.withValues(alpha: 0.6) : softLavender.withValues(alpha: 0.5),
    fontFamily: 'monospace',
  );

  static TextStyle formulaStyle(BuildContext context) => TextStyle(
    fontSize: 22,
    color: isLight(context) ? deepViolet : softLavender,
    fontStyle: FontStyle.italic,
  );

  static TextStyle highlightVarStyle = const TextStyle(
    fontSize: 22,
    color: neonMagenta,
    fontWeight: FontWeight.bold,
    fontStyle: FontStyle.normal,
    shadows: [
      Shadow(color: Color(0x66E879F9), blurRadius: 10),
    ],
  );

  static TextStyle resultEquationStyle(BuildContext context) => TextStyle(
    fontSize: 20,
    color: isLight(context) ? deepViolet : softLavender,
    fontStyle: FontStyle.italic,
    letterSpacing: 0.5,
  );

  static TextStyle placeholderStyle(BuildContext context) => TextStyle(
    fontSize: 14,
    fontStyle: FontStyle.italic,
    color: isLight(context) ? deepViolet.withValues(alpha: 0.3) : softLavender.withValues(alpha: 0.25),
  );

  static TextStyle inputTextStyle(BuildContext context) => TextStyle(
    fontSize: 16,
    color: textPrimary(context),
  );

  static TextStyle inputHintStyle(BuildContext context) => TextStyle(
    color: isLight(context) ? deepViolet.withValues(alpha: 0.3) : softLavender.withValues(alpha: 0.25),
  );

  static TextStyle statChipLabelStyle(BuildContext context) => TextStyle(
    fontSize: 9,
    letterSpacing: 0.8,
    color: isLight(context) ? deepViolet.withValues(alpha: 0.6) : softLavender.withValues(alpha: 0.5),
    fontFamily: 'monospace',
  );

  static TextStyle statChipValueStyle(BuildContext context) => TextStyle(
    fontSize: 13,
    color: isLight(context) ? deepViolet : softLavender,
    fontStyle: FontStyle.italic,
  );

  static TextStyle statChipEmptyStyle(BuildContext context) => TextStyle(
    fontSize: 13,
    color: isLight(context) ? deepViolet.withValues(alpha: 0.2) : softLavender.withValues(alpha: 0.2),
    fontStyle: FontStyle.italic,
  );

  static const TextStyle badgeKeyStyle = TextStyle(
    fontSize: 12,
    color: neonMagenta,
    fontWeight: FontWeight.bold,
    fontFamily: 'monospace',
  );

  static TextStyle badgeValueStyle(BuildContext context) => TextStyle(
    fontSize: 12,
    color: isLight(context) ? deepViolet : softLavender,
    fontFamily: 'monospace',
  );

  static TextStyle inputLabelStyle(BuildContext context) => TextStyle(
    fontSize: 11,
    letterSpacing: 1.2,
    color: electricPurple.withValues(alpha: 0.7),
    fontFamily: 'monospace',
  );

  static TextStyle inputVarStyle = TextStyle(
    fontSize: 14,
    color: neonMagenta,
    fontStyle: FontStyle.italic,
    fontWeight: FontWeight.bold,
    shadows: [
      Shadow(color: neonMagenta.withValues(alpha: 0.3), blurRadius: 6),
    ],
  );
}