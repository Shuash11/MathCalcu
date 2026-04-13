// lib/modules/yintercept/solver/parallel_perpendicular_solver.dart
import 'fraction.dart';

// ─────────────────────────────────────────────────────────────
// PARALLEL / PERPENDICULAR SOLVER
//
// Accepts any valid linear equation with terms in ANY order:
//   • General form      Ax + By + C = 0   e.g. "3x + 5y + 7 = 0"
//   • Standard form     Ax + By = C       e.g. "5x - 3y = 2"
//   • Slope-intercept   y = mx + b        e.g. "y = 2x + 1"
//   • Jumbled           e.g. "3 + y - 2x = 0", "-5 + 2x + y = 0"
// ─────────────────────────────────────────────────────────────

enum PPRelationship { parallel, perpendicular, neither, sameLine }

// ── Data models ───────────────────────────────────────────────

class PPResult {
  final YIFraction? slope1;
  final YIFraction? slope2;
  final YIFraction? yIntercept1;
  final YIFraction? yIntercept2;
  final String slopeIntercept1;
  final String slopeIntercept2;
  final PPRelationship relationship;
  final String verdict;
  final String verdictSymbol;
  final List<PPSolverStep> steps;

  // Raw integer coefficients exposed for the graph painter
  final int a1, b1, c1;
  final int a2, b2, c2;

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
    required this.a1,
    required this.b1,
    required this.c1,
    required this.a2,
    required this.b2,
    required this.c2,
  });
}

/// A single classroom step.
///
/// [groupKey] — when two steps share the same non-null groupKey they will be
/// rendered side-by-side in the UI (Line 1 on the left, Line 2 on the right).
/// Leave null for steps that should always be full-width.
class PPSolverStep {
  final int number;
  final String title;
  final List<PPStepBlock> blocks;

  /// Optional pairing key. Steps that share the same key are displayed
  /// side-by-side. The first step encountered with a key goes on the left,
  /// the second goes on the right.
  final String? groupKey;

  const PPSolverStep({
    required this.number,
    required this.title,
    required this.blocks,
    this.groupKey,
  });
}

/// Block types map directly to the four container styles in the UI.
enum PPBlockType {
  formula,      // the rule / theorem being applied
  substitution, // plugging in the actual numbers
  working,      // intermediate algebra lines
  result,       // the boxed final answer for that step
  note,         // plain-English teacher note
}

class PPStepBlock {
  final PPBlockType type;

  /// Plain text label shown above the LaTeX (optional).
  final String? label;

  /// LaTeX string rendered with flutter_math_fork.
  /// If null, [content] is rendered as plain text.
  final String? latex;

  /// Plain-text fallback / note content (used when latex is null).
  final String content;

  const PPStepBlock({
    required this.type,
    this.label,
    this.latex,
    this.content = '',
  });
}

// ── Internal helpers ──────────────────────────────────────────

class _Line {
  final int A, B, C;
  final String display;
  const _Line({
    required this.A,
    required this.B,
    required this.C,
    required this.display,
  });
}

class _SIResult {
  final YIFraction? slope;
  final YIFraction? yInt;
  final String equation;
  final String latexEquation;
  final bool isVertical;
  const _SIResult({
    required this.slope,
    required this.yInt,
    required this.equation,
    required this.latexEquation,
    required this.isVertical,
  });
}

// ── LaTeX helpers ─────────────────────────────────────────────

String _fracTex(YIFraction f) {
  final s = f.simplified();
  if (s.denominator == 1) return '${s.numerator}';
  final sign = (s.numerator < 0) ? '-' : '';
  final num = s.numerator.abs();
  // Clean standard Dart string interpolation (fixed from raw string hack)
  return '$sign\\frac{$num}{${s.denominator}}';
}

String _siLatex(YIFraction m, YIFraction b) {
  final mTex = _fracTex(m);
  final bAbs = _fracTex(b.abs());

  if (m.isZero) return 'y = ${_fracTex(b)}';

  String mPart;
  final ms = m.simplified();
  if (ms.numerator == 1 && ms.denominator == 1) {
    mPart = 'x';
  } else if (ms.numerator == -1 && ms.denominator == 1) {
    mPart = '-x';
  } else {
    mPart = '${mTex}x';
  }

  if (b.isZero) return 'y = $mPart';
  if (b.numerator > 0) return 'y = $mPart + ${_fracTex(b)}';
  return 'y = $mPart - $bAbs';
}

