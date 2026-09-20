// ─────────────────────────────────────────────────────────────
// INTEGRATION BY PARTS (LIATE) — calculus/finals.
// Product patterns ∫ k*x*f(x) dx where f ∈ {ln(x), e^x, sin(x), cos(x)}.
// One responsibility: match the by-parts shape and return the
// antiderivative + rule label. The promoted SHS engine stays untouched
// (G12/College also uses it).
// ─────────────────────────────────────────────────────────────

import 'package:calculus_system/topics/grade6/solvers/g6_support.dart';

/// A matched by-parts result: the antiderivative string and the rule label.
class ByPartsResult {
  final String antiderivative;
  final String rule;

  const ByPartsResult(this.antiderivative, this.rule);
}

/// One signed term: coefficient [c] on monomial [mono] (e.g. 'x^2 ln(x)').
class _Term {
  final String mono;
  final double c;

  const _Term(this.mono, this.c);
}

/// LIATE product-pattern matchers for ∫ k*x*f(x) dx.
///
/// [f] is the normalized integrand: no spaces, '−' folded to '-', 'X'
/// folded to 'x', and 'int' / 'dx' already stripped (e.g. 'x*ln(x)',
/// '2xsin(x)', 'xe^x').
class ByPartsIntegration {
  final String f;

  ByPartsIntegration(this.f);

  /// Returns the by-parts result for [f], or null when no LIATE
  /// product pattern matches (caller falls back to u-sub).
  ByPartsResult? solve() {
    final ln = RegExp(r'^([+-]?\d+(?:\.\d+)?)?\*?x\*?ln\(x\)$').firstMatch(f);
    if (ln != null) {
      final k = _k(ln);
      // ∫k·x·ln(x) dx = (k/2)·x²·ln(x) − (k/4)·x² + C
      return _result([
        _Term('x^2 ln(x)', k / 2),
        _Term('x^2', -k / 4),
      ]);
    }
    final exp = RegExp(r'^([+-]?\d+(?:\.\d+)?)?\*?x\*?e\^x$').firstMatch(f);
    if (exp != null) {
      final k = _k(exp);
      // ∫k·x·e^x dx = k(x − 1)e^x + C
      return _result([_Term('(x - 1)e^x', k)]);
    }
    final sin = RegExp(r'^([+-]?\d+(?:\.\d+)?)?\*?x\*?sin\(x\)$').firstMatch(f);
    if (sin != null) {
      final k = _k(sin);
      // ∫k·x·sin(x) dx = −k·x·cos(x) + k·sin(x) + C
      return _result([
        _Term('x cos(x)', -k),
        _Term('sin(x)', k),
      ]);
    }
    final cos = RegExp(r'^([+-]?\d+(?:\.\d+)?)?\*?x\*?cos\(x\)$').firstMatch(f);
    if (cos != null) {
      final k = _k(cos);
      // ∫k·x·cos(x) dx = k·x·sin(x) + k·cos(x) + C
      return _result([
        _Term('x sin(x)', k),
        _Term('cos(x)', k),
      ]);
    }
    return null;
  }

  /// Leading coefficient k of k*x*f(x) from the optional group 1.
  double _k(RegExpMatch m) {
    final g = m.group(1);
    return (g == null || g.isEmpty) ? 1.0 : double.parse(g);
  }

  ByPartsResult _result(List<_Term> terms) =>
      ByPartsResult(_join(terms), 'integration by parts (LIATE)');

  /// Joins signed terms into 'a - b + C' / 'a + b + C' style.
  String _join(List<_Term> terms) {
    final sb = StringBuffer();
    for (var i = 0; i < terms.length; i++) {
      final t = terms[i];
      final neg = t.c < 0;
      if (i == 0) {
        if (neg) sb.write('-');
      } else {
        sb.write(neg ? ' - ' : ' + ');
      }
      sb.write(_mono(t.mono, t.c.abs()));
    }
    sb.write(' + C');
    return sb.toString();
  }

  /// Renders [c]·[mono] readably: 'x^2/2 ln(x)' for c = 0.5 on a leading
  /// x^2, the bare monomial for c = 1, else a decimal coefficient
  /// ('0.7x^2') matching the SHS display convention.
  String _mono(String mono, double c) {
    if (mono.startsWith('x^2')) {
      final rest = mono.substring(3); // already carries the separator space
      if (_eq(c, 0.25)) return 'x^2/4$rest';
      if (_eq(c, 0.5)) return 'x^2/2$rest';
    }
    if (_eq(c, 1)) return mono;
    return '${G6Format.num(c)}$mono';
  }

  bool _eq(double a, double b) => (a - b).abs() < 1e-12;
}
