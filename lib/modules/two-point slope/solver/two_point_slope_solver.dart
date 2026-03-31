// ─────────────────────────────────────────────────────────────
// TWO-POINT SLOPE SOLVER — ALL BUGS FIXED
// ─────────────────────────────────────────────────────────────

class TwoPointSlopeResult {
  final double x1, y1, x2, y2;
  final double? slope;
  final double? yIntercept;
  final bool isVertical;
  final bool isHorizontal;
  final String slopeDisplay;
  final String lineEquation;
  final String standardForm;
  final String generalForm;
  final String slopeType;
  final List<SolverStep> steps;

  const TwoPointSlopeResult({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
    required this.slope,
    required this.yIntercept,
    required this.isVertical,
    required this.isHorizontal,
    required this.slopeDisplay,
    required this.lineEquation,
    required this.standardForm,
    required this.generalForm,
    required this.slopeType,
    required this.steps,
  });
}

class SolverStep {
  final int number;
  final String title;
  final String formula;
  final String substitution;
  final String result;
  final String explanation;

  const SolverStep({
    required this.number,
    required this.title,
    required this.formula,
    this.substitution = '',
    required this.result,
    this.explanation = '',
  });
}

class TwoPointSlopeSolver {
  TwoPointSlopeSolver._();

  static TwoPointSlopeResult solve({
    required double x1,
    required double y1,
    required double x2,
    required double y2,
  }) {
    final dx = x2 - x1;
    final dy = y2 - y1;

    final isVertical = dx == 0;
    final isHorizontal = dy == 0 && !isVertical;

    double? slope;
    double? yIntercept;
    String slopeDisplay;
    String lineEquation;
    String standardForm;
    String generalForm;
    String slopeType;

    final List<SolverStep> steps = [];

    // Step 1 — Identify points
    steps.add(SolverStep(
      number: 1,
      title: 'Identify Points',
      formula: 'P\u2081 = (x\u2081, y\u2081)   P\u2082 = (x\u2082, y\u2082)',
      substitution:
          'P\u2081 = (${_fmt(x1)}, ${_fmt(y1)})   P\u2082 = (${_fmt(x2)}, ${_fmt(y2)})',
      result: 'Points identified',
      explanation: 'Label the two coordinate points.',
    ));

    // Step 2 — Slope formula (show substitution before simplification)
    steps.add(SolverStep(
      number: 2,
      title: 'Slope Formula',
      formula: 'm = (y\u2082 - y\u2081) / (x\u2082 - x\u2081)',
      substitution:
          'm = (${_fmt(y2)} - ${_fmt(y1)}) / (${_fmt(x2)} - ${_fmt(x1)})'
          ' = ${_fmt(dy)} / ${_fmt(dx)}',
      result: 'm = ${_fmt(dy)} / ${_fmt(dx)}',
      explanation: 'Rise over run.',
    ));

    if (isVertical) {
      slope = null;
      yIntercept = null;
      slopeDisplay = 'Undefined';
      lineEquation = 'x = ${_fmt(x1)}';
      standardForm = 'x = ${_fmt(x1)}';
      generalForm = 'x - ${_fmt(x1)} = 0';
      slopeType = 'Vertical Line';

      steps.add(SolverStep(
        number: 3,
        title: 'Vertical Line',
        formula: 'm = \u0394y / 0',
        substitution: 'Division by zero — slope is undefined',
        result: 'x = ${_fmt(x1)}',
        explanation: 'All points share the same x-value.',
      ));
    } else {
      slope = dy / dx;
      slopeDisplay = _fmtSlope(slope);

      // Step 3 — Simplified slope
      steps.add(SolverStep(
        number: 3,
        title: 'Simplify Slope',
        formula: 'm = ${_fmt(dy)} / ${_fmt(dx)}',
        substitution: _fractionString(dy, dx),
        result: 'm = $slopeDisplay',
        explanation: _simplifyExplanation(dy, dx, slope),
      ));

      // Step 4 — Y-intercept
      yIntercept = y1 - slope * x1;
      steps.add(SolverStep(
        number: 4,
        title: 'Y-Intercept',
        formula: 'b = y\u2081 - m \u00b7 x\u2081',
        substitution:
            'b = ${_fmt(y1)} - ($slopeDisplay)(${_fmt(x1)}) = ${_fmtSlope(yIntercept)}',
        result: 'b = ${_fmtSlope(yIntercept)}',
        explanation: 'Plug in point P\u2081 and the slope.',
      ));

      // Step 5 — Slope-intercept form
      lineEquation = _buildSlopeIntercept(slope, yIntercept);
      steps.add(SolverStep(
        number: 5,
        title: 'Slope-Intercept Form',
        formula: 'y = mx + b',
        substitution: lineEquation,
        result: lineEquation,
        explanation: 'Shows slope and y-intercept directly.',
      ));

      // ── Standard form  Ax + By = C ──────────────────────────
      //
      // Derivation (from the two-point line equation):
      //   A =  y1 - y2   (equivalent to -dy)
      //   B =  x2 - x1   (equivalent to  dx)
      //   C =  A*x1 + B*y1   ← CORRECT; cross-product formula is WRONG
      //
      // Cross-product (x1*y2 - x2*y1) is NOT equal to C here and
      // produces wrong answers for most inputs.
      //
      // Verification: A*x1 + B*y1 == C  and  A*x2 + B*y2 == C
      final int rawA = (y1 - y2).round();
      final int rawB = (x2 - x1).round();
      final int rawC = rawA * x1.round() + rawB * y1.round();

      // Reduce all three coefficients by their GCD
      final int g = _gcd3(rawA.abs(), rawB.abs(), rawC.abs());
      int a = rawA ~/ g;
      int b = rawB ~/ g;
      int c = rawC ~/ g;

      // Normalise sign: leading non-zero coefficient must be positive
      if (a < 0 || (a == 0 && b < 0)) {
        a = -a;
        b = -b;
        c = -c;
      }

      standardForm = _buildStandardForm(a, b, c);
      generalForm = _buildGeneralForm(a, b, c);

      steps.add(SolverStep(
        number: 6,
        title: 'Standard Form',
        formula: 'Ax + By = C',
        substitution: 'A = $a, B = $b, C = $c',
        result: standardForm,
        explanation: 'Integer coefficients reduced by GCD($g).',
      ));

      steps.add(SolverStep(
        number: 7,
        title: 'General Form',
        formula: 'Ax + By + C = 0',
        substitution: 'Move C to the left — sign flips',
        result: generalForm,
        explanation: 'All terms on the left, right side is zero.',
      ));

      slopeType = isHorizontal
          ? 'Horizontal (m = 0)'
          : slope > 0
              ? 'Positive \u2197'
              : 'Negative \u2198';
    }

    return TwoPointSlopeResult(
      x1: x1,
      y1: y1,
      x2: x2,
      y2: y2,
      slope: slope,
      yIntercept: yIntercept,
      isVertical: isVertical,
      isHorizontal: isHorizontal,
      slopeDisplay: slopeDisplay,
      lineEquation: lineEquation,
      standardForm: standardForm,
      generalForm: generalForm,
      slopeType: slopeType,
      steps: steps,
    );
  }

