// lib/modules/yintercept/solver/parallel_perpendicular_solver.dart
import 'fraction.dart';

// ─────────────────────────────────────────────────────────────
// PARALLEL / PERPENDICULAR SOLVER
//
// Accepts two lines in either:
//   • General form   Ax + By + C = 0   (e.g. "3x + 5y + 7 = 0")
//   • Standard form  Ax + By = C       (e.g. "5x - 3y = 2")
//
// Converts each to slope-intercept form y = mx + b,
// then determines if the lines are parallel, perpendicular, or neither.
// ─────────────────────────────────────────────────────────────

enum PPRelationship { parallel, perpendicular, neither, sameLine }

enum PPInputFormat { generalForm, standardForm, unknown }

// ── Result ────────────────────────────────────────────────────

class PPResult {
  /// Slope of line 1. Null for vertical lines.
  final YIFraction? slope1;

  /// Slope of line 2. Null for vertical lines.
  final YIFraction? slope2;

  /// y-intercept of line 1. Null for vertical lines.
  final YIFraction? yIntercept1;

  /// y-intercept of line 2. Null for vertical lines.
  final YIFraction? yIntercept2;

  /// Slope-intercept form of line 1.
  final String slopeIntercept1;

  /// Slope-intercept form of line 2.
  final String slopeIntercept2;

  /// The relationship between the two lines.
  final PPRelationship relationship;

  /// Human-readable verdict string.
  final String verdict;

  /// Emoji/symbol for the verdict.
  final String verdictSymbol;

  /// Full solution steps.
  final List<PPSolverStep> steps;

  const PPResult({
    required this.slope1,
    required this.slope2,
    required this.yIntercept1,
    required this.yIntercept2,
    required this.slopeIntercept1,
    required this.slopeIntercept2,
    required this.relationship,
    required this.verdict,
    required this.verdictSymbol,
    required this.steps,
  });
}

class PPSolverStep {
  final int number;
  final String title;
  final String formula;
  final String substitution;
  final String result;
  final String explanation;

  const PPSolverStep({
    required this.number,
    required this.title,
    required this.formula,
    this.substitution = '',
    required this.result,
    this.explanation = '',
  });
}

// ── Solver ────────────────────────────────────────────────────

class ParallelPerpendicularSolver {
  ParallelPerpendicularSolver._();

  /// Parse two line strings and compute their relationship.
  /// Returns null if either string cannot be parsed.
  static PPResult? tryParse({
    required String line1,
    required String line2,
  }) {
    final c1 = _parseLineString(line1.trim());
    final c2 = _parseLineString(line2.trim());
    if (c1 == null || c2 == null) return null;
    return _compute(c1, c2);
  }

  // ── Core computation ─────────────────────────────────────

