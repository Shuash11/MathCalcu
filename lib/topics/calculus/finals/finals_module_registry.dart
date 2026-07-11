import 'package:flutter/material.dart';

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// FINALS MODULE REGISTRY
//
// Same pattern as ModuleRegistry but scoped to Finals topics.
// Each developer adds ONE entry here â€” nothing else to touch.
// The FinalsPickerScreen reads this list automatically.
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class FinalsModuleRegistry {
  static final List<FinalsModuleEntry> modules = [
    // â”€â”€ Add Finals topic entries below â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    const FinalsModuleEntry(
      label: 'Evaluating Limits',
      subtitle: 'By substitution  · By conjugate · By factoring ',
      route: '/topics/calculus/finals/limits',
      icon: Icons.functions_rounded,
      accent: Color(0xFFFFB020),
    ),
    const FinalsModuleEntry(
      label: 'Limits at Infinity',
      subtitle: 'Horizontal asymptotes & end behavior',
      route: '/topics/calculus/finals/infinity',
      icon: Icons.all_inclusive_rounded,
      accent: Color(0xFFFF6B35), // Secondary deep orange
    ),
    const FinalsModuleEntry(
      label: 'Derivatives',
      subtitle: 'Power rule · Product rule · Quotient rule · Chain rule',
      route: '/topics/calculus/finals/derivatives',
      icon: Icons.trending_up_rounded,
      accent: Color(0xFFFFD166), // Tertiary soft yellow
    ),
    const FinalsModuleEntry(
      label: 'Slope Using Derivatives',
      subtitle: 'Tangent line slope · Evaluate at point · Instantaneous rate',
      route: '/topics/calculus/finals/slope-derivative',
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
    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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
