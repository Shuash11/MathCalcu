// ─────────────────────────────────────────────────────────────
// TRIG IDENTITY — PreCalc. Proof-step outline for common identities
// + numeric verification. e.g. 'prove sin^2+cos^2=1'. Never throws.
// ─────────────────────────────────────────────────────────────

import 'dart:math' as math;
import 'package:calculus_system/core/base_equation.dart';
import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/shared/widgets/input_validation.dart';

class TrigIdentityEquation extends BaseEquation {
  @override
  final String rawInput;
  String? _error;

  TrigIdentityEquation(this.rawInput);

  static const _known = <String, List<String>>{
    'pythagorean': [
      'Start with sin²θ + cos²θ on the unit circle (x = cos θ, y = sin θ).',
      'x² + y² = 1 for every point on the unit circle.',
      'Therefore sin²θ + cos²θ = 1. ∎',
    ],
    'tangent': [
      'Write tan θ as sin θ / cos θ.',
      'sin²θ + cos²θ = 1 (Pythagorean).',
      'Divide by cos²θ: tan²θ + 1 = sec²θ. ∎',
    ],
    'double-angle-sin': [
      'Rotate by θ twice: sin(α + β) = sin α cos β + cos α sin β.',
      'Set α = β = θ.',
      'sin 2θ = 2 sin θ cos θ. ∎',
    ],
    'double-angle-cos': [
      'cos(α + β) = cos α cos β − sin α sin β.',
      'Set α = β = θ: cos 2θ = cos²θ − sin²θ.',
      'Forms: 2cos²θ − 1, or 1 − 2sin²θ. ∎',
    ],
    'reciprocal': [
      'Definitions: sec θ = 1/cos θ, csc θ = 1/sin θ, cot θ = 1/tan θ.',
      'Substitute and simplify each side.',
      'Both sides match. ∎',
    ],
    'quotient': [
      'Write tan θ = sin θ / cos θ and cot θ = cos θ / sin θ.',
      'Substitute and cancel common factors.',
      'Both sides match. ∎',
    ],
  };

  String _norm() => rawInput
      .toLowerCase()
      .replaceAll(' ', '')
      .replaceAll('²', '^2')
      .replaceAll('θ', 't')
      .replaceAll('prove:', '')
      .replaceAll('prove', '');

  String? _match() {
    final t = _norm();
    if (t.contains('sin^2') && t.contains('cos^2') && t.contains('=1')) {
      return 'pythagorean';
    }
    if (t.contains('tan^2') && t.contains('sec^2')) return 'tangent';
    if (t.contains('sin2') && t.contains('2sin')) return 'double-angle-sin';
    if (t.contains('cos2')) return 'double-angle-cos';
    if (t.contains('sec') || t.contains('csc') || t.contains('cot')) {
      return 'reciprocal';
    }
    if (t.contains('tan') && t.contains('sin') && t.contains('cos')) {
      return 'quotient';
    }
    return null;
  }

