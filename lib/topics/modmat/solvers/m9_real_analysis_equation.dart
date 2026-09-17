// ─────────────────────────────────────────────────────────────
// M9 REAL ANALYSIS — limits of sequences a(n) as n → ∞ for rational
// functions, e.g. 'lim (2n+1)/(n+3)', 'lim 1/n', 'lim 5'.
// Offline, pure Dart. Never throws.
// ─────────────────────────────────────────────────────────────

import 'package:calculus_system/core/base_equation.dart';
import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/shared/widgets/input_validation.dart';

/// Limit-at-infinity solver via leading-degree comparison.
class M9RealAnalysisEquation extends BaseEquation {
  @override
  final String rawInput;
  String? _error;

  M9RealAnalysisEquation(this.rawInput);

  String _norm() =>
      rawInput.replaceAll('−', '-').replaceAll(' ', '').toLowerCase();

  /// Splits 'lim <expr>' body.
  String? _body() {
    final t = _norm();
    final m =
        RegExp(r'^(lim|limit)(n->inf|n→inf|asn->inf)?(.*)$').firstMatch(t);
    if (m == null) return null;
    var body = m.group(3)!;
    body = body.replaceAll(RegExp(r'^(asn->inf|n->inf|n→∞)+'), '');
    if (body.startsWith('as')) body = body.replaceFirst(RegExp(r'^as'), '');
    if (body.startsWith('(') && body.endsWith(')') && body.isNotEmpty) {
      var depth = 0;
      var wraps = true;
      for (var i = 0; i < body.length; i++) {
        if (body[i] == '(') depth++;
        if (body[i] == ')') depth--;
        if (depth == 0 && i < body.length - 1) {
          wraps = false;
          break;
        }
      }
      if (wraps) body = body.substring(1, body.length - 1);
    }
    return body.isEmpty ? null : body;
  }

  /// Parses a polynomial in n into {degree: coeff}.
  /// Supports terms like 3n^2, -n, 5, +2.5n.
  static Map<int, double>? _poly(String s) {
    if (s.isEmpty) return null;
    var t = s;
    if (!t.startsWith('+') && !t.startsWith('-')) t = '+$t';
    final termRe = RegExp(r'[+-](?:[^+-]+)');
    final terms = termRe.allMatches(t).map((m) => m.group(0)!).toList();
    if (terms.join() != t) return null;
    final out = <int, double>{};
    for (final term in terms) {
      final sign = term.startsWith('-') ? -1.0 : 1.0;
      final body = term.substring(1);
      if (body.isEmpty) return null;
      if (!body.contains('n')) {
        final c = double.tryParse(body);
        if (c == null || !c.isFinite) return null;
        out[0] = (out[0] ?? 0) + sign * c;
        continue;
      }
      final m = RegExp(r'^(\d*(?:\.\d+)?)\*?n(?:\^(\d+))?$').firstMatch(body);
      if (m == null) return null;
      final coeffStr = m.group(1)!;
      final coeff = coeffStr.isEmpty ? 1.0 : double.parse(coeffStr);
      final deg = m.group(2) == null ? 1 : int.parse(m.group(2)!);
      out[deg] = (out[deg] ?? 0) + sign * coeff;
    }
    out.removeWhere((_, v) => v == 0);
    return out.isEmpty ? {0: 0.0} : out;
  }

  /// Returns [numPoly, denPoly-or-null].
  List<dynamic>? _parse() {
    final body = _body();
    if (body == null) return null;
    final slash = _topSlash(body);
    if (slash < 0) {
      final p = _poly(body);
      return p == null ? null : [p, null];
    }
    final num = _poly(_strip(body.substring(0, slash)));
    final den = _poly(_strip(body.substring(slash + 1)));
    if (num == null || den == null) return null;
    if (den.length == 1 && den.containsKey(0) && den[0] == 0) return null;
    return [num, den];
  }

  /// Strips one layer of wrapping parens, e.g. '(2n+1)' → '2n+1'.
  static String _strip(String s) {
    var t = s.trim();
    while (t.length >= 2 && t.startsWith('(') && t.endsWith(')')) {
      var depth = 0;
      var wraps = true;
      for (var i = 0; i < t.length; i++) {
        if (t[i] == '(') depth++;
        if (t[i] == ')') depth--;
        if (depth == 0 && i < t.length - 1) {
          wraps = false;
          break;
        }
      }
      if (!wraps) break;
      t = t.substring(1, t.length - 1).trim();
    }
    return t;
  }

