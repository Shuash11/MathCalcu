// ─────────────────────────────────────────────────────────────
// RATIONAL INEQUALITY — SHS GenMath. Sign-chart solve + asymptotes.
// e.g. '(x-1)/(x+2) > 0' -> (-inf,-2) U (1,inf). Never throws.
// ─────────────────────────────────────────────────────────────

import 'package:calculus_system/calculator/calculator_engine.dart';
import 'package:calculus_system/core/base_equation.dart';
import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/shared/widgets/input_validation.dart';
import 'package:calculus_system/topics/grade6/solvers/g6_support.dart';

class RationalInequalityEquation extends BaseEquation {
  @override
  final String rawInput;
  String? _error;

  RationalInequalityEquation(this.rawInput);

  String _n() => rawInput.replaceAll(' ', '').replaceAll('−', '-');

  double? _ev(String e) {
    try {
      return CalculatorEngine.evaluate(e);
    } catch (_) {
      return null;
    }
  }

  /// Parses (mx+b)/(nx+c) <op> rhs(num). Returns map or null.
  Map<String, dynamic>? _parse() {
    final t = _n();
    final m =
        RegExp(r'^\(?([^()]*x[^()]*)\)?/\(?([^()]*x[^()]*)\)?(<=|>=|<|>)(.+)$')
            .firstMatch(t);
    if (m == null) return null;
    final numE = m.group(1)!, denE = m.group(2)!;
    final op = m.group(3)!;
    final rhs = _ev(m.group(4)!);
    if (rhs == null) return null;
    // Linear coeffs via probing (explicit * for implicit forms like 2x).
    double? coef(String e) {
      String sub(String expr, String v) => expr
          .replaceAllMapped(
              RegExp(r'(\d|\))([xX])'), (m) => '${m.group(1)}*${m.group(2)}')
          .replaceAll('x', v)
          .replaceAll('X', v);
      final f0 = _ev(sub(e, '(0)'));
      final f1 = _ev(sub(e, '(1)'));
      if (f0 == null || f1 == null) return null;
      return f1 - f0;
    }

    String sub0(String expr) => expr
        .replaceAllMapped(
            RegExp(r'(\d|\))([xX])'), (m) => '${m.group(1)}*${m.group(2)}')
        .replaceAll('x', '(0)')
        .replaceAll('X', '(0)');
    final a = coef(numE), b0 = _ev(sub0(numE));
    final c = coef(denE), d0 = _ev(sub0(denE));
    if (a == null || b0 == null || c == null || d0 == null) return null;
    if (c.abs() < 1e-12) return null;
    return {'a': a, 'b': b0, 'c': c, 'd': d0, 'op': op, 'rhs': rhs};
  }

  @override
  bool validate() {
    final empty =
        FieldValidators.notEmpty(rawInput, example: '(x - 1)/(x + 2) > 0');
    if (empty != null) {
      _error = empty;
      return false;
    }
    if (!RegExp(r'<=|>=|<|>').hasMatch(rawInput)) {
      _error = 'Include <, >, ≤ or ≥ — e.g. (x - 1)/(x + 2) > 0.';
      return false;
    }
    if (_parse() == null) {
      _error = 'Use (ax + b)/(cx + d) <op> number — e.g. (x - 1)/(x + 2) > 0.';
      return false;
    }
    _error = null;
    return true;
  }

  bool _holds(double v, String op) {
    // v = LHS - rhs sign test vs 0.
    switch (op) {
      case '<':
        return v < 0;
      case '>':
        return v > 0;
      case '<=':
        return v <= 0;
      case '>=':
        return v >= 0;
    }
    return false;
  }

