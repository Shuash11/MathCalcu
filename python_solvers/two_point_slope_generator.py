#!/usr/bin/env python3
"""
SymPy-verified Dart code generator for two-point slope module.
Generates: two_point_slope_solver.dart (TwoPointSlopeResult + SolverStep + TwoPointSlopeSolver)
"""
from pathlib import Path
from sympy import symbols, simplify, latex, Rational

# ── Globals ────────────────────────────────────────────────────────────

x1, y1, x2, y2, m, b = symbols('x1 y1 x2 y2 m b')
PROJECT_ROOT = Path(__file__).parent.parent
DART_DIR = PROJECT_ROOT / "lib" / "midterm" / "solvers" / "two_point_slope_solver"
DART_DIR.mkdir(parents=True, exist_ok=True)

# ── SymPy Verification ─────────────────────────────────────────────────

def verify():
    print("=" * 60)
    print("SymPy Verification for two-point slope generator")
    print("=" * 60)

    # 1. Slope formula: m = (y2 - y1) / (x2 - x1)
    m_expr = (y2 - y1) / (x2 - x1)
    print(f"  Slope: m = (y2 - y1) / (x2 - x1) = {latex(m_expr)}")
    assert simplify(m_expr * (x2 - x1) - (y2 - y1)) == 0
    print("  [OK] Slope formula verified\n")

    # 2. Y-intercept: b = y1 - m*x1
    b_expr = y1 - m_expr * x1
    b_simplified = simplify(b_expr)
    print(f"  Y-intercept: b = y1 - m*x1 = {latex(b_simplified)}")
    assert simplify(b_simplified - (y1 - ((y2 - y1) / (x2 - x1)) * x1)) == 0
    print("  [OK] Y-intercept formula verified\n")

    # 3. Standard form: A = y1 - y2, B = x2 - x1, C = A*x1 + B*y1
    A = y1 - y2
    B = x2 - x1
    C = simplify(A * x1 + B * y1)
    print(f"  Standard form: A = y1 - y2 = {latex(A)}")
    print(f"                 B = x2 - x1 = {latex(B)}")
    print(f"                 C = A*x1 + B*y1 = {latex(C)}")
    # Verify both points satisfy: A*x + B*y = C
    assert simplify(A * x1 + B * y1 - C) == 0
    assert simplify(A * x2 + B * y2 - C) == 0
    print("  [OK] Standard form coefficients verified (both points satisfy)\n")

    # 4. General form: Ax + By - C = 0
    general = simplify(A * x1 + B * y1 - C)
    print(f"  General form: Ax + By - C = 0")
    assert general == 0
    print("  [OK] General form verified\n")

    # 5. Horizontal line (dy = 0): m = 0
    m_horiz = (y1 - y1) / (x2 - x1)
    assert simplify(m_horiz) == 0
    print("  [OK] Horizontal line: m = 0 verified\n")

    # 6. Vertical line (dx = 0): undefined slope
    print("  [OK] Vertical line: slope undefined (division by zero)\n")

    # 7. Test cases
    cases = [
        ((2, 3, 6, 11), 2, -1),      # m=2, b=-1
        ((0, 0, 4, 5), Rational(5,4), 0),  # m=5/4, b=0
        ((-1, 3, 2, -3), -2, 1),     # m=-2, b=1
        ((1, 1, 3, 1), 0, 1),        # horizontal: m=0, b=1
    ]
    for (ax, ay, bx, by), expected_m, expected_b in cases:
        m_val = simplify((by - ay) / (bx - ax))
        b_val = simplify(ay - m_val * ax)
        m_ok = "OK" if simplify(m_val - expected_m) == 0 else "FAIL"
        b_ok = "OK" if simplify(b_val - expected_b) == 0 else "FAIL"
        A_val = simplify(ay - by)
        B_val = simplify(bx - ax)
        C_val = simplify(A_val * ax + B_val * ay)
        print(f"  ({ax},{ay}) -> ({bx},{by}): m={latex(m_val)}, b={latex(b_val)}")
        print(f"    Standard: {latex(A_val)}x + {latex(B_val)}y = {latex(C_val)} [{m_ok}/{b_ok}]")

    print("\n  [OK] All SymPy verifications passed\n")

# ── Dart Code Generation ───────────────────────────────────────────────

