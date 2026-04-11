import 'dart:math';

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

  factory DistanceResult.error(String message) => DistanceResult(
        hasError: true,
        errorMessage: message,
      );

  factory DistanceResult.success({
    required double distance,
    required String formula,
  }) =>
      DistanceResult(
        distance: distance,
        formula: formula,
        hasError: false,
      );
}

/// Handles 1D (number line) and 2D (coordinate plane) distance calculations
class DistanceSolver {
  /// Main entry point — parses inputs and routes to appropriate solver
  static DistanceResult solve({
    required String x1,
    required String x2,
    String? y1,
    String? y2,
    required bool is2D,
  }) {
    // Parse x coordinates
    final parsedX1 = _parseCoordinate(x1, 'x₁');
    final parsedX2 = _parseCoordinate(x2, 'x₂');

    if (parsedX1.hasError) return parsedX1.errorResult!;
    if (parsedX2.hasError) return parsedX2.errorResult!;

    final double xv1 = parsedX1.value!;
    final double xv2 = parsedX2.value!;

    if (is2D) {
      // 2D requires y coordinates
      if (y1 == null || y2 == null) {
        return DistanceResult.error('Y coordinates required for 2D mode');
      }

      final parsedY1 = _parseCoordinate(y1, 'y₁');
      final parsedY2 = _parseCoordinate(y2, 'y₂');

      if (parsedY1.hasError) return parsedY1.errorResult!;
      if (parsedY2.hasError) return parsedY2.errorResult!;

      final double yv1 = parsedY1.value!;
      final double yv2 = parsedY2.value!;

      return _solve2D(xv1, yv1, xv2, yv2);
    } else {
      return _solve1D(xv1, xv2);
    }
  }

  /// 1D distance: |x₂ − x₁|
  static DistanceResult _solve1D(double x1, double x2) {
    final diff = x2 - x1;
    final distance = diff.abs();

    // Build formula string showing the work
    final formula = diff >= 0
        ? '|$x2 − $x1| = |${diff.toStringAsFixed(4).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '')}| = ${distance.toStringAsFixed(4).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '')}'
        : '|$x2 − $x1| = |${diff.toStringAsFixed(4).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '')}| = ${distance.toStringAsFixed(4).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '')}';

    return DistanceResult.success(
      distance: distance,
      formula: formula,
    );
  }

  /// 2D distance: √((x₂−x₁)² + (y₂−y₁)²)
  static DistanceResult _solve2D(double x1, double y1, double x2, double y2) {
    final dx = x2 - x1;
    final dy = y2 - y1;
    final distance = sqrt(dx * dx + dy * dy);

    // Format numbers cleanly (trim trailing zeros)
    String fmt(double n) {
      final s = n.toStringAsFixed(4);
      return s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    }

    final formula = '√((${fmt(x2)}−${fmt(x1)})² + (${fmt(y2)}−${fmt(y1)})²)\n'
        '= √(${fmt(dx)}² + ${fmt(dy)}²)\n'
        '= √(${fmt(dx * dx)} + ${fmt(dy * dy)})\n'
        '= √${fmt(dx * dx + dy * dy)}\n'
        '= ${fmt(distance)}';

    return DistanceResult.success(
      distance: distance,
      formula: formula,
    );
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
    } catch (e) {
      return _ParseResult.error('$label must be a valid number');
    }
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
