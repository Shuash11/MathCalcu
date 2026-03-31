import 'dart:math';
import 'fraction.dart';

// ─────────────────────────────────────────────────────────────
// Y-INTERCEPT SOLVER
// Supports two input types:
//   1. Standard form  Ax + By = C   (e.g. "6x - 3y = -3")
//   2. Slope-intercept parts  m + b  (e.g. m = -3/4, b = 3/2)
// ─────────────────────────────────────────────────────────────

// ── Result ────────────────────────────────────────────────────

enum YIInputType { slopeIntercept, standardForm }

class YIResult {
  /// The slope. Null only for a vertical line.
  final YIFraction? slope;

  /// The y-intercept. Null only for a vertical line.
  final YIFraction? yIntercept;

  /// The x-intercept. Null when slope is zero (horizontal line).
  final YIFraction? xIntercept;

  /// Human-readable slope-intercept equation string.
  final String equation;

  /// Standard form: Ax + By = C
  final String standardForm;

  /// General form: Ax + By + C = 0
  final String generalForm;

  /// "Rising ↗", "Falling ↘", or "Horizontal →".
  final String direction;

  /// Angle of inclination in degrees (e.g. "-36.9°").
  final String angle;

  /// Rise/run ratio as a string (e.g. "-3/4 per 1").
  final String riseRun;

  /// Which input type produced this result.
  final YIInputType inputType;

  /// Step-by-step working.
  final List<YISolverStep> steps;

  const YIResult({
    required this.slope,
    required this.yIntercept,
    required this.xIntercept,
    required this.equation,
    required this.standardForm,
    required this.generalForm,
    required this.direction,
    required this.angle,
    required this.riseRun,
    required this.inputType,
    required this.steps,
  });
}

class YISolverStep {
  final int number;
  final String title;
  final String formula;
  final String substitution;
  final String result;
  final String explanation;

  const YISolverStep({
    required this.number,
    required this.title,
    required this.formula,
    this.substitution = '',
    required this.result,
    this.explanation = '',
  });
}

// ── Solver ────────────────────────────────────────────────────

class YInterceptSolver {
  YInterceptSolver._();

  // ── Public entry points ──────────────────────────────────

  /// Solve from slope m and y-intercept b (as fractions).
  static YIResult fromSlopeIntercept({
    required YIFraction m,
    required YIFraction b,
  }) {
    return _computeSlopeIntercept(m, b);
  }

  /// Solve from slope m and y-intercept b (as doubles).
  static YIResult fromSlopeInterceptDoubles({
    required double m,
    required double b,
  }) {
    return _computeSlopeIntercept(
      YIFraction.fromDouble(m),
      YIFraction.fromDouble(b),
    );
  }

  /// Solve from standard form  Ax + By = C  (as integers).
  static YIResult fromStandardForm({
    required int A,
    required int B,
    required int C,
  }) {
    return _computeStandardForm(A, B, C);
  }

  /// Parse and solve a standard-form string like "6x - 3y = -3".
  static YIResult? tryParseStandardForm(String input) {
    final parsed = _parseStandardFormString(input);
    if (parsed == null) return null;
    return _computeStandardForm(parsed.$1, parsed.$2, parsed.$3);
  }

  /// Parse and solve a slope-intercept string pair like m="−3/4", b="3/2".
  static YIResult? tryParseSlopeIntercept({
    required String mText,
    required String bText,
  }) {
    final mFrac = _parseFractionString(mText);
    final bFrac = _parseFractionString(bText);
    if (mFrac == null || bFrac == null) return null;
    return _computeSlopeIntercept(mFrac, bFrac);
  }

  // ── Core computation: slope-intercept ────────────────────

