// ─────────────────────────────────────────────────────────────
// RATIONAL EQUATION — G8. Solves a/x+b=c, a/(x+b)=c, a/(x+b)=c/(x+d)
// with excluded-value / extraneous-root check. Never throws.
// ─────────────────────────────────────────────────────────────

import 'package:calculus_system/core/base_equation.dart';
import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/shared/widgets/input_validation.dart';
import 'package:calculus_system/topics/grade6/solvers/g6_support.dart';

class RationalEquation extends BaseEquation {
  @override
  final String rawInput;
  String? _error;

  RationalEquation(this.rawInput);

  String _n() => rawInput.replaceAll(' ', '').replaceAll('−', '-');

  @override
  bool validate() {
    final empty =
        FieldValidators.notEmpty(rawInput, example: '1/x + 1/2 = 3/4');
    if (empty != null) {
      _error = empty;
      return false;
    }
    final t = _n();
    if ('='.allMatches(t).length != 1) {
      _error = 'Use one = sign — e.g. 1/x + 1/2 = 3/4.';
      return false;
    }
    if (!t.contains('/')) {
      _error = 'Include a fraction in x — e.g. 1/x + 1/2 = 3/4.';
      return false;
    }
    if (RegExp(r'/0(?![\d.])').hasMatch(t)) {
      _error = 'Denominator cannot be zero.';
      return false;
    }
    _error = null;
    return true;
  }

  /// Tries supported patterns; returns (x, excluded, steps-text).
  List<dynamic>? _solve() {
    var t = _n().replaceAll('X', 'x');
    final sides = t.split('=');
    if (sides.length != 2) return null;

    // Pattern A: p/x + q = r   (q, r plain numbers)
    var m = RegExp(
            r'^([+-]?\d+(?:\.\d+)?)/x([+-]\d+(?:\.\d+)?/)?([+-]?\d+(?:\.\d+)?)?$')
        .firstMatch(sides[0]);
    // General approach for A: split LHS into fraction + rest.
    final rSide = double.tryParse(sides[1]);
    if (rSide != null) {
      final left = sides[0];
      final fm = RegExp(r'([+-]?\d+(?:\.\d+)?)/x').firstMatch(left);
      if (fm != null) {
        final p = double.parse(fm.group(1)!);
        final rest = left.replaceFirst(fm.group(0)!, '');
        double q = 0;
        if (rest.isNotEmpty) {
          // rest like +1/2 or -3.
          if (rest.contains('/')) {
            final parts = rest.replaceFirst(RegExp(r'^[+-]'), '').split('/');
            if (parts.length != 2) return null;
            final num = double.tryParse(parts[0]);
            final den = double.tryParse(parts[1]);
            if (num == null || den == null || den == 0) return null;
            q = num / den;
            if (rest.startsWith('-')) q = -q;
          } else {
            final v = double.tryParse(rest);
            if (v == null) return null;
            q = v;
          }
        }
        if ((rSide - q).abs() < 1e-12 || p == 0) return null;
        final x = p / (rSide - q);
        if (x.abs() < 1e-12) return null; // would zero the denominator
        return [
          [x],
          [0.0],
          'p/x + q = r with p=${G6Format.num(p)}, q=${G6Format.num(q)}, r=${G6Format.num(rSide)}'
        ];
      }
      // Pattern B: a/(x+b) (+q) = r
      final bm =
          RegExp(r'^([+-]?\d+(?:\.\d+)?)/\(x([+-]\d+(?:\.\d+)?)\)([+-].+)?$')
              .firstMatch(left);
      if (bm != null) {
        final a = double.parse(bm.group(1)!);
        final b = double.parse(bm.group(2)!);
        double q = 0;
        final rest = bm.group(3) ?? '';
        if (rest.isNotEmpty) {
          if (rest.contains('/')) {
            final s = rest.startsWith('+') || rest.startsWith('-')
                ? rest.substring(1)
                : rest;
            final neg = rest.startsWith('-');
            final pp = s.split('/');
            if (pp.length != 2) return null;
            final n1 = double.tryParse(pp[0]);
            final n2 = double.tryParse(pp[1]);
            if (n1 == null || n2 == null || n2 == 0) return null;
            q = (neg ? -1 : 1) * n1 / n2;
          } else {
            final v = double.tryParse(rest);
            if (v == null) return null;
            q = v;
          }
        }
        if ((rSide - q).abs() < 1e-12) return null;
        final x = a / (rSide - q) - b;
        final excl = -b;
        if ((x - excl).abs() < 1e-9) return const ['extraneous'];
        return [
          [x],
          [excl],
          'a/(x+b) = r−q with a=${G6Format.num(a)}, b=${G6Format.num(b)}'
        ];
      }
    }

    // Pattern C: a/(x+b) = c/(x+d).
    final cm = RegExp(
            r'^([+-]?\d+(?:\.\d+)?)/\(x([+-]\d+(?:\.\d+)?)\)=([+-]?\d+(?:\.\d+)?)/\(x([+-]\d+(?:\.\d+)?)\)$')
        .firstMatch(t);
    if (cm != null) {
      final a = double.parse(cm.group(1)!);
      final b = double.parse(cm.group(2)!);
      final c = double.parse(cm.group(3)!);
      final d = double.parse(cm.group(4)!);
      if ((c - a).abs() < 1e-12) return null;
      final x = (a * d - b * c) / (c - a);
      final ex = [-b, -d];
      if (ex.any((e) => (x - e).abs() < 1e-9)) return const ['extraneous'];
      return [
        [x],
        ex,
        'Cross-multiply: a(x+d) = c(x+b)'
      ];
    }
    if (m != null) {
      return null;
    }
    return null;
  }

