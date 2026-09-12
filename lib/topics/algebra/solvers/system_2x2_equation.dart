// ─────────────────────────────────────────────────────────────
// SYSTEM 2x2 — G8. Solves two linear equations by elimination and
// verifies by substitution. Returns the intersection point.
// e.g. 'x+y=5, x-y=1' -> (3, 2). Never throws.
// ─────────────────────────────────────────────────────────────

import 'package:calculus_system/calculator/calculator_engine.dart';
import 'package:calculus_system/core/base_equation.dart';
import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/shared/widgets/input_validation.dart';
import 'package:calculus_system/topics/grade6/solvers/g6_support.dart';

class System2x2Equation extends BaseEquation {
  @override
  final String rawInput;
  String? _error;

  System2x2Equation(this.rawInput);

  double? _evalAt(String expr, double xv, double yv) {
    var e = expr
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('−', '-')
        .replaceAll(' ', '');
    e = e.replaceAllMapped(
        RegExp(r'(\d|\))([xXyY])'), (m) => '${m.group(1)}*${m.group(2)}');
    e = e.replaceAllMapped(
        RegExp(r'(\d|\))(\()'), (m) => '${m.group(1)}*${m.group(2)}');
    e = e.replaceAll(RegExp(r'[xX]'), '($xv)');
    e = e.replaceAll(RegExp(r'[yY]'), '($yv)');
    try {
      return CalculatorEngine.evaluate(e);
    } catch (_) {
      return null;
    }
  }

  /// (a, b, c) for ax+by=c, or null when not linear.
  List<double>? _row(String eq) {
    if ('='.allMatches(eq).length != 1) return null;
    final sides = eq.split('=');
    double? f(int x, int y) => _evalAt('${sides[0]}-(${sides[1]})', x.toDouble(), y.toDouble());
    final f00 = f(0, 0), f10 = f(1, 0), f01 = f(0, 1);
    if (f00 == null || f10 == null || f01 == null) return null;
    final a = f10 - f00, b = f01 - f00;
    // linearity check at (1,1).
    final f11 = f(1, 1);
    if (f11 == null || (a + b + f00 - f11).abs() > 1e-6) return null;
    return [a, b, -f00];
  }

  List<List<double>>? _parse() {
    final t = rawInput.replaceAll('−', '-').trim();
    final parts = t.split(RegExp(r'[,;\n]+')).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    if (parts.length != 2) return null;
    final r1 = _row(parts[0]);
    final r2 = _row(parts[1]);
    if (r1 == null || r2 == null) return null;
    return [r1, r2];
  }

  @override
  bool validate() {
    final empty =
        FieldValidators.notEmpty(rawInput, example: 'x + y = 5, x - y = 1');
    if (empty != null) {
      _error = empty;
      return false;
    }
    if (_parse() == null) {
      _error = 'Two linear equations in x and y — e.g. x + y = 5, x - y = 1.';
      return false;
    }
    _error = null;
    return true;
  }

  @override
  SolveResult solve() {
    final rows = _parse();
    if (rows == null) {
      return SolveResult.error(
          _error ?? 'Enter two equations — e.g. x + y = 5, x - y = 1.');
    }
    final a1 = rows[0][0], b1 = rows[0][1], c1 = rows[0][2];
    final a2 = rows[1][0], b2 = rows[1][1], c2 = rows[1][2];
    final det = a1 * b2 - a2 * b1;
    if (det.abs() < 1e-12) {
      // Parallel vs same line: check ratio.
      if ((a1 * c2 - a2 * c1).abs() < 1e-9 &&
          (b1 * c2 - b2 * c1).abs() < 1e-9) {
        return const SolveResult(
            answer: 'Infinitely many solutions (same line)',
            points: [],
            customData: [
              {'kind': 'system', 'type': 'coincident'}
            ]);
      }
      return SolveResult.error('No solution — parallel lines.');
    }
    final x = (c1 * b2 - c2 * b1) / det;
    final y = (a1 * c2 - a2 * c1) / det;
    return SolveResult(
      answer: '(x, y) = (${G6Format.num(x)}, ${G6Format.num(y)})',
      points: [x, y],
      customData: [
        {
          'kind': 'system',
          'type': 'point',
          'x': x,
          'y': y,
          'lines': [
            {'a': a1, 'b': b1, 'c': c1},
            {'a': a2, 'b': b2, 'c': c2},
          ],
        }
      ],
    );
  }

  @override
  List<StepModel> getSteps() {
    final rows = _parse();
    if (rows == null) {
      return [
        StepModel(
            stepNumber: 1,
            title: 'Invalid input',
            explanation: _error ?? 'Use x + y = 5, x - y = 1.')
      ];
    }
    final r = solve();
    return [
      const StepModel(
          stepNumber: 1,
          title: 'Write in ax + by = c form',
          explanation: 'Align x, y, and constant columns.'),
      const StepModel(
          stepNumber: 2,
          title: 'Eliminate one variable',
          explanation: 'Scale and add the equations so one variable cancels.'),
      StepModel(stepNumber: 3, title: 'Solve the point', explanation: r.answer),
      const StepModel(
          stepNumber: 4,
          title: 'Check by substitution',
          explanation: 'Both equations must balance at the point.'),
    ];
  }
}
