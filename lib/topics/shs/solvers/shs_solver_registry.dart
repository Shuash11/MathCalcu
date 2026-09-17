// ─────────────────────────────────────────────────────────────
// SHS SOLVER REGISTRY — backend wiring for the 10 SHS engines
// (Cycle 8 P1-2). Pure Dart: no router, no widgets. Registry ids
// match shs_equations.dart + curriculum_registry routes.
// ─────────────────────────────────────────────────────────────

import 'package:calculus_system/core/base_equation.dart';

import 'shs_equations.dart';

/// Backend contract for one solver-screen entry.
class ShsSolverSpec {
  final String id;
  final String gradeLevel;
  final String subject;
  final String hint;
  final String helper;
  final BaseEquation Function(String input) create;

  const ShsSolverSpec({
    required this.id,
    required this.gradeLevel,
    required this.subject,
    required this.hint,
    required this.helper,
    required this.create,
  });
}

/// All wired SHS solvers (PH map: G9 trig · G11 genmath/precalc ·
/// G12 calculus · college lhopital).
class ShsSolverRegistry {
  ShsSolverRegistry._();

  static final List<ShsSolverSpec> specs = [
    ShsSolverSpec(
      id: 'g9-trig-ratios',
      gradeLevel: 'G9',
      subject: 'Trigonometry',
      hint: 'e.g. sin 30',
      helper: 'SOH-CAH-TOA — angle or side from a right triangle.',
      create: (input) => TrigRatioEquation(input),
    ),
    ShsSolverSpec(
      id: 'g11-logarithms',
      gradeLevel: 'G11',
      subject: 'Logarithms',
      hint: 'e.g. 2^x = 32',
      helper: 'b^x = n, log_b(x+k) = n, log sums — domain checked.',
      create: (input) => ExpLogEquation(input),
    ),
    ShsSolverSpec(
      id: 'g11-interest',
      gradeLevel: 'G11',
      subject: 'Interest',
      hint: 'e.g. P = 10000, r = 5%, t = 2, compound',
      helper: 'Simple vs compound — growth over time.',
      create: (input) => InterestEquation(input),
    ),
    ShsSolverSpec(
      id: 'g11-inverse-functions',
      gradeLevel: 'G11',
      subject: 'Functions',
      hint: 'e.g. f(x) = 2x + 3',
      helper: 'One-to-one functions — swap x and y.',
      create: (input) => InverseFunctionEquation(input),
    ),
    ShsSolverSpec(
      id: 'g11-rational-inequality',
      gradeLevel: 'G11',
      subject: 'Inequalities',
      hint: 'e.g. (x - 1)/(x + 2) > 0',
      helper: 'Sign chart — asymptotes excluded.',
      create: (input) => RationalInequalityEquation(input),
    ),
    ShsSolverSpec(
      id: 'g11-trig-equations',
      gradeLevel: 'G11',
      subject: 'Trigonometry',
      hint: 'e.g. sin x = 1/2',
      helper: 'Trig equations — solutions on [0, 2π).',
      create: (input) => TrigEquationSolver(input),
    ),
    ShsSolverSpec(
      id: 'g11-trig-identities',
      gradeLevel: 'G11',
      subject: 'Trigonometry',
      hint: 'e.g. prove: sin^2 + cos^2 = 1',
      helper: 'Identity proofs — step-by-step verification.',
      create: (input) => TrigIdentityEquation(input),
    ),
    ShsSolverSpec(
      id: 'g12-definite-integral',
      gradeLevel: 'G12',
      subject: 'Integrals',
      hint: 'e.g. def a = 0, b = 2, f = x^2',
      helper: 'Definite integral via substitution / FTC.',
      create: (input) => IntegralSubEquation(input),
    ),
    ShsSolverSpec(
      id: 'g12-optimization',
      gradeLevel: 'G12',
      subject: 'Applications',
      hint: 'e.g. max xy, x + y = 20',
      helper: 'Max/min + related rates — diagram + derivative.',
      create: (input) => RelatedRatesEquation(input),
    ),
    ShsSolverSpec(
      id: 'college-lhopital',
      gradeLevel: 'College',
      subject: 'Limits',
      hint: 'e.g. lim x->0 sin(x)/x',
      helper: "L'Hôpital — 0/0 or ∞/∞ indeterminate forms.",
      create: (input) => LHopitalEquation(input),
    ),
  ];

  static ShsSolverSpec? byId(String id) {
    try {
      return specs.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}
