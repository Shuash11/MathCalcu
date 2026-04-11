import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────
// MODULE REGISTRY
// Each developer registers their module here — ONE line.
// The CategoryPickerScreen reads this list automatically.
// No one needs to touch category_picker_screen.dart ever.
// ─────────────────────────────────────────────────────────────

class ModuleRegistry {
  static final List<ModuleEntry> modules = [
    // ── JOASHUA: your module entry ────────────────────────
    const ModuleEntry(
      label: 'Inequalities',
      subtitle: 'Strict · Non-strict · Absolute value',
      route: '/inequalities',
      icon: Icons.trending_up_rounded,
      accent: Color(0xFF6C63FF),
    ),
    // ─────────────────────────────────────────────────────

    // ─────────────────────────────────────────────────────

    // ── SLOPE MODULE ─────────────────────────────────────
    const ModuleEntry(
      label: 'slope',
      subtitle: 'Find slope between two points',
      route: '/slope',
      icon: Icons.show_chart,
      accent: Color(0xFF00C2FF),
    ),
    const ModuleEntry(
      label: 'midpoint',
      subtitle: 'Find center point between coordinates',
      route: '/midpoint',
      icon: Icons.center_focus_strong_rounded,
      accent: Color(0xFFE9ECEF), // Ice white/silver
    ),

    // ── DISTANCE MODULE ──────────────────────────────────
    const ModuleEntry(
      label: 'distance',
      subtitle: 'Calculate distance between points',
      route: '/distance',
      icon: Icons.straighten_rounded,
      accent: Color(0xFF4ECDC4),
    ),

    // ── MIDPOINT MODULE ──────────────────────────────────
    // Clean white/silver accent - unique from orange distance

    // ─────────────────────────────────────────────────────
// ── POINT-SLOPE MODULE ───────────────────────────────
// Deep violet/purple theme - mathematical sophistication
    const ModuleEntry(
      label: 'point-slope',
      subtitle: 'y − y₁ = m(x − x₁) · Line equations',
      route: '/point-slope',
      icon: Icons.trending_flat_rounded, // Suggests line/slope
      accent: Color(0xFFA855F7), // Electric purple
    ),
// ─────────────────────────────────────────────────────
    const ModuleEntry(
      label: 'Two-Point Slope',
      subtitle: 'Find slope from two coordinate points',
      route: '/two-point-slope',
      icon: Icons.show_chart_rounded,
      accent: Color(0xFFF59E0B), // Amber
    ),
// ── Y-INTERCEPT MODULE ────────────────────────────────
// Emerald green + gold - represents crossing point/growth
    const ModuleEntry(
      label: 'slope-intercept-form',
      subtitle: 'Find where \nline crosses\nY-axis',
      route: '/slope-intercept-form',
      icon: Icons.vertical_align_bottom_rounded, // Suggests bottom/crossing
      accent: Color(0xFF10B981), // Emerald green
    ),
    const ModuleEntry(
      label: 'parallel-perpendicular',
      subtitle: 'Compare two lines and\ncheck their relationship',
      route: '/parallel-perpendicular',
      icon: Icons.compare_arrows_rounded,
      accent: Color(0xFF06B6D4),
    ),
// ─────────────────────────────────────────────────────
// ── CIRCLE MODULE ─────────────────────────────────────
// Indigo + cyan theme - 3 solution types inside
    const ModuleEntry(
      label: 'circle',
      subtitle: 'Standard · General · Center-Radius',
      route: '/circle',
      icon: Icons.radio_button_unchecked_rounded, // Circle icon
      accent: Color(0xFF06B6D4), // Cyan
    ),
// ─────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────
    // ── FUTURE DEV: add your one line here ───────────────
    // ModuleEntry(
    //   label: 'Your Topic',
    //   subtitle: 'Type A · Type B · Type C',
    //   route: '/your_route',
    //   icon: Icons.calculate_rounded,
    //   accent: Color(0xFFFF6B6B),
    // ),
    // ─────────────────────────────────────────────────────
  ];
}

class ModuleEntry {
  final String label;
  final String subtitle;
  final String route;
  final IconData icon;
  final Color accent;

  const ModuleEntry({
    required this.label,
    required this.subtitle,
    required this.route,
    required this.icon,
    required this.accent,
  });
}
