// ─────────────────────────────────────────────────────────────
// EXPONENTIAL / LOG EQUATION — SHS GenMath.
// e.g. '2^x=32', 'log2(x)+log2(x-2)=3'. Domain-checked. Never throws.
// ─────────────────────────────────────────────────────────────

import 'dart:math' as math;
import 'package:calculus_system/core/base_equation.dart';
import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/shared/widgets/input_validation.dart';
import 'package:calculus_system/topics/grade6/solvers/g6_support.dart';

class ExpLogEquation extends BaseEquation {
  @override
  final String rawInput;
  String? _error;

  ExpLogEquation(this.rawInput);

  String _n() => rawInput.replaceAll(' ', '').replaceAll('−', '-');

  double _logBase(double b, double v) => math.log(v) / math.log(b);

  List<dynamic>? _parse() {
    final t = _n();
    if ('='.allMatches(t).length != 1) return null;
    final sides = t.split('=');
    final rhs = double.tryParse(sides[1]);
    if (rhs == null) return null;
    final left = sides[0];

    // E1: b^x = rhs  or b^(mx+k) = rhs.
    var m = RegExp(r'^(\d+(?:\.\d+)?)\^\(?([+-]?x(?:[+-]\d+(?:\.\d+)?)?)\)?$')
        .firstMatch(left.replaceAll('X', 'x'));
    if (m != null) {
      final b = double.parse(m.group(1)!);
      var inner = m.group(2)!;
      double mm = 1, kk = 0;
      final im = RegExp(r'^([+-]?)x([+-]\d+(?:\.\d+)?)?$').firstMatch(inner);
      if (im == null) return null;
      mm = im.group(1) == '-' ? -1 : 1;
      if (im.group(2) != null) kk = double.parse(im.group(2)!);
      return ['exp', b, mm, kk, rhs];
    }
    // E2: e^(mx+k) = rhs or exp(mx+k) = rhs.
    m = RegExp(r'^(?:e\^|exp)\(?([^)]+)\)?$').firstMatch(left);
    if (m != null) {
      final inner = m.group(1)!;
      final im = RegExp(r'^([+-]?\d+(?:\.\d+)?)\*?x([+-]\d+(?:\.\d+)?)?$')
          .firstMatch(inner.replaceAll('X', 'x'));
      double mm, kk = 0;
      if (im != null) {
        mm = double.parse(im.group(1)!);
        if (im.group(2) != null) kk = double.parse(im.group(2)!);
      } else if (RegExp(r'^[+-]?x([+-]\d+(?:\.\d+)?)?$')
          .hasMatch(inner.replaceAll('X', 'x'))) {
        final jm = RegExp(r'^([+-]?)x([+-]\d+(?:\.\d+)?)?$')
            .firstMatch(inner.replaceAll('X', 'x'))!;
        mm = jm.group(1) == '-' ? -1 : 1;
        if (jm.group(2) != null) kk = double.parse(jm.group(2)!);
      } else {
        return null;
      }
      return ['exp', math.e, mm, kk, rhs];
    }
    // L1: log_b(x+k) = rhs.
    m = RegExp(r'^log(\d+(?:\.\d+)?)\((x(?:[+-]\d+(?:\.\d+)?)?)\)$')
        .firstMatch(left.replaceAll('X', 'x'));
    if (m != null) {
      return ['log1', double.parse(m.group(1)!), m.group(2)!, rhs];
    }
    // L2: log_b(x+a)+log_b(x+b2) = rhs (same base, plus only).
    m = RegExp(
            r'^log(\d+(?:\.\d+)?)\((x(?:[+-]\d+(?:\.\d+)?)?)\)\+log\1\((x(?:[+-]\d+(?:\.\d+)?)?)\)$')
        .firstMatch(left.replaceAll('X', 'x'));
    if (m != null) {
      return ['log2', double.parse(m.group(1)!), m.group(2)!, m.group(3)!, rhs];
    }
    // L3: ln(x+k) = rhs.
    m = RegExp(r'^ln\((x(?:[+-]\d+(?:\.\d+)?)?)\)$')
        .firstMatch(left.replaceAll('X', 'x'));
    if (m != null) {
      return ['log1', math.e, m.group(1)!, rhs];
    }
    return null;
  }

  double _shiftOf(String lin) {
    // 'x', 'x-2', 'x+5' -> k.
    final mm = RegExp(r'^x([+-]\d+(?:\.\d+)?)?$').firstMatch(lin);
    if (mm == null) return 0;
    return mm.group(1) == null ? 0 : double.parse(mm.group(1)!);
  }

  @override
  bool validate() {
    final empty = FieldValidators.notEmpty(
        rawInput, example: 'log2(x) + log2(x - 2) = 3');
    if (empty != null) {
      _error = empty;
      return false;
    }
    final t = _n().toLowerCase();
    if (!t.contains('^') && !t.contains('log') && !t.contains('ln') && !t.contains('exp')) {
      _error = 'Include ^, log, or ln — e.g. 2^x = 32.';
      return false;
    }
    if (_parse() == null) {
      _error = 'Supported: b^x = n, log_b(x+k) = n, log2(x)+log2(x-2) = 3.';
      return false;
    }
    _error = null;
    return true;
  }

