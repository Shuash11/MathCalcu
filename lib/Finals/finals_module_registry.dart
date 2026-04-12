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