  @override
  SolveResult solve() {
    final p = _parse();
    if (p == null) {
      return SolveResult.error(_error ?? 'Use (ax + b)/(cx + d) > 0.');
    }
    final a = p['a'] as double, b = p['b'] as double;
    final c = p['c'] as double, d = p['d'] as double;
    final op = p['op'] as String, rhs = p['rhs'] as double;
    // Reduce to (Ax+B)/(Cx+D) vs 0: subtract rhs.
    // (ax+b)/(cx+d) - rhs = ((a-rhs*c)x + (b-rhs*d))/(cx+d).
    final na = a - rhs * c, nb = b - rhs * d;
    final zeroN = na.abs() > 1e-12 ? -nb / na : double.nan;
    final hole = -d / c; // vertical asymptote / excluded
    final strict = op == '<' || op == '>';
    double f(double x) => (na * x + nb) / (c * x + d);

    String fmt(double v) =>
        v.isNaN ? '—' : (v.isInfinite ? (v > 0 ? '∞' : '-∞') : G6Format.num(v));

    // Critical points sorted.
    final pts = <double>[if (!zeroN.isNaN) zeroN, hole]..sort();
    // Sample intervals: (-inf,p0), (p0,p1), (p1,inf).
    final bounds = <double>[double.negativeInfinity, ...pts, double.infinity];
    final keep = <List<double>>[];
    for (var i = 0; i < bounds.length - 1; i++) {
      final lo = bounds[i], hi = bounds[i + 1];
      double sample;
      if (lo.isInfinite && hi.isInfinite) {
        sample = 0;
      } else if (lo.isInfinite) {
        sample = hi - 1;
      } else if (hi.isInfinite) {
        sample = lo + 1;
      } else {
        sample = (lo + hi) / 2;
      }
      if ((sample - hole).abs() < 1e-9) continue;
      if (_holds(f(sample), op)) keep.add([lo, hi]);
    }
    String iv(double lo, double hi) {
      final l = lo.isInfinite ? '(-∞' : '(${fmt(lo)}';
      // Endpoints: hole always open; numerator zero closed when non-strict.
      var leftBracket = '(';
      var rightBracket = ')';
      if (!lo.isInfinite &&
          !zeroN.isNaN &&
          (lo - zeroN).abs() < 1e-9 &&
          !strict) {
        leftBracket = '[';
      }
      if (!hi.isInfinite &&
          !zeroN.isNaN &&
          (hi - zeroN).abs() < 1e-9 &&
          !strict) {
        rightBracket = ']';
      }
      final _ = l;
      return '$leftBracket${lo.isInfinite ? '-∞' : fmt(lo)}, ${hi.isInfinite ? '∞' : fmt(hi)}$rightBracket';
    }

    if (keep.isEmpty) {
      return SolveResult(
        answer: 'No solution',
        points: const [],
        intervalNotation: '∅',
        customData: [
          {
            'kind': 'rational-ineq',
            'zero': zeroN.isNaN ? null : zeroN,
            'asymptote': hole,
            'intervals': [],
          }
        ],
      );
    }
    final ans = keep.map((e) => iv(e[0], e[1])).join(' ∪ ');
    return SolveResult(
      answer: ans,
      points: [if (!zeroN.isNaN) zeroN, hole],
      intervalNotation: ans,
      customData: [
        {
          'kind': 'rational-ineq',
          'zero': zeroN.isNaN ? null : zeroN,
          'asymptote': hole,
          'verticalAsymptote': 'x = ${fmt(hole)}',
          'horizontalAsymptote': 'y = ${fmt(na / c)}',
          'intervals': keep
              .map((e) => {
                    'lo': e[0].isInfinite ? null : e[0],
                    'hi': e[1].isInfinite ? null : e[1]
                  })
              .toList(),
        }
      ],
    );
  }

  @override
  List<StepModel> getSteps() {
    final p = _parse();
    if (p == null) {
      return [
        StepModel(
            stepNumber: 1,
            title: 'Invalid input',
            explanation: _error ?? 'Use (x - 1)/(x + 2) > 0.')
      ];
    }
    final r = solve();
    return [
      const StepModel(
          stepNumber: 1,
          title: 'Excluded value + asymptotes',
          explanation:
              'Denominator ≠ 0 gives the vertical asymptote (open dot).'),
      const StepModel(
          stepNumber: 2,
          title: 'Move everything left',
          explanation: 'Subtract RHS so the sign chart compares against 0.'),
      const StepModel(
          stepNumber: 3,
          title: 'Sign chart',
          explanation: 'Test each interval between critical points.'),
      StepModel(
          stepNumber: 4, title: 'Solution intervals', explanation: r.answer),
    ];
  }
}
