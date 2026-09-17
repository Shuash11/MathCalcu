// ─────────────────────────────────────────────────────────────
// G6 EXTRAS REGISTRY — backend wiring for the two built-but-
// unreachable supplements (Cycle 8 P2-1): GCF/LCM + Rate.
// Both already ride the grade6_equations.dart barrel; this file
// gives frontend/middle-end a stable id → factory map without
// touching routers or picker UI.
// ─────────────────────────────────────────────────────────────

import 'package:calculus_system/core/base_equation.dart';

import 'grade6_equations.dart';

/// Backend contract for one solver-screen entry.
class G6ExtraSolverSpec {
  final String id;
  final String gradeLevel;
  final String subject;
  final String hint;
  final String helper;
  final BaseEquation Function(String input) create;

  const G6ExtraSolverSpec({
    required this.id,
    required this.gradeLevel,
    required this.subject,
    required this.hint,
    required this.helper,
    required this.create,
  });
}

/// GCF/LCM (factors wave) + Rate (speed / best-buy / meter).
class G6ExtrasRegistry {
  G6ExtrasRegistry._();

  static final List<G6ExtraSolverSpec> specs = [
    G6ExtraSolverSpec(
      id: 'g6-gcf-lcm',
      gradeLevel: 'G6',
      subject: 'Factors',
      hint: 'e.g. GCF(12, 18)',
      helper: 'GCF or LCM of whole numbers — listing + Euclid check.',
      create: (input) => G6GcfLcmEquation(input),
    ),
    G6ExtraSolverSpec(
      id: 'g6-rate',
      gradeLevel: 'G6',
      subject: 'Rate',
      hint: 'e.g. R=? D=120 T=2',
      helper: 'D = R × T triad, best-buy compare, meter reading.',
      create: (input) => G6RateEquation(input),
    ),
  ];

  static G6ExtraSolverSpec? byId(String id) {
    try {
      return specs.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}
