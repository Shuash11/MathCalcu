import 'package:flutter/material.dart';

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// MODULE REGISTRY
// Each developer registers their module here â€” ONE line.
// The CategoryPickerScreen reads this list automatically.
// No one needs to touch category_picker_screen.dart ever.
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class ModuleRegistry {
  static final List<ModuleEntry> modules = [
    // â”€â”€ JOASHUA: your module entry â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    const ModuleEntry(
      label: 'Inequalities',
      subtitle: 'Strict · Non-strict · Absolute value',
      route: '/inequalities',
      icon: Icons.trending_up_rounded,
      accent: Color(0xFF6C63FF),
    ),
    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    // â”€â”€ SLOPE MODULE â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

    // â”€â”€ DISTANCE MODULE â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    const ModuleEntry(
      label: 'distance',
      subtitle: 'Calculate distance between points',
      route: '/distance',
      icon: Icons.straighten_rounded,
      accent: Color(0xFF4ECDC4),
    ),

    // â”€â”€ MIDPOINT MODULE â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    // Clean white/silver accent - unique from orange distance

    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// â”€â”€ POINT-SLOPE MODULE â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Deep violet/purple theme - mathematical sophistication
    const ModuleEntry(
      label: 'point-slope',
      subtitle: 'y âˆ’ yâ‚ = m(x âˆ’ xâ‚) · Line equations',
      route: '/point-slope',
      icon: Icons.trending_flat_rounded, // Suggests line/slope
      accent: Color(0xFFA855F7), // Electric purple
    ),
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    const ModuleEntry(
      label: 'Two-Point Slope',
      subtitle: 'Find slope from two coordinate points',
      route: '/two-point-slope',
      icon: Icons.show_chart_rounded,
      accent: Color(0xFFF59E0B), // Amber
    ),
// â”€â”€ Y-INTERCEPT MODULE â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// â”€â”€ CIRCLE MODULE â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Indigo + cyan theme - 3 solution types inside
    const ModuleEntry(
      label: 'circle',
      subtitle: 'Standard · General · Center-Radius',
      route: '/circle',
      icon: Icons.radio_button_unchecked_rounded, // Circle icon
      accent: Color(0xFF06B6D4), // Cyan
    ),
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    // â”€â”€ FUTURE DEV: add your one line here â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    // ModuleEntry(
    //   label: 'Your Topic',
    //   subtitle: 'Type A · Type B · Type C',
    //   route: '/your_route',
    //   icon: Icons.calculate_rounded,
    //   accent: Color(0xFFFF6B6B),
    // ),
    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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
