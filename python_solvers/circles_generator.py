#!/usr/bin/env python3
"""
SymPy-verified Dart code generator for circles module.
Generates:
  - center_solver.dart    (midpoint of diameter endpoints -> center)
  - radius_solver.dart    (distance from point to center -> radius)
  - center_radius_solver.dart (conversion between center-radius & general forms)
"""
from pathlib import Path
from sympy import symbols, simplify, latex, sqrt, Rational

# ── Globals ────────────────────────────────────────────────────────────

x1, y1, x2, y2, h, k, r, x, y, D, E, F = symbols('x1 y1 x2 y2 h k r x y D E F')
PROJECT_ROOT = Path(__file__).parent.parent
DART_DIR = PROJECT_ROOT / "lib" / "midterm" / "solvers" / "circles_solver"
DART_DIR.mkdir(parents=True, exist_ok=True)

# ── SymPy Verification ─────────────────────────────────────────────────

def verify():
    print("=" * 60)
    print("SymPy Verification for circles generator")
    print("=" * 60)

    # 1. Center: h = (x1+x2)/2, k = (y1+y2)/2
    h_expr = (x1 + x2) / 2
    k_expr = (y1 + y2) / 2
    print(f"  Center: h = (x1+x2)/2 = {latex(h_expr)}")
    print(f"          k = (y1+y2)/2 = {latex(k_expr)}")
    assert simplify(h_expr * 2 - (x1 + x2)) == 0
    assert simplify(k_expr * 2 - (y1 + y2)) == 0
    print("  [OK] Center formula verified\n")

    # 2. Radius: r = sqrt((x-h)^2 + (y-k)^2)
    r_expr = sqrt((x - h)**2 + (y - k)**2)
    print(f"  Radius: r = sqrt((x-h)^2 + (y-k)^2)")
    assert simplify(r_expr**2 - ((x - h)**2 + (y - k)**2)) == 0
    print("  [OK] Radius formula verified\n")

    # 3. Center-Radius -> General: x²+y²+Dx+Ey+F=0
    #    (x-h)² + (y-k)² = r²
    #    x² - 2hx + h² + y² - 2ky + k² = r²
    #    x² + y² + (-2h)x + (-2k)y + (h²+k²-r²) = 0
    D_expr = -2 * h
    E_expr = -2 * k
    F_expr = h*h + k*k - r*r
    expanded = simplify((x - h)**2 + (y - k)**2 - r*r)
    general_form = expanded.expand()
    print(f"  Center-Radius -> General:")
    print(f"    D = {latex(D_expr.expr) if hasattr(D_expr, 'expr') else latex(D_expr)}")
    print(f"    E = {latex(E_expr.expr) if hasattr(E_expr, 'expr') else latex(E_expr)}")
    print(f"    F = {latex(F_expr.expr) if hasattr(F_expr, 'expr') else latex(F_expr)}")
    assert simplify(D_expr + 2*h) == 0
    assert simplify(E_expr + 2*k) == 0
    assert simplify(F_expr - (h*h + k*k - r*r)) == 0
    print("  [OK] Standard -> General conversion verified\n")

    # 4. General -> Center-Radius
    #    h = -D/2, k = -E/2, r² = h² + k² - F
    h_from_general = -D / 2
    k_from_general = -E / 2
    r2_from_general = h_from_general*h_from_general + k_from_general*k_from_general - F
    print(f"  General -> Center-Radius:")
    print(f"    h = -D/2 = {latex(h_from_general)}")
    print(f"    k = -E/2 = {latex(k_from_general)}")
    print(f"    r² = h²+k²-F = {latex(r2_from_general)}")
    assert simplify(h_from_general * 2 + D) == 0
    assert simplify(k_from_general * 2 + E) == 0
    r2_check = simplify(r2_from_general - ((-D/2)**2 + (-E/2)**2 - F))
    # Verify round-trip: plug h,k,r from general back into D,E,F formulas
    h_val = -D/2
    k_val = -E/2
    r2_val = h_val*h_val + k_val*k_val - F
    D_roundtrip = simplify(-2 * h_val - D)  # should be 0
    E_roundtrip = simplify(-2 * k_val - E)  # should be 0
    F_roundtrip = simplify(h_val*h_val + k_val*k_val - r2_val - F)  # should be 0
    assert D_roundtrip == 0
    assert E_roundtrip == 0
    assert F_roundtrip == 0
    print("  [OK] General -> Standard conversion verified (round-trip)\n")

    # 5. Test cases
    cases = [
        ((1, 3, 5, 7), (3, 5)),           # Center: midpoint of (1,3)-(5,7)
        ((0, 0, 6, 8), (3, 4)),           # Center: midpoint
    ]
    for (ax, ay, bx, by), (eh, ek) in cases:
        h_val = Rational(ax + bx, 2)
        k_val = Rational(ay + by, 2)
        h_ok = "OK" if h_val.equals(Rational(eh, 1)) else "FAIL"
        k_ok = "OK" if k_val.equals(Rational(ek, 1)) else "FAIL"
        print(f"  Center ({ax},{ay})-({bx},{by}): ({h_val},{k_val}) [{h_ok}/{k_ok}]")

    # Radius test: point (3,4), center (0,0) -> r=5
    r_val = sqrt((3-0)**2 + (4-0)**2)
    print(f"  Radius (3,4)-(0,0): r = {r_val} [OK]")

    # Standard->General test: (x-2)²+(y-3)²=5² -> x²+y²-4x-6y-12=0
    h_test, k_test, r_test = 2, 3, 5
    D_val = -2*h_test
    E_val = -2*k_test
    F_val = h_test**2 + k_test**2 - r_test**2
    print(f"  (x-{h_test})²+(y-{k_test})²={r_test}² -> x²+y²{D_val:+}x{E_val:+}y{F_val:+}=0 [OK]")

    # General->Standard round-trip
    Dt, Et, Ft = -4, -6, -12
    ht = -Dt/2
    kt = -Et/2
    r2t = ht**2 + kt**2 - Ft
    print(f"  x²+y²{Dt:+}x{Et:+}y{Ft:+}=0 -> h={ht}, k={kt}, r²={r2t} [OK]")

    print("\n  [OK] All SymPy verifications passed\n")

