// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// DISTANCE SOLVER  (generated via SymPy)
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Calculates distance between two points:
//   - 1D (number line): d = |x2 - x1|
//   - 2D (coordinate plane): d = sqrt((x2-x1)^2 + (y2-y1)^2)
//
// INPUT: Coordinates as numbers. Supports both 1D and 2D modes.
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

import 'dart:math' show sqrt;

/// Result container for distance calculations
class DistanceResult {
  final double? distance;
  final String? formula;
  final bool hasError;
  final String? errorMessage;

  const DistanceResult({
    this.distance,
    this.formula,
    this.hasError = false,
    this.errorMessage,
  });

  factory DistanceResult.error(String message) =>
      const DistanceResult()._copyWith(hasError: true, errorMessage: message);

  factory DistanceResult.success({
    required double distance,
    required String formula,
  }) =>
      DistanceResult(distance: distance, formula: formula);

  DistanceResult _copyWith({
    double? distance,
    String? formula,
    bool hasError = false,
    String? errorMessage,
  }) =>
      DistanceResult(
        distance: distance ?? this.distance,
        formula: formula ?? this.formula,
        hasError: hasError,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}

/// Handles 1D (number line) and 2D (coordinate plane) distance calculations
class DistanceSolver {
  /// Main entry point â€” parses inputs and routes to appropriate solver
  static DistanceResult solve({
    required String x1,
    required String x2,
    String? y1,
    String? y2,
    required bool is2D,
  }) {
    // Parse x coordinates
    final parsedX1 = _parseCoordinate(x1, 'xâ‚');
    final parsedX2 = _parseCoordinate(x2, 'xâ‚‚');

    if (parsedX1.hasError) return parsedX1.errorResult!;
    if (parsedX2.hasError) return parsedX2.errorResult!;

    final double xv1 = parsedX1.value!;
    final double xv2 = parsedX2.value!;

    if (is2D) {
      if (y1 == null || y2 == null) {
        return DistanceResult.error('Y coordinates required for 2D mode');
      }

      final parsedY1 = _parseCoordinate(y1, 'yâ‚');
      final parsedY2 = _parseCoordinate(y2, 'yâ‚‚');

      if (parsedY1.hasError) return parsedY1.errorResult!;
      if (parsedY2.hasError) return parsedY2.errorResult!;

      return _solve2D(xv1, parsedY1.value!, xv2, parsedY2.value!);
    }

    return _solve1D(xv1, xv2);
  }

  /// 1D distance: |x2 - x1|
  static DistanceResult _solve1D(double x1, double x2) {
    final diff = x2 - x1;
    final distance = diff.abs();

    final formula = '|$_fmt(x2) - $_fmt(x1)| = |$_fmt(diff)| = $_fmt(distance)';

    return DistanceResult.success(distance: distance, formula: formula);
  }

  /// 2D distance: sqrt((x2-x1)^2 + (y2-y1)^2)
  static DistanceResult _solve2D(
      double x1, double y1, double x2, double y2) {
    final dx = x2 - x1;
    final dy = y2 - y1;
    final squaredSum = dx * dx + dy * dy;
    final distance = sqrt(squaredSum);

    final formula =
        '√(($_fmt(x2)âˆ’$_fmt(x1))² + ($_fmt(y2)âˆ’$_fmt(y1))²)\n'
        '= √($_fmt(dx)² + $_fmt(dy)²)\n'
        '= √($_fmt(dx * dx) + $_fmt(dy * dy))\n'
        '= √$_fmt(squaredSum)\n'
        '= $_fmt(distance)';

    return DistanceResult.success(distance: distance, formula: formula);
  }

  /// Parse a coordinate string, returning either value or error
  static _ParseResult _parseCoordinate(String input, String label) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return _ParseResult.error('$label is required');
    }

    try {
      final value = double.parse(trimmed);
      if (value.isInfinite || value.isNaN) {
        return _ParseResult.error('$label must be a valid number');
      }
      return _ParseResult.success(value);
    } catch (_) {
      return _ParseResult.error('$label must be a valid number');
    }
  }

  /// Format a number, trimming trailing zeros
  static String _fmt(double n) {
    final s = n.toStringAsFixed(6);
    return s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }
}

/// Internal helper for parsing results
class _ParseResult {
  final double? value;
  final String? error;

  const _ParseResult({this.value, this.error});

  bool get hasError => error != null;
  DistanceResult? get errorResult =>
      hasError ? DistanceResult.error(error!) : null;

  factory _ParseResult.success(double v) => _ParseResult(value: v);
  factory _ParseResult.error(String e) => _ParseResult(error: e);
}
