// lib/Solver/center_solver.dart
// Pure Dart — no Flutter imports. Unit-testable in isolation.

class CenterResult {
  final double h;
  final double k;
  final String steps;

  const CenterResult({required this.h, required this.k, required this.steps});
}

class CenterSolver {
  /// Parses a string that may be an integer, decimal, or fraction (e.g. "3/4").
  /// Returns null if the string is invalid or the denominator is zero.
  static double? parse(String text) {
    text = text.trim();
    if (text.contains('/')) {
      final parts = text.split('/');
      if (parts.length == 2) {
        final num = double.tryParse(parts[0]);
        final den = double.tryParse(parts[1]);
        if (num != null && den != null && den != 0) return num / den;
      }
      return null;
    }
    return double.tryParse(text);
  }

  /// Formats a double: no decimal point for whole numbers, 4 dp otherwise.
  static String fmt(double v) {
    if (v == v.truncateToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(4);
  }

  /// Computes the midpoint (center) from two diameter endpoints.
  /// Returns a [CenterResult] with h, k, and the full step-by-step string.
  static CenterResult compute({
    required double x1,
    required double y1,
    required double x2,
    required double y2,
  }) {
    final h = (x1 + x2) / 2;
    final k = (y1 + y2) / 2;

    final steps =
        'h = (x₁ + x₂) / 2\n'
        'h = (${fmt(x1)} + ${fmt(x2)}) / 2\n'
        'h = ${fmt(x1 + x2)} / 2\n'
        'h = ${fmt(h)}\n'
        '\n'
        'k = (y₁ + y₂) / 2\n'
        'k = (${fmt(y1)} + ${fmt(y2)}) / 2\n'
        'k = ${fmt(y1 + y2)} / 2\n'
        'k = ${fmt(k)}';

    return CenterResult(h: h, k: k, steps: steps);
  }
}