  static PPResult _compute(_LineCoeffs l1, _LineCoeffs l2) {
    final steps = <PPSolverStep>[];
    int stepNum = 1;

    // ── Step 1: Identify line 1 ──
    steps.add(PPSolverStep(
      number: stepNum++,
      title: 'Identify Line 1',
      formula: l1.format == PPInputFormat.generalForm
          ? 'Ax + By + C = 0'
          : 'Ax + By = C',
      substitution: l1.display,
      result: 'A₁ = ${l1.A},  B₁ = ${l1.B},  C₁ = ${l1.C}',
      explanation: 'Extract coefficients from Line 1.',
    ));

    // ── Step 2: Identify line 2 ──
    steps.add(PPSolverStep(
      number: stepNum++,
      title: 'Identify Line 2',
      formula: l2.format == PPInputFormat.generalForm
          ? 'Ax + By + C = 0'
          : 'Ax + By = C',
      substitution: l2.display,
      result: 'A₂ = ${l2.A},  B₂ = ${l2.B},  C₂ = ${l2.C}',
      explanation: 'Extract coefficients from Line 2.',
    ));

    // ── Convert L1 to slope-intercept ──
    final conv1 = _toSlopeIntercept(l1, 1, steps, stepNum);
    stepNum = conv1.nextStep;
    final si1 = conv1.equation;
    final m1  = conv1.slope;
    final b1  = conv1.yIntercept;

    // ── Convert L2 to slope-intercept ──
    final conv2 = _toSlopeIntercept(l2, 2, steps, stepNum);
    stepNum = conv2.nextStep;
    final si2 = conv2.equation;
    final m2  = conv2.slope;
    final b2  = conv2.yIntercept;

    // ── Slope comparison step ──
    final m1Str = m1 == null ? 'undefined (vertical)' : m1.toString();
    final m2Str = m2 == null ? 'undefined (vertical)' : m2.toString();

    steps.add(PPSolverStep(
      number: stepNum++,
      title: 'Compare Slopes',
      formula: 'Parallel: m₁ = m₂   |   Perpendicular: m₁ × m₂ = -1',
      substitution: 'm₁ = $m1Str,   m₂ = $m2Str',
      result: 'm₁ = $m1Str   and   m₂ = $m2Str',
      explanation:
          'Compare the two slopes to determine the line relationship.',
    ));

    // ── Determine relationship ──
    final rel = _relationship(m1, m2, b1, b2);

    // ── Verdict step ──
    String verdictFormula = '';
    String verdictSub = '';
    switch (rel) {
      case PPRelationship.parallel:
        verdictFormula = 'm₁ = m₂';
        verdictSub = '$m1Str = $m2Str  ✓';
        break;
      case PPRelationship.perpendicular:
        verdictFormula = 'm₁ × m₂ = -1';
        final product = m1 != null && m2 != null
            ? (m1 * m2).simplified().toString()
            : 'undefined';
        verdictSub = '$m1Str × $m2Str = $product';
        break;
      case PPRelationship.sameLine:
        verdictFormula = 'm₁ = m₂  and  b₁ = b₂';
        verdictSub = 'Same slope and same intercept';
        break;
      case PPRelationship.neither:
        verdictFormula = 'm₁ ≠ m₂  and  m₁ × m₂ ≠ -1';
        verdictSub = 'Slopes are different and not negative reciprocals';
        break;
    }

    steps.add(PPSolverStep(
      number: stepNum++,
      title: 'Conclusion',
      formula: verdictFormula,
      substitution: verdictSub,
      result: _verdictString(rel),
      explanation: _verdictExplanation(rel),
    ));

    return PPResult(
      slope1: m1,
      slope2: m2,
      yIntercept1: b1,
      yIntercept2: b2,
      slopeIntercept1: si1,
      slopeIntercept2: si2,
      relationship: rel,
      verdict: _verdictString(rel),
      verdictSymbol: _verdictSymbol(rel),
      steps: steps,
    );
  }

  // ── Convert one line to slope-intercept, appending steps ──

  static _ConvResult _toSlopeIntercept(
    _LineCoeffs l,
    int lineNum,
    List<PPSolverStep> steps,
    int startStep,
  ) {
    int n = startStep;
    final sub = lineNum == 1 ? '₁' : '₂';

    // Vertical line: B = 0
    if (l.B == 0) {
      if (l.A == 0) {
        steps.add(PPSolverStep(
          number: n++,
          title: 'Convert Line $lineNum to Slope-Intercept',
          formula: 'Degenerate (A = B = 0)',
          substitution: l.display,
          result: 'Invalid line',
          explanation: 'Both A and B are zero — this is not a valid line.',
        ));
        return _ConvResult(
          equation: 'Invalid',
          slope: null,
          yIntercept: null,
          nextStep: n,
        );
      }
      // x = -C/A  (general) or x = C/A (standard)
      final xVal = l.format == PPInputFormat.generalForm
          ? YIFraction(numerator: -l.C, denominator: l.A).simplified()
          : YIFraction(numerator: l.C, denominator: l.A).simplified();
      steps.add(PPSolverStep(
        number: n++,
        title: 'Convert Line $lineNum to Slope-Intercept',
        formula: 'B$sub = 0 → vertical line',
        substitution: l.display,
        result: 'x = $xVal  (vertical — slope undefined)',
        explanation:
            'When B = 0 there is no y-term, so the line is vertical with undefined slope.',
      ));
      return _ConvResult(
        equation: 'x = $xVal',
        slope: null,
        yIntercept: null,
        nextStep: n,
      );
    }

    // For general form  Ax + By + C = 0  →  y = (-A/B)x + (-C/B)
    // For standard form Ax + By = C      →  y = (-A/B)x + (C/B)
    final YIFraction m;
    final YIFraction b;

    if (l.format == PPInputFormat.generalForm) {
      m = YIFraction(numerator: -l.A, denominator: l.B).simplified();
      b = YIFraction(numerator: -l.C, denominator: l.B).simplified();
    } else {
      // standard: Ax + By = C  →  y = (-A/B)x + C/B
      m = YIFraction(numerator: -l.A, denominator: l.B).simplified();
      b = YIFraction(numerator: l.C, denominator: l.B).simplified();
    }

    final eq = _slopeInterceptStr(m, b);

    steps.add(PPSolverStep(
      number: n++,
      title: 'Convert Line $lineNum to Slope-Intercept',
      formula: l.format == PPInputFormat.generalForm
          ? 'By = -Ax - C  →  y = (-A/B)x + (-C/B)'
          : 'By = C - Ax   →  y = (-A/B)x + (C/B)',
      substitution: '${l.B}y = ${l.format == PPInputFormat.generalForm ? '-' : ''}${l.A != 0 ? '${-l.A}x' : ''}'
          '${l.format == PPInputFormat.generalForm ? ' - ${l.C}' : ' + ${l.C}'}',
      result: eq,
      explanation:
          'Isolate y by moving the x-term and constant, then divide by B$sub = ${l.B}.',
    ));

    return _ConvResult(equation: eq, slope: m, yIntercept: b, nextStep: n);
  }