  static YIResult _computeSlopeIntercept(YIFraction m, YIFraction b) {
    final ms = m.simplified();
    final bs = b.simplified();

    final steps = <YISolverStep>[];

    steps.add(YISolverStep(
      number: 1,
      title: 'Identify slope and y-intercept',
      formula: 'y = mx + b',
      substitution: 'm = $ms,  b = $bs',
      result: 'Given directly',
      explanation: 'The slope m and y-intercept b are already known.',
    ));

    // Slope-intercept equation
    final eq = _equationString(ms, bs);

    steps.add(YISolverStep(
      number: 2,
      title: 'Write slope-intercept equation',
      formula: 'y = mx + b',
      substitution: eq,
      result: eq,
      explanation: 'Substitute m and b into y = mx + b.',
    ));

    // x-intercept: set y = 0  →  x = -b / m
    YIFraction? xInt;
    if (!ms.isZero) {
      xInt = (bs * const YIFraction(numerator: -1, denominator: 1))
          .divided(ms)
          .simplified();
      steps.add(YISolverStep(
        number: 3,
        title: 'Find x-intercept',
        formula: '0 = mx + b  →  x = -b / m',
        substitution: 'x = -($bs) / ($ms) = $xInt',
        result: 'x-intercept = $xInt',
        explanation: 'Set y = 0 and solve for x.',
      ));
    } else {
      steps.add(const YISolverStep(
        number: 3,
        title: 'x-intercept',
        formula: '0 = mx + b',
        substitution: 'm = 0, so 0 = b (no x term)',
        result: 'No x-intercept (horizontal line)',
        explanation:
            'A horizontal line never crosses the x-axis (unless b = 0).',
      ));
    }

    // Convert to standard form: multiply through by denominator of m to clear fractions
    // y = (p/q)x + (r/s)  →  multiply by lcm(q,s)
    // Standard: Ax - y = -b  scaled to integers
    // We derive A, B, C integers from m=p/q, b=r/s
    // y = ms*x + bs  →  -ms*x + y = bs  →  multiply by ms.denominator * bs.denominator / gcd
    final sfStr = _standardFormFromSlopeIntercept(ms, bs);
    final gfStr = _generalFormFromSlopeIntercept(ms, bs);

    steps.add(YISolverStep(
      number: 4,
      title: 'Convert to Standard Form',
      formula: 'Ax + By = C',
      substitution: 'Rearrange y = mx + b → -mx + y = b, scale to integers',
      result: sfStr,
      explanation:
          'Move the x-term to the left and scale all coefficients to integers.',
    ));

    steps.add(YISolverStep(
      number: 5,
      title: 'Convert to General Form',
      formula: 'Ax + By + C = 0',
      substitution: 'Move constant to left: $sfStr → $gfStr',
      result: gfStr,
      explanation: 'Move the constant C to the left side so the right side equals 0.',
    ));

    // Angle
    final angleVal = atan(ms.toDouble()) * 180 / pi;

    steps.add(YISolverStep(
      number: 6,
      title: 'Angle of inclination',
      formula: 'θ = arctan(m)',
      substitution: 'θ = arctan(${ms.toDouble().toStringAsFixed(4)})',
      result: '${angleVal.toStringAsFixed(1)}°',
      explanation: 'Angle the line makes with the positive x-axis.',
    ));

    return YIResult(
      slope: ms,
      yIntercept: bs,
      xIntercept: xInt,
      equation: eq,
      standardForm: sfStr,
      generalForm: gfStr,
      direction: _direction(ms.toDouble()),
      angle: '${angleVal.toStringAsFixed(1)}°',
      riseRun: _riseRun(ms),
      inputType: YIInputType.slopeIntercept,
      steps: steps,
    );
  }

  // ── Core computation: standard form ──────────────────────

