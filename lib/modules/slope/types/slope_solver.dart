// ═════════════════════════════════════════════════════════════
// SLOPE SOLVER
// ─────────────────────────────────────────────────────────────
// Calculates slope between two points with detailed results
// and step-by-step workings. Shows results as fractions.
//
// INPUT: Coordinates can be plain numbers (3, -2.5) OR
//        fractions using slash notation (3/5, -1/4, 2/3).
// ═════════════════════════════════════════════════════════════

class SlopeStep {
  final String label;
  final String equation;
  const SlopeStep({required this.label, required this.equation});
}

class SlopeSolverResult {
  final double x1;
  final double y1;
  final double x2;
  final double y2;
  final double slope;
  final double deltaY;
  final double deltaX;
  final bool isVertical;
  final bool isHorizontal;
  final String equation;
  final String slopeDisplay;
  final String? error;

  SlopeSolverResult({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
    required this.slope,
    required this.deltaY,
    required this.deltaX,
    required this.isVertical,
    required this.isHorizontal,
    required this.equation,
    required this.slopeDisplay,
    this.error,
  });

  bool get hasError => error != null;
}

class SlopeComparisonResult {
  final SlopeSolverResult slope1;
  final SlopeSolverResult slope2;
  final String relationship;
  final String relationshipIcon;
  final String explanation;

  SlopeComparisonResult({
    required this.slope1,
    required this.slope2,
    required this.relationship,
    required this.relationshipIcon,
    required this.explanation,
  });

  bool get isParallel => relationship == 'parallel';
  bool get isPerpendicular => relationship == 'perpendicular';
  bool get isNeither => relationship == 'neither';
}

class SlopeSolver {
  // ── Fraction-aware parser ────────────────────────────────

  static double? parseCoordinate(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return null;

    final direct = double.tryParse(s);
    if (direct != null) return direct;

    final slashIdx = s.indexOf('/');
    if (slashIdx < 0) return null;

    final numStr = s.substring(0, slashIdx).trim();
    final denStr = s.substring(slashIdx + 1).trim();

    final num = double.tryParse(numStr);
    final den = double.tryParse(denStr);

    if (num == null || den == null) return null;
    if (den == 0) return null;

    return num / den;
  }

  // ── Core solver ──────────────────────────────────────────

  static SlopeSolverResult solve(double x1, double y1, double x2, double y2) {
    try {
      if (x1.isNaN || y1.isNaN || x2.isNaN || y2.isNaN) {
        throw Exception('Invalid coordinate values');
      }

      final deltaY = y2 - y1;
      final deltaX = x2 - x1;

      if (deltaX == 0) {
        return SlopeSolverResult(
          x1: x1, y1: y1, x2: x2, y2: y2,
          slope: double.infinity,
          deltaY: deltaY,
          deltaX: deltaX,
          isVertical: true,
          isHorizontal: false,
          equation: 'x = ${_formatNum(x1)}',
          slopeDisplay: 'Undefined',
          error: null,
        );
      }

      final slope = deltaY / deltaX;
      final isHorizontal = deltaY == 0;
      final slopeDisplay = _toFraction(deltaY, deltaX);
      final b = y1 - (slope * x1);
      final equation = _getEquation(slope, b);

      return SlopeSolverResult(
        x1: x1, y1: y1, x2: x2, y2: y2,
        slope: slope,
        deltaY: deltaY,
        deltaX: deltaX,
        isVertical: false,
        isHorizontal: isHorizontal,
        equation: equation,
        slopeDisplay: slopeDisplay,
      );
    } catch (e) {
      return SlopeSolverResult(
        x1: x1, y1: y1, x2: x2, y2: y2,
        slope: 0, deltaY: 0, deltaX: 0,
        isVertical: false, isHorizontal: false,
        equation: '', slopeDisplay: '',
        error: e.toString(),
      );
    }
  }