  // ── Relationship logic ────────────────────────────────────

  static PPRelationship _relationship(
    YIFraction? m1,
    YIFraction? m2,
    YIFraction? b1,
    YIFraction? b2,
  ) {
    // Both vertical
    if (m1 == null && m2 == null) {
      if (b1 == b2) return PPRelationship.sameLine;
      return PPRelationship.parallel;
    }
    // One vertical, one not → neither
    if (m1 == null || m2 == null) return PPRelationship.neither;

    // Same slope
    if (m1 == m2) {
      if (b1 != null && b2 != null && b1 == b2) return PPRelationship.sameLine;
      return PPRelationship.parallel;
    }

    // ── FIX: Check perpendicular via cross-multiplication ──
    // m1 * m2 == -1  ⟺  numerator(m1 * m2) == -denominator(m1 * m2)
    // This avoids relying on == against a hardcoded YIFraction(-1, 1),
    // which fails when simplified() leaves the product as e.g. -15/15.
    final product = (m1 * m2).simplified();
    final isNegativeOne = product.numerator == -product.denominator;
    if (isNegativeOne) {
      return PPRelationship.perpendicular;
    }

    return PPRelationship.neither;
  }

  // ── Parsing ───────────────────────────────────────────────

  /// Tries general form first, then standard form.
  static _LineCoeffs? _parseLineString(String input) {
    final gf = _parseGeneralForm(input);
    if (gf != null) return gf;
    final sf = _parseStandardForm(input);
    return sf;
  }

  /// Parses "Ax + By + C = 0" variants.
  static _LineCoeffs? _parseGeneralForm(String input) {
    final s = _normalise(input);

    // Must end with "=0"
    if (!s.endsWith('=0')) return null;
    final lhs = s.substring(0, s.length - 2);

    final coeffs = _extractCoeffsFromExpression(lhs);
    if (coeffs == null) return null;

    return _LineCoeffs(
      A: coeffs.$1,
      B: coeffs.$2,
      C: coeffs.$3,
      format: PPInputFormat.generalForm,
      display: _buildGeneralFormDisplay(coeffs.$1, coeffs.$2, coeffs.$3),
    );
  }

  /// Parses "Ax + By = C" variants.
  static _LineCoeffs? _parseStandardForm(String input) {
    final s = _normalise(input);

    final eqIdx = s.indexOf('=');
    if (eqIdx < 0) return null;
    final lhs = s.substring(0, eqIdx);
    final rhs = s.substring(eqIdx + 1);

    // rhs must be a plain integer (standard form C)
    final C = int.tryParse(rhs);
    if (C == null) return null;

    final coeffs = _extractCoeffsFromExpression(lhs);
    if (coeffs == null) return null;

    // coeffs.$3 should be 0 (no standalone constant in lhs for standard form)
    return _LineCoeffs(
      A: coeffs.$1,
      B: coeffs.$2,
      C: C,
      format: PPInputFormat.standardForm,
      display: _buildStandardFormDisplay(coeffs.$1, coeffs.$2, C),
    );
  }

  /// Extracts (A, B, freeConstant) from an expression like "3x+5y+7" or "-2x+y".
  static (int, int, int)? _extractCoeffsFromExpression(String expr) {
    int A = 0, B = 0, C = 0;

    // Tokenise into signed terms: e.g. "+3x", "-5y", "+7"
    final tokenPattern = RegExp(r'[+-]?[^+-]+');
    final tokens = tokenPattern.allMatches(expr).map((m) => m.group(0)!).toList();

    for (final tok in tokens) {
      if (tok.isEmpty) continue;
      if (tok.contains('x')) {
        final raw = tok.replaceAll('x', '').trim();
        A = _parseCoefficient(raw);
      } else if (tok.contains('y')) {
        final raw = tok.replaceAll('y', '').trim();
        B = _parseCoefficient(raw);
      } else {
        final val = int.tryParse(tok.trim());
        if (val == null) return null;
        C = val;
      }
    }

    return (A, B, C);
  }