String _lineLatex(int A, int B, int C) {
  String t(int c, String v, bool first) {
    if (c == 0) return '';
    final abs = c.abs();
    final vs = abs == 1 ? v : '$abs$v';
    if (first) return c < 0 ? '-$vs' : vs;
    return c < 0 ? ' - $vs' : ' + $vs';
  }

  final x = t(A, 'x', true);
  final y = t(B, 'y', x.isEmpty);
  String c = '';
  if (C != 0) {
    if (x.isEmpty && y.isEmpty) {
      c = '$C';
    } else {
      c = C > 0 ? ' + $C' : ' - ${C.abs()}';
    }
  }
  return '$x$y$c = 0';
}

// ── Parser ────────────────────────────────────────────────────

class ParallelPerpendicularSolver {
  ParallelPerpendicularSolver._();

  static PPResult? tryParse({required String line1, required String line2}) {
    final l1 = _parseLine(line1.trim());
    final l2 = _parseLine(line2.trim());
    if (l1 == null || l2 == null) return null;
    return _compute(l1, l2);
  }

  static _Line? _parseLine(String raw) {
    final s = raw
        .replaceAll('\u2212', '-')
        .replaceAll('\u2013', '-')
        .replaceAll(' ', '')
        .toLowerCase();

    final eqIdx = s.indexOf('=');
    if (eqIdx < 0) return null;

    final lhsStr = s.substring(0, eqIdx);
    final rhsStr = s.substring(eqIdx + 1);

    int A = 0, B = 0, C = 0;

    void addTokens(String expr, int sign) {
      final e = (expr.isEmpty ? '' : (expr[0] != '-' ? '+$expr' : expr));
      final re = RegExp(r'[+\-][^+\-]+');
      for (final m in re.allMatches(e)) {
        final tok = m.group(0)!;
        final tokSign = tok[0] == '-' ? -1 : 1;
        final body = tok.substring(1);
        if (body.contains('x')) {
          final rawC = body.replaceAll('x', '');
          A += sign * tokSign * _coeff(rawC);
        } else if (body.contains('y')) {
          final rawC = body.replaceAll('y', '');
          B += sign * tokSign * _coeff(rawC);
        } else {
          final v = int.tryParse(body);
          if (v == null) return;
          C += sign * tokSign * v;
        }
      }
    }

    addTokens(lhsStr, 1);
    addTokens(rhsStr, -1);

    if (A == 0 && B == 0) return null;

    return _Line(A: A, B: B, C: C, display: _buildDisplay(A, B, C));
  }

  static int _coeff(String raw) {
    if (raw.isEmpty || raw == '+') return 1;
    if (raw == '-') return -1;
    return int.tryParse(raw) ?? 1;
  }

  static String _buildDisplay(int A, int B, int C) {
    String t(int c, String v, bool first) {
      if (c == 0) return '';
      final abs = c.abs();
      final vs = abs == 1 ? v : '$abs$v';
      if (first) return c < 0 ? '-$vs' : vs;
      return c < 0 ? ' - $vs' : ' + $vs';
    }

    final x = t(A, 'x', true);
    final y = t(B, 'y', x.isEmpty);
    String c = '';
    if (C != 0) {
      if (x.isEmpty && y.isEmpty) {
        c = '$C';
      } else {
        c = C > 0 ? ' + $C' : ' - ${C.abs()}';
      }
    }
    return '$x$y$c = 0';
  }

  // ── Core computation ──────────────────────────────────────

