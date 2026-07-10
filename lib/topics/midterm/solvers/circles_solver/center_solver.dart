// ═════════════════════════════════════════════════════════════
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