  // ── GCD ───────────────────────────────────────────────────

  static int _gcd2(int a, int b) => b == 0 ? a : _gcd2(b, a % b);

  static int _gcd3(int a, int b, int c) {
    final g = _gcd2(a, b);
    final result = _gcd2(g, c);
    return result == 0 ? 1 : result;
  }

  // ── FORMATTING ────────────────────────────────────────────

  /// Integer if whole, 2 dp otherwise.
  static String _fmt(double v) {
    if (v == v.truncateToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(2);
  }

  /// Fraction when possible, otherwise 3 dp.
  static String _fmtSlope(double v) {
    if (v == v.truncateToDouble()) return v.toInt().toString();
    return _toFraction(v) ?? v.toStringAsFixed(3);
  }

  /// Returns "n/d" reduced to lowest terms, or null if denominator > 20.
  static String? _toFraction(double value) {
    for (int d = 1; d <= 20; d++) {
      final n = (value * d).round();
      if ((value * d - n).abs() < 1e-9) {
        final g = _gcd2(n.abs(), d);
        final fn = n ~/ g;
        final fd = d ~/ g;
        return fd == 1 ? fn.toString() : '$fn/$fd';
      }
    }
    return null;
  }

  static String _fractionString(double dy, double dx) {
    final frac = _toFraction(dy / dx);
    return frac != null ? 'Simplified: $frac' : '${_fmt(dy)} / ${_fmt(dx)}';
  }

  static String _simplifyExplanation(double dy, double dx, double slope) {
    final frac = _toFraction(slope);
    return frac != null
        ? 'Reduced fraction: $frac'
        : 'Decimal: ${slope.toStringAsFixed(3)}';
  }

  // ── EQUATION STRING BUILDERS ──────────────────────────────

  /// y = mx + b
  /// — uses ASCII '-' (not unicode minus)
  /// — omits coefficient of 1 (writes 'x' not '1x')
  /// — handles m=0 and b=0 cleanly
  static String _buildSlopeIntercept(double m, double b) {
    final ms = _fmtSlope(m);
    final absB = _fmtSlope(b.abs());

    String mPart;
    if (ms == '1') {
      mPart = 'x';
    } else if (ms == '-1') {
      mPart = '-x';
    } else {
      mPart = '${ms}x';
    }

    if (m == 0) return 'y = ${_fmtSlope(b)}';
    if (b == 0) return 'y = $mPart';
    final sign = b > 0 ? ' + ' : ' - ';
    return 'y = $mPart$sign$absB';
  }

  /// Ax + By = C
  /// — zero terms are omitted entirely
  /// — coefficient of 1 is omitted (writes 'x' not '1x', 'y' not '1y')
  /// — proper spacing between terms
  static String _buildStandardForm(int a, int b, int c) {
    final xPart = _varTerm(a, 'x', isFirst: true);
    final yPart = _varTerm(b, 'y', isFirst: xPart.isEmpty);
    final lhs = '$xPart$yPart';
    return '${lhs.isEmpty ? '0' : lhs} = $c';
  }

  /// Ax + By + C = 0
  /// Moves the constant from the right side to the left — sign flips.
  static String _buildGeneralForm(int a, int b, int c) {
    final xPart = _varTerm(a, 'x', isFirst: true);
    final yPart = _varTerm(b, 'y', isFirst: xPart.isEmpty);
    // In general form the C from standard form appears as -C on the left
    final constPart = _constTerm(-c, isFirst: xPart.isEmpty && yPart.isEmpty);
    return '$xPart$yPart$constPart = 0';
  }

  /// Builds one variable term: e.g. "2x", " + 2x", "-x", " - y".
  /// [isFirst] — true when this is the first non-zero term in the expression.
  static String _varTerm(int coeff, String v, {required bool isFirst}) {
    if (coeff == 0) return '';
    final abs = coeff.abs();
    final varStr = abs == 1 ? v : '$abs$v';
    if (isFirst) return coeff < 0 ? '-$varStr' : varStr;
    return coeff < 0 ? ' - $varStr' : ' + $varStr';
  }

  /// Builds a standalone constant term (no variable letter).
  static String _constTerm(int value, {required bool isFirst}) {
    if (value == 0) return '';
    if (isFirst) return '$value';
    return value < 0 ? ' - ${value.abs()}' : ' + $value';
  }
}