  static PPResult _compute(_Line l1, _Line l2) {
    final steps = <PPSolverStep>[];
    int n = 1;

    // ── STEP 1: Identify both lines ──────────────────────────
    steps.add(PPSolverStep(
      number: n++,
      title: 'Identify the given equations',
      blocks: [
        const PPStepBlock(
          type: PPBlockType.note,
          content:
              'We rewrite each equation in general form Ax + By + C = 0 so we can clearly identify the coefficients A, B, and C.',
        ),
        const PPStepBlock(
          type: PPBlockType.formula,
          latex: r'Ax + By + C = 0',
          content: 'General form',
          label: 'General form',
        ),
        PPStepBlock(
          type: PPBlockType.substitution,
          label: 'Line 1',
          latex:
              '${_lineLatex(l1.A, l1.B, l1.C)} \\quad\\Rightarrow\\quad A_1 = ${l1.A},\\; B_1 = ${l1.B},\\; C_1 = ${l1.C}',
          content: '',
        ),
        PPStepBlock(
          type: PPBlockType.substitution,
          label: 'Line 2',
          latex:
              '${_lineLatex(l2.A, l2.B, l2.C)} \\quad\\Rightarrow\\quad A_2 = ${l2.A},\\; B_2 = ${l2.B},\\; C_2 = ${l2.C}',
          content: '',
        ),
      ],
    ));

    // ── STEP 2 & 3: Convert each line to slope-intercept ─────
    final si1 = _toSI(l1);
    final si2 = _toSI(l2);
    steps.add(_buildSIStep(n++, 1, l1, si1, groupKey: 'convert_si'));
    steps.add(_buildSIStep(n++, 2, l2, si2, groupKey: 'convert_si'));

    // ── STEP 4: State the slopes ─────────────────────────────
    final m1Str = si1.slope == null ? 'undefined' : _fracTex(si1.slope!);
    final m2Str = si2.slope == null ? 'undefined' : _fracTex(si2.slope!);

    steps.add(PPSolverStep(
      number: n++,
      title: 'Extract and compare the slopes',
      blocks: [
        const PPStepBlock(
          type: PPBlockType.note,
          content:
              'The slope m is the coefficient of x after isolating y. We now read off the slopes from each slope-intercept form.',
        ),
        const PPStepBlock(
          type: PPBlockType.formula,
          latex: r'y = mx + b \quad\Rightarrow\quad \text{slope} = m',
          content: '',
          label: 'Slope-intercept form',
        ),
        PPStepBlock(
          type: PPBlockType.substitution,
          label: 'Line 1 slope',
          latex: '${si1.latexEquation} \\quad\\Rightarrow\\quad m_1 = $m1Str',
          content: '',
        ),
        PPStepBlock(
          type: PPBlockType.substitution,
          label: 'Line 2 slope',
          latex: '${si2.latexEquation} \\quad\\Rightarrow\\quad m_2 = $m2Str',
          content: '',
        ),
        PPStepBlock(
          type: PPBlockType.result,
          latex: 'm_1 = $m1Str \\qquad m_2 = $m2Str',
          content: '',
        ),
      ],
    ));

    // ── STEP 5: Apply the relationship tests ─────────────────
    final rel = _classify(si1, si2);
    steps.add(_buildTestStep(n++, si1, si2, rel));

    // ── STEP 6: Conclusion ───────────────────────────────────
    steps.add(PPSolverStep(
      number: n++,
      title: 'Conclusion',
      blocks: [
        PPStepBlock(
          type: PPBlockType.note,
          content: _verdictExplanation(rel),
        ),
        PPStepBlock(
          type: PPBlockType.result,
          latex:
              '\\textbf{${_verdictSymbol(rel)}\\; \\text{The lines are ${_verdictString(rel).replaceAll(' ', '\\ ')}}}',
          content:
              '${_verdictSymbol(rel)}  The lines are ${_verdictString(rel)}.',
        ),
      ],
    ));

    return PPResult(
      slope1: si1.slope,
      slope2: si2.slope,
      yIntercept1: si1.yInt,
      yIntercept2: si2.yInt,
      slopeIntercept1: si1.equation,
      slopeIntercept2: si2.equation,
      relationship: rel,
      verdict: _verdictString(rel),
      verdictSymbol: _verdictSymbol(rel),
      steps: steps,
      a1: l1.A,
      b1: l1.B,
      c1: l1.C,
      a2: l2.A,
      b2: l2.B,
      c2: l2.C,
    );
  }

  // ── Build slope-intercept conversion step ─────────────────

