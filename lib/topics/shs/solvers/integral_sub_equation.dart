// ─────────────────────────────────────────────────────────────
// INTEGRAL (u-sub + definite area) — G12/College.
// Indefinite: 'int 2x(x^2+1)^3 dx' (power-of-linear-inner patterns +
// monomials). Definite: 'def a=0 b=2 f=x^2'. Simpson numeric area.
// ─────────────────────────────────────────────────────────────

import 'package:calculus_system/calculator/calculator_engine.dart';
import 'package:calculus_system/core/base_equation.dart';
import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/shared/widgets/input_validation.dart';
import 'package:calculus_system/topics/grade6/solvers/g6_support.dart';

class IntegralSubEquation extends BaseEquation {
  @override
  final String rawInput;
  String? _error;

  IntegralSubEquation(this.rawInput);

  String _n() => rawInput.replaceAll(' ', '').replaceAll('−', '-').replaceAll('X', 'x');

  double? _ev(String e, double x) {
    try {
      var s = e.replaceAllMapped(
          RegExp(r'(\d|\))([x])'), (m) => '${m.group(1)}*${m.group(2)}');
      s = s.replaceAll('x', '($x)');
      final v = CalculatorEngine.evaluate(s);
      return v.isFinite ? v : null;
    } catch (_) {
      return null;
    }
  }

  double _simpson(String f, double a, double b, [int n = 200]) {
    if (n.isOdd) n++;
    final h = (b - a) / n;
    var sum = (_ev(f, a) ?? 0) + (_ev(f, b) ?? 0);
    for (var i = 1; i < n; i++) {
      final v = _ev(f, a + i * h) ?? 0;
      sum += (i.isOdd ? 4 : 2) * v;
    }
    return sum * h / 3;
  }

  /// Antiderivative for k*x^n (n≠-1) and k*(m*x+b)^n chain patterns.
  String? _antiderivative(String f) {
    // k*x^n
    var m = RegExp(r'^([+-]?\d+(?:\.\d+)?)?\*?x\^([+-]?\d+(?:\.\d+)?)$')
        .firstMatch(f);
    if (m != null) {
      final k = m.group(1) == null || m.group(1)!.isEmpty
          ? 1.0
          : double.parse(m.group(1)!);
      final n = double.parse(m.group(2)!);
      if ((n + 1).abs() < 1e-12) return null;
      final c = k / (n + 1);
      return '${G6Format.num(c)}x^${G6Format.num(n + 1)} + C';
    }
    // plain x, k*x, constant
    if (RegExp(r'^[+-]?x$').hasMatch(f)) return 'x^2/2 + C';
    m = RegExp(r'^([+-]?\d+(?:\.\d+)?)\*?x$').firstMatch(f);
    if (m != null) {
      return '${G6Format.num(double.parse(m.group(1)!) / 2)}x^2 + C';
    }
    if (double.tryParse(f) != null) {
      return '${G6Format.num(double.parse(f))}x + C';
    }
    // k*(m*x+b)^n with outer k optional: '2x(x^2+1)^3' handled as chain
    // u=x^2+1 special-case below; general linear-inner:
    m = RegExp(r'^([+-]?\d+(?:\.\d+)?)?\*?\(([+-]?\d+(?:\.\d+)?)\*?x([+-]\d+(?:\.\d+)?)?\)\^(\d+)$')
        .firstMatch(f);
    if (m != null) {
      final k = m.group(1) == null || m.group(1)!.isEmpty
          ? 1.0
          : double.parse(m.group(1)!);
      final mi = double.parse(m.group(2)!);
      final pw = int.parse(m.group(4)!);
      if (mi.abs() < 1e-12) return null;
      final c = k / (mi * (pw + 1));
      return '${G6Format.num(c)}(${G6Format.num(mi)}x${m.group(3) ?? ''})^${pw + 1} + C';
    }
    // 2x*(x^2+1)^n chain: outer derivative of inner.
    m = RegExp(r'^([+-]?\d+(?:\.\d+)?)\*?x\*?\(x\^2([+-]\d+(?:\.\d+)?)?\)\^(\d+)$')
        .firstMatch(f);
    if (m != null) {
      final k = double.parse(m.group(1)!);
      final pw = int.parse(m.group(3)!);
      final c = k / (2 * (pw + 1));
      return '${G6Format.num(c)}(x^2${m.group(2) ?? ''})^${pw + 1} + C';
    }
    return null;
  }