  static int _topSlash(String s) {
    var depth = 0;
    for (var i = 0; i < s.length; i++) {
      if (s[i] == '(') depth++;
      if (s[i] == ')') depth--;
      if (s[i] == '/' && depth == 0) return i;
    }
    return -1;
  }

  static int _deg(Map<int, double> p) =>
      p.keys.fold(0, (a, b) => a > b ? a : b);

  @override
  bool validate() {
    final empty =
        FieldValidators.notEmpty(rawInput, example: 'lim (2n+1)/(n+3)');
    if (empty != null) {
      _error = empty;
      return false;
    }
    if (_parse() == null) {
      _error = 'Use lim <poly>[/<poly>] in n — e.g. lim (2n+1)/(n+3).';
      return false;
    }
    _error = null;
    return true;
  }

  @override
  SolveResult solve() {
    final p = _parse();
    if (p == null) {
      return SolveResult.error(_error ?? 'Use lim (2n+1)/(n+3).');
    }
    final num = p[0] as Map<int, double>;
    final den = p[1] as Map<int, double>?;
    if (den == null) {
      final d = _deg(num);
      if (d == 0) {
        final v = num[0]!;
        return SolveResult(
          answer: 'lim = ${_fmt(v)} (constant sequence converges to itself)',
          points: [v],
          customData: [
            {'kind': 'sequence-limit', 'value': 'constant', 'limit': v}
          ],
        );
      }
      final lead = num[d]!;
      final sign = lead > 0 ? '+∞' : '−∞';
      return SolveResult(
        answer:
            'lim = $sign (degree $d polynomial, leading coeff ${_fmt(lead)})',
        points: [lead > 0 ? double.infinity : double.negativeInfinity],
        customData: [
          {'kind': 'sequence-limit', 'value': 'infinite', 'sign': sign}
        ],
      );
    }
    final dn = _deg(num);
    final dd = _deg(den);
    if (dn < dd) {
      return SolveResult(
        answer: 'lim = 0 (denominator degree $dd beats numerator degree $dn)',
        points: [0.0],
        customData: [
          {'kind': 'sequence-limit', 'value': 'zero', 'limit': 0.0}
        ],
      );
    }
    if (dn > dd) {
      final sign = (num[dn]! / den[dd]!) > 0 ? '+∞' : '−∞';
      return SolveResult(
        answer:
            'lim = $sign (numerator degree $dn beats denominator degree $dd)',
        points: [sign == '+∞' ? double.infinity : double.negativeInfinity],
        customData: [
          {'kind': 'sequence-limit', 'value': 'infinite', 'sign': sign}
        ],
      );
    }
    final v = num[dn]! / den[dd]!;
    return SolveResult(
      answer: 'lim = ${_fmt(v)} (ratio of leading coefficients)',
      points: [v],
      customData: [
        {'kind': 'sequence-limit', 'value': 'finite', 'limit': v}
      ],
    );
  }

  static String _fmt(double v) {
    if (v == v.roundToDouble() && v.abs() < 1e12) return v.toInt().toString();
    return v
        .toStringAsFixed(4)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  @override
  List<StepModel> getSteps() {
    final p = _parse();
    if (p == null) {
      return [
        StepModel(
            stepNumber: 1,
            title: 'Invalid input',
            explanation: _error ?? 'Use lim (2n+1)/(n+3).')
      ];
    }
    final r = solve();
    return [
      const StepModel(
          stepNumber: 1,
          title: 'Compare degrees',
          explanation: 'deg(num) vs deg den: lower → 0, '
              'equal → leading-coeff ratio, higher → ±∞.'),
      const StepModel(
          stepNumber: 2,
          title: 'Divide by the top power',
          explanation: 'Divide num and den by n^max so vanishing terms → 0.'),
      StepModel(
          stepNumber: 3,
          title: 'Read the limit',
          explanation: r.hasError ? (r.errorMessage ?? '') : r.answer),
    ];
  }
}