  static PPSolverStep _buildSIStep(
    int n,
    int lineNum,
    _Line l,
    _SIResult si, {
    String? groupKey,
  }) {
    // FIX: Removed the duplicate `final sub = lineNum == 1 ? 'Sub 1' : 'Sub 2';` line
    final sub = lineNum == 1 ? '_1' : '_2';

    final lineLabel = 'Line $lineNum';

    if (l.B == 0) {
      return PPSolverStep(
        number: n,
        title: 'Convert $lineLabel to slope-intercept form',
        groupKey: groupKey,
        blocks: [
          PPStepBlock(
            type: PPBlockType.note,
            content:
                'Since B$sub = 0, there is no y-term. This line is vertical and has an undefined slope.',
          ),
          const PPStepBlock(
            type: PPBlockType.formula,
            latex:
                r'B = 0 \;\Rightarrow\; Ax + C = 0 \;\Rightarrow\; x = -\tfrac{C}{A}',
            content: '',
            label: 'Vertical line rule',
          ),
          PPStepBlock(
            type: PPBlockType.substitution,
            label: 'Substituting',
            latex:
                '${l.A}x + (${l.C}) = 0 \\\\[4pt] ${l.A}x = ${-l.C} \\\\[4pt] x = \\dfrac{${-l.C}}{${l.A}}',
            content: '',
          ),
          PPStepBlock(
            type: PPBlockType.result,
            latex: si.latexEquation,
            content: '${si.equation}  (vertical — slope undefined)',
          ),
        ],
      );
    }

    final mNum = -l.A;
    final bNum = -l.C;
    final mFrac = YIFraction(numerator: mNum, denominator: l.B).simplified();
    final bFrac = YIFraction(numerator: bNum, denominator: l.B).simplified();

    return PPSolverStep(
      number: n,
      title: 'Convert $lineLabel to slope-intercept form',
      groupKey: groupKey,
      blocks: [
        PPStepBlock(
          type: PPBlockType.note,
          content:
              'Isolate y by moving all other terms to the right, then divide every term by B$sub = ${l.B}.',
        ),
        const PPStepBlock(
          type: PPBlockType.formula,
          latex:
              r'Ax + By + C = 0 \;\Rightarrow\; y = -\dfrac{A}{B}x - \dfrac{C}{B}',
          content: '',
          label: 'Conversion formula',
        ),
        PPStepBlock(
          type: PPBlockType.substitution,
          label: 'Substituting',
          latex: '${_lineLatex(l.A, l.B, l.C)} \\\\[6pt]'
              '${l.B}y = ${mNum < 0 ? mNum : '+$mNum'}x + $bNum \\\\[6pt]'
              'y = \\dfrac{$mNum}{${l.B}}x + \\dfrac{$bNum}{${l.B}}',
          content: '',
        ),
        PPStepBlock(
          type: PPBlockType.working,
          label: 'Simplifying',
          latex: 'm$sub = \\dfrac{$mNum}{${l.B}} = ${_fracTex(mFrac)} \\\\[6pt]'
              'b$sub = \\dfrac{$bNum}{${l.B}} = ${_fracTex(bFrac)}',
          content: '',
        ),
        PPStepBlock(
          type: PPBlockType.result,
          latex: si.latexEquation,
          content: si.equation,
        ),
      ],
    );
  }

  // ── Build the test step ───────────────────────────────────

