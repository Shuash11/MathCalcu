// ─────────────────────────────────────────────────────────────
// INVERSE FUNCTION — SHS GenMath. f(x)=ax+b or (ax+b)/(cx+d).
// e.g. 'f(x)=2x+3' -> f^-1(x)=(x-3)/2. Never throws.
// ─────────────────────────────────────────────────────────────

import 'package:calculus_system/calculator/calculator_engine.dart';
import 'package:calculus_system/core/base_equation.dart';
import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/shared/widgets/input_validation.dart';
import 'package:calculus_system/topics/grade6/solvers/g6_support.dart';

class InverseFunctionEquation extends BaseEquation {
  @override
  final String rawInput;
  String? _error;

  InverseFunctionEquation(this.rawInput);

  String _rhs() {
    var t = rawInput.replaceAll(' ', '').replaceAll('−', '-');
    final eq = t.split('=');
    return eq.length == 2 ? eq[1] : t;
  }

  double? _ev(String e, double x) {
    try {
      // Insert explicit * for implicit forms like 2x (CalculatorEngine
      // needs 2*(x); same prep pattern as integral/lhopital solvers).
      final s = e.replaceAllMapped(
          RegExp(r'(\d|\))([xX])'), (m) => '${m.group(1)}*${m.group(2)}');
      return CalculatorEngine.evaluate(
          s.replaceAll('x', '($x)').replaceAll('X', '($x)'));
    } catch (_) {
      return null;
    }
  }

  /// Returns {'type': 'linear'|'frac', coeffs...} or null.
  Map<String, double>? _parse() {
    final e = _rhs().replaceAll('X', 'x');
    if (!e.contains('x')) return null;
    if (e.contains('/')) {
      final parts = e.split('/');
      if (parts.length != 2) return null;
      var num = parts[0].replaceAll('(', '').replaceAll(')', '');
      var den = parts[1].replaceAll('(', '').replaceAll(')', '');
      final f0n = _ev(num, 0), f1n = _ev(num, 1);
      final f0d = _ev(den, 0), f1d = _ev(den, 1);
      if (f0n == null || f1n == null || f0d == null || f1d == null) return null;
      return {
        'type': 1, // frac marker
        'a': f1n - f0n,
        'b': f0n,
        'c': f1d - f0d,
        'd': f0d,
      };
    }
    final f0 = _ev(e, 0), f1 = _ev(e, 1);
    if (f0 == null || f1 == null) return null;
    final f2 = _ev(e, 2);
    if (f2 == null || ((f1 - f0) * 2 + f0 - f2).abs() > 1e-6) return null;
    return {'type': 0, 'a': f1 - f0, 'b': f0};
  }

  @override
  bool validate() {
    final empty = FieldValidators.notEmpty(rawInput, example: 'f(x) = 2x + 3');
    if (empty != null) {
      _error = empty;
      return false;
    }
    if (!rawInput.toLowerCase().contains('x')) {
      _error = 'Include x — e.g. f(x) = 2x + 3.';
      return false;
    }
    if (_parse() == null) {
      _error = 'Linear or linear-fractional only — e.g. f(x) = 2x + 3.';
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
          _error ?? 'Enter f(x) = 2x + 3 or (2x+1)/(x-3).');
    }
    if (p['type'] == 0) {
      final a = p['a']!, b = p['b']!;
      if (a.abs() < 1e-12) {
        return SolveResult.error('Constant functions have no inverse.');
      }
      // y=ax+b -> x=ay+b -> y=(x-b)/a.
      final inv = b.abs() < 1e-12
          ? 'f⁻¹(x) = x/${G6Format.num(a)}'
          : 'f⁻¹(x) = (x ${b > 0 ? '-' : '+'} ${G6Format.num(b.abs())})/${G6Format.num(a)}';
      return SolveResult(
        answer: inv,
        points: const [],
        customData: [
          {'kind': 'inverse', 'type': 'linear', 'a': a, 'b': b}
        ],
      );
    }
    final a = p['a']!, b = p['b']!, c = p['c']!, d = p['d']!;
    if ((a * d - b * c).abs() < 1e-12) {
      return SolveResult.error('Not one-to-one — no inverse (ad − bc = 0).');
    }
    // y=(ax+b)/(cx+d) -> inverse: y=(dx-b)/(a-cx) i.e. (-dx+b... let me: x=(ay+b)/(cy+d) -> x(cy+d)=ay+b -> y(cx-a)=b-xd -> y=(dx-b)/(cx-a).
    String term(double coef, String v, {bool first = false}) {
      if (coef.abs() < 1e-12) return '';
      final mag = G6Format.num(coef.abs());
      final body = mag == '1' ? v : '$mag$v';
      if (first) return coef < 0 ? '-$body' : body;
      return coef < 0 ? ' - $body' : ' + $body';
    }

    final numS =
        '${term(d, 'x', first: true)}${b.abs() < 1e-12 ? '' : (b > 0 ? ' - ${G6Format.num(b)}' : ' + ${G6Format.num(b.abs())}')}'
            .trim();
    final denS =
        '${term(c, 'x', first: true)}${a.abs() < 1e-12 ? '' : (a > 0 ? ' - ${G6Format.num(a)}' : ' + ${G6Format.num(a.abs())}')}'
            .trim();
    return SolveResult(
      answer: 'f⁻¹(x) = ($numS)/($denS)',
      points: const [],
      customData: [
        {
          'kind': 'inverse',
          'type': 'fractional',
          'a': a,
          'b': b,
          'c': c,
          'd': d
        }
      ],
    );
  }

  @override
  List<StepModel> getSteps() {
    if (_parse() == null) {
      return [
        StepModel(
            stepNumber: 1,
            title: 'Invalid input',
            explanation: _error ?? 'Use f(x) = 2x + 3.')
      ];
    }
    final r = solve();
    return [
      const StepModel(
          stepNumber: 1,
          title: 'Replace f(x) with y',
          explanation: 'y = ... so x and y can swap.'),
      const StepModel(
          stepNumber: 2,
          title: 'Swap x and y',
          explanation: 'One-to-one functions reverse inputs and outputs.'),
      const StepModel(
          stepNumber: 3,
          title: 'Solve for y',
          explanation: 'Isolate y with inverse operations.'),
      StepModel(stepNumber: 4, title: 'Inverse + check', explanation: r.answer),
    ];
  }
}
