// ─────────────────────────────────────────────────────────────
// ALGEBRA SOLVER REGISTRY — backend wiring for the 4 orphaned
// G7–G8 engines (Cycle 8 P1-2). Pure Dart: no router, no widgets.
// Frontend builds Grade6SolverScreen configs from [SolverSpec];
// middle-end resolves routes/bySubject from [id].
// ─────────────────────────────────────────────────────────────

import 'package:calculus_system/core/base_equation.dart';

import 'algebra_equations.dart';

/// Backend contract for one solver-screen entry.
class AlgebraSolverSpec {
  final String id;
  final String gradeLevel;
  final String subject;
  final String hint;
  final String helper;
  final BaseEquation Function(String input) create;

  const AlgebraSolverSpec({
    required this.id,
    required this.gradeLevel,
    required this.subject,
    required this.hint,
    required this.helper,
    required this.create,
  });
}

/// All wired algebra solvers (PH map: G7 linear · G8 factoring/systems).
class AlgebraSolverRegistry {
  AlgebraSolverRegistry._();

  static final List<AlgebraSolverSpec> specs = [
    AlgebraSolverSpec(
      id: 'g7-linear-equations',
      gradeLevel: 'G7',
      subject: 'Algebra',
      hint: 'e.g. 2x - 5 = 9',
      helper: 'Linear in x — one variable, both sides allowed.',
      create: (input) => LinearOneVarEquation(input),
    ),
    AlgebraSolverSpec(
      id: 'g8-factoring',
      gradeLevel: 'G8',
      subject: 'Factoring',
      hint: 'e.g. x^2 + 5x + 6',
      helper: 'Quadratic in x — GCF, difference of squares, trinomial.',
      create: (input) => FactoringEquation(input),
    ),
    AlgebraSolverSpec(
      id: 'g8-rational-equations',
      gradeLevel: 'G8',
      subject: 'Algebra',
      hint: 'e.g. 1/x + 1/2 = 3/4',
      helper: 'Rational equation — domain excludes zero denominators.',
      create: (input) => RationalEquation(input),
    ),
    AlgebraSolverSpec(
      id: 'g8-systems',
      gradeLevel: 'G8',
      subject: 'Systems',
      hint: 'e.g. x + y = 5, x - y = 1',
      helper: 'Two equations in x and y — intersection point.',
      create: (input) => System2x2Equation(input),
    ),
  ];

  static AlgebraSolverSpec? byId(String id) {
    try {
      return specs.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}