  double? _evalSide(String expr, double th) {
    // Tiny evaluator for sin/cos/tan/sec/csc/cot with ^2 and numbers.
    try {
      var e = expr;
      e = e.replaceAll('sin', 's');
      // Protect csc/sec before replacing.
      e = e.replaceAll('csc', 'C');
      e = e.replaceAll('sec', 'S');
      e = e.replaceAll('cot', 'T');
      e = e.replaceAll('cos', 'c');
      e = e.replaceAll('tan', 'n');
      double val(String tok) {
        if (tok == 's') return math.sin(th);
        if (tok == 'c') return math.cos(th);
        if (tok == 'n') return math.tan(th);
        if (tok == 'S') return 1 / math.cos(th);
        if (tok == 'C') return 1 / math.sin(th);
        if (tok == 'T') return 1 / math.tan(th);
        return double.parse(tok);
      }

      // Handle func^2 and func(t) / func t patterns simply.
      final tokens = RegExp(r'[sScCnT]|t|-?\d+(?:\.\d+)?|[+*/^()-]')
          .allMatches(e)
          .map((m) => m.group(0)!)
          .toList();
      // Shunting-yard lite: convert to RPN with ^ right-assoc.
      double calc(List<String> toks) {
        var pos = 0;
        late double Function() parseExpr, parseTerm, parsePow, parseAtom;
        parseExpr = () {
          var v = parseTerm();
          while (pos < toks.length && (toks[pos] == '+' || toks[pos] == '-')) {
            final op = toks[pos++];
            final r = parseTerm();
            v = op == '+' ? v + r : v - r;
          }
          return v;
        };

        parseTerm = () {
          var v = parsePow();
          while (pos < toks.length && (toks[pos] == '*' || toks[pos] == '/')) {
            final op = toks[pos++];
            final r = parsePow();
            v = op == '*' ? v * r : v / r;
          }
          return v;
        };

        parsePow = () {
          var v = parseAtom();
          if (pos < toks.length && toks[pos] == '^') {
            pos++;
            final r = parsePow();
            v = math.pow(v, r).toDouble();
          }
          return v;
        };

        parseAtom = () {
          if (toks[pos] == '(') {
            pos++;
            final v = parseExpr();
            pos++; // ')'
            return v;
          }
          if (toks[pos] == 't') {
            pos++;
            return th;
          }
          if (RegExp(r'^[sScCnT]$').hasMatch(toks[pos])) {
            final f = toks[pos++];
            // Optional (t) wrapper.
            if (pos < toks.length && toks[pos] == '(') {
              pos += 2; // '(' 't'
              pos++; // ')'
            } else if (pos < toks.length && toks[pos] == 't') {
              pos++;
            }
            return val(f);
          }
          return double.parse(toks[pos++]);
        };

        return parseExpr();
      }

      return calc(tokens);
    } catch (_) {
      return null;
    }
  }

  @override
  bool validate() {
    final empty =
        FieldValidators.notEmpty(rawInput, example: 'prove: sin^2 + cos^2 = 1');
    if (empty != null) {
      _error = empty;
      return false;
    }
    if (!rawInput.contains('=')) {
      _error = 'Write an identity with = — e.g. prove: sin^2 + cos^2 = 1.';
      return false;
    }
    _error = null;
    return true;
  }

  @override
  SolveResult solve() {
    if (!rawInput.contains('=')) {
      return SolveResult.error(_error ?? 'Write an identity with = sign.');
    }
    final sides = _norm().split('=');
    if (sides.length != 2 || sides.any((s) => s.isEmpty)) {
      return SolveResult.error('Need LHS = RHS — e.g. sin^2+cos^2 = 1.');
    }
    // Numeric check at 5 sample angles.
    var okCount = 0;
    var checked = 0;
    for (final th in [0.3, 0.7, 1.1, 2.0, 2.6]) {
      final l = _evalSide(sides[0], th);
      final r = _evalSide(sides[1], th);
      if (l == null || r == null || !l.isFinite || !r.isFinite) continue;
      checked++;
      if ((l - r).abs() < 1e-6) okCount++;
    }
    final key = _match();
    if (checked > 0 && okCount < checked) {
      return SolveResult.error(
          'Not an identity — sides differ at sample angles ($okCount/$checked match).');
    }
    if (key == null) {
      if (checked == 0) {
        return SolveResult.error(
            'Could not verify — keep to sin/cos/tan/sec/csc/cot with numeric angles.');
      }
      return SolveResult(
        answer:
            'Verified numerically at $okCount/$checked sample angles (no named proof template).',
        points: const [],
        customData: [
          {'kind': 'identity', 'template': 'numeric', 'matches': okCount}
        ],
      );
    }
    return SolveResult(
      answer: 'Identity holds — ${_known[key]!.last}',
      points: const [],
      customData: [
        {'kind': 'identity', 'template': key, 'steps': _known[key]}
      ],
    );
  }

  @override
  List<StepModel> getSteps() {
    final r = solve();
    if (r.hasError) {
      return [
        StepModel(
            stepNumber: 1,
            title: 'Check failed',
            explanation: r.errorMessage ?? '')
      ];
    }
    final data = r.customData!.first as Map;
    final steps = (data['steps'] as List?)?.cast<String>() ??
        ['Both sides agree at sample angles.'];
    return [
      for (var i = 0; i < steps.length; i++)
        StepModel(
            stepNumber: i + 1,
            title: i == steps.length - 1 ? 'Conclusion' : 'Step ${i + 1}',
            explanation: steps[i]),
    ];
  }
}
