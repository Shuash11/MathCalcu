// ─────────────────────────────────────────────────────────────
// QUADRATICS SOLVER REGISTRY — backend wiring for the 5 orphaned
// G9–G10 engines (Cycle 8 P1-2). Pure Dart: no router, no widgets.
// ─────────────────────────────────────────────────────────────

import 'package:calculus_system/core/base_equation.dart';

import 'quadratics_equations.dart';

/// Backend contract for one solver-screen entry.
class QuadraticsSolverSpec {
  final String id;
  final String gradeLevel;
  final String subject;
  final String hint;
  final String helper;
  final BaseEquation Function(String input) create;

  const QuadraticsSolverSpec({
    required this.id,
    required this.gradeLevel,
    required this.subject,
    required this.hint,
    required this.helper,
    required this.create,
  });
}

/// All wired quadratics solvers (PH map: G9 quad/variation/radicals,
/// G10 sequence/poly-division).
class QuadraticsSolverRegistry {
  QuadraticsSolverRegistry._();

  static final List<QuadraticsSolverSpec> specs = [
    QuadraticsSolverSpec(
      id: 'g9-quadratic-formula',
      gradeLevel: 'G9',
      subject: 'Quadratics',
      hint: 'e.g. x^2 - 5x + 6 = 0',
      helper: 'Quadratic = 0 form — discriminant + formula.',
      create: (input) => QuadraticEquation(input),
    ),
    QuadraticsSolverSpec(
      id: 'g9-radical-equations',
      gradeLevel: 'G9',
      subject: 'Radicals',
      hint: 'e.g. sqrt(x + 5) = 3',
      helper: 'Radical equation — extraneous roots rejected.',
      create: (input) => RadicalEquation(input),
    ),
    QuadraticsSolverSpec(
      id: 'g9-variation',
      gradeLevel: 'G9',
      subject: 'Variation',
      hint: 'e.g. y = kx, y = 10, x = 2',
      helper: 'Direct / inverse / joint variation — find k first.',
      create: (input) => VariationEquation(input),
    ),
    QuadraticsSolverSpec(
      id: 'g10-sequences',
      gradeLevel: 'G10',
      subject: 'Sequences',
      hint: 'e.g. arith a1 = 2, d = 3, n = 5',
      helper: 'Arithmetic or geometric — nth term + sum.',
      create: (input) => SequenceEquation(input),
    ),
    QuadraticsSolverSpec(
      id: 'g10-polynomial-division',
      gradeLevel: 'G10',
      subject: 'Polynomials',
      hint: 'e.g. (x^2 + 5x + 6) / (x + 2)',
      helper: 'Polynomial long / synthetic division.',
      create: (input) => PolyDivisionEquation(input),
    ),
  ];

  static QuadraticsSolverSpec? byId(String id) {
    try {
      return specs.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}