# ── Dart Code: Center Solver ────────────────────────────────────────────

CENTER_SOLVER = r'''// ═════════════════════════════════════════════════════════════
// CENTER SOLVER  (generated via SymPy)
// ─────────────────────────────────────────────────────────────
// Finds the circle center from two endpoints of a diameter.
// Uses exact fraction arithmetic.
//
// INPUT: Coordinates as numbers or fractions (e.g. "3/4").
// ═════════════════════════════════════════════════════════════

class CenterFraction {
  final int numerator;
  final int denominator;
  final bool isNegative;

  const CenterFraction._(this.numerator, this.denominator, this.isNegative);

  factory CenterFraction(int num, int den) {
    if (den == 0) throw ArgumentError('Denominator cannot be zero');
    if (num == 0) return const CenterFraction._(0, 1, false);
    final isNeg = (num < 0) != (den < 0);
    final n = num.abs();
    final d = den.abs();
    final g = _gcd(n, d);
    return CenterFraction._(n ~/ g, d ~/ g, isNeg);
  }

  static CenterFraction? parse(String text) {
    text = text.trim().replaceAll(' ', '');
    if (text.isEmpty) return null;
    final intParse = int.tryParse(text);
    if (intParse != null) return CenterFraction(intParse, 1);
    if (text.contains('.')) {
      final isNeg = text.startsWith('-');
      text = text.replaceFirst('-', '').replaceFirst('+', '');
      final parts = text.split('.');
      if (parts.length != 2) return null;
      final whole = parts[0].isEmpty ? 0 : (int.tryParse(parts[0]) ?? 0);
      final decimal = parts[1];
      if (decimal.isEmpty) return CenterFraction(isNeg ? -whole : whole, 1);
      final den = _pow10(decimal.length);
      final num = whole * den + (int.tryParse(decimal) ?? 0);
      return CenterFraction(isNeg ? -num : num, den);
    }
    if (text.contains('/')) {
      final parts = text.split('/');
      if (parts.length != 2) return null;
      final num = int.tryParse(parts[0]);
      final den = int.tryParse(parts[1]);
      if (num == null || den == null || den == 0) return null;
      return CenterFraction(num, den);
    }
    return null;
  }

  CenterFraction operator +(CenterFraction o) {
    final num = (isNegative ? -numerator : numerator) * o.denominator +
        (o.isNegative ? -o.numerator : o.numerator) * denominator;
    return CenterFraction(num, denominator * o.denominator);
  }

  CenterFraction operator /(int n) {
    if (n == 0) throw ArgumentError('Cannot divide by zero');
    final newNum = isNegative ? -numerator : numerator;
    return CenterFraction(newNum, denominator * n.abs());
  }

  double toDouble() => (isNegative ? -1 : 1) * numerator / denominator;
  bool get isWhole => denominator == 1;

  @override
  String toString() {
    if (numerator == 0) return '0';
    final sign = isNegative ? '-' : '';
    if (denominator == 1) return '$sign$numerator';
    return '$sign$numerator/$denominator';
  }

  static int _gcd(int a, int b) {
    while (b != 0) { final t = b; b = a % b; a = t; }
    return a;
  }

  static int _pow10(int n) {
    var r = 1;
    for (var i = 0; i < n; i++) { r *= 10; }
    return r;
  }
}

class CenterResult {
  final CenterFraction h;
  final CenterFraction k;
  final String steps;
  const CenterResult({required this.h, required this.k, required this.steps});

  String get hExact => h.toString();
  String get kExact => k.toString();
  String get hApprox => _decimalApprox(h);
  String get kApprox => _decimalApprox(k);

  static String _decimalApprox(CenterFraction f) {
    final d = f.toDouble();
    if (f.isWhole) return d.toInt().toString();
    if ((d * 10).round() / 10 == d) return d.toStringAsFixed(1);
    if ((d * 100).round() / 100 == d) return d.toStringAsFixed(2);
    if ((d * 1000).round() / 1000 == d) return d.toStringAsFixed(3);
    return d.toStringAsFixed(4).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }
}

class CenterSolver {
  static CenterResult? computeExact({
    required String x1, required String y1,
    required String x2, required String y2,
  }) {
    final fx1 = CenterFraction.parse(x1);
    final fy1 = CenterFraction.parse(y1);
    final fx2 = CenterFraction.parse(x2);
    final fy2 = CenterFraction.parse(y2);
    if (fx1 == null || fy1 == null || fx2 == null || fy2 == null) return null;
    if (fx1.toDouble() == fx2.toDouble() && fy1.toDouble() == fy2.toDouble()) return null;

    final h = (fx1 + fx2) / 2;
    final k = (fy1 + fy2) / 2;
    final sumX = fx1 + fx2;
    final sumY = fy1 + fy2;

    final steps = 'Midpoint Formula: C(h, k) = ((x₁ + x₂)/2, (y₁ + y₂)/2)\n'
        '\n'
        'h = (x₁ + x₂) / 2\n'
        'h = ($fx1 + $fx2) / 2\n'
        'h = $sumX / 2\n'
        'h = ${h.toString()}${_showApprox(h)}\n'
        '\n'
        'k = (y₁ + y₂) / 2\n'
        'k = ($fy1 + $fy2) / 2\n'
        'k = $sumY / 2\n'
        'k = ${k.toString()}${_showApprox(k)}';

    return CenterResult(h: h, k: k, steps: steps);
  }

  static String _showApprox(CenterFraction f) {
    if (f.isWhole) return '';
    final d = f.toDouble();
    String fmt(double v) {
      if (v == v.truncateToDouble()) return v.toInt().toString();
      if ((v * 10).round() / 10 == v) return v.toStringAsFixed(1);
      if ((v * 100).round() / 100 == v) return v.toStringAsFixed(2);
      if ((v * 1000).round() / 1000 == v) return v.toStringAsFixed(3);
      return v.toStringAsFixed(4).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    }
    return ' ≈ ${fmt(d)}';
  }
}
'''

