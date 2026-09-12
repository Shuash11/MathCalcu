// ─────────────────────────────────────────────────────────────
// SEQUENCES — G10. Arithmetic / geometric nth term + sum.
// e.g. 'arith a1=2 d=3 n=5' or 'geom 3,6,12 n=4'. Never throws.
// ─────────────────────────────────────────────────────────────

import 'package:calculus_system/core/base_equation.dart';
import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/shared/widgets/input_validation.dart';
import 'package:calculus_system/topics/grade6/solvers/g6_support.dart';
import 'dart:math' as math;

class SequenceEquation extends BaseEquation {
  @override
  final String rawInput;
  String? _error;

  SequenceEquation(this.rawInput);

  String? _mode() {
    final t = rawInput.toLowerCase();
    if (t.startsWith('arith') || t.contains('arithmetic')) return 'arith';
    if (t.startsWith('geom') || t.contains('geometric')) return 'geom';
    return null;
  }

  double? _param(String name) {
    final m = RegExp('$name\\s*=\\s*(-?\\d+(?:\\.\\d+)?)')
        .firstMatch(rawInput.toLowerCase());
    return m == null ? null : double.parse(m.group(1)!);
  }

  List<double> _listed() {
    // Numbers not attached to a param name.
    final stripped = rawInput.replaceAll(
        RegExp(r'[a-zA-Z]+\s*=\s*-?\d+(?:\.\d+)?'), ' ');
    return RegExp(r'-?\d+(?:\.\d+)?')
        .allMatches(stripped)
        .map((m) => double.parse(m.group(0)!))
        .toList();
  }

  @override
  bool validate() {
    final empty = FieldValidators.notEmpty(
        rawInput, example: 'arith a1 = 2, d = 3, n = 5');
    if (empty != null) {
      _error = empty;
      return false;
    }
    if (_mode() == null) {
      _error = 'Start with arith or geom — e.g. arith a1 = 2, d = 3, n = 5.';
      return false;
    }
    _error = null;
    return true;
  }

  @override
  SolveResult solve() {
    final mode = _mode();
    if (mode == null) {
      return SolveResult.error(
          _error ?? 'Start with arith or geom.');
    }
    final nRaw = _param('n');
    if (nRaw == null || nRaw <= 0 || nRaw != nRaw.roundToDouble() || nRaw > 10000) {
      return SolveResult.error('n must be a positive whole number — e.g. n = 5.');
    }
    final n = nRaw.toInt();
    if (mode == 'arith') {
      double? a1 = _param('a1') ?? _param('a');
      double? d = _param('d');
      final list = _listed();
      if ((a1 == null || d == null) && list.length >= 2) {
        a1 ??= list[0];
        d ??= list[1] - list[0];
      }
      if (a1 == null || d == null) {
        return SolveResult.error('Arithmetic needs a1 and d — e.g. arith a1 = 2, d = 3, n = 5.');
      }
      final an = a1 + (n - 1) * d;
      final sn = n / 2 * (2 * a1 + (n - 1) * d);
      final terms = [for (var i = 1; i <= (n < 8 ? n : 8); i++) a1 + (i - 1) * d];
      return SolveResult(
        answer:
            'a($n) = ${G6Format.num(an)}, S($n) = ${G6Format.num(sn)}',
        points: terms,
        customData: [
          {'kind': 'sequence', 'mode': 'arith', 'a1': a1, 'd': d, 'n': n, 'an': an, 'sum': sn, 'terms': terms}
        ],
      );
    }
    double? a1 = _param('a1') ?? _param('a');
    double? r = _param('r');
    final list = _listed();
    if ((a1 == null || r == null) && list.length >= 2) {
      a1 ??= list[0];
      if (list[0] != 0) r ??= list[1] / list[0];
    }
    if (a1 == null || r == null) {
      return SolveResult.error('Geometric needs a1 and r — e.g. geom a1 = 3, r = 2, n = 4.');
    }
    final an = a1 * math.pow(r, n - 1);
    double sn;
    if ((r - 1).abs() < 1e-12) {
      sn = a1 * n;
    } else {
      sn = a1 * (math.pow(r, n) - 1) / (r - 1);
    }
    if (!an.isFinite || !sn.isFinite) {
      return SolveResult.error('Terms overflow — use a smaller n or ratio.');
    }
    final terms = [
      for (var i = 1; i <= (n < 8 ? n : 8); i++) a1 * math.pow(r, i - 1)
    ];
    return SolveResult(
      answer: 'a($n) = ${G6Format.num(an.toDouble())}, S($n) = ${G6Format.num(sn.toDouble())}',
      points: terms.map((e) => (e as num).toDouble()).toList(),
      customData: [
        {'kind': 'sequence', 'mode': 'geom', 'a1': a1, 'r': r, 'n': n, 'an': an, 'sum': sn, 'terms': terms}
      ],
    );
  }

  @override
  List<StepModel> getSteps() {
    if (_mode() == null) {
      return [
        StepModel(
            stepNumber: 1,
            title: 'Invalid input',
            explanation: _error ?? 'Start with arith or geom.')
      ];
    }
    final r = solve();
    final isArith = _mode() == 'arith';
    return [
      StepModel(
          stepNumber: 1,
          title: isArith ? 'Arithmetic form' : 'Geometric form',
          explanation: isArith
              ? 'a(n) = a1 + (n−1)d, S(n) = n/2·(2a1 + (n−1)d).'
              : 'a(n) = a1·r^(n−1), S(n) = a1(r^n − 1)/(r − 1).'),
      StepModel(stepNumber: 2, title: 'Substitute', explanation: rawInput.trim()),
      StepModel(stepNumber: 3, title: 'nth term + sum', explanation: r.answer),
    ];
  }
}