  @override
  SolveResult solve() {
    final s = _solve();
    if (s == null) {
      return SolveResult.error(_error ??
          'Supported: 1/x + 1/2 = 3/4, 2/(x-1) = 4, a/(x+b) = c/(x+d).');
    }
    if (s.length == 1 && s[0] == 'extraneous') {
      return SolveResult.error(
          'No solution — the only candidate makes a denominator zero (extraneous).');
    }
    final xs = (s[0] as List).cast<double>();
    final ex = (s[1] as List).cast<double>();
    final x = xs.first;
    return SolveResult(
      answer: 'x = ${G6Format.num(x)}',
      points: [x],
      customData: [
        {
          'kind': 'rational',
          'root': x,
          'excluded': ex,
          'detail': s[2],
        }
      ],
    );
  }

  @override
  List<StepModel> getSteps() {
    final s = _solve();
    final isExtraneous = s != null && s.length == 1 && s[0] == 'extraneous';
    if (s == null || isExtraneous) {
      return [
        StepModel(
            stepNumber: 1,
            title: isExtraneous ? 'Extraneous root' : 'Invalid input',
            explanation: isExtraneous
                ? 'Candidate zeroes a denominator — no solution.'
                : (_error ?? 'Use 1/x + 1/2 = 3/4 or a/(x+b) = c/(x+d).'))
      ];
    }
    final ex = (s[1] as List).cast<double>();
    final r = solve();
    return [
      StepModel(
          stepNumber: 1,
          title: 'Excluded values',
          explanation:
              'Denominators ≠ 0, so x ≠ ${ex.map(G6Format.num).join(', ')}.'),
      StepModel(
          stepNumber: 2,
          title: 'Clear denominators',
          explanation: s[2] as String),
      StepModel(
          stepNumber: 3,
          title: 'Solve the linear equation',
          explanation: r.answer),
      const StepModel(
          stepNumber: 4,
          title: 'Check for extraneous roots',
          explanation:
              'Substitute back — reject any x that zeroes a denominator.'),
    ];
  }
}