  static YIResult _computeStandardForm(int A, int B, int C) {
    final steps = <YISolverStep>[];

    steps.add(YISolverStep(
      number: 1,
      title: 'Write standard form equation',
      formula: 'Ax + By = C',
      substitution:
          '${_termStr(A, 'x', isFirst: true)} ${_termStr(B, 'y', isFirst: false)} = $C',
      result: _sfString(A, B, C),
      explanation: 'Identify coefficients A = $A, B = $B, C = $C.',
    ));

    // General form from given A,B,C
    final gfStr = _generalFormFromABC(A, B, C);

    steps.add(YISolverStep(
      number: 2,
      title: 'Write General Form',
      formula: 'Ax + By + C = 0',
      substitution: 'Move C to left: ${_sfString(A, B, C)} → $gfStr',
      result: gfStr,
      explanation: 'Move the constant to the left side so right side equals 0.',
    ));

    // Vertical line: B = 0
    if (B == 0) {
      if (A == 0) {
        return YIResult(
          slope: null,
          yIntercept: null,
          xIntercept: null,
          equation: C == 0 ? 'All real numbers' : 'No solution',
          standardForm: _sfString(A, B, C),
          generalForm: gfStr,
          direction: 'N/A',
          angle: 'N/A',
          riseRun: 'N/A',
          inputType: YIInputType.standardForm,
          steps: steps,
        );
      }
      final xVal = YIFraction(numerator: C, denominator: A).simplified();
      steps.add(YISolverStep(
        number: 3,
        title: 'Vertical line',
        formula: 'Ax = C  →  x = C/A',
        substitution: 'x = $C / $A = $xVal',
        result: 'x = $xVal',
        explanation: 'B = 0 means no y-term — this is a vertical line.',
      ));
      return YIResult(
        slope: null,
        yIntercept: null,
        xIntercept: xVal,
        equation: 'x = $xVal',
        standardForm: _sfString(A, B, C),
        generalForm: gfStr,
        direction: 'Vertical |',
        angle: '90.0°',
        riseRun: 'Undefined',
        inputType: YIInputType.standardForm,
        steps: steps,
      );
    }

    // Step 3 — Isolate y
    steps.add(YISolverStep(
      number: 3,
      title: 'Isolate y',
      formula: 'By = C - Ax  →  y = C/B - (A/B)x',
      substitution: '${B}y = $C - ${A}x',
      result: '${B}y = ${_termStr(-A, 'x', isFirst: true)} + $C',
      explanation: 'Move the x-term to the right side.',
    ));

    // Slope: m = -A/B
    final mFrac = YIFraction(numerator: -A, denominator: B).simplified();

    steps.add(YISolverStep(
      number: 4,
      title: 'Extract slope',
      formula: 'm = -A / B',
      substitution: 'm = -($A) / ($B) = ${-A}/$B',
      result: 'm = $mFrac',
      explanation: 'Divide both sides by B = $B.',
    ));

    // y-intercept: b = C/B
    final bFrac = YIFraction(numerator: C, denominator: B).simplified();

    steps.add(YISolverStep(
      number: 5,
      title: 'Extract y-intercept',
      formula: 'b = C / B',
      substitution: 'b = $C / $B',
      result: 'b = $bFrac',
      explanation: 'The constant term after dividing by B.',
    ));

    // Slope-intercept equation
    final eq = _equationString(mFrac, bFrac);

    steps.add(YISolverStep(
      number: 6,
      title: 'Slope-intercept form',
      formula: 'y = mx + b',
      substitution: eq,
      result: eq,
      explanation: 'Final equation in slope-intercept form.',
    ));

    // x-intercept
    YIFraction? xInt;
    if (!mFrac.isZero) {
      xInt = (bFrac * const YIFraction(numerator: -1, denominator: 1))
          .divided(mFrac)
          .simplified();
      steps.add(YISolverStep(
        number: 7,
        title: 'Find x-intercept',
        formula: '0 = mx + b  →  x = -b / m',
        substitution: 'x = -($bFrac) / ($mFrac) = $xInt',
        result: 'x-intercept = $xInt',
        explanation: 'Set y = 0 and solve for x.',
      ));
    }

    // Angle
    final angleVal = atan(mFrac.toDouble()) * 180 / pi;

    steps.add(YISolverStep(
      number: xInt != null ? 8 : 7,
      title: 'Angle of inclination',
      formula: 'θ = arctan(m)',
      substitution: 'θ = arctan(${mFrac.toDouble().toStringAsFixed(4)})',
      result: '${angleVal.toStringAsFixed(1)}°',
      explanation: 'Angle the line makes with the positive x-axis.',
    ));

    return YIResult(
      slope: mFrac,
      yIntercept: bFrac,
      xIntercept: xInt,
      equation: eq,
      standardForm: _sfString(A, B, C),
      generalForm: gfStr,
      direction: _direction(mFrac.toDouble()),
      angle: '${angleVal.toStringAsFixed(1)}°',
      riseRun: _riseRun(mFrac),
      inputType: YIInputType.standardForm,
      steps: steps,
    );
  }

