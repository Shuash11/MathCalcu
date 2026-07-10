// ═════════════════════════════════════════════════════════════
// CENTER-RADIUS FORM SOLVER  (generated via SymPy)
// ─────────────────────────────────────────────────────────────
// Converts between center-radius form (x-h)²+(y-k)²=r² and
// general form x²+y²+Dx+Ey+F=0 via completing the square.
//
// Also parses general form equation strings.
// ═════════════════════════════════════════════════════════════

import 'dart:math' show sqrt;

// ── Models ────────────────────────────────────────────────────────────

class SolverStep {
  final String label;
  final String equation;
  final List<String> subLines;
  final bool isFinal;
  final bool arrow;
  final SolverColors? color;

  const SolverStep({
    required this.label,
    required this.equation,
    this.subLines = const [],
    this.isFinal = false,
    this.arrow = false,
    this.color,
  });
}

enum SolverColors { teal, cyan }

class GeneralFormResult {
  final double D, E, F;
  const GeneralFormResult({required this.D, required this.E, required this.F});
}

// ── Formatter helpers ─────────────────────────────────────────────────

String _fmt(double v) {
  if (v == v.truncateToDouble()) return v.truncate().toString();
  return v.toStringAsFixed(3).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
}

String _signed(double v, {bool leading = false}) {
  if (leading) return _fmt(v);
  if (v >= 0) return '+ ${_fmt(v)}';
  return '- ${_fmt(v.abs())}';
}

// ── General Form Parser ────────────────────────────────────────────────

class GeneralFormParser {
  static GeneralFormResult parse(String raw) {
    String input = raw
        .toLowerCase().trim()
        .replaceAll('²', '2').replaceAll('\u00B2', '2')
        .replaceAll('−', '-').replaceAll('–', '-').replaceAll('—', '-')
        .replaceAll('\u2212', '-').replaceAll('\u2013', '-').replaceAll('\u2014', '-')
        .replaceAll('×', '').replaceAll('·', '').replaceAll('\u00D7', '').replaceAll('\u00B7', '').replaceAll('*', '')
        .replaceAll(RegExp(r'x\s*\^\s*2'), 'x2').replaceAll(RegExp(r'y\s*\^\s*2'), 'y2')
        .replaceAll(RegExp(r'x\s*2'), 'x2').replaceAll(RegExp(r'y\s*2'), 'y2')
        .replaceAll(' ', '');

    input = input.replaceAllMapped(
      RegExp(r'\((\d+(?:\.\d+)?)\/(\d+(?:\.\d+)?)\)'),
      (m) => (double.parse(m.group(1)!) / double.parse(m.group(2)!)).toString(),
    );

    final sides = input.split('=');
    String lhs = sides[0];
    String rhs = sides.length > 1 ? sides[1] : '0';

    if (lhs == '0') { final t = lhs; lhs = rhs; rhs = t; }

    if (rhs != '0') {
      if (!rhs.startsWith('-') && !rhs.startsWith('+')) rhs = '+$rhs';
      final flipped = rhs.replaceAll('+', '__POS__').replaceAll('-', '+').replaceAll('__POS__', '-');
      lhs += flipped;
    }

    String prev;
    int iters = 0;
    do {
      prev = lhs;
      lhs = lhs.replaceAll('+-', '-').replaceAll('-+', '-').replaceAll('--', '+').replaceAll('++', '+');
      iters++;
    } while (lhs != prev && iters < 10);

    if (!lhs.startsWith('-') && !lhs.startsWith('+')) lhs = '+$lhs';

    final tokens = <String>[];
    int start = 0;
    for (int i = 1; i < lhs.length; i++) {
      if (lhs[i] == '+' || lhs[i] == '-') { tokens.add(lhs.substring(start, i)); start = i; }
    }
    tokens.add(lhs.substring(start));

    double x2coeff = 0, y2coeff = 0, D = 0, E = 0, F = 0;
    const eps = 1e-10;

    for (final token in tokens) {
      if (token.isEmpty || token == '+' || token == '-') continue;
      final sign = token.startsWith('-') ? -1.0 : 1.0;
      final body = token.substring(1);
      if (body.isEmpty) continue;
      if (body.contains('x2')) {
        final np = body.replaceAll('x2', '');
        x2coeff += sign * (np.isEmpty ? 1.0 : (double.tryParse(np) ?? 1.0));
      } else if (body.contains('y2')) {
        final np = body.replaceAll('y2', '');
        y2coeff += sign * (np.isEmpty ? 1.0 : (double.tryParse(np) ?? 1.0));
      } else if (body.contains('x')) {
        final np = body.replaceAll('x', '');
        D += sign * (np.isEmpty ? 1.0 : (double.tryParse(np) ?? 1.0));
      } else if (body.contains('y')) {
        final np = body.replaceAll('y', '');
        E += sign * (np.isEmpty ? 1.0 : (double.tryParse(np) ?? 1.0));
      } else {
        final p = double.tryParse(body);
        if (p == null) throw FormatException('Cannot parse: "$body" in token "$token"');
        F += sign * p;
      }
    }

    if (x2coeff.abs() < eps || y2coeff.abs() < eps) {
      throw ArgumentError('Invalid: missing x² or y² term');
    }
    if ((x2coeff - y2coeff).abs() > eps) {
      throw ArgumentError('Not a circle: x²=$x2coeff ≠ y²=$y2coeff');
    }
    if ((x2coeff - 1.0).abs() > eps) {
      D /= x2coeff; E /= x2coeff; F /= x2coeff;
    }

    return GeneralFormResult(D: D, E: E, F: F);
  }
}

