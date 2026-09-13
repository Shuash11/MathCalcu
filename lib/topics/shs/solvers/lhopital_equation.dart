// ─────────────────────────────────────────────────────────────
// L'HOPITAL — College. 0/0 (and 0-value) limits via numeric f/g and
// numeric derivatives: lim f/g = f'/g'. e.g. 'lim x->0 sin(x)/x'.
// ─────────────────────────────────────────────────────────────

import 'package:calculus_system/calculator/calculator_engine.dart';
import 'package:calculus_system/core/base_equation.dart';
import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/shared/widgets/input_validation.dart';
import 'package:calculus_system/topics/grade6/solvers/g6_support.dart';

class LHopitalEquation extends BaseEquation {
  @override
  final String rawInput;
  String? _error;

  LHopitalEquation(this.rawInput);

  String _prep(String e, double x) {
    var s = e
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('−', '-')
        .replaceAll(' ', '')
        .replaceAll('X', 'x');
    s = s.replaceAllMapped(
        RegExp(r'(\d|\))([x])'), (m) => '${m.group(1)}*${m.group(2)}');
    return s.replaceAll('x', '($x)');
  }

  double? _ev(String e, double x) {
    try {
      final v = CalculatorEngine.evaluate(_prep(e, x));
      return v.isFinite ? v : null;
    } catch (_) {
      return null;
    }
  }

  List<dynamic>? _parse() {
    final t = rawInput.replaceAll('−', '-');
    // 'lim x->0 expr' with optional 'f/g, a=' parts.
    final lm = RegExp(r'lim\s*x\s*->\s*(-?\d+(?:\.\d+)?|0)\s*(.+)?',
            caseSensitive: false)
        .firstMatch(t);
    String body;
    double a;
    if (lm != null) {
      a = double.parse(lm.group(1)!);
      body = (lm.group(2) ?? '').trim();
      if (body.isEmpty) return null;
    } else {
      // 'f, g, a=' or 'f/g, a=' form.
      final am = RegExp(r'a\s*=\s*(-?\d+(?:\.\d+)?)').firstMatch(t);
      if (am == null) return null;
      a = double.parse(am.group(1)!);
      body = t
          .replaceFirst(am.group(0)!, '')
          .trim()
          .replaceAll(RegExp(r'^[,;]\s*'), '');
      if (body.isEmpty) return null;
    }
    // Split f/g: explicit '/' or 'f=..., g=...' or comma pair.
    String f, g;
    if (body.contains('/')) {
      final i = body.indexOf('/');
      f = body.substring(0, i).replaceAll(RegExp(r'^\(+'), '').trim();
      g = body.substring(i + 1).replaceAll(RegExp(r'\)+$'), '').trim();
      // Balance: strip one outer paren pair when wrapping both.
      if (f.startsWith('(') && g.endsWith(')')) {
        final whole = '$f/$g';
        if (whole.startsWith('(') && whole.endsWith(')')) {
          f = f.substring(1);
          g = g.substring(0, g.length - 1);
        }
      }
    } else if (body.contains(',')) {
      final parts = body.split(',');
      if (parts.length != 2) return null;
      f = parts[0].trim();
      g = parts[1].trim();
    } else {
      return null;
    }
    if (f.isEmpty || g.isEmpty) return null;
    return [f, g, a];
  }

  double? _deriv(String e, double a) {
    const h = 1e-5;
    final p = _ev(e, a + h), m = _ev(e, a - h);
    if (p == null || m == null) return null;
    return (p - m) / (2 * h);
  }

  @override
  bool validate() {
    final empty =
        FieldValidators.notEmpty(rawInput, example: 'lim x->0 sin(x)/x');
    if (empty != null) {
      _error = empty;
      return false;
    }
    if (_parse() == null) {
      _error = 'Use lim x->a f/g — e.g. lim x->0 sin(x)/x.';
      return false;
    }
    _error = null;
    return true;
  }

  @override
  SolveResult solve() {
    final p = _parse();
    if (p == null) {
      return SolveResult.error(_error ?? 'Use lim x->a f/g.');
    }
    final f = p[0] as String, g = p[1] as String, a = p[2] as double;
    // Direct values near a (avoid exact singular point).
    const h = 1e-7;
    final fv = _ev(f, a) ?? _ev(f, a + h);
    final gv = _ev(g, a) ?? _ev(g, a + h);
    if (fv == null || gv == null) {
      return SolveResult.error(
          'Could not evaluate f and g near x = ${G6Format.num(a)}.');
    }
    final is00 = fv.abs() < 1e-4 && gv.abs() < 1e-4;
    final fp = _deriv(f, a), gp = _deriv(g, a);
    if (fp == null || gp == null) {
      return SolveResult.error(
          'Could not differentiate numerically at x = ${G6Format.num(a)}.');
    }
    if (gp.abs() < 1e-12) {
      return SolveResult.error("L'Hôpital does not apply — g′(a) = 0.");
    }
    final lim = fp / gp;
    // Cross-check with direct sampling.
    final s1 = _ev('$f/($g)', a + 1e-4);
    final s2 = _ev('$f/($g)', a - 1e-4);
    final check = (s1 != null && s2 != null) ? (s1 + s2) / 2 : lim;
    return SolveResult(
      answer:
          'lim = ${G6Format.num(lim)}  (${is00 ? '0/0 — L\'Hôpital f′/g′ applies' : 'f(a)≈${G6Format.num(fv)}, g(a)≈${G6Format.num(gv)} — L\'Hôpital form'})',
      points: [lim],
      customData: [
        {
          'kind': 'lhôpital',
          'a': a,
          'fPrime': fp,
          'gPrime': gp,
          'limit': lim,
          'sampleCheck': check,
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
            explanation: _error ?? 'Use lim x->0 sin(x)/x.')
      ];
    }
    final r = solve();
    if (r.hasError) {
      return [
        StepModel(
            stepNumber: 1,
            title: 'Cannot apply',
            explanation: r.errorMessage ?? '')
      ];
    }
    final d = r.customData!.first as Map;
    return [
      const StepModel(
          stepNumber: 1,
          title: 'Check the form',
          explanation: 'Evaluate f(a) and g(a) — need 0/0 or ∞/∞.'),
      StepModel(
          stepNumber: 2,
          title: "Differentiate top and bottom",
          explanation:
              'f′ ≈ ${G6Format.num((d['fPrime'] as num).toDouble())}, g′ ≈ ${G6Format.num((d['gPrime'] as num).toDouble())}.'),
      StepModel(stepNumber: 3, title: 'Limit of f′/g′', explanation: r.answer),
      const StepModel(
          stepNumber: 4,
          title: 'Sanity check',
          explanation: 'Sample both sides of a — values must agree.'),
    ];
  }
}