  // ── Form conversion helpers ───────────────────────────────

  /// Derives standard form Ax + By = C from slope m=p/q and intercept b=r/s.
  /// Multiplies through by lcm(q, s) to get integer coefficients.
  static String _standardFormFromSlopeIntercept(YIFraction m, YIFraction b) {
    if (m.isZero) {
      // y = b  →  y = b  (standard: 0x + 1y = b)
      return 'y = $b';
    }
    // y = (p/q)x + (r/s)
    // Multiply by lcm(q, s): lcm*q denominator clears x coeff, lcm*s clears b
    final q = m.denominator;
    final s = b.denominator;
    final scale = _lcm(q, s);

    // Scaled: scale*y = (scale*p/q)*x + (scale*r/s)
    // Move x: -(scale*p/q)*x + scale*y = scale*r/s  → all integers
    final A = -(m.numerator * (scale ~/ q));
    final B = scale;
    final C = b.numerator * (scale ~/ s);

    // Reduce by gcd of all three
    final g = _gcd3(A.abs(), B.abs(), C.abs());
    final rA = A ~/ g;
    final rB = B ~/ g;
    final rC = C ~/ g;

    return _sfString(rA, rB, rC);
  }

  /// Derives general form Ax + By + C = 0 from slope and intercept.
  static String _generalFormFromSlopeIntercept(YIFraction m, YIFraction b) {
    if (m.isZero) {
      final neg = -b.numerator;
      final denom = b.denominator;
      if (denom == 1) return neg >= 0 ? 'y + $neg = 0' : 'y - ${neg.abs()} = 0';
      return 'y + ${YIFraction(numerator: neg, denominator: denom).simplified()} = 0';
    }
    final q = m.denominator;
    final s = b.denominator;
    final scale = _lcm(q, s);

    final A = -(m.numerator * (scale ~/ q));
    final B = scale;
    final C = -(b.numerator * (scale ~/ s));  // negated: move to left

    final g = _gcd3(A.abs(), B.abs(), C.abs());
    final rA = A ~/ g;
    final rB = B ~/ g;
    final rC = C ~/ g;

    return _gfString(rA, rB, rC);
  }

  /// Derives general form Ax + By + C = 0 from given A, B, C of standard form.
  static String _generalFormFromABC(int A, int B, int C) {
    // Ax + By = C  →  Ax + By - C = 0
    return _gfString(A, B, -C);
  }

  // ── String parsing ────────────────────────────────────────

  static (int, int, int)? _parseStandardFormString(String input) {
    final s = input
        .replaceAll('\u2212', '-')
        .replaceAll('\u00d7', '*')
        .replaceAll(' ', '');

    final pattern = RegExp(
      r'^([+-]?\d*)x([+-]\d*)y=([+-]?\d+)$',
      caseSensitive: false,
    );
    final match = pattern.firstMatch(s);
    if (match == null) return null;

    int? parseCoeff(String raw, String varName) {
      if (raw.isEmpty || raw == '+') return 1;
      if (raw == '-') return -1;
      return int.tryParse(raw);
    }

    final A = parseCoeff(match.group(1)!, 'x');
    final B = parseCoeff(match.group(2)!, 'y');
    final C = int.tryParse(match.group(3)!);

    if (A == null || B == null || C == null) return null;
    return (A, B, C);
  }

