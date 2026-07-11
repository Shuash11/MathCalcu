// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// RADIUS SOLVER  (generated via SymPy)
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Computes the radius of a circle given a point on the circle
// and the circle's center. r = sqrt((x-h)^2 + (y-k)^2)
//
// INPUT: Point coordinates and center coordinates as numbers
//        or fractions (e.g. "3/4").
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

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
    final exact = coeff == 1 ? 'âˆš$radicand' : '$coeffâˆš$radicand';
    return '$exact â‰ˆ ${_f(radius)}';
  }

  String get exactRadius {
    final sumInt = sum.round();
    final isInteger = (sum - sumInt).abs() < 1e-9;
    if (!isInteger) return _f(radius);
    if (_isPerfectSquare(sum)) return sqrt(sum).round().toString();
    final (coeff, radicand) = _simplifyRadical(sum);
    return coeff == 1 ? 'âˆš$radicand' : '$coeffâˆš$radicand';
  }

  String get steps {
    final buf = StringBuffer();
    buf.writeln('r = âˆš((x âˆ’ h)Â² + (y âˆ’ k)Â²)');
    buf.writeln('r = âˆš((${_fmt(x, rawX)} âˆ’ ${_fmt(h, rawH)})Â² + (${_fmt(y, rawY)} âˆ’ ${_fmt(k, rawK)})Â²)');
    buf.writeln('r = âˆš((${_f(dx)})Â² + (${_f(dy)})Â²)');
    buf.writeln('r = âˆš(${_f(dx2)} + ${_f(dy2)})');
    buf.writeln('r = âˆš${_f(sum)}');
    final sumInt = sum.round();
    final isInteger = (sum - sumInt).abs() < 1e-9;
    if (isInteger && !_isPerfectSquare(sum)) {
      final (coeff, radicand) = _simplifyRadical(sum);
      final exact = coeff == 1 ? 'âˆš$radicand' : '$coeffâˆš$radicand';
      buf.write('r = $exact â‰ˆ ${_f(radius)}');
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