  static SlopeSolverResult solveFromStrings(
    String sx1, String sy1,
    String sx2, String sy2,
  ) {
    final x1 = parseCoordinate(sx1);
    final y1 = parseCoordinate(sy1);
    final x2 = parseCoordinate(sx2);
    final y2 = parseCoordinate(sy2);

    if (x1 == null || y1 == null || x2 == null || y2 == null) {
      return SlopeSolverResult(
        x1: 0, y1: 0, x2: 0, y2: 0,
        slope: 0, deltaY: 0, deltaX: 0,
        isVertical: false, isHorizontal: false,
        equation: '', slopeDisplay: '',
        error: 'Invalid input — use numbers or fractions like 3/5',
      );
    }

    return solve(x1, y1, x2, y2);
  }

  // ── Step-by-step workings ────────────────────────────────

  static List<SlopeStep> getSteps(double x1, double y1, double x2, double y2) {
    final result = solve(x1, y1, x2, y2);

    if (result.isVertical) {
      return [
        SlopeStep(
          label: 'Given Points',
          equation: '(${_formatNum(x1)}, ${_formatNum(y1)})  and  (${_formatNum(x2)}, ${_formatNum(y2)})',
        ),
        SlopeStep(
          label: 'Find Δx',
          equation: 'Δx = ${_formatNum(x2)} − ${_formatNum(x1)} = 0',
        ),
    const    SlopeStep(
          label: 'Conclusion',
          equation: 'Δx = 0  →  Slope is undefined',
        ),
        SlopeStep(
          label: 'Equation',
          equation: result.equation,
        ),
      ];
    }

    if (result.isHorizontal) {
      return [
        SlopeStep(
          label: 'Given Points',
          equation: '(${_formatNum(x1)}, ${_formatNum(y1)})  and  (${_formatNum(x2)}, ${_formatNum(y2)})',
        ),
        SlopeStep(
          label: 'Find Δy',
          equation: 'Δy = ${_formatNum(y2)} − ${_formatNum(y1)} = 0',
        ),
      const  SlopeStep(
          label: 'Conclusion',
          equation: 'Δy = 0  →  m = 0',
        ),
        SlopeStep(
          label: 'Equation',
          equation: result.equation,
        ),
      ];
    }

    return [
      SlopeStep(
        label: 'Given Points',
        equation: '(${_formatNum(x1)},${_formatNum(y1)}) and (${_formatNum(x2)},${_formatNum(y2)})',
      ),
   const   SlopeStep(
        label: 'Formula',
        equation: 'm =(y₂−y₁)/(x₂−x₁)',
      ),
      SlopeStep(
        label: 'Substitute',
        equation: 'm =(${_formatNum(y2)}−${_formatNum(y1)}) / (${_formatNum(x2)}−${_formatNum(x1)})',
      ),
      SlopeStep(
        label: 'Simplify',
        equation: 'm = ${_formatNum(result.deltaY)} / ${_formatNum(result.deltaX)}',
      ),
      SlopeStep(
        label: 'Slope',
        equation: 'm = ${result.slopeDisplay}',
      ),
      SlopeStep(
        label: 'Line Equation',
        equation: result.equation,
      ),
    ];
  }

  // ── Slope comparison ─────────────────────────────────────

  static SlopeComparisonResult compareSlopes(
    SlopeSolverResult slope1,
    SlopeSolverResult slope2,
  ) {
    if (slope1.isVertical && slope2.isVertical) {
      return SlopeComparisonResult(
        slope1: slope1, slope2: slope2,
        relationship: 'parallel',
        relationshipIcon: 'parallel',
        explanation: 'Both lines are vertical (parallel)',
      );
    }

    if (slope1.isVertical || slope2.isVertical) {
      return SlopeComparisonResult(
        slope1: slope1, slope2: slope2,
        relationship: 'perpendicular',
        relationshipIcon: 'perpendicular',
        explanation: 'One vertical, one not (perpendicular)',
      );
    }

    if ((slope1.slope - slope2.slope).abs() < 0.0001) {
      return SlopeComparisonResult(
        slope1: slope1, slope2: slope2,
        relationship: 'parallel',
        relationshipIcon: 'parallel',
        explanation: 'Lines have equal slopes (parallel)',
      );
    }

    final product = slope1.slope * slope2.slope;
    if ((product + 1.0).abs() < 0.0001) {
      return SlopeComparisonResult(
        slope1: slope1, slope2: slope2,
        relationship: 'perpendicular',
        relationshipIcon: 'perpendicular',
        explanation: 'Product of slopes equals −1 (perpendicular)',
      );
    }

    return SlopeComparisonResult(
      slope1: slope1, slope2: slope2,
      relationship: 'neither',
      relationshipIcon: 'trending_flat',
      explanation: 'Lines are neither parallel nor perpendicular',
    );
  }