  static YIFraction? _parseFractionString(String text) {
    text = text.trim().replaceAll('\u2212', '-');

    if (text.contains(' ') && text.contains('/')) {
      final parts = text.split(' ');
      if (parts.length == 2) {
        final whole = int.tryParse(parts[0]);
        final fracParts = parts[1].split('/');
        if (whole != null && fracParts.length == 2) {
          final n = int.tryParse(fracParts[0]);
          final d = int.tryParse(fracParts[1]);
          if (n != null && d != null && d != 0) {
            final sign = whole < 0 ? -1 : 1;
            final totalNum = (whole.abs() * d + n) * sign;
            return YIFraction(numerator: totalNum, denominator: d).simplified();
          }
        }
      }
    }

    if (text.contains('/')) {
      final parts = text.split('/');
      if (parts.length == 2) {
        final n = int.tryParse(parts[0]);
        final d = int.tryParse(parts[1]);
        if (n != null && d != null && d != 0) {
          return YIFraction(numerator: n, denominator: d).simplified();
        }
      }
    }

    final intVal = int.tryParse(text);
    if (intVal != null) return YIFraction(numerator: intVal, denominator: 1);

    final dblVal = double.tryParse(text);
    if (dblVal != null) return YIFraction.fromDouble(dblVal);

    return null;
  }

  // ── Display helpers ───────────────────────────────────────

  static String _equationString(YIFraction m, YIFraction b) {
    final ms = m.simplified();
    final bs = b.simplified();

    String mPart;
    if (ms.isZero) {
      return 'y = $bs';
    // ignore: curly_braces_in_flow_control_structures
    } else if (ms == const YIFraction(numerator: 1, denominator: 1))  mPart = 'x';
    // ignore: curly_braces_in_flow_control_structures
    else if (ms == const YIFraction(numerator: -1, denominator: 1)) mPart = '-x';
    // ignore: curly_braces_in_flow_control_structures
    else mPart = '${ms}x';

    if (bs.isZero)        return 'y = $mPart';
    if (bs.numerator > 0) return 'y = $mPart + $bs';
    return 'y = $mPart - ${bs.abs()}';
  }

  /// Builds a readable "Ax + By = C" string.
  static String _sfString(int A, int B, int C) {
    final x = _termStr(A, 'x', isFirst: true);
    final y = _termStr(B, 'y', isFirst: false);
    return '$x $y = $C'.replaceAll('  ', ' ').trim();
  }

  /// Builds a readable "Ax + By + C = 0" string.
  static String _gfString(int A, int B, int C) {
    // C here is the constant moved to left (i.e. original -C from Ax+By=C)
    final xPart = _termStr(A, 'x', isFirst: true);
    final yPart = _termStr(B, 'y', isFirst: false);
    String cPart = '';
    if (C != 0) {
      cPart = C > 0 ? '+ $C' : '- ${C.abs()}';
    }
    final parts = [xPart, yPart, cPart]
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .join(' ');
    return '$parts = 0';
  }

  static String _termStr(int coeff, String v, {required bool isFirst}) {
    if (coeff == 0) return '';
    final abs = coeff.abs();
    final varStr = abs == 1 ? v : '$abs$v';
    if (isFirst) return coeff < 0 ? '-$varStr' : varStr;
    return coeff < 0 ? '- $varStr' : '+ $varStr';
  }

  static String _direction(double m) {
    if (m > 0) return 'Rising \u2197';
    if (m < 0) return 'Falling \u2198';
    return 'Horizontal \u2192';
  }

  static String _riseRun(YIFraction m) {
    final s = m.simplified();
    if (s.denominator == 1) return '${s.numerator} / 1';
    return '${s.numerator} / ${s.denominator}';
  }

  // ── Math utilities ────────────────────────────────────────

  static int _lcm(int a, int b) {
    if (a == 0 || b == 0) return 0;
    return (a * b).abs() ~/ _gcd2(a.abs(), b.abs());
  }

  static int _gcd2(int a, int b) {
    while (b != 0) {
      final t = b;
      b = a % b;
      a = t;
    }
    return a;
  }

  static int _gcd3(int a, int b, int c) => _gcd2(_gcd2(a, b), c);
}