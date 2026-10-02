// ─────────────────────────────────────────────────────────────
// FINALS LATEX — shared plain-text → LaTeX conversion helpers
// for the Cycle 12 finals solvers (Cycle 13 Item 2).
//
// One responsibility: emit the KaTeX subset supported by
// flutter_math_fork (pinned 2f270aee) from the plain math strings
// the finals solvers produce. Never unicode ²/π/∞ inside latex
// output, and never the constructs flutter_math_fork cannot
// render (gather, Vmatrix, \hspace*, \smash, \mathchoice, \pmb).
// ─────────────────────────────────────────────────────────────

/// Plain-text → LaTeX helpers for the finals solvers.
abstract class FinalsLatex {
  FinalsLatex._();

  /// Matches a known function call, e.g. 'sin(x)' — single-level
  /// parens only (the finals inputs never nest calls).
  static final RegExp _funcRe = RegExp(r'([A-Za-z]+)\(([^()]*)\)');

  /// Matches a numeric exponent, e.g. '^2' or '^1.5'.
  static final RegExp _expRe = RegExp(r'\^([+-]?\d+(?:\.\d+)?)');

  /// Exact rational p/q for [v] (denominator ≤ 120), else null.
  static (int, int)? rational(double v) {
    for (int q = 1; q <= 120; q++) {
      final p = v * q;
      if ((p - p.round()).abs() < 1e-9) {
        final r = p.round();
        final g = _gcd(r.abs(), q);
        return (r ~/ g, q ~/ g);
      }
    }
    return null;
  }

  /// Human LaTeX number: integer, \frac{p}{q}, or decimal.
  static String num(double v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    final r = rational(v);
    if (r != null) {
      final (p, q) = r;
      final sign = p < 0 ? '-' : '';
      final ap = p.abs();
      return q == 1 ? '$sign$ap' : '$sign\\frac{$ap}{$q}';
    }
    var s = v.toStringAsFixed(6);
    s = s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    return s;
  }

  /// Converts a plain expression string (e.g. 'x*ln(x)', 'x^2+1',
  /// '2xsin(x)', 'e^x') into LaTeX: known function calls become
  /// \sin/\cos/..., numeric exponents gain braces, '*' becomes
  /// \cdot, and unicode ²/π/− are folded to LaTeX/ASCII first.
  static String expr(String input) {
    var s = input
        .replaceAll('−', '-')
        .replaceAll('²', '^2')
        .replaceAll('³', '^3')
        .replaceAll('π', r'\pi');
    s = s.replaceAllMapped(_funcRe, (m) {
      final name = m.group(1)!.toLowerCase();
      final arg = m.group(2)!;
      switch (name) {
        case 'sin':
          return '\\sin\\left($arg\\right)';
        case 'cos':
          return '\\cos\\left($arg\\right)';
        case 'tan':
          return '\\tan\\left($arg\\right)';
        case 'ln':
          return '\\ln\\left($arg\\right)';
        case 'log':
          return '\\log\\left($arg\\right)';
        case 'sqrt':
          return '\\sqrt{$arg}';
        case 'exp':
          return 'e^{$arg}';
        default:
          return '${m.group(1)}\\left($arg\\right)';
      }
    });
    s = s.replaceAllMapped(_expRe, (m) => '^{${m.group(1)}}');
    s = s.replaceAll('*', r'\cdot');
    return s;
  }

  /// Converts a coefficient·monomial antiderivative term that uses
  /// the SHS display convention for a leading x^2 (e.g. 'x^2 ln(x)'
  /// with c = 0.5 → \frac{x^{2}}{2}\ln\left(x\right)), the bare
  /// monomial for c = 1, else a decimal coefficient.
  static String mono(String mono, double c) {
    if (mono.startsWith('x^2')) {
      final rest = expr(mono.substring(3).trim());
      if (_eq(c, 0.25)) return '\\frac{x^{2}}{4}$rest';
      if (_eq(c, 0.5)) return '\\frac{x^{2}}{2}$rest';
      if (_eq(c, 1)) return 'x^{2}$rest';
      return '${num(c)}x^{2}$rest';
    }
    final body = expr(mono);
    return _eq(c, 1) ? body : '${num(c)}$body';
  }

  /// Antiderivative string produced by the SHS engine (e.g.
  /// '0.25(x^2+1)^4 + C', '0.333333x^3 + C', 'x^2/2 + C') → LaTeX:
  /// the leading decimal coefficient becomes an exact \frac where
  /// possible, and a leading x^2/d becomes \frac{x^{2}}{d}.
  static String anti(String s) {
    final body = s.replaceFirst(RegExp(r'\s*\+\s*C$'), '');
    final m = RegExp(r'^([+-]?\d+(?:\.\d+)?)(.*)$').firstMatch(body);
    var coefPart = '';
    var restPart = body;
    if (m != null) {
      coefPart = num(double.parse(m.group(1)!));
      restPart = m.group(2)!;
    }
    final frac = RegExp(r'^x\^2/(\d+)').firstMatch(restPart);
    if (frac != null) {
      restPart =
          '\\frac{x^{2}}{${frac.group(1)}}${restPart.substring(frac.end)}';
    }
    return '$coefPart${expr(restPart)} + C';
  }

  static bool _eq(double a, double b) => (a - b).abs() < 1e-12;

  static int _gcd(int a, int b) {
    while (b != 0) {
      final t = b;
      b = a % b;
      a = t;
    }
    return a;
  }
}