  @override
  bool validate() {
    final empty = FieldValidators.notEmpty(
        rawInput, example: 'def a = 0, b = 2, f = x^2');
    if (empty != null) {
      _error = empty;
      return false;
    }
    final t = _n().toLowerCase();
    if (!t.contains('int') && !t.contains('∫') && !t.contains('def')) {
      _error = 'Start with int (indefinite) or def a/b (definite).';
      return false;
    }
    _error = null;
    return true;
  }

  @override
  SolveResult solve() {
    final t = _n();
    final lo = t.toLowerCase();
    if (lo.startsWith('def')) {
      final am = RegExp(r'a\s*=\s*(-?\d+(?:\.\d+)?)').firstMatch(t);
      final bm = RegExp(r'b\s*=\s*(-?\d+(?:\.\d+)?)').firstMatch(t);
      final fm = RegExp(r'f\s*=\s*(.+)$').firstMatch(t);
      if (am == null || bm == null || fm == null) {
        return SolveResult.error(_error ?? 'Definite needs a, b, f — e.g. def a = 0, b = 2, f = x^2.');
      }
      final a = double.parse(am.group(1)!), b = double.parse(bm.group(1)!);
      final f = fm.group(1)!;
      if (_ev(f, (a + b) / 2) == null && _ev(f, a) == null) {
        return SolveResult.error('Could not evaluate f on [a, b].');
      }
      final area = _simpson(f, a, b);
      final anti = _antiderivative(f);
      final ans = anti == null
          ? 'Area = ${G6Format.num(area)} (numeric, Simpson)'
          : 'Area = ${G6Format.num(area)}  (F(x) = $anti)';
      // Sample curve for graph.
      final pts = [
        for (var i = 0; i <= 10; i++) _ev(f, a + (b - a) * i / 10) ?? 0
      ];
      return SolveResult(
        answer: ans,
        points: pts,
        customData: [
          {'kind': 'definite', 'a': a, 'b': b, 'f': f, 'area': area, 'antiderivative': anti}
        ],
      );
    }
    // Indefinite: strip 'int' and 'dx'.
    var f = t.replaceAll(RegExp(r'^int', caseSensitive: false), '').replaceAll(RegExp(r'dx$', caseSensitive: false), '');
    f = f.replaceAll('(', '(').trim();
    final anti = _antiderivative(f);
    if (anti == null) {
      return SolveResult.error(
          'u-sub patterns only: k*x^n, k*(mx+b)^n, or 2x*(x^2+c)^n.');
    }
    final isChain = f.contains('(x^2') || (f.contains('(') && f.contains(')^'));
    return SolveResult(
      answer: '∫ $f dx = $anti',
      points: const [],
      customData: [
        {
          'kind': 'indefinite',
          'f': f,
          'antiderivative': anti,
          'u': isChain ? 'u = inner function (e.g. x²+1)' : 'direct power rule',
        }
      ],
    );
  }

  @override
  List<StepModel> getSteps() {
    final r = solve();
    final isDef = _n().toLowerCase().startsWith('def');
    if (r.hasError) {
      return [
        StepModel(
            stepNumber: 1, title: 'Cannot integrate', explanation: r.errorMessage ?? '')
      ];
    }
    if (isDef) {
      return [
        const StepModel(
            stepNumber: 1,
            title: 'FTC setup',
            explanation: 'Area = F(b) − F(a); shade above the x-axis.'),
        StepModel(
            stepNumber: 2, title: 'Antiderivative', explanation: r.answer),
        const StepModel(
            stepNumber: 3,
            title: 'Evaluate + numeric check',
            explanation: 'Simpson rule confirms the shaded area.'),
      ];
    }
    return [
      const StepModel(
          stepNumber: 1,
          title: 'Choose u',
          explanation: 'u = inner function; du absorbs the outer factor.'),
      const StepModel(
          stepNumber: 2,
          title: 'Rewrite in u',
          explanation: 'Integrate the power: ∫u^n du = u^(n+1)/(n+1).'),
      StepModel(stepNumber: 3, title: 'Back-substitute + C', explanation: r.answer),
    ];
  }
}
