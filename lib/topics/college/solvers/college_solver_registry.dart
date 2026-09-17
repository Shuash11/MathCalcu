// ─────────────────────────────────────────────────────────────
// COLLEGE SOLVER REGISTRY — backend wiring for the Cycle 9 F4
// college-stats engine. Pure Dart: no router, no widgets.
// ─────────────────────────────────────────────────────────────

import 'package:calculus_system/core/base_equation.dart';

import 'college_stats_equation.dart';

export 'college_stats_equation.dart';

/// Backend contract for one college solver-screen entry.
class CollegeSolverSpec {
  final String id;
  final String section;
  final String subject;
  final String hint;
  final String helper;
  final BaseEquation Function(String input) create;

  const CollegeSolverSpec({
    required this.id,
    required this.section,
    required this.subject,
    required this.hint,
    required this.helper,
    required this.create,
  });
}

/// College wave 1: stats (kills the college-stats stub).
class CollegeSolverRegistry {
  CollegeSolverRegistry._();

  static final List<CollegeSolverSpec> specs = [
    CollegeSolverSpec(
      id: 'college-stats',
      section: 'statistics',
      subject: 'Statistics',
      hint: 'e.g. 4,7,9 stats',
      helper: 'Mean / median / mode / SD + regression + z-test.',
      create: (input) => CollegeStatsEquation(input),
    ),
  ];

  static CollegeSolverSpec? byId(String id) {
    try {
      return specs.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}