  static int _parseCoefficient(String raw) {
    if (raw.isEmpty || raw == '+') return 1;
    if (raw == '-') return -1;
    return int.tryParse(raw) ?? 0;
  }

  static String _normalise(String s) => s
      .replaceAll('\u2212', '-')
      .replaceAll(' ', '')
      .toLowerCase();

  // ── Display builders ──────────────────────────────────────

  static String _buildGeneralFormDisplay(int A, int B, int C) {
    final x = _termStr(A, 'x', isFirst: true);
    final y = _termStr(B, 'y', isFirst: x.isEmpty);
    final c = C == 0
        ? ''
        : C > 0
            ? '+ $C'
            : '- ${C.abs()}';
    return '${[x, y, c].where((s) => s.isNotEmpty).join(' ')} = 0';
  }

  static String _buildStandardFormDisplay(int A, int B, int C) {
    final x = _termStr(A, 'x', isFirst: true);
    final y = _termStr(B, 'y', isFirst: x.isEmpty);
    return '${[x, y].where((s) => s.isNotEmpty).join(' ')} = $C';
  }

  static String _termStr(int coeff, String v, {required bool isFirst}) {
    if (coeff == 0) return '';
    final abs = coeff.abs();
    final varStr = abs == 1 ? v : '$abs$v';
    if (isFirst) return coeff < 0 ? '-$varStr' : varStr;
    return coeff < 0 ? '- $varStr' : '+ $varStr';
  }

  static String _slopeInterceptStr(YIFraction m, YIFraction b) {
    String mPart;
    if (m.isZero) return 'y = $b';
    if (m == const YIFraction(numerator: 1, denominator: 1)) {
      mPart = 'x';
    // ignore: curly_braces_in_flow_control_structures
    } else if (m == const YIFraction(numerator: -1, denominator: 1)) mPart = '-x';
    // ignore: curly_braces_in_flow_control_structures
    else mPart = '${m}x';

    if (b.isZero)        return 'y = $mPart';
    if (b.numerator > 0) return 'y = $mPart + $b';
    return 'y = $mPart - ${b.abs()}';
  }

  // ── Verdict helpers ───────────────────────────────────────

  static String _verdictString(PPRelationship r) {
    switch (r) {
      case PPRelationship.parallel:      return 'Parallel';
      case PPRelationship.perpendicular: return 'Perpendicular';
      case PPRelationship.sameLine:      return 'Same Line (Coincident)';
      case PPRelationship.neither:       return 'Neither';
    }
  }

  static String _verdictSymbol(PPRelationship r) {
    switch (r) {
      case PPRelationship.parallel:      return '∥';
      case PPRelationship.perpendicular: return '⊥';
      case PPRelationship.sameLine:      return '≡';
      case PPRelationship.neither:       return '∦';
    }
  }

  static String _verdictExplanation(PPRelationship r) {
    switch (r) {
      case PPRelationship.parallel:
        return 'Equal slopes (m₁ = m₂) and different y-intercepts mean the lines never intersect.';
      case PPRelationship.perpendicular:
        return 'Slopes are negative reciprocals (m₁ × m₂ = -1), so the lines meet at a right angle.';
      case PPRelationship.sameLine:
        return 'Identical slopes and intercepts — these are the same line.';
      case PPRelationship.neither:
        return 'Slopes are neither equal nor negative reciprocals, so the lines intersect at an oblique angle.';
    }
  }
}

// ── Internal helpers ──────────────────────────────────────────

class _LineCoeffs {
  final int A;
  final int B;
  final int C;
  final PPInputFormat format;
  final String display;
  const _LineCoeffs({
    required this.A,
    required this.B,
    required this.C,
    required this.format,
    required this.display,
  });
}

class _ConvResult {
  final String equation;
  final YIFraction? slope;
  final YIFraction? yIntercept;
  final int nextStep;
  const _ConvResult({
    required this.equation,
    required this.slope,
    required this.yIntercept,
    required this.nextStep,
  });
}

// Re-export so the UI only needs to import this file for the PP feature.
// YIFraction is already in fraction.dart — referenced via relative import.