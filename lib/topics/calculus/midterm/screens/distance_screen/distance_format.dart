import 'dart:math';

/// Pure, widget-free formatting for distance results.
///
/// Extracted from `_DistancescreenState._formatDistance` (Cycle 3 F3) so the
/// exact-display notation is covered by output-level regression tests.
/// Single responsibility: turn a computed distance into its display string.
///
/// Notation contract (matches `radius_solver` / `distancesolver`):
/// always the real radical `√` (U+221A), never the ASCII `v` fallback.
class DistanceFormat {
  const DistanceFormat._();

  /// Formats [value] for display.
  /// - 1D: absolute value (integer or trimmed decimal).
  /// - 2D perfect square: integer (e.g. `"5"`).
  /// - 2D non-perfect square: exact radical + approximation
  ///   (e.g. `"√5 ≈ 2.2361"`, `"2√5 ≈ 4.4721"`).
  static String formatDistance(double value, bool is2D) {
    if (!is2D) {
      final abs = value.abs();
      return abs == abs.toInt()
          ? abs.toInt().toString()
          : abs
              .toStringAsFixed(6)
              .replaceAll(RegExp(r'0+$'), '')
              .replaceAll(RegExp(r'\.$'), '');
    }

    final int squared = (value * value).round();
    final double sqrtVal = sqrt(squared);

    // Perfect square → integer only.
    if (sqrtVal == sqrtVal.roundToDouble()) {
      return sqrtVal.round().toString();
    }

    // Simplify the radical: squared = largestSquare² × remaining.
    int largestSquare = 1;
    int remaining = squared;
    for (int i = 2; i * i <= squared; i++) {
      while (remaining % (i * i) == 0) {
        largestSquare *= i;
        remaining ~/= (i * i);
      }
    }

    String exact;
    if (remaining == 1) {
      exact = largestSquare.toString();
    } else if (largestSquare == 1) {
      exact = '√$remaining';
    } else {
      exact = '$largestSquare√$remaining';
    }

    // Decimal approximation (trimmed to 4 decimal places).
    final approx = value
        .toStringAsFixed(4)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');

    return '$exact ≈ $approx';
  }
}