  static PPSolverStep _buildTestStep(
      int n, _SIResult si1, _SIResult si2, PPRelationship rel) {
    final m1Tex =
        si1.slope != null ? _fracTex(si1.slope!) : r'\text{undefined}';
    final m2Tex =
        si2.slope != null ? _fracTex(si2.slope!) : r'\text{undefined}';

    switch (rel) {
      case PPRelationship.parallel:
        final b1Tex = si1.yInt != null ? _fracTex(si1.yInt!) : r'\text{—}';
        final b2Tex = si2.yInt != null ? _fracTex(si2.yInt!) : r'\text{—}';
        return PPSolverStep(
          number: n,
          title: 'Apply the parallel lines test',
          blocks: [
            const PPStepBlock(
              type: PPBlockType.note,
              content:
                  'Two lines are parallel when they have EQUAL slopes but DIFFERENT y-intercepts. They never intersect.',
            ),
            const PPStepBlock(
              type: PPBlockType.formula,
              latex: r'm_1 = m_2 \quad\text{and}\quad b_1 \neq b_2',
              content: '',
              label: 'Parallel condition',
            ),
            PPStepBlock(
              type: PPBlockType.substitution,
              label: 'Checking slopes',
              latex: 'm_1 = $m1Tex \\quad,\\quad m_2 = $m2Tex',
              content: '',
            ),
            PPStepBlock(
              type: PPBlockType.substitution,
              label: 'Checking intercepts',
              latex: 'b_1 = $b1Tex \\quad,\\quad b_2 = $b2Tex',
              content: '',
            ),
            const PPStepBlock(
              type: PPBlockType.working,
              latex:
                  'm_1 = m_2 \\;\\checkmark \\quad(\\text{slopes equal})\\\\[4pt] b_1 \\neq b_2 \\;\\checkmark \\quad(\\text{intercepts differ})',
              content: '',
            ),
            const PPStepBlock(
              type: PPBlockType.result,
              latex: r'\text{The lines are } \textbf{PARALLEL} \;(\parallel)',
              content: 'The lines are PARALLEL (∥).',
            ),
          ],
        );

      case PPRelationship.perpendicular:
        final product = si1.slope != null && si2.slope != null
            ? (si1.slope! * si2.slope!).simplified()
            : null;
        final prodTex =
            product != null ? _fracTex(product) : r'\text{undefined}';
        return PPSolverStep(
          number: n,
          title: 'Apply the perpendicular lines test',
          blocks: [
            const PPStepBlock(
              type: PPBlockType.note,
              content:
                  'Two lines are perpendicular when their slopes are negative reciprocals. Their product equals −1.',
            ),
            const PPStepBlock(
              type: PPBlockType.formula,
              latex: r'm_1 \times m_2 = -1',
              content: '',
              label: 'Perpendicular condition',
            ),
            PPStepBlock(
              type: PPBlockType.substitution,
              label: 'Substituting',
              latex: '($m1Tex) \\times ($m2Tex)',
              content: '',
            ),
            PPStepBlock(
              type: PPBlockType.working,
              latex: '= $prodTex = -1 \\;\\checkmark',
              content: '',
            ),
            const PPStepBlock(
              type: PPBlockType.result,
              latex:
                  r'm_1 \times m_2 = -1 \;\checkmark \quad\text{The lines are } \textbf{PERPENDICULAR}\;(\perp)',
              content: 'The lines are PERPENDICULAR (⊥).',
            ),
          ],
        );

      case PPRelationship.sameLine:
        final b1Tex = si1.yInt != null ? _fracTex(si1.yInt!) : r'\text{—}';
        final b2Tex = si2.yInt != null ? _fracTex(si2.yInt!) : r'\text{—}';
        return PPSolverStep(
          number: n,
          title: 'Apply the coincident lines test',
          blocks: [
            const PPStepBlock(
              type: PPBlockType.note,
              content:
                  'Two lines are coincident when both slopes AND y-intercepts are identical — they overlap completely.',
            ),
            const PPStepBlock(
              type: PPBlockType.formula,
              latex: r'm_1 = m_2 \quad\text{and}\quad b_1 = b_2',
              content: '',
              label: 'Same-line condition',
            ),
            PPStepBlock(
              type: PPBlockType.substitution,
              latex:
                  'm_1 = $m1Tex = m_2 \\;\\checkmark \\\\[4pt] b_1 = $b1Tex = $b2Tex = b_2 \\;\\checkmark',
              content: '',
            ),
            const PPStepBlock(
              type: PPBlockType.result,
              latex: r'\text{The lines are the } \textbf{SAME LINE}\;(\equiv)',
              content: 'The lines are the SAME LINE (≡).',
            ),
          ],
        );

      case PPRelationship.neither:
        final product = si1.slope != null && si2.slope != null
            ? (si1.slope! * si2.slope!).simplified()
            : null;
        final prodTex =
            product != null ? _fracTex(product) : r'\text{undefined}';
        return PPSolverStep(
          number: n,
          title: 'Apply both tests — parallel and perpendicular',
          blocks: [
            const PPStepBlock(
              type: PPBlockType.note,
              content:
                  'We check both conditions. If neither is satisfied, the lines intersect at an oblique angle.',
            ),
            const PPStepBlock(
              type: PPBlockType.formula,
              latex:
                  r'\text{Parallel: } m_1 = m_2 \qquad \text{Perpendicular: } m_1 \times m_2 = -1',
              content: '',
              label: 'Both conditions',
            ),
            PPStepBlock(
              type: PPBlockType.substitution,
              latex: 'm_1 = $m1Tex,\\quad m_2 = $m2Tex',
              content: '',
            ),
            PPStepBlock(
              type: PPBlockType.working,
              latex:
                  '\\text{Parallel? } m_1 = m_2 \\;\\Rightarrow\\; $m1Tex \\neq $m2Tex \\;\\times \\\\[6pt]'
                  '\\text{Perpendicular? } m_1 \\times m_2 = $prodTex \\neq -1 \\;\\times',
              content: '',
            ),
            const PPStepBlock(
              type: PPBlockType.result,
              latex:
                  r'\text{The lines are } \textbf{NEITHER}\text{ parallel nor perpendicular}',
              content: 'The lines are NEITHER parallel nor perpendicular.',
            ),
          ],
        );
    }
  }

