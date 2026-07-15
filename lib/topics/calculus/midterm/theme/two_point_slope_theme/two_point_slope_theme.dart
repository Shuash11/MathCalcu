import 'package:calculus_system/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TwoPointSlopeTheme {
  TwoPointSlopeTheme._();

  // ── Maroon accent palette ──────────────────────────────────
  static const Color primary = Color(0xFF7F1D1D); // deep maroon
  static const Color primaryDark = Color(0xFF7F1D1D); // deep maroon
  static const Color primaryLight = Color(0xFF7F1D1D); // deep maroon
  static const Color orange = Color(0xFF7F1D1D); // deep maroon

  // Dynamic Theme Integration
  static Color surface(BuildContext context) =>
      context.watch<ThemeProvider>().surface;
  static Color background(BuildContext context) =>
      context.watch<ThemeProvider>().surface;
  static Color cardBg(BuildContext context) =>
      context.watch<ThemeProvider>().card;
  static Color textPrimary(BuildContext context) =>
      context.watch<ThemeProvider>().textPrimary;
  static Color textSecondary(BuildContext context) =>
      context.watch<ThemeProvider>().textSecondary;
  static Color textMuted(BuildContext context) =>
      context.watch<ThemeProvider>().textSecondary;
  static bool isLight(BuildContext context) =>
      context.watch<ThemeProvider>().isLight;

  // ── Step colors ───────────────────────────────────────────
  static const Color stepBlue = Color(0xFF60A5FA);
  static const Color stepGreen = Color(0xFF34D399);
  static const Color stepPurple = Color(0xFFA78BFA);
  static const Color stepOrange = Color(0xFFFB923C);

  // ── Border ────────────────────────────────────────────────
  static Color border(double opacity) => primary.withValues(alpha: opacity);

  // ── Card decoration ───────────────────────────────────────
  static BoxDecoration cardDecoration(BuildContext context,
          {bool glowing = false}) =>
      BoxDecoration(
        color: cardBg(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: primary.withValues(alpha: glowing ? 0.35 : 0.15),
          width: glowing ? 1.5 : 1,
        ),
        boxShadow: glowing
            ? [
                BoxShadow(
                  color: primary.withValues(alpha: 0.15),
                  blurRadius: 32,
                  offset: const Offset(0, 8),
                  spreadRadius: 2,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black
                      .withValues(alpha: isLight(context) ? 0.05 : 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
      );

  // ── Input decoration ──────────────────────────────────────
  static InputDecoration inputDecoration(
          BuildContext context, String label, String hint) =>
      InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(
          color: textSecondary(context),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(
          color: textSecondary(context).withValues(alpha: 0.6),
          fontSize: 14,
        ),
        filled: true,
        fillColor: surface(context),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: primary.withValues(alpha: 0.15),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: primary.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      );

  // ── Text styles ───────────────────────────────────────────
  static TextStyle headingStyle(BuildContext context,
          {bool responsive = false}) =>
      TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: textPrimary(context),
        letterSpacing: -1.0,
        height: 1.1,
      );

  static TextStyle subheadingStyle(BuildContext context,
          {bool responsive = false}) =>
      TextStyle(
        fontSize: 13,
        color: textSecondary(context),
        letterSpacing: 0.2,
      );

  static TextStyle labelStyle(BuildContext context,
          {bool responsive = false}) =>
      TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: textSecondary(context).withValues(alpha: 0.6),
        letterSpacing: 1.2,
      );

  static TextStyle monoStyle(BuildContext context,
          {bool responsive = false}) =>
      TextStyle(
        fontFamily: 'monospace',
        fontSize: 15,
        color: textPrimary(context),
        height: 1.5,
      );
}