// ── Converter ──────────────────────────────────────────────────────────

class CircleEquationSolver {
  /// Standard -> General: (x-h)²+(y-k)²=r² -> x²+y²+Dx+Ey+F=0
  ///   D = -2h, E = -2k, F = h²+k²-r²
  static List<SolverStep> standardToGeneral({
    required double h, required double k, required double r,
  }) {
    final D = -2 * h;
    final E = -2 * k;
    final F = h * h + k * k - r * r;
    final rSq = r * r;
    final hSq = h * h;
    final kSq = k * k;

    return [
      SolverStep(label: 'Center-Radius Form', arrow: true,
        equation: '(x ${h >= 0 ? '-' : '+'} ${_fmt(h.abs())})² + (y ${k >= 0 ? '-' : '+'} ${_fmt(k.abs())})² = ${_fmt(r)}²',
        color: SolverColors.teal),
      SolverStep(label: 'Substitute r² = ${_fmt(rSq)}',
        equation: '(x ${h >= 0 ? '-' : '+'} ${_fmt(h.abs())})² + (y ${k >= 0 ? '-' : '+'} ${_fmt(k.abs())})² = ${_fmt(rSq)}'),
      SolverStep(label: 'Expand binomial squares',
        equation: 'x² ${_signed(-2 * h)}x + ${_fmt(hSq)} + y² ${_signed(-2 * k)}y + ${_fmt(kSq)} = ${_fmt(rSq)}'),
      SolverStep(label: 'Move ${_fmt(rSq)} to left',
        equation: 'x² + y² ${_signed(-2 * h)}x ${_signed(-2 * k)}y + ${_fmt(hSq + kSq - rSq)} = 0'),
      SolverStep(label: 'General Form', isFinal: true,
        equation: 'x² + y² ${_signed(D)}x ${_signed(E)}y ${_signed(F)} = 0',
        color: SolverColors.cyan),
    ];
  }

  /// General -> Standard: x²+y²+Dx+Ey+F=0 -> (x-h)²+(y-k)²=r²
  ///   h = -D/2, k = -E/2, r² = h²+k²-F
  static List<SolverStep> generalToStandard({
    required double D, required double E, required double F,
  }) {
    final h = -D / 2;
    final k = -E / 2;
    final halfD = D / 2;
    final halfE = E / 2;
    final halfDSq = halfD * halfD;
    final halfESq = halfE * halfE;
    final rSq = halfDSq + halfESq - F;

    if (rSq <= 0) throw ArgumentError('Invalid: r² = $_fmt(rSq) ≤ 0 (imaginary circle)');

    final r = sqrt(rSq);
    final rightSide = -F + halfDSq + halfESq;

    return [
      SolverStep(label: 'General Form', arrow: true,
        equation: 'x² + y² ${_signed(D)}x ${_signed(E)}y ${_signed(F)} = 0',
        color: SolverColors.teal),
      SolverStep(label: 'Group terms; move constant to right',
        equation: '(x² ${_signed(D)}x) + (y² ${_signed(E)}y) = ${_signed(-F, leading: true)}'),
      SolverStep(label: 'Complete the square:\n  x: add (${_fmt(halfD)})² = ${_fmt(halfDSq)}\n  y: add (${_fmt(halfE)})² = ${_fmt(halfESq)}',
        equation: '(x² ${_signed(D)}x ${_signed(halfDSq)}) + (y² ${_signed(E)}y ${_signed(halfESq)}) = ${_fmt(rightSide)}'),
      SolverStep(label: 'Factor as perfect squares',
        equation: '(x ${_signed(halfD)})² + (y ${_signed(halfE)})² = ${_fmt(rSq)}'),
      SolverStep(label: 'Center-Radius Form', isFinal: true,
        equation: '(x ${h >= 0 ? '-' : '+'} ${_fmt(h.abs())})² + (y ${k >= 0 ? '-' : '+'} ${_fmt(k.abs())})² = ${_fmt(r)}²',
        subLines: ['Center: (${_fmt(h)}, ${_fmt(k)})', 'Radius: r = ${_fmt(r)}'],
        color: SolverColors.cyan),
    ];
  }

  /// Convenience: parse a general form string and convert to standard
  static List<SolverStep> solveFromString(String raw) {
    final coeffs = GeneralFormParser.parse(raw);
    return generalToStandard(D: coeffs.D, E: coeffs.E, F: coeffs.F);
  }
}
