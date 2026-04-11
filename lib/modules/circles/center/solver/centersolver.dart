// lib/Solver/center_solver.dart

/// Immutable fraction with exact arithmetic.
class Fraction {
  final int numerator;
  final int denominator;
  final bool isNegative;

  const Fraction._(this.numerator, this.denominator, this.isNegative)
      : assert(denominator > 0, 'Denominator must be positive');

  factory Fraction(int num, int den) {
    if (den == 0) throw ArgumentError('Denominator cannot be zero');
    if (num == 0) return const Fraction._(0, 1, false);

    final isNeg = (num < 0) != (den < 0);
    final n = num.abs();
    final d = den.abs();
    final g = _gcd(n, d);

    return Fraction._(n ~/ g, d ~/ g, isNeg);
  }

  static Fraction? parse(String text) {
    text = text.trim().replaceAll(' ', '');
    if (text.isEmpty) return null;

    final intParse = int.tryParse(text);
    if (intParse != null) return Fraction(intParse, 1);

    if (text.contains('.')) {
      final isNeg = text.startsWith('-');
      text = text.replaceFirst('-', '').replaceFirst('+', '');

      final parts = text.split('.');
      if (parts.length != 2) return null;

      final whole = parts[0].isEmpty ? 0 : (int.tryParse(parts[0]) ?? 0);
      final decimal = parts[1];
      if (decimal.isEmpty) return Fraction(isNeg ? -whole : whole, 1);

      final den = _pow10(decimal.length);
      final num = whole * den + (int.tryParse(decimal) ?? 0);

      return Fraction(isNeg ? -num : num, den);
    }

    if (text.contains('/')) {
      final parts = text.split('/');
      if (parts.length != 2) return null;

      final num = int.tryParse(parts[0]);
      final den = int.tryParse(parts[1]);
      if (num == null || den == null || den == 0) return null;

      return Fraction(num, den);
    }

    return null;
  }

  Fraction operator +(Fraction other) {
    final num = (isNegative ? -numerator : numerator) * other.denominator +
        (other.isNegative ? -other.numerator : other.numerator) * denominator;
    return Fraction(num, denominator * other.denominator);
  }

  Fraction operator /(int n) {
    if (n == 0) throw ArgumentError('Cannot divide by zero');
    final newNum = isNegative ? -numerator : numerator;
    return Fraction(newNum, denominator * n.abs());
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Fraction) return false;
    return numerator == other.numerator &&
        denominator == other.denominator &&
        isNegative == other.isNegative;
  }

  @override
  int get hashCode => Object.hash(numerator, denominator, isNegative);

  static int _gcd(int a, int b) {
    while (b != 0) {
      final t = b;
      b = a % b;
      a = t;
    }
    return a;
  }

  static int _pow10(int n) {
    var result = 1;
    for (var i = 0; i < n; i++) {
      result *= 10;
    }
    return result;
  }
}

class CenterResult {
  final Fraction h;
  final Fraction k;
  final String steps;

  const CenterResult({required this.h, required this.k, required this.steps});

  /// Exact fraction form: "7/2" or "3"
  String get hExact => h.toString();
  String get kExact => k.toString();

  /// Approximate decimal: "3.5" or "3.0000" → "3"
  String get hApprox => _decimalApprox(h);
  String get kApprox => _decimalApprox(k);

  static String _decimalApprox(Fraction f) {
    final d = f.toDouble();

    // Whole number
    if (f.isWhole) return d.toInt().toString();

    // Find minimal decimal representation
    if ((d * 10).round() / 10 == d) return d.toStringAsFixed(1);
    if ((d * 100).round() / 100 == d) return d.toStringAsFixed(2);
    if ((d * 1000).round() / 1000 == d) return d.toStringAsFixed(3);

    return d
        .toStringAsFixed(4)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }
}

class CenterSolver {
  static CenterResult? computeExact({
    required String x1,
    required String y1,
    required String x2,
    required String y2,
  }) {
    final fx1 = Fraction.parse(x1);
    final fy1 = Fraction.parse(y1);
    final fx2 = Fraction.parse(x2);
    final fy2 = Fraction.parse(y2);

    if (fx1 == null || fy1 == null || fx2 == null || fy2 == null) {
      return null;
    }

    if (fx1.toDouble() == fx2.toDouble() && fy1.toDouble() == fy2.toDouble()) {
      return null;
    }

    final h = (fx1 + fx2) / 2;
    final k = (fy1 + fy2) / 2;

    final steps = _buildSteps(fx1, fy1, fx2, fy2, h, k);

    return CenterResult(h: h, k: k, steps: steps);
  }

  static String _fmt(Fraction f) {
    if (f.isWhole) return f.toString();

    final d = f.toDouble();

    if ((d * 10).round() / 10 == d) return d.toStringAsFixed(1);
    if ((d * 100).round() / 100 == d) return d.toStringAsFixed(2);
    if ((d * 1000).round() / 1000 == d) return d.toStringAsFixed(3);

    return d
        .toStringAsFixed(4)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  static String _buildSteps(
    Fraction x1,
    Fraction y1,
    Fraction x2,
    Fraction y2,
    Fraction h,
    Fraction k,
  ) {
    final sumX = x1 + x2;
    final sumY = y1 + y2;

    return 'Midpoint Formula: C(h, k) = ((x₁ + x₂)/2, (y₁ + y₂)/2)\n'
        '\n'
        'h = (x₁ + x₂) / 2\n'
        'h = ($x1 + $x2) / 2\n'
        'h = $sumX / 2\n'
        'h = ${h.toString()}${_showApprox(h)}\n'
        '\n'
        'k = (y₁ + y₂) / 2\n'
        'k = ($y1 + $y2) / 2\n'
        'k = $sumY / 2\n'
        'k = ${k.toString()}${_showApprox(k)}';
  }

  static String _showApprox(Fraction f) {
    if (f.isWhole) return '';
    return ' ≈ ${_fmt(f)}';
  }
}