  // ── Convert line to slope-intercept ──────────────────────

  static _SIResult _toSI(_Line l) {
    if (l.B == 0) {
      if (l.A == 0) {
        return const _SIResult(
            slope: null,
            yInt: null,
            equation: 'Invalid',
            latexEquation: r'\text{Invalid}',
            isVertical: true);
      }
      final xv = YIFraction(numerator: -l.C, denominator: l.A).simplified();
      final xvTex = _fracTex(xv);
      return _SIResult(
          slope: null,
          yInt: null,
          equation: 'x = $xv',
          latexEquation: 'x = $xvTex',
          isVertical: true);
    }
    final m = YIFraction(numerator: -l.A, denominator: l.B).simplified();
    final b = YIFraction(numerator: -l.C, denominator: l.B).simplified();
    return _SIResult(
      slope: m,
      yInt: b,
      equation: _siStr(m, b),
      latexEquation: _siLatex(m, b),
      isVertical: false,
    );
  }

  static String _siStr(YIFraction m, YIFraction b) {
    if (m.isZero) return 'y = $b';
    String mp;
    if (m == const YIFraction(numerator: 1, denominator: 1)) {
      mp = 'x';
    } else if (m == const YIFraction(numerator: -1, denominator: 1)) {
      mp = '-x';
    } else
      mp = '${m}x  ';
    if (b.isZero) return 'y = $mp';
    if (b.numerator > 0) return 'y = $mp + $b';
    return 'y = $mp - ${b.abs()}';
  }

  // ── Classification ────────────────────────────────────────

  static PPRelationship _classify(_SIResult s1, _SIResult s2) {
    if (s1.isVertical && s2.isVertical) {
      return s1.equation == s2.equation
          ? PPRelationship.sameLine
          : PPRelationship.parallel;
    }
    if (s1.isVertical || s2.isVertical) return PPRelationship.neither;

    final m1 = s1.slope!, m2 = s2.slope!;

    if (m1 == m2) {
      if (s1.yInt != null && s2.yInt != null && s1.yInt == s2.yInt) {
        return PPRelationship.sameLine;
      }
      return PPRelationship.parallel;
    }

    final product = (m1 * m2).simplified();
    if (product.numerator == -product.denominator) {
      return PPRelationship.perpendicular;
    }

    return PPRelationship.neither;
  }

  // ── Verdict helpers ───────────────────────────────────────

  static String _verdictString(PPRelationship r) {
    switch (r) {
      case PPRelationship.parallel:
        return 'Parallel';
      case PPRelationship.perpendicular:
        return 'Perpendicular';
      case PPRelationship.sameLine:
        return 'Same Line (Coincident)';
      case PPRelationship.neither:
        return 'Neither';
    }
  }

  static String _verdictSymbol(PPRelationship r) {
    switch (r) {
      case PPRelationship.parallel:
        return '∥';
      case PPRelationship.perpendicular:
        return '⊥';
      case PPRelationship.sameLine:
        return '≡';
      case PPRelationship.neither:
        return '∦';
    }
  }

  static String _verdictExplanation(PPRelationship r) {
    switch (r) {
      case PPRelationship.parallel:
        return 'Since m₁ = m₂ and b₁ ≠ b₂, the lines have the same slope but different y-intercepts. They run in the same direction and will never meet — they are parallel.';
      case PPRelationship.perpendicular:
        return 'Since m₁ × m₂ = −1, the slopes are negative reciprocals. The lines cross at exactly 90° — they are perpendicular.';
      case PPRelationship.sameLine:
        return 'Since m₁ = m₂ and b₁ = b₂, both equations describe the exact same line. Every point on one line is also on the other — they are coincident.';
      case PPRelationship.neither:
        return 'The slopes are not equal (so not parallel) and their product is not −1 (so not perpendicular). The lines intersect at an oblique angle — neither condition applies.';
    }
  }
}