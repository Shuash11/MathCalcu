// ═════════════════════════════════════════════════════════════
// SLOPE SOLVER  (generated via SymPy)
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
  final double x1, y1, x2, y2;
  final double slope, deltaY, deltaX;
  final bool isVertical;
  final bool isHorizontal;
  final String equation;
  final String slopeDisplay;
  final String? error;

  SlopeSolverResult({
    required this.x1, required this.y1,
    required this.x2, required this.y2,
    required this.slope, required this.deltaY, required this.deltaX,
    required this.isVertical, required this.isHorizontal,
    required this.equation, required this.slopeDisplay,
    this.error,
  });

  bool get hasError => error != null;
}

class SlopeComparisonResult {
  final SlopeSolverResult slope1, slope2;
  final String relationship;
  final String relationshipIcon;
  final String explanation;

  SlopeComparisonResult({
    required this.slope1, required this.slope2,
    required this.relationship, required this.relationshipIcon,
    required this.explanation,
  });

  bool get isParallel => relationship == 'parallel';
  bool get isPerpendicular => relationship == 'perpendicular';
  bool get isNeither => relationship == 'neither';
}

class SlopeSolver {
  SlopeSolver._();

  // ── Fraction-aware parser ────────────────────────────────

  static double? parseCoordinate(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return null;
    final direct = double.tryParse(s);
    if (direct != null) return direct;
    final slashIdx = s.indexOf('/');
    if (slashIdx < 0) return null;
    final num = double.tryParse(s.substring(0, slashIdx).trim());
    final den = double.tryParse(s.substring(slashIdx + 1).trim());
    if (num == null || den == null || den == 0) return null;
    return num / den;
  }

  // ── Core solver ──────────────────────────────────────────

  static SlopeSolverResult solve(double x1, double y1, double x2, double y2) {
    if (x1.isNaN || y1.isNaN || x2.isNaN || y2.isNaN) {
      return _error('Invalid coordinate values');
    }
    final deltaY = y2 - y1;
    final deltaX = x2 - x1;

    if (deltaX == 0) {
      return SlopeSolverResult(
        x1: x1, y1: y1, x2: x2, y2: y2,
        slope: double.infinity, deltaY: deltaY, deltaX: deltaX,
        isVertical: true, isHorizontal: false,
        equation: 'x = ${_fmt(x1)}',
        slopeDisplay: 'Undefined',
      );
    }

    final slope = deltaY / deltaX;
    final isHorizontal = deltaY == 0;
    final slopeDisplay = _toFraction(deltaY, deltaX);
    final b = y1 - slope * x1;
    final equation = _buildEq(slope, b);

    return SlopeSolverResult(
      x1: x1, y1: y1, x2: x2, y2: y2,
      slope: slope, deltaY: deltaY, deltaX: deltaX,
      isVertical: false, isHorizontal: isHorizontal,
      equation: equation, slopeDisplay: slopeDisplay,
    );
  }

  static SlopeSolverResult solveFromStrings(
    String sx1, String sy1, String sx2, String sy2,
  ) {
    final x1 = parseCoordinate(sx1);
    final y1 = parseCoordinate(sy1);
    final x2 = parseCoordinate(sx2);
    final y2 = parseCoordinate(sy2);
    if (x1 == null || y1 == null || x2 == null || y2 == null) {
      return _error('Invalid input - use numbers or fractions like 3/5');
    }
    return solve(x1, y1, x2, y2);
  }

  // ── Steps ────────────────────────────────────────────────

  static List<SlopeStep> getSteps(double x1, double y1, double x2, double y2) {
    final r = solve(x1, y1, x2, y2);
    final pts = '(${_fmt(x1)}, ${_fmt(y1)}) and (${_fmt(x2)}, ${_fmt(y2)})';

    if (r.isVertical) {
      return [
        SlopeStep(label: 'Given Points', equation: pts),
        SlopeStep(label: 'Find dx', equation: 'dx = ${_fmt(x2)} - ${_fmt(x1)} = 0'),
        const SlopeStep(label: 'Conclusion', equation: 'dx = 0 -> Slope is undefined'),
        SlopeStep(label: 'Equation', equation: r.equation),
      ];
    }

    if (r.isHorizontal) {
      return [
        SlopeStep(label: 'Given Points', equation: pts),
        SlopeStep(label: 'Find dy', equation: 'dy = ${_fmt(y2)} - ${_fmt(y1)} = 0'),
        const SlopeStep(label: 'Conclusion', equation: 'dy = 0 -> m = 0'),
        SlopeStep(label: 'Equation', equation: 'y = ${_fmt(r.y1)}'),
      ];
    }

    return [
      SlopeStep(label: 'Given Points', equation: pts),
      const SlopeStep(label: 'Formula', equation: 'm = (y2 - y1) / (x2 - x1)'),
      SlopeStep(label: 'Substitute', equation: 'm = (${_fmt(y2)} - ${_fmt(y1)}) / (${_fmt(x2)} - ${_fmt(x1)})'),
      SlopeStep(label: 'Simplify', equation: 'm = ${_fmt(r.deltaY)} / ${_fmt(r.deltaX)}'),
      SlopeStep(label: 'Slope', equation: 'm = ${r.slopeDisplay}'),
      SlopeStep(label: 'Line Equation', equation: r.equation),
    ];
  }

