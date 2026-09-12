// ─────────────────────────────────────────────────────────────
// LINEAR 1-VAR — G7 Algebra. Solves ax+b=cx+d (two-step included).
// e.g. '2x-5=9' -> x=7. Offline, pure Dart. Never throws.
// ─────────────────────────────────────────────────────────────

import 'package:calculus_system/calculator/calculator_engine.dart';
import 'package:calculus_system/core/base_equation.dart';
import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/shared/widgets/input_validation.dart';
import 'package:calculus_system/topics/grade6/solvers/g6_support.dart';

/// Linear equation in one variable: `2x - 5 = 9`, `3(x+2) = 15`.
class LinearOneVarEquation extends BaseEquation {
  @override
  final String rawInput;
  String? _error;

  LinearOneVarEquation(this.rawInput);

  String _prep(String expr, double xVal) {
    var e = expr
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('−', '-')
        .replaceAll(' ', '');
    // Implicit multiply: 3x -> 3*x, 2(x+1) -> 2*(x+1), )x -> )*x.
    e = e.replaceAllMapped(
        RegExp(r'(\d|\))([xX])'), (m) => '${m.group(1)}*${m.group(2)}');
    e = e.replaceAllMapped(
        RegExp(r'(\d|\))(\()'), (m) => '${m.group(1)}*${m.group(2)}');
    e = e.replaceAll(RegExp(r'[xX]'), '($xVal)');
    return e;
  }

  double? _evalAt(String expr, double xVal) {
    try {
      return CalculatorEngine.evaluate(_prep(expr, xVal));
    } catch (_) {
      return null;
    }
  }

  /// Returns (coef, constant) for a linear side, or null.
  List<double>? _linearCoeffs(String side) {
    final f0 = _evalAt(side, 0);
    final f1 = _evalAt(side, 1);
    if (f0 == null || f1 == null) return null;
    if (!f0.isFinite || !f1.isFinite) return null;
    return [f1 - f0, f0];
  }

  List<double>? _parse() {
    final t = rawInput.replaceAll('−', '-').trim();
    if ('='.allMatches(t).length != 1) return null;
    final parts = t.split('=');
    final l = _linearCoeffs(parts[0]);
    final r = _linearCoeffs(parts[1]);
    if (l == null || r == null) return null;
    // Verify linearity at a third point (rejects x^2 etc).
    final f2l = _evalAt(parts[0], 2);
    if (f2l == null || (l[0] * 2 + l[1] - f2l).abs() > 1e-6) return null;
    final f2r = _evalAt(parts[1], 2);
    if (f2r == null || (r[0] * 2 + r[1] - f2r).abs() > 1e-6) return null;
    return [l[0] - r[0], r[1] - l[1]]; // a*x = b
  }

  @override
  bool validate() {
    final empty =
        FieldValidators.notEmpty(rawInput, example: '2x - 5 = 9');
    if (empty != null) {
      _error = empty;
      return false;
    }
    if (!rawInput.toLowerCase().contains('x')) {
      _error = 'Include the variable x — e.g. 2x - 5 = 9.';
      return false;
    }
    if (_parse() == null) {
      _error = 'Linear in x only — e.g. 2x - 5 = 9 or 3(x+2) = 15.';
      return false;
    }
    _error = null;
    return true;
  }

  @override
  SolveResult solve() {
    final c = _parse();
    if (c == null) {
      return SolveResult.error(_error ?? 'Enter a linear equation — e.g. 2x - 5 = 9.');
    }
    final a = c[0], b = c[1];
    if (a.abs() < 1e-12) {
      if (b.abs() < 1e-9) {
        return const SolveResult(
            answer: 'All real numbers (identity)',
            points: [],
            customData: [
              {'kind': 'line', 'identity': true}
            ]);
      }
      return SolveResult.error('No solution — parallel lines (0 = ${b.toStringAsFixed(2)}).');
    }
    final x = b / a;
    return SolveResult(
      answer: 'x = ${G6Format.num(x)}',
      points: [x],
      customData: [
        {
          'kind': 'line',
          'root': x,
          'line': [-5 + x, -4 + x, -3 + x, -2 + x, -1 + x, x, 1 + x, 2 + x],
        }
      ],
    );
  }

  @override
  List<StepModel> getSteps() {
    final c = _parse();
    if (c == null) {
      return [
        StepModel(
            stepNumber: 1,
            title: 'Invalid input',
            explanation: _error ?? 'Use 2x - 5 = 9.')
      ];
    }
    final a = c[0], b = c[1];
    if (a.abs() < 1e-12) {
      return [
        const StepModel(
            stepNumber: 1,
            title: 'Collect like terms',
            explanation: 'x terms cancel — check constants.'),
      ];
    }
    return [
      const StepModel(
          stepNumber: 1,
          title: 'Move x terms left, constants right',
          explanation: 'Add/subtract both sides to get ax = b.'),
      StepModel(
          stepNumber: 2,
          title: 'Combine',
          explanation:
              '${G6Format.num(a)}x = ${G6Format.num(b)} — like terms collected.'),
      StepModel(
          stepNumber: 3,
          title: 'Divide',
          explanation: 'x = ${G6Format.num(b)} ÷ ${G6Format.num(a)}.'),
      StepModel(
          stepNumber: 4,
          title: 'Check',
          explanation: 'Substitute x = ${G6Format.num(b / a)} back into both sides.'),
    ];
  }
}
