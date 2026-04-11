import 'dart:math';

/// Parses a string that may be a decimal, integer, or fraction (e.g. "3/4", "-1/2").
double _parseFraction(String input) {
  final trimmed = input.trim();
  final slashIndex = trimmed.indexOf('/');
  if (slashIndex == -1) {
    final value = double.tryParse(trimmed);
    if (value == null) throw ArgumentError('Invalid number: "$trimmed"');
    return value;
  }
  final numerator = double.tryParse(trimmed.substring(0, slashIndex).trim());
  final denominator = double.tryParse(trimmed.substring(slashIndex + 1).trim());
  if (numerator == null) {
    throw ArgumentError('Invalid numerator in: "$trimmed"');
  }
  if (denominator == null) {
    throw ArgumentError('Invalid denominator in: "$trimmed"');
  }
  if (denominator == 0) {
    throw ArgumentError('Denominator cannot be zero in: "$trimmed"');
  }
  return numerator / denominator;
}

/// Pure computation — no Flutter dependency.
class RadiusSolver {
  /// Accepts raw string inputs so callers can pass fractions like "3/4".
  static RadiusResult solveFromStrings({
    required String x,
    required String y,
    required String h,
    required String k,
  }) {
    return solve(
      x: _parseFraction(x),
      y: _parseFraction(y),
      h: _parseFraction(h),
      k: _parseFraction(k),
      rawX: x.trim(),
      rawY: y.trim(),
      rawH: h.trim(),
      rawK: k.trim(),
    );
  }

  /// Computes the radius given a point (x, y) on the circle
  /// and the circle's center (h, k).
  static RadiusResult solve({
    required double x,
    required double y,
    required double h,
    required double k,
    String? rawX,
    String? rawY,
    String? rawH,
    String? rawK,
  }) {
    final dx = x - h;
    final dy = y - k;
    final dx2 = dx * dx;
    final dy2 = dy * dy;
    final sum = dx2 + dy2;
    final r = sqrt(sum);

    return RadiusResult(
      x: x,
      y: y,
      h: h,
      k: k,
      dx: dx,
      dy: dy,
      dx2: dx2,
      dy2: dy2,
      sum: sum,
      radius: r,
      rawX: rawX,
      rawY: rawY,
      rawH: rawH,
      rawK: rawK,
    );
  }
}

/// Immutable value-object that carries every intermediate value
/// produced by [RadiusSolver.solve].
class RadiusResult {
  const RadiusResult({
    required this.x,
    required this.y,
    required this.h,
    required this.k,
    required this.dx,
    required this.dy,
    required this.dx2,
    required this.dy2,
    required this.sum,
    required this.radius,
    this.rawX,
    this.rawY,
    this.rawH,
    this.rawK,
  });

  final double x, y, h, k;
  final double dx, dy;
  final double dx2, dy2;
  final double sum;
  final double radius;

  /// Original string inputs (preserved for display when fractions are used).
  final String? rawX, rawY, rawH, rawK;

  String _fmt(double v, String? raw) {
    if (raw != null && raw.contains('/')) return raw;
    return v == v.truncateToDouble()
        ? v.toInt().toString()
        : v.toStringAsFixed(4);
  }

  String _f(double v) =>
      v == v.truncateToDouble() ? v.toInt().toString() : v.toStringAsFixed(4);

  /// Checks if [n] is a perfect square (within floating point tolerance).
  bool _isPerfectSquare(double n) {
    if (n < 0) return false;
    final root = sqrt(n);
    return (root - root.round()).abs() < 1e-9;
  }

  /// Simplifies √n into a√b form where b is square-free.
  /// Returns (coefficient, radicand). For √12 → (2, 3) meaning 2√3.
  (int, int) _simplifyRadical(double n) {
    if (n <= 0) return (0, 0);

    // Round to handle floating point errors (e.g., 5.0000000001 → 5)
    final intN = n.round();
    if ((n - intN).abs() > 1e-6) {
      return (1, intN); // Non-integer, can't simplify nicely
    }

    int coeff = 1;
    int remaining = intN;

    // Extract square factors: 12 = 4×3 → coeff=2, remaining=3
    for (int i = 2; i * i <= remaining; i++) {
      while (remaining % (i * i) == 0) {
        coeff *= i;
        remaining ~/= (i * i);
      }
    }
    return (coeff, remaining);
  }

  /// Returns exact radical form with approximation when needed:
  /// • Perfect square: "5"
  /// • Simplified: "2√5 ≈ 4.4721"
  /// • Non-integer radicand: "4.1231"
  String get formattedRadius {
    final sumInt = sum.round();
    final isInteger = (sum - sumInt).abs() < 1e-9;

    if (!isInteger) return _f(radius); // Decimal sum → decimal result

    if (_isPerfectSquare(sum)) return sqrt(sum).round().toString();

    // Not perfect square: show exact and approximate
    final (coeff, radicand) = _simplifyRadical(sum);
    final exact = coeff == 1 ? '√$radicand' : '$coeff√$radicand';
    return '$exact ≈ ${_f(radius)}';
  }

  /// Returns just the exact form: "5", "√5", or "2√5"
  String get exactRadius {
    final sumInt = sum.round();
    final isInteger = (sum - sumInt).abs() < 1e-9;

    if (!isInteger) return _f(radius);
    if (_isPerfectSquare(sum)) return sqrt(sum).round().toString();

    final (coeff, radicand) = _simplifyRadical(sum);
    return coeff == 1 ? '√$radicand' : '$coeff√$radicand';
  }

  /// Human-readable, monospace step-by-step solution string.
  String get steps {
    final buffer = StringBuffer();

    buffer.writeln('r = √((x − h)² + (y − k)²)');
    buffer.writeln(
        'r = √((${_fmt(x, rawX)} − ${_fmt(h, rawH)})² + (${_fmt(y, rawY)} − ${_fmt(k, rawK)})²)');
    buffer.writeln('r = √((${_f(dx)})² + (${_f(dy)})²)');
    buffer.writeln('r = √(${_f(dx2)} + ${_f(dy2)})');
    buffer.writeln('r = √${_f(sum)}');

    // Final line: exact form with approximation if irrational
    final sumInt = sum.round();
    final isInteger = (sum - sumInt).abs() < 1e-9;

    if (isInteger && !_isPerfectSquare(sum)) {
      final (coeff, radicand) = _simplifyRadical(sum);
      final exact = coeff == 1 ? '√$radicand' : '$coeff√$radicand';
      buffer.write('r = $exact ≈ ${_f(radius)}');
    } else {
      buffer.write('r = ${_f(radius)}');
    }

    return buffer.toString();
  }
}
