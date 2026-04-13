import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────
// FINALS MODULE REGISTRY
//
// Same pattern as ModuleRegistry but scoped to Finals topics.
// Each developer adds ONE entry here — nothing else to touch.
// The FinalsPickerScreen reads this list automatically.
// ─────────────────────────────────────────────────────────────

class FinalsModuleRegistry {
  static final List<FinalsModuleEntry> modules = [
    // ── Add Finals topic entries below ────────────────────
    const FinalsModuleEntry(
      label: 'Evaluating Limits',
      subtitle: 'By substitution  · By conjugate · By factoring ',
      route: '/limits',
      icon: Icons.functions_rounded,
      accent: Color(0xFFFFB020),
    ),
    const FinalsModuleEntry(
      label: 'Limits at Infinity',
      subtitle: '',
      route: '/infinity',
      icon: Icons.all_inclusive_rounded,
      accent: Color(0xFFFF6B35), // Secondary deep orange
    ),
    const FinalsModuleEntry(
      label: 'Derivatives',
      subtitle: 'Power rule · Product rule · Quotient rule · Chain rule',
      route: '/second-sem/derivatives',
      icon: Icons.trending_up_rounded,
      accent: Color(0xFFFFD166), // Tertiary soft yellow
    ),
    const FinalsModuleEntry(
      label: 'Slope Using Derivatives',
      subtitle: 'Tangent line slope · Evaluate at point · Instantaneous rate',
      route: '/slope-derivative',
      icon: Icons.show_chart_rounded,
      accent: Color(0xFFEF476F), // Danger rose red
    ),
    // const FinalsModuleEntry(
    //   label: 'Limits',
    //   subtitle: 'One-sided · Infinite · At a point',
    //   route: '/finals/limits',
    //   icon: Icons.compress_rounded,
    //   accent: Color(0xFFFFB020),
    // ),
    //
    // ─────────────────────────────────────────────────────
  ];
}

class FinalsModuleEntry {
  final String label;
  final String subtitle;
  final String route;
  final IconData icon;
  final Color accent;

  const FinalsModuleEntry({
    required this.label,
    required this.subtitle,
    required this.route,
    required this.icon,
    required this.accent,
  });
}