  static List<SlopeStep> getComparisonSteps(SlopeComparisonResult comparison) {
    final s1 = comparison.slope1;
    final s2 = comparison.slope2;

    return [
      SlopeStep(
        label: 'Line 1 — Points',
        equation: '(${_formatNum(s1.x1)}, ${_formatNum(s1.y1)})  and  (${_formatNum(s1.x2)}, ${_formatNum(s1.y2)})',
      ),
      SlopeStep(
        label: 'Line 1 — Slope',
        equation: s1.isVertical ? 'm₁ = Undefined' : 'm₁ = ${s1.slopeDisplay}',
      ),
      SlopeStep(
        label: 'Line 2 — Points',
        equation: '(${_formatNum(s2.x1)}, ${_formatNum(s2.y1)})  and  (${_formatNum(s2.x2)}, ${_formatNum(s2.y2)})',
      ),
      SlopeStep(
        label: 'Line 2 — Slope',
        equation: s2.isVertical ? 'm₂ = Undefined' : 'm₂ = ${s2.slopeDisplay}',
      ),
      SlopeStep(
        label: 'Check',
        equation: comparison.isParallel
            ? 'm₁ = m₂  →  Parallel'
            : comparison.isPerpendicular
                ? 'm₁ × m₂ = −1  →  Perpendicular'
                : 'm₁ ≠ m₂  and  m₁ × m₂ ≠ −1  →  Neither',
      ),
      SlopeStep(
        label: 'Result',
        equation: comparison.relationship.toUpperCase(),
      ),
    ];
  }

  // ── Private helpers ──────────────────────────────────────

  static String _formatNum(double n) {
    if (n % 1 == 0) return n.toInt().toString();
    return n.toStringAsFixed(2);
  }

  static String _toFraction(double num, double den) {
    if (num % 1 == 0 && den % 1 == 0) {
      final n = num.toInt();
      final d = den.toInt();
      final gcd = _gcd(n.abs(), d.abs());
      final sn = n ~/ gcd;
      final sd = d ~/ gcd;

      if (sd == 1)  return sn.toString();
      if (sd == -1) return (-sn).toString();
      if (sd < 0)   return '${-sn}/${-sd}';
      return '$sn/$sd';
    }
    return (num / den).toStringAsFixed(2);
  }

  static int _gcd(int a, int b) {
    while (b != 0) {
      final t = b;
      b = a % b;
      a = t;
    }
    return a;
  }

  static String _getEquation(double m, double b) {
    final mStr = (m % 1 == 0)
        ? _toFraction(m, 1)
        : m.toStringAsFixed(2);
    final bAbs = b.abs().toStringAsFixed(2);

    if (b == 0)  return 'y = ${mStr}x';
    if (b > 0)   return 'y = ${mStr}x + $bAbs';
    return 'y = ${mStr}x − $bAbs';
  }

  static String getInterpretation(double slope) {
    if (slope.isInfinite) return 'Vertical line (undefined)';
    if (slope == 0)       return 'Horizontal line (no change in y)';
    if (slope > 0)        return 'Line goes up from left to right (positive slope)';
    return 'Line goes down from left to right (negative slope)';
  }
}