  @override
  SolveResult solve() {
    final p = _parse();
    if (p == null) {
      return SolveResult.error(
          _error ?? 'Supported: 2^x = 32, log2(x)+log2(x-2) = 3.');
    }
    if (p[0] == 'exp') {
      final b = p[1] as double, mm = p[2] as double;
      final kk = p[3] as double, rhs = p[4] as double;
      if (b <= 0 || (b - 1).abs() < 1e-12) {
        return SolveResult.error('Base must be positive and ≠ 1.');
      }
      if (rhs <= 0) {
        return SolveResult.error('No real solution — b^(…) is always positive.');
      }
      if (mm.abs() < 1e-12) {
        return SolveResult.error('Exponent must include x.');
      }
      final x = (_logBase(b, rhs) - kk) / mm;
      return SolveResult(
        answer: 'x = ${G6Format.num(x)}',
        points: [x],
        customData: [
          {'kind': 'explog', 'mode': 'exp', 'base': b, 'root': x}
        ],
      );
    }
    if (p[0] == 'log1') {
      final b = p[1] as double, lin = p[2] as String, rhs = p[3] as double;
      if (b <= 0 || (b - 1).abs() < 1e-12) {
        return SolveResult.error('Log base must be positive and ≠ 1.');
      }
      final k = _shiftOf(lin);
      final arg = math.pow(b, rhs).toDouble();
      if (!arg.isFinite) return SolveResult.error('Value overflows.');
      final x = arg - k;
      if (x + k <= 0) {
        return SolveResult.error('No solution — log argument must be positive.');
      }
      return SolveResult(
        answer: 'x = ${G6Format.num(x)}',
        points: [x],
        customData: [
          {'kind': 'explog', 'mode': 'log', 'base': b, 'root': x}
        ],
      );
    }
    // log2: log_b(x+a)+log_b(x+b2)=rhs -> (x+a)(x+b2)=b^rhs, check domain.
    final b = p[1] as double, a = _shiftOf(p[2] as String);
    final b2 = _shiftOf(p[3] as String);
    final rhs = p[4] as double;
    if (b <= 0 || (b - 1).abs() < 1e-12) {
      return SolveResult.error('Log base must be positive and ≠ 1.');
    }
    final target = math.pow(b, rhs).toDouble();
    if (!target.isFinite) return SolveResult.error('Value overflows.');
    // x² + (a+b2)x + a*b2 - target = 0.
    final s = a + b2, pr = a * b2 - target;
    final disc = s * s - 4 * pr;
    if (disc < 0) return SolveResult.error('No real solution.');
    final sq = disc <= 0 ? 0.0 : _sqrt(disc);
    final cands = disc == 0 ? [(-s) / 2] : [(-s - sq) / 2, (-s + sq) / 2];
    final valid = cands.where((x) => x + a > 0 && x + b2 > 0).toList();
    if (valid.isEmpty) {
      return SolveResult.error(
          'No solution — candidates fail the log domain (arguments > 0).');
    }
    final ans = valid.length == 1
        ? 'x = ${G6Format.num(valid.first)}'
        : 'x = ${valid.map(G6Format.num).join(', ')}';
    return SolveResult(
      answer: valid.length == 1
          ? ans
          : '$ans  (${cands.length - valid.length} extraneous rejected)',
      points: valid,
      customData: [
        {
          'kind': 'explog',
          'mode': 'log-sum',
          'base': b,
          'roots': valid,
          'rejected': cands.where((e) => !valid.contains(e)).toList(),
        }
      ],
    );
  }

  double _sqrt(double d) {
    var x = d / 2;
    if (x <= 0) x = 1;
    for (var i = 0; i < 40; i++) {
      x = 0.5 * (x + d / x);
    }
    return x;
  }

  @override
  List<StepModel> getSteps() {
    final p = _parse();
    if (p == null) {
      return [
        StepModel(
            stepNumber: 1,
            title: 'Invalid input',
            explanation: _error ?? 'Use 2^x = 32.')
      ];
    }
    final r = solve();
    final isExp = p[0] == 'exp';
    return [
      StepModel(
          stepNumber: 1,
          title: isExp ? 'One-to-one (exponents)' : 'Domain first',
          explanation: isExp
              ? 'RHS must be positive for a real solution.'
              : 'Every log argument must be > 0.'),
      StepModel(
          stepNumber: 2,
          title: isExp ? 'Take logs' : 'Condense the logs',
          explanation: isExp
              ? 'x = (log_b(RHS) − k)/m.'
              : 'log_b A + log_b B = log_b(AB), then exponentiate.'),
      StepModel(
          stepNumber: 3,
          title: 'Solve the resulting equation',
          explanation: r.hasError ? (r.errorMessage ?? '') : r.answer),
      const StepModel(
          stepNumber: 4,
          title: 'Verify domain',
          explanation: 'Reject any candidate outside the domain (extraneous).'),
    ];
  }
}