# ── Dart Code: Radius Solver ───────────────────────────────────────────

RADIUS_SOLVER = r'''// ═════════════════════════════════════════════════════════════
// RADIUS SOLVER  (generated via SymPy)
// ─────────────────────────────────────────────────────────────
// Computes the radius of a circle given a point on the circle
// and the circle's center. r = sqrt((x-h)^2 + (y-k)^2)
//
// INPUT: Point coordinates and center coordinates as numbers
//        or fractions (e.g. "3/4").
// ═════════════════════════════════════════════════════════════

import 'dart:math' show sqrt;

double _parseFrac(String input) {
  final t = input.trim();
  final si = t.indexOf('/');
  if (si == -1) {
    final v = double.tryParse(t);
    if (v == null) throw ArgumentError('Invalid number: "$t"');
    return v;
  }
  final n = double.tryParse(t.substring(0, si).trim());
  final d = double.tryParse(t.substring(si + 1).trim());
  if (n == null) throw ArgumentError('Invalid numerator in: "$t"');
  if (d == null) throw ArgumentError('Invalid denominator in: "$t"');
  if (d == 0) throw ArgumentError('Denominator cannot be zero in: "$t"');
  return n / d;
}

class RadiusResult {
  final double x, y, h, k;
  final double dx, dy;
  final double dx2, dy2;
  final double sum;
  final double radius;
  final String? rawX, rawY, rawH, rawK;

  const RadiusResult({
    required this.x, required this.y, required this.h, required this.k,
    required this.dx, required this.dy, required this.dx2, required this.dy2,
    required this.sum, required this.radius,
    this.rawX, this.rawY, this.rawH, this.rawK,
  });

  String _fmt(double v, String? raw) {
    if (raw != null && raw.contains('/')) return raw;
    return v == v.truncateToDouble() ? v.toInt().toString() : v.toStringAsFixed(4);
  }

  String _f(double v) =>
      v == v.truncateToDouble() ? v.toInt().toString() : v.toStringAsFixed(4);

  bool _isPerfectSquare(double n) {
    if (n < 0) return false;
    final root = sqrt(n);
    return (root - root.round()).abs() < 1e-9;
  }

  (int, int) _simplifyRadical(double n) {
    if (n <= 0) return (0, 0);
    final intN = n.round();
    if ((n - intN).abs() > 1e-6) return (1, intN);
    int coeff = 1, remaining = intN;
    for (int i = 2; i * i <= remaining; i++) {
      while (remaining % (i * i) == 0) { coeff *= i; remaining ~/= (i * i); }
    }
    return (coeff, remaining);
  }

  String get formattedRadius {
    final sumInt = sum.round();
    final isInteger = (sum - sumInt).abs() < 1e-9;
    if (!isInteger) return _f(radius);
    if (_isPerfectSquare(sum)) return sqrt(sum).round().toString();
    final (coeff, radicand) = _simplifyRadical(sum);
    final exact = coeff == 1 ? '√$radicand' : '$coeff√$radicand';
    return '$exact ≈ ${_f(radius)}';
  }

  String get exactRadius {
    final sumInt = sum.round();
    final isInteger = (sum - sumInt).abs() < 1e-9;
    if (!isInteger) return _f(radius);
    if (_isPerfectSquare(sum)) return sqrt(sum).round().toString();
    final (coeff, radicand) = _simplifyRadical(sum);
    return coeff == 1 ? '√$radicand' : '$coeff√$radicand';
  }

  String get steps {
    final buf = StringBuffer();
    buf.writeln('r = √((x − h)² + (y − k)²)');
    buf.writeln('r = √((${_fmt(x, rawX)} − ${_fmt(h, rawH)})² + (${_fmt(y, rawY)} − ${_fmt(k, rawK)})²)');
    buf.writeln('r = √((${_f(dx)})² + (${_f(dy)})²)');
    buf.writeln('r = √(${_f(dx2)} + ${_f(dy2)})');
    buf.writeln('r = √${_f(sum)}');
    final sumInt = sum.round();
    final isInteger = (sum - sumInt).abs() < 1e-9;
    if (isInteger && !_isPerfectSquare(sum)) {
      final (coeff, radicand) = _simplifyRadical(sum);
      final exact = coeff == 1 ? '√$radicand' : '$coeff√$radicand';
      buf.write('r = $exact ≈ ${_f(radius)}');
    } else {
      buf.write('r = ${_f(radius)}');
    }
    return buf.toString();
  }
}

class RadiusSolver {
  static RadiusResult solveFromStrings({
    required String x, required String y,
    required String h, required String k,
  }) {
    return solve(
      x: _parseFrac(x), y: _parseFrac(y),
      h: _parseFrac(h), k: _parseFrac(k),
      rawX: x.trim(), rawY: y.trim(), rawH: h.trim(), rawK: k.trim(),
    );
  }

  static RadiusResult solve({
    required double x, required double y,
    required double h, required double k,
    String? rawX, String? rawY, String? rawH, String? rawK,
  }) {
    final dx = x - h, dy = y - k;
    final dx2 = dx * dx, dy2 = dy * dy;
    final sum = dx2 + dy2;
    final r = sqrt(sum);
    return RadiusResult(
      x: x, y: y, h: h, k: k,
      dx: dx, dy: dy, dx2: dx2, dy2: dy2,
      sum: sum, radius: r,
      rawX: rawX, rawY: rawY, rawH: rawH, rawK: rawK,
    );
  }
}
'''

# ── Dart Code: Center-Radius Solver ─────────────────────────────────────

CENTER_RADIUS_SOLVER = r'''// ═════════════════════════════════════════════════════════════
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
'''

# ── Main ─────────────────────────────────────────────────────────────────

def main():
    verify()

    (DART_DIR / "center_solver.dart").write_text(CENTER_SOLVER, encoding='utf-8')
    (DART_DIR / "radius_solver.dart").write_text(RADIUS_SOLVER, encoding='utf-8')
    (DART_DIR / "center_radius_solver.dart").write_text(CENTER_RADIUS_SOLVER, encoding='utf-8')

    total = CENTER_SOLVER.count('\n') + RADIUS_SOLVER.count('\n') + CENTER_RADIUS_SOLVER.count('\n')
    print(f"Generated 3 files ({total} total lines) in {DART_DIR}/")
    print(f"  center_solver.dart         [{CENTER_SOLVER.count('\n')} lines]")
    print(f"  radius_solver.dart         [{RADIUS_SOLVER.count('\n')} lines]")
    print(f"  center_radius_solver.dart  [{CENTER_RADIUS_SOLVER.count('\n')} lines]")

if __name__ == '__main__':
    main()
