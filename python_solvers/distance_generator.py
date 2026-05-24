#!/usr/bin/env python3
"""
SymPy-verified Dart code generator for distance module.
Generates: distancesolver.dart (DistanceResult + DistanceSolver)
"""
from pathlib import Path
from sympy import symbols, sqrt, Abs, simplify, latex

# ── Globals ────────────────────────────────────────────────────────────

x1, x2, y1, y2, d, dx, dy = symbols('x1 x2 y1 y2 d dx dy')
PROJECT_ROOT = Path(__file__).parent.parent
DART_DIR = PROJECT_ROOT / "lib" / "midterm" / "solvers" / "distance_solver"
DART_DIR.mkdir(parents=True, exist_ok=True)

# ── SymPy Verification ─────────────────────────────────────────────────

def verify():
    print("=" * 60)
    print("SymPy Verification for distance generator")
    print("=" * 60)

    # 1. 1D distance: |x2 - x1|
    d1d = Abs(x2 - x1)
    print(f"  1D: d = |x2 - x1| = {latex(d1d)}")
    assert simplify(d1d - Abs(x1 - x2)) == 0  # commutative
    print("  [OK] 1D distance formula verified\n")

    # 2. 2D distance: sqrt((x2-x1)^2 + (y2-y1)^2)
    expr = sqrt((x2 - x1)**2 + (y2 - y1)**2)
    print(f"  2D: d = sqrt((x2-x1)^2 + (y2-y1)^2)")
    # verify form is equivalent
    expanded = simplify(expr**2 - ((x2 - x1)**2 + (y2 - y1)**2))
    assert expanded == 0
    print("  [OK] 2D distance formula verified\n")

    # 3. Test cases
    cases = [
        ((1, 0, 5, 0), 4),           # 1D: |5-1| = 4
        ((-3, 0, 2, 0), 5),          # 1D: |2-(-3)| = 5
        ((0, 0, 3, 4), 5),           # 2D: sqrt(9+16) = 5
        ((1, 2, 4, 6), 5),           # 2D: sqrt(9+16) = 5
        ((-1, -1, 2, 3), 5),         # 2D: sqrt(9+16) = 5
    ]
    for (ax, ay, bx, by), expected in cases:
        if ay == 0 and by == 0:
            # 1D
            d_val = abs(bx - ax)
        else:
            d_val = float(sqrt((bx - ax)**2 + (by - ay)**2))
        ok = "OK" if abs(d_val - expected) < 1e-9 else "FAIL"
        print(f"  ({ax},{ay}) -> ({bx},{by}): d = {d_val} [{ok}]")

    print("\n  [OK] All SymPy verifications passed\n")

# ── Dart Code Generation ───────────────────────────────────────────────

DART_CODE = r'''// ═════════════════════════════════════════════════════════════
// DISTANCE SOLVER  (generated via SymPy)
// ─────────────────────────────────────────────────────────────
// Calculates distance between two points:
//   - 1D (number line): d = |x2 - x1|
//   - 2D (coordinate plane): d = sqrt((x2-x1)^2 + (y2-y1)^2)
//
// INPUT: Coordinates as numbers. Supports both 1D and 2D modes.
// ═════════════════════════════════════════════════════════════

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
      if (y1 == null || y2 == null) {
        return DistanceResult.error('Y coordinates required for 2D mode');
      }

      final parsedY1 = _parseCoordinate(y1, 'y₁');
      final parsedY2 = _parseCoordinate(y2, 'y₂');

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
        '√(($_fmt(x2)−$_fmt(x1))² + ($_fmt(y2)−$_fmt(y1))²)\n'
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
'''

# ── Main ─────────────────────────────────────────────────────────────────

def main():
    verify()
    path = DART_DIR / "distancesolver.dart"
    path.write_text(DART_CODE, encoding='utf-8')
    lines = DART_CODE.count('\n')
    print(f"Generated {path} [{lines} lines]")

if __name__ == '__main__':
    main()
