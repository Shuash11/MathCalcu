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
  if (numerator == null) throw ArgumentError('Invalid numerator in: "$trimmed"');
  if (denominator == null) throw ArgumentError('Invalid denominator in: "$trimmed"');
  if (denominator == 0) throw ArgumentError('Denominator cannot be zero in: "$trimmed"');
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
    final dx  = x - h;
    final dy  = y - k;
    final dx2 = dx * dx;
    final dy2 = dy * dy;
    final sum = dx2 + dy2;
    final r   = sqrt(sum);

    return RadiusResult(
      x: x, y: y, h: h, k: k,
      dx: dx, dy: dy,
      dx2: dx2, dy2: dy2,
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
    // If the raw input was a fraction, show it as-is in the first substitution step
    if (raw != null && raw.contains('/')) return raw;
    return v == v.truncateToDouble() ? v.toInt().toString() : v.toStringAsFixed(4);
  }

  String _f(double v) =>
      v == v.truncateToDouble() ? v.toInt().toString() : v.toStringAsFixed(4);

  /// Human-readable, monospace step-by-step solution string.
  String get steps {
    return '''r = √((x − h)² + (y − k)²)
r = √((${_fmt(x, rawX)} − ${_fmt(h, rawH)})² + (${_fmt(y, rawY)} − ${_fmt(k, rawK)})²)
r = √((${_f(dx)})² + (${_f(dy)})²)
r = √(${_f(dx2)} + ${_f(dy2)})
r = √${_f(sum)}
r = ${_f(radius)}''';
  }

  /// Formatted radius string (integer when whole, else 4 d.p.).
  String get formattedRadius {
    if (radius == radius.truncateToDouble()) return radius.toInt().toString();
    return radius.toStringAsFixed(4);
  }
}