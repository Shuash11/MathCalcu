// ─────────────────────────────────────────────────────────────
// MODMATH SOLVER REGISTRY — backend wiring for the M1–M6 wave-1
// engines (Cycle 8). Pure Dart: no router, no widgets.
// ─────────────────────────────────────────────────────────────

import 'package:calculus_system/core/base_equation.dart';

import 'modmat_equations.dart';

/// Backend contract for one solver-screen entry.
class ModmatSolverSpec {
  final String id;
  final String section;
  final String subject;
  final String hint;
  final String helper;
  final BaseEquation Function(String input) create;

  const ModmatSolverSpec({
    required this.id,
    required this.section,
    required this.subject,
    required this.hint,
    required this.helper,
    required this.create,
  });
}

/// M1–M6 wave 1 (foundations + number theory + linear algebra slice).
class ModmatSolverRegistry {
  ModmatSolverRegistry._();

  static final List<ModmatSolverSpec> specs = [
    ModmatSolverSpec(
      id: 'modmat-propositional',
      section: 'foundations',
      subject: 'Propositional Logic',
      hint: 'e.g. p -> q',
      helper: 'Truth tables over p, q (, r) — tautology check.',
      create: (input) => M1PropositionalEquation(input),
    ),
    ModmatSolverSpec(
      id: 'modmat-sets',
      section: 'foundations',
      subject: 'Set Theory',
      hint: 'e.g. A={1,2,3} B={3,4} UNION',
      helper: 'Union, intersect, difference, cardinality, power.',
      create: (input) => M2SetsEquation(input),
    ),
    ModmatSolverSpec(
      id: 'modmat-combinatorics',
      section: 'foundations',
      subject: 'Combinatorics',
      hint: 'e.g. C(5,2)',
      helper: 'nPr / nCr / factorial — kills g10-combinatorics stub.',
      create: (input) => M3CombinatoricsEquation(input),
    ),
    ModmatSolverSpec(
      id: 'modmat-bases',
      section: 'foundations',
      subject: 'Number Systems',
      hint: 'e.g. 1011 base2 to base10',
      helper: 'Binary / octal / decimal / hex conversion.',
      create: (input) => M4BaseConversionEquation(input),
    ),
    ModmatSolverSpec(
      id: 'modmat-matrices',
      section: 'advanced',
      subject: 'Linear Algebra',
      hint: 'e.g. det [[1,2],[3,4]]',
      helper: 'Determinant + inverse for 2×2 / 3×3.',
      create: (input) => M5MatrixEquation(input),
    ),
    ModmatSolverSpec(
      id: 'modmat-modular',
      section: 'advanced',
      subject: 'Number Theory',
      hint: 'e.g. 17 mod 5',
      helper: 'Residues, powers, inverses — extends G6 GCF/LCM.',
      create: (input) => M6ModularEquation(input),
    ),
  ];

  static ModmatSolverSpec? byId(String id) {
    try {
      return specs.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}