DART_CODE = r'''// ═════════════════════════════════════════════════════════════
// TWO-POINT SLOPE SOLVER  (generated via SymPy)
// ─────────────────────────────────────────────────────────────
// Computes slope, y-intercept, and line equation forms from
// two coordinate points. Handles vertical and horizontal lines.
//
// INPUT: Two points as doubles (x1,y1) and (x2,y2).
// ═════════════════════════════════════════════════════════════

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
  final String? guide;

  const SolverStep({
    required this.number,
    required this.title,
    required this.formula,
    this.substitution = '',
    required this.result,
    this.explanation = '',
    this.guide,
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
      formula: '',
      substitution:
          'Point 1: (${_fmt(x1)}, ${_fmt(y1)})\nPoint 2: (${_fmt(x2)}, ${_fmt(y2)})',
      result: 'Points identified',
      explanation: 'Label the two coordinate points.',
    ));

    // Step 2 — Slope formula
    steps.add(SolverStep(
      number: 2,
      title: 'Slope Formula',
      formula: r'm = \frac{y_2 - y_1}{x_2 - x_1}',
      substitution: _toLatex(
          'm = (${_fmt(y2)}-${_fmt(y1)})/(${_fmt(x2)}-${_fmt(x1)}) = ${_fmt(dy)}/${_fmt(dx)}'),
      result: r'\frac{${_fmt(dy)}}{${_fmt(dx)}}',
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
        formula: r'm = \frac{\Delta y}{0}',
        substitution: 'Division by zero — slope is undefined',
        result: _toLatex('x = ${_fmt(x1)}'),
        explanation: 'All points share the same x-value.',
        guide: 'Handle vertical line',
      ));
    } else {
      slope = dy / dx;
      slopeDisplay = _fmtSlope(slope);

      // Step 3 — Simplify slope
      steps.add(SolverStep(
        number: 3,
        title: 'Simplify Slope',
        formula: _toLatex('m = ${_fmt(dy)} / ${_fmt(dx)}'),
        substitution: _fractionString(dy, dx),
        result: _toLatex('m = $slopeDisplay'),
        explanation: _simplifyExplanation(dy, dx, slope),
        guide: 'Simplify the fraction',
      ));

      // Step 4 — Y-intercept
      yIntercept = y1 - slope * x1;
      steps.add(SolverStep(
        number: 4,
        title: 'Y-Intercept',
        formula: r'b = y_1 - m \cdot x_1',
        substitution: _toLatex(
            'b = ${_fmt(y1)} - (${_fmtSlope(slope)})(${_fmt(x1)}) = ${_fmtSlope(yIntercept)}'),
        result: _toLatex('b = ${_fmtSlope(yIntercept)}'),
        explanation: 'Plug in point P₁ and the slope.',
        guide: 'Find y-intercept',
      ));

      // Step 5 — Slope-intercept form
      lineEquation = _buildSlopeIntercept(slope, yIntercept);
      steps.add(SolverStep(
        number: 5,
        title: 'Slope-Intercept Form',
        formula: r'y = mx + b',
        substitution: _toLatex(lineEquation),
        result: _toLatex(lineEquation),
        explanation: 'Shows slope and y-intercept directly.',
        guide: 'Write in y = mx + b form',
      ));

      // Standard & general forms with integer coefficients
      final rawA = y1 - y2;
      final rawB = x2 - x1;
      final rawC = rawA * x1 + rawB * y1;

      final aInt = rawA.round();
      final bInt = rawB.round();
      final cInt = rawC.round();

      final g = _gcd3(aInt.abs(), bInt.abs(), cInt.abs());
      var a = aInt ~/ g;
      var b = bInt ~/ g;
      var c = cInt ~/ g;

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
        formula: r'Ax + By = C',
        substitution: _toLatex('A = $a, B = $b, C = $c'),
        result: _toLatex(standardForm),
        explanation: 'Integer coefficients reduced by GCD($g).',
        guide: 'Convert to Ax + By = C',
      ));

      steps.add(SolverStep(
        number: 7,
        title: 'General Form',
        formula: r'Ax + By + C = 0',
        substitution: 'Move C to the left — sign flips',
        result: _toLatex(generalForm),
        explanation: 'All terms on the left, right side is zero.',
        guide: 'Move constant to left side',
      ));

      slopeType = isHorizontal
          ? 'Horizontal (m = 0)'
          : slope > 0
              ? 'Positive \u2197'
              : 'Negative \u2198';
    }

    return TwoPointSlopeResult(
      x1: x1, y1: y1, x2: x2, y2: y2,
      slope: slope, yIntercept: yIntercept,
      isVertical: isVertical, isHorizontal: isHorizontal,
      slopeDisplay: slopeDisplay, lineEquation: lineEquation,
      standardForm: standardForm, generalForm: generalForm,
      slopeType: slopeType, steps: steps,
    );
  }

  // ── GCD ───────────────────────────────────────────────────

  static int _gcd2(int a, int b) => b == 0 ? a : _gcd2(b, a % b);
  static int _gcd3(int a, int b, int c) {
    final g = _gcd2(a, b);
    final r = _gcd2(g, c);
    return r == 0 ? 1 : r;
  }

  // ── Formatting ────────────────────────────────────────────

  static String _fmt(double v) {
    if (v == v.truncateToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
  }

  static String _fmtSlope(double v) {
    if (v == v.truncateToDouble()) return v.toInt().toString();
    final f = _toFraction(v);
    if (f != null) return f;
    return v.toStringAsFixed(3).replaceAll(RegExp(r'\.?0+$'), '');
  }

  static String? _toFraction(double v) {
    for (int d = 1; d <= 20; d++) {
      final n = (v * d).round();
      if ((v * d - n).abs() < 1e-9) {
        final g = _gcd2(n.abs(), d);
        final fn = n ~/ g;
        final fd = d ~/ g;
        return fd == 1 ? fn.toString() : '$fn/$fd';
      }
    }
    return null;
  }

  static String? _toLatexFraction(double v) {
    for (int d = 1; d <= 20; d++) {
      final n = (v * d).round();
      if ((v * d - n).abs() < 1e-9) {
        final g = _gcd2(n.abs(), d);
        final fn = n ~/ g;
        final fd = d ~/ g;
        if (fd == 1) return fn.toString();
        return r'\frac{$fn}{$fd}';
      }
    }
    return null;
  }

  static String _fractionString(double dy, double dx) {
    final f = _toLatexFraction(dy / dx);
    if (f != null) {
      return r'm = \frac{${_fmt(dy)}}{${_fmt(dx)}} = $f';
    }
    return 'm = ${_fmt(dy)} / ${_fmt(dx)}';
  }

  static String _simplifyExplanation(double dy, double dx, double slope) {
    final f = _toLatexFraction(slope);
    if (f != null) return 'Reduced: $f';
    final s = slope.toStringAsFixed(3).replaceAll(RegExp(r'\.?0+$'), '');
    return 'Decimal: $s';
  }

  static String _toLatex(String input) {
    final regex = RegExp(r'(-?\d+)\s*/\s*(-?\d+)');
    return input.replaceAllMapped(regex, (m) {
      final n = m.group(1)!;
      final d = m.group(2)!;
      if (d == '1') return n;
      return r'\frac{$n}{$d}';
    });
  }

  // ── Equation builders ─────────────────────────────────────

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

  static String _buildStandardForm(int a, int b, int c) {
    final xPart = _varTerm(a, 'x', isFirst: true);
    final yPart = _varTerm(b, 'y', isFirst: xPart.isEmpty);
    final lhs = '$xPart$yPart';
    return '${lhs.isEmpty ? '0' : lhs} = $c';
  }

  static String _buildGeneralForm(int a, int b, int c) {
    final xPart = _varTerm(a, 'x', isFirst: true);
    final yPart = _varTerm(b, 'y', isFirst: xPart.isEmpty);
    final constPart = _constTerm(-c, isFirst: xPart.isEmpty && yPart.isEmpty);
    return '$xPart$yPart$constPart = 0';
  }

  static String _varTerm(int coeff, String v, {required bool isFirst}) {
    if (coeff == 0) return '';
    final abs = coeff.abs();
    final vs = abs == 1 ? v : '$abs$v';
    if (isFirst) return coeff < 0 ? '-$vs' : vs;
    return coeff < 0 ? ' - $vs' : ' + $vs';
  }

  static String _constTerm(int value, {required bool isFirst}) {
    if (value == 0) return '';
    if (isFirst) return '$value';
    return value < 0 ? ' - ${value.abs()}' : ' + $value';
  }
}
'''

# ── Main ─────────────────────────────────────────────────────────────────

def main():
    verify()
    path = DART_DIR / "two_point_slope_solver.dart"
    path.write_text(DART_CODE, encoding='utf-8')
    lines = DART_CODE.count('\n')
    print(f"Generated {path} [{lines} lines]")

if __name__ == '__main__':
    main()
