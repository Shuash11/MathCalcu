import 'package:flutter/material.dart';

// ═════════════════════════════════════════════════════════════
// JOASHUA — INEQUALITY MODULE THEME
// ─────────────────────────────────────────────────────────────
// This file is JOASHUA's design space.
// Change colors, typography, spacing, and any visual tokens here.
// These values are used by InequalityPickerScreen + InequalityScreen.
//
// accentColor   → card glows, button fills, active highlights
// secondAccent  → secondary labels, subtitle tints
// cardColor     → background of each subtype card
// ═════════════════════════════════════════════════════════════

class InequalityTheme {
  // ── JOASHUA: customize your accent color here ─────────────
  static const Color accentColor = Color(0xFF6C63FF); // violet
  static const Color secondAccent = Color(0xFFA89CFF); // lighter violet
  // ──────────────────────────────────────────────────────────

  static const Color cardColor = Color(0xFF12121A);
  static const Color surface = Color(0xFF0A0A0F);

  // ── JOASHUA: subtype card accent overrides (optional) ─────
  static const Map<String, Color> subtypeAccents = {
    'strict': Color(0xFF6C63FF),
    'non_strict': Color(0xFF9B8FFF),
    'absolute': Color(0xFFC4BCFF),
  };
  // ──────────────────────────────────────────────────────────

  static TextStyle get titleStyle => const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: Color(0xFFE8E8F0),
        letterSpacing: -0.5,
      );

  static TextStyle get subtitleStyle => TextStyle(
        fontSize: 13,
        color: const Color(0xFFE8E8F0).withValues(alpha: .4),
      );
}
