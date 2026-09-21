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
      subtitle: 'By substitution • By conjugate • By factoring',
      route: '/topics/calculus/finals/limits',
      icon: Icons.functions_rounded,
      accent: Color(0xFF334155),
    ),
    const FinalsModuleEntry(
      label: 'Limits at Infinity',
      subtitle: 'Horizontal asymptotes & end behavior',
      route: '/topics/calculus/finals/infinity',
      icon: Icons.all_inclusive_rounded,
      accent: Color(0xFF334155),
    ),
    const FinalsModuleEntry(
      label: 'Derivatives',
      subtitle: 'Power rule • Product rule • Quotient rule • Chain rule',
      route: '/topics/calculus/finals/derivatives',
      icon: Icons.trending_up_rounded,
      accent: Color(0xFF334155),
    ),
    const FinalsModuleEntry(
      label: 'Integration Techniques',
      subtitle: 'u-substitution • By-parts • Definite integrals • FTC',
      route: '/topics/calculus/finals/integration',
      icon: Icons.area_chart_rounded,
      accent: Color(0xFF334155),
    ),
    const FinalsModuleEntry(
      label: 'Partial Derivatives',
      subtitle: 'd/dx • d/dy • multivariable functions',
      route: '/topics/calculus/finals/partials',
      icon: Icons.terrain_rounded,
      accent: Color(0xFF334155),
    ),
    const FinalsModuleEntry(
      label: 'Slope Using Derivatives',
      subtitle: 'Tangent line slope • Evaluate at point • Instantaneous rate',
      route: '/topics/calculus/finals/slope-derivative',
      icon: Icons.show_chart_rounded,
      accent: Color(0xFF334155),
    ),
    const FinalsModuleEntry(
      label: 'Taylor & Maclaurin Series',
      subtitle: 'taylor series • Maclaurin • successive derivatives',
      route: '/topics/calculus/finals/taylor',
      icon: Icons.stacked_line_chart_rounded,
      accent: Color(0xFF334155),
    ),
    const FinalsModuleEntry(
      label: 'Differential Equations',
      subtitle: 'separable equations',
      route: '/topics/calculus/finals/diffeq',
      icon: Icons.auto_graph_rounded,
      accent: Color(0xFF334155),
    ),
    const FinalsModuleEntry(
      label: 'Volumes of Revolution',
      subtitle: 'disk • washer • shell methods',
      route: '/topics/calculus/finals/volumes',
      icon: Icons.donut_large_rounded,
      accent: Color(0xFF334155),
    ),
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