  // ── Comparison ────────────────────────────────────────────

  static SlopeComparisonResult compareSlopes(
    SlopeSolverResult a, SlopeSolverResult b,
  ) {
    if (a.isVertical && b.isVertical) {
      return _cmp(a, b, 'parallel', 'parallel', 'Both lines are vertical (parallel)');
    }
    if (a.isVertical || b.isVertical) {
      return _cmp(a, b, 'perpendicular', 'perpendicular', 'One vertical, one not (perpendicular)');
    }
    if ((a.slope - b.slope).abs() < 1e-10) {
      return _cmp(a, b, 'parallel', 'parallel', 'Lines have equal slopes (parallel)');
    }
    if ((a.slope * b.slope + 1).abs() < 1e-10) {
      return _cmp(a, b, 'perpendicular', 'perpendicular', 'Product of slopes equals -1 (perpendicular)');
    }
    return _cmp(a, b, 'neither', 'trending_flat', 'Lines are neither parallel nor perpendicular');
  }

  static List<SlopeStep> getComparisonSteps(SlopeComparisonResult c) {
    final a = c.slope1, b = c.slope2;
    final m1 = a.isVertical ? 'Undefined' : a.slopeDisplay;
    final m2 = b.isVertical ? 'Undefined' : b.slopeDisplay;
    final check = c.isParallel
        ? 'm1 = m2 -> Parallel'
        : c.isPerpendicular
            ? 'm1 x m2 = -1 -> Perpendicular'
            : 'm1 != m2 and m1 x m2 != -1 -> Neither';
    return [
      SlopeStep(label: 'Line 1 - Points', equation: '(${_fmt(a.x1)}, ${_fmt(a.y1)}) and (${_fmt(a.x2)}, ${_fmt(a.y2)})'),
      SlopeStep(label: 'Line 1 - Slope', equation: 'm1 = $m1'),
      SlopeStep(label: 'Line 2 - Points', equation: '(${_fmt(b.x1)}, ${_fmt(b.y1)}) and (${_fmt(b.x2)}, ${_fmt(b.y2)})'),
      SlopeStep(label: 'Line 2 - Slope', equation: 'm2 = $m2'),
      SlopeStep(label: 'Check', equation: check),
      SlopeStep(label: 'Result', equation: c.relationship.toUpperCase()),
    ];
  }

  // ── Interpretation ─────────────────────────────────────────

  static String getInterpretation(double slope) {
    if (slope.isInfinite) return 'Vertical line (undefined)';
    if (slope == 0) return 'Horizontal line (no change in y)';
    if (slope > 0) return 'Line goes up from left to right (positive slope)';
    return 'Line goes down from left to right (negative slope)';
  }

  // ── Private Helpers ───────────────────────────────────────

  static SlopeSolverResult _error(String msg) => SlopeSolverResult(
    x1: 0, y1: 0, x2: 0, y2: 0, slope: 0, deltaY: 0, deltaX: 0,
    isVertical: false, isHorizontal: false, equation: '', slopeDisplay: '', error: msg,
  );

  static SlopeComparisonResult _cmp(
    SlopeSolverResult a, SlopeSolverResult b,
    String rel, String icon, String explanation,
  ) => SlopeComparisonResult(slope1: a, slope2: b, relationship: rel, relationshipIcon: icon, explanation: explanation);

  static String _fmt(double n) {
    if (n == n.truncateToDouble()) return n.toInt().toString();
    return n.toStringAsFixed(2).replaceAll(RegExp(r'\.[0-9]*?0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  static String _toFraction(double num, double den) {
    if (den == 0) return 'Undefined';
    if (num == num.truncateToDouble() && den == den.truncateToDouble()) {
      int n = num.toInt(), d = den.toInt();
      if (d == 0) return 'Undefined';
      final g = _gcd(n.abs(), d.abs());
      n ~/= g; d ~/= g;
      if (d == 1) return '$n';
      if (d == -1) return '${-n}';
      if (d < 0) return '${-n}/${-d}';
      return '$n/$d';
    }
    final r = num / den;
    if (r == r.truncateToDouble()) return r.toInt().toString();
    for (int d = 1; d <= 100; d++) {
      final n = (r * d).round();
      if ((r * d - n).abs() < 1e-9) {
        final g = _gcd(n.abs(), d);
        final fn = n ~/ g, fd = d ~/ g;
        if (fd == 1) return '$fn';
        if (fd < 0) return '${-fn}/${-fd}';
        return '$fn/$fd';
      }
    }
    return '${num.toInt()}/${den.toInt()}';
  }

  static int _gcd(int a, int b) {
    while (b != 0) { final t = b; b = a % b; a = t; }
    return a;
  }

  static String _buildEq(double m, double b) {
    final mStr = _toFraction(m, 1);
    final bStr = b == b.truncateToDouble()
        ? b.toInt().toString()
        : b.toStringAsFixed(2).replaceAll(RegExp(r'\.[0-9]*?0+$'), '').replaceAll(RegExp(r'\.$'), '');
    if (b == 0) return 'y = ${mStr}x';
    if (b > 0) return 'y = ${mStr}x + $bStr';
    return 'y = ${mStr}x - $bStr';
  }
}
