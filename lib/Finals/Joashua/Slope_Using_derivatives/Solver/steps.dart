// solution_steps.dart
// Classroom Solution Steps — Slope Solver
// ════════════════════════════════════════
// Depends on: slope_solver.dart (share the same directory)
// Usage:
//   dart solution_steps.dart
//   dart solution_steps.dart "y = x^3 - 2x + 1" x=2
//   dart solution_steps.dart "x^2 + y^2 = 25" x=3 y=4
//   dart solution_steps.dart "x=cos(t), y=sin(t)" t=1.5708

import 'dart:math' as math;
import 'dart:io';

import 'package:calculus_system/Finals/Joashua/Slope_Using_derivatives/Solver/math_engine.dart';
import 'package:calculus_system/Finals/Joashua/Slope_Using_derivatives/Solver/models.dart';
import 'package:calculus_system/Finals/Joashua/Slope_Using_derivatives/Solver/solver.dart';

// ══════════════════════════════════════════════════════════════════════════════
// PASTE THE ENTIRE CONTENTS OF slope_solver.dart HERE (all classes up to main)
// then delete slope_solver's own main() — only the main() below is kept.
// ══════════════════════════════════════════════════════════════════════════════

// ─── Forward declarations satisfied by slope_solver content above ─────────────
// TokenType, Token, Tokenizer, Parser, Expr hierarchy (Num, Var, Const, BinOp,
// Pow, UnaryNeg, Func, DerivSym), ExprUtils, Simplifier, Differentiator,
// ProblemType, SlopeResult, SlopeSolver, StepExplainer, PrettyPrinter

// ══════════════════════════════════════════════════════════════════════════════
// §1  DATA MODEL
// ══════════════════════════════════════════════════════════════════════════════

/// Semantic category of a single classroom step.
enum StepKind {
  sectionHeader, // bold title line  e.g. "── GIVEN ──"
  ruleStatement, // the calculus rule being applied
  algebra, // one line of algebraic work
  substitution, // plugging a numeric value in
  result, // boxed final answer
  tangentNormal, // tangent / normal line derivation
  note, // aside or caveat
}

/// A single logical beat in the classroom walkthrough.
class ClassroomStep {
  final StepKind kind;
  final String label; // short label shown in the left gutter e.g. "Step 3"
  final List<String> lines; // one or more display lines

  const ClassroomStep({
    required this.kind,
    required this.label,
    required this.lines,
  });
}

/// Ordered collection of ClassroomStep objects for one problem.
class ClassroomSolution {
  final String problemTitle;
  final ProblemType type;
  final List<ClassroomStep> steps;
  final SlopeResult result;

  const ClassroomSolution({
    required this.problemTitle,
    required this.type,
    required this.steps,
    required this.result,
  });
}

// ══════════════════════════════════════════════════════════════════════════════
// §2  DERIVATIVE NARRATOR
//     Converts an Expr AST node into the name of the differentiation rule
//     applied at the top level, with a short justification phrase.
// ══════════════════════════════════════════════════════════════════════════════

class DerivativeNarrator {
  /// Returns lines such as:
  ///   "Power Rule:  d/dx[uⁿ] = n·uⁿ⁻¹·u'"
  ///   "Product Rule: d/dx[f·g] = f'g + fg'"
  static List<String> narrate(Expr expr, String wrtVar) {
    if (expr is Num || expr is Const) {
      return ['Constant Rule:  d/d$wrtVar[c] = 0'];
    }
    if (expr is Var) {
      if (expr.name == wrtVar) {
        return ['Identity Rule:  d/d$wrtVar[$wrtVar] = 1'];
      }
      return [
        'Constant Rule:  d/d$wrtVar[${expr.name}] = 0  (${expr.name} is constant w.r.t. $wrtVar)'
      ];
    }
    if (expr is UnaryNeg) {
      return [
        'Constant Multiple Rule:  d/d$wrtVar[-f] = -(d/d$wrtVar[f])',
        ...narrate(expr.operand, wrtVar).map((s) => '  ↳ inner: $s'),
      ];
    }
    if (expr is BinOp) {
      switch (expr.op) {
        case '+':
          return ['Sum Rule:  d/d$wrtVar[f + g] = f\' + g\''];
        case '-':
          return ['Difference Rule:  d/d$wrtVar[f − g] = f\' − g\''];
        case '*':
          return [
            'Product Rule:  d/d$wrtVar[f·g] = f\'·g + f·g\'',
            '  where  f = ${expr.left.toMathString()}',
            '         g = ${expr.right.toMathString()}',
          ];
        case '/':
          return [
            'Quotient Rule:  d/d$wrtVar[f/g] = (f\'g − fg\') / g²',
            '  where  f = ${expr.left.toMathString()}',
            '         g = ${expr.right.toMathString()}',
          ];
      }
    }
    if (expr is Pow) {
      final baseHasVar = ExprUtils.containsVar(expr.base, wrtVar);
      final expHasVar = ExprUtils.containsVar(expr.exponent, wrtVar);
      if (baseHasVar && !expHasVar) {
        return [
          'Power Rule:  d/d$wrtVar[uⁿ] = n·uⁿ⁻¹·u\'  (with Chain Rule)',
          '  where  u = ${expr.base.toMathString()}',
          '         n = ${expr.exponent.toMathString()}',
        ];
      }
      if (!baseHasVar && expHasVar) {
        return [
          'Exponential Rule:  d/d$wrtVar[aᵘ] = aᵘ·ln(a)·u\'',
          '  where  a = ${expr.base.toMathString()}',
          '         u = ${expr.exponent.toMathString()}',
        ];
      }
      return [
        'General Power Rule:  d/d$wrtVar[fᵍ] = fᵍ·(g\'·ln f + g·f\'/f)',
        '  where  f = ${expr.base.toMathString()}',
        '         g = ${expr.exponent.toMathString()}',
      ];
    }
    if (expr is Func) {
      return _narrateFunc(expr, wrtVar);
    }
    return ['Differentiation rule applied'];
  }

  static List<String> _narrateFunc(Func expr, String wrtVar) {
    final u = expr.arg.toMathString();
    final needsChain = u != wrtVar;
    final chain =
        needsChain ? '  + Chain Rule: multiply by d/d$wrtVar[$u]' : '';

    switch (expr.name) {
      case 'sin':
        return ['d/d$wrtVar[sin u] = cos u · u\'$chain', '  where  u = $u'];
      case 'cos':
        return ['d/d$wrtVar[cos u] = −sin u · u\'$chain', '  where  u = $u'];
      case 'tan':
        return [
          'd/d$wrtVar[tan u] = sec²u · u\'  =  u\' / cos²u$chain',
          '  where  u = $u'
        ];
      case 'cot':
        return [
          'd/d$wrtVar[cot u] = −csc²u · u\'  =  −u\' / sin²u$chain',
          '  where  u = $u'
        ];
      case 'sec':
        return [
          'd/d$wrtVar[sec u] = sec u · tan u · u\'  =  sin u · u\' / cos²u$chain',
          '  where  u = $u'
        ];
      case 'csc':
        return [
          'd/d$wrtVar[csc u] = −csc u · cot u · u\'  =  −cos u · u\' / sin²u$chain',
          '  where  u = $u'
        ];
      case 'asin':
      case 'arcsin':
        return [
          'd/d$wrtVar[arcsin u] = u\' / √(1 − u²)$chain',
          '  where  u = $u'
        ];
      case 'acos':
      case 'arccos':
        return [
          'd/d$wrtVar[arccos u] = −u\' / √(1 − u²)$chain',
          '  where  u = $u'
        ];
      case 'atan':
      case 'arctan':
        return [
          'd/d$wrtVar[arctan u] = u\' / (1 + u²)$chain',
          '  where  u = $u'
        ];
      case 'sinh':
        return ['d/d$wrtVar[sinh u] = cosh u · u\'$chain', '  where  u = $u'];
      case 'cosh':
        return ['d/d$wrtVar[cosh u] = sinh u · u\'$chain', '  where  u = $u'];
      case 'tanh':
        return ['d/d$wrtVar[tanh u] = u\' / cosh²u$chain', '  where  u = $u'];
      case 'ln':
        return ['d/d$wrtVar[ln u] = u\' / u$chain', '  where  u = $u'];
      case 'log':
        return [
          'd/d$wrtVar[log₁₀ u] = u\' / (u · ln 10)$chain',
          '  where  u = $u'
        ];
      case 'exp':
        return ['d/d$wrtVar[eᵘ] = eᵘ · u\'$chain', '  where  u = $u'];
      case 'sqrt':
        return ['d/d$wrtVar[√u] = u\' / (2√u)$chain', '  where  u = $u'];
      case 'abs':
        return [
          'd/d$wrtVar[|u|] = u · u\' / |u|   (u ≠ 0)$chain',
          '  where  u = $u'
        ];
      case 'cbrt':
        return [
          'd/d$wrtVar[∛u] = u\' / (3 · u^(2/3))$chain',
          '  where  u = $u'
        ];
      default:
        return [
          'd/d$wrtVar[${expr.name}(u)] · u\'  (Chain Rule)',
          '  where  u = $u'
        ];
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// §3  SOLUTION BUILDER — dispatches to the three sub-builders
// ══════════════════════════════════════════════════════════════════════════════

class SolutionBuilder {
  static ClassroomSolution build(SlopeResult r) {
    switch (r.type) {
      case ProblemType.explicit:
        return ExplicitSolutionBuilder.build(r);
      case ProblemType.implicit:
        return ImplicitSolutionBuilder.build(r);
      case ProblemType.parametric:
        return ParametricSolutionBuilder.build(r);
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// §4  EXPLICIT SOLUTION BUILDER   y = f(x)
// ══════════════════════════════════════════════════════════════════════════════

class ExplicitSolutionBuilder {
  static ClassroomSolution build(SlopeResult r) {
    final steps = <ClassroomStep>[];
    final x = r.independentVar;
    final y = r.dependentVar ?? 'y';
    final f = r.functionExpr;
    final fStr = f.toMathString();
    final rawStr = r.derivative.toMathString();
    final simpStr = r.simplifiedDerivative.toMathString();

    // ── GIVEN ──────────────────────────────────────────────────────────────
    steps.add(ClassroomStep(
      kind: StepKind.sectionHeader,
      label: 'Given',
      lines: [
        '$y = $fStr',
        'Find:  d$y/d$x'
            '${r.point.containsKey(x) ? ' at $x = ${_fmt(r.point[x]!)}' : ' as a function of $x'}',
      ],
    ));

    // ── STEP 1 — Identify the governing rule ──────────────────────────────
    steps.add(ClassroomStep(
      kind: StepKind.ruleStatement,
      label: 'Step 1',
      lines: [
        'Identify the differentiation rule for the top-level structure:',
        '',
        ...DerivativeNarrator.narrate(f, x),
      ],
    ));

    // ── STEP 2 — Set up the derivative ────────────────────────────────────
    steps.add(ClassroomStep(
      kind: StepKind.algebra,
      label: 'Step 2',
      lines: [
        'Write the derivative operator:',
        '',
        '  d$y/d$x  =  d/d$x [ $fStr ]',
      ],
    ));

    // ── STEP 3 — Apply rules term by term ─────────────────────────────────
    steps.add(ClassroomStep(
      kind: StepKind.algebra,
      label: 'Step 3',
      lines: [
        'Apply the rule — differentiate each component:',
        '',
        '  d$y/d$x  =  $rawStr',
      ],
    ));

    // ── STEP 4 — Simplify ─────────────────────────────────────────────────
    if (rawStr != simpStr) {
      steps.add(ClassroomStep(
        kind: StepKind.algebra,
        label: 'Step 4',
        lines: [
          'Simplify — combine like terms, cancel factors:',
          '',
          '  d$y/d$x  =  $simpStr',
        ],
      ));
    } else {
      steps.add(ClassroomStep(
        kind: StepKind.note,
        label: 'Step 4',
        lines: ['The derivative requires no further simplification.'],
      ));
    }

    // ── STEP 5 — Evaluate at the given point ──────────────────────────────
    if (r.point.containsKey(x) && r.slopeValue != null) {
      final xVal = r.point[x]!;
      final yVal = _evalSafe(r.functionExpr, r.point);

      steps.add(ClassroomStep(
        kind: StepKind.substitution,
        label: 'Step 5',
        lines: [
          'Substitute $x = ${_fmt(xVal)} into the derivative:',
          '',
          '  d$y/d$x |_{$x = ${_fmt(xVal)}}  =  [ $simpStr ]_{$x = ${_fmt(xVal)}}',
          '                         =  ${_fmt(r.slopeValue!)}',
          '',
          if (yVal != null)
            'The curve passes through  (${_fmt(xVal)},  ${_fmt(yVal)}).',
        ],
      ));

      // ── STEP 6 — Tangent line ────────────────────────────────────────────
      if (yVal != null && r.tangentLineEquation != null) {
        final m = r.slopeValue!;
        final b = yVal - m * xVal;
        steps.add(ClassroomStep(
          kind: StepKind.tangentNormal,
          label: 'Step 6',
          lines: [
            'Tangent line at  (${_fmt(xVal)}, ${_fmt(yVal)}):',
            '',
            '  Use point-slope form:  y − y₀ = m(x − x₀)',
            '',
            '  m  =  ${_fmt(m)}',
            '  (x₀, y₀)  =  (${_fmt(xVal)}, ${_fmt(yVal)})',
            '',
            '  y − ${_fmt(yVal)}  =  ${_fmt(m)}(x − ${_fmt(xVal)})',
            '  y  =  ${_fmt(m)}x + ${_fmt(b)}',
            '',
            '  Tangent line:  ${r.tangentLineEquation}',
          ],
        ));
      }

      // ── STEP 7 — Normal line ─────────────────────────────────────────────
      if (yVal != null &&
          r.normalLineEquation != null &&
          r.normalSlope != null) {
        final mN = r.normalSlope!;
        final bN = yVal - mN * xVal;
        steps.add(ClassroomStep(
          kind: StepKind.tangentNormal,
          label: 'Step 7',
          lines: [
            'Normal line at  (${_fmt(xVal)}, ${_fmt(yVal)}):',
            '',
            '  The normal is perpendicular to the tangent.',
            '  For two perpendicular lines:  m₁ · m₂ = −1',
            '',
            '  m_normal  =  −1 / m_tangent',
            '            =  −1 / ${_fmt(r.slopeValue!)}',
            '            =  ${_fmt(mN)}',
            '',
            '  y − ${_fmt(yVal)}  =  ${_fmt(mN)}(x − ${_fmt(xVal)})',
            '  y  =  ${_fmt(mN)}x + ${_fmt(bN)}',
            '',
            '  Normal line:  ${r.normalLineEquation}',
          ],
        ));
      }
    }

    // ── RESULT ────────────────────────────────────────────────────────────
    steps.add(ClassroomStep(
      kind: StepKind.result,
      label: 'Answer',
      lines: [
        'd$y/d$x  =  $simpStr',
        if (r.slopeValue != null)
          'Slope at $x = ${_fmt(r.point[x]!)}:   m = ${_fmt(r.slopeValue!)}',
        if (r.tangentLineEquation != null)
          'Tangent line:  ${r.tangentLineEquation}',
        if (r.normalLineEquation != null)
          'Normal line:   ${r.normalLineEquation}',
      ],
    ));

    return ClassroomSolution(
      problemTitle: 'Explicit Differentiation — ${r.originalInput}',
      type: r.type,
      steps: steps,
      result: r,
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// §5  IMPLICIT SOLUTION BUILDER   F(x,y) = G(x,y)
// ══════════════════════════════════════════════════════════════════════════════

class ImplicitSolutionBuilder {
  static ClassroomSolution build(SlopeResult r) {
    final steps = <ClassroomStep>[];
    final lhsStr = r.leftSide?.toMathString() ?? '';
    final rhsStr = r.rightSide?.toMathString() ?? '';
    final dLStr = r.leftDerivative?.toMathString() ?? '';
    final dRStr = r.rightDerivative?.toMathString() ?? '';
    final diffStr = r.derivative.toMathString();
    final slopeStr = r.implicitSlopeExpr?.toMathString() ??
        r.simplifiedDerivative.toMathString();
    final hasPoint = r.point.containsKey('x') && r.point.containsKey('y');

    // ── GIVEN ──────────────────────────────────────────────────────────────
    steps.add(ClassroomStep(
      kind: StepKind.sectionHeader,
      label: 'Given',
      lines: [
        '$lhsStr  =  $rhsStr',
        'Find:  dy/dx  using Implicit Differentiation'
            '${hasPoint ? '  at  (${_fmt(r.point['x']!)}, ${_fmt(r.point['y']!)})' : ''}',
      ],
    ));

    // ── STEP 1 — Concept ───────────────────────────────────────────────────
    steps.add(ClassroomStep(
      kind: StepKind.ruleStatement,
      label: 'Step 1',
      lines: [
        'Strategy: Implicit Differentiation.',
        '',
        '  y is implicitly defined as a function of x.',
        '  Differentiate both sides of the equation with respect to x.',
        '  Every time we differentiate a term containing y,',
        '  the Chain Rule requires multiplying by  dy/dx.',
        '',
        '  Key identity:  d/dx[f(y)]  =  f\'(y) · dy/dx',
      ],
    ));

    // ── STEP 2 — Differentiate left side ──────────────────────────────────
    final dLRuleLines = r.leftSide != null
        ? DerivativeNarrator.narrate(r.leftSide!, 'x')
        : <String>[];
    steps.add(ClassroomStep(
      kind: StepKind.algebra,
      label: 'Step 2',
      lines: [
        'Differentiate the LEFT side  d/dx[$lhsStr]:',
        '',
        ...dLRuleLines.map((l) => '  → $l'),
        '',
        '  d/dx[$lhsStr]  =  $dLStr',
      ],
    ));

    // ── STEP 3 — Differentiate right side ─────────────────────────────────
    final dRRuleLines = r.rightSide != null
        ? DerivativeNarrator.narrate(r.rightSide!, 'x')
        : <String>[];
    steps.add(ClassroomStep(
      kind: StepKind.algebra,
      label: 'Step 3',
      lines: [
        'Differentiate the RIGHT side  d/dx[$rhsStr]:',
        '',
        ...dRRuleLines.map((l) => '  → $l'),
        '',
        '  d/dx[$rhsStr]  =  $dRStr',
      ],
    ));

    // ── STEP 4 — Equate and collect ────────────────────────────────────────
    steps.add(ClassroomStep(
      kind: StepKind.algebra,
      label: 'Step 4',
      lines: [
        'Set the differentiated sides equal:',
        '',
        '  $dLStr  =  $dRStr',
        '',
        'Move all terms to one side:',
        '',
        '  $diffStr  =  0',
      ],
    ));

    // ── STEP 5 — Isolate dy/dx ─────────────────────────────────────────────
    steps.add(ClassroomStep(
      kind: StepKind.algebra,
      label: 'Step 5',
      lines: [
        'Group all dy/dx terms on the left, everything else on the right.',
        'Factor out dy/dx and divide:',
        '',
        '  dy/dx  =  $slopeStr',
      ],
    ));

    // ── STEP 6 — Evaluate at point ────────────────────────────────────────
    if (hasPoint && r.slopeValue != null) {
      final xVal = r.point['x']!;
      final yVal = r.point['y']!;
      steps.add(ClassroomStep(
        kind: StepKind.substitution,
        label: 'Step 6',
        lines: [
          'Substitute  x = ${_fmt(xVal)},  y = ${_fmt(yVal)}:',
          '',
          '  dy/dx  =  [ $slopeStr ]_{x=${_fmt(xVal)}, y=${_fmt(yVal)}}',
          '         =  ${_fmt(r.slopeValue!)}',
        ],
      ));

      // ── STEP 7 — Tangent line ────────────────────────────────────────────
      if (r.tangentLineEquation != null) {
        final m = r.slopeValue!;
        final b = yVal - m * xVal;
        steps.add(ClassroomStep(
          kind: StepKind.tangentNormal,
          label: 'Step 7',
          lines: [
            'Tangent line at  (${_fmt(xVal)}, ${_fmt(yVal)}):',
            '',
            '  Point-slope form:  y − y₀ = m(x − x₀)',
            '',
            '  m  =  ${_fmt(m)}',
            '  (x₀, y₀)  =  (${_fmt(xVal)}, ${_fmt(yVal)})',
            '',
            '  y − ${_fmt(yVal)}  =  ${_fmt(m)}(x − ${_fmt(xVal)})',
            '  y  =  ${_fmt(m)}x + ${_fmt(b)}',
            '',
            '  Tangent line:  ${r.tangentLineEquation}',
          ],
        ));
      }

      // ── STEP 8 — Normal line ─────────────────────────────────────────────
      if (r.normalLineEquation != null && r.normalSlope != null) {
        final mN = r.normalSlope!;
        final bN = yVal - mN * xVal;
        steps.add(ClassroomStep(
          kind: StepKind.tangentNormal,
          label: 'Step 8',
          lines: [
            'Normal line at  (${_fmt(xVal)}, ${_fmt(yVal)}):',
            '',
            '  m_normal  =  −1 / m_tangent',
            '            =  −1 / ${_fmt(r.slopeValue!)}',
            '            =  ${_fmt(mN)}',
            '',
            '  y − ${_fmt(yVal)}  =  ${_fmt(mN)}(x − ${_fmt(xVal)})',
            '  y  =  ${_fmt(mN)}x + ${_fmt(bN)}',
            '',
            '  Normal line:  ${r.normalLineEquation}',
          ],
        ));
      }
    }

    // ── RESULT ────────────────────────────────────────────────────────────
    steps.add(ClassroomStep(
      kind: StepKind.result,
      label: 'Answer',
      lines: [
        'dy/dx  =  $slopeStr',
        if (r.slopeValue != null)
          'Slope at (${_fmt(r.point['x']!)}, ${_fmt(r.point['y']!)}):   m = ${_fmt(r.slopeValue!)}',
        if (r.tangentLineEquation != null)
          'Tangent line:  ${r.tangentLineEquation}',
        if (r.normalLineEquation != null)
          'Normal line:   ${r.normalLineEquation}',
      ],
    ));

    return ClassroomSolution(
      problemTitle: 'Implicit Differentiation — ${r.originalInput}',
      type: r.type,
      steps: steps,
      result: r,
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// §6  PARAMETRIC SOLUTION BUILDER   x = f(t),  y = g(t)
// ══════════════════════════════════════════════════════════════════════════════

class ParametricSolutionBuilder {
  static ClassroomSolution build(SlopeResult r) {
    final steps = <ClassroomStep>[];
    final t = r.independentVar;
    final xStr = r.paramXExpr?.toMathString() ?? '';
    final yStr = r.paramYExpr?.toMathString() ?? '';
    final dxStr = r.dxDt?.toMathString() ?? '';
    final dyStr = r.dyDt?.toMathString() ?? '';
    final slopeStr = r.simplifiedDerivative.toMathString();

    // ── GIVEN ──────────────────────────────────────────────────────────────
    steps.add(ClassroomStep(
      kind: StepKind.sectionHeader,
      label: 'Given',
      lines: [
        'x($t)  =  $xStr',
        'y($t)  =  $yStr',
        'Find:  dy/dx  using Parametric Differentiation'
            '${r.point.containsKey(t) ? '  at  $t = ${_fmt(r.point[t]!)}' : ''}',
      ],
    ));

    // ── STEP 1 — Concept ───────────────────────────────────────────────────
    steps.add(ClassroomStep(
      kind: StepKind.ruleStatement,
      label: 'Step 1',
      lines: [
        'Strategy: Parametric Slope Formula.',
        '',
        '  x and y are not directly related — both depend on the parameter $t.',
        '  By the Chain Rule:',
        '',
        '    dy     dy/d$t',
        '    ──  =  ──────',
        '    dx     dx/d$t',
        '',
        '  This is valid whenever  dx/d$t ≠ 0.',
        '  When dx/d$t = 0 and dy/d$t ≠ 0, the tangent is vertical.',
        '  When both are 0, the point is singular — further analysis needed.',
      ],
    ));

    // ── STEP 2 — Differentiate x(t) ───────────────────────────────────────
    final dxRuleLines = r.paramXExpr != null
        ? DerivativeNarrator.narrate(r.paramXExpr!, t)
        : <String>[];
    steps.add(ClassroomStep(
      kind: StepKind.algebra,
      label: 'Step 2',
      lines: [
        'Differentiate  x($t) = $xStr  with respect to $t:',
        '',
        ...dxRuleLines.map((l) => '  → $l'),
        '',
        '  dx/d$t  =  $dxStr',
      ],
    ));

    // ── STEP 3 — Differentiate y(t) ───────────────────────────────────────
    final dyRuleLines = r.paramYExpr != null
        ? DerivativeNarrator.narrate(r.paramYExpr!, t)
        : <String>[];
    steps.add(ClassroomStep(
      kind: StepKind.algebra,
      label: 'Step 3',
      lines: [
        'Differentiate  y($t) = $yStr  with respect to $t:',
        '',
        ...dyRuleLines.map((l) => '  → $l'),
        '',
        '  dy/d$t  =  $dyStr',
      ],
    ));

    // ── STEP 4 — Form dy/dx ───────────────────────────────────────────────
    steps.add(ClassroomStep(
      kind: StepKind.algebra,
      label: 'Step 4',
      lines: [
        'Apply the parametric slope formula:',
        '',
        '  dy     dy/d$t     $dyStr',
        '  ──  =  ──────  =  ──────────────────',
        '  dx     dx/d$t     $dxStr',
        '',
        '  dy/dx  =  $slopeStr',
      ],
    ));

    // ── STEP 5 — Evaluate at parameter value ──────────────────────────────
    if (r.point.containsKey(t) && r.slopeValue != null) {
      final tVal = r.point[t]!;
      final xVal = _evalSafe(r.paramXExpr!, r.point);
      final yVal = _evalSafe(r.paramYExpr!, r.point);
      final dxVal = _evalSafe(r.dxDt!, r.point);
      final dyVal = _evalSafe(r.dyDt!, r.point);

      final verticalTangent = dxVal != null && dxVal.abs() < 1e-12;

      steps.add(ClassroomStep(
        kind: StepKind.substitution,
        label: 'Step 5',
        lines: [
          'Substitute  $t = ${_fmt(tVal)}:',
          '',
          if (xVal != null)
            '  x  =  $xStr |_{$t=${_fmt(tVal)}}  =  ${_fmt(xVal)}',
          if (yVal != null)
            '  y  =  $yStr |_{$t=${_fmt(tVal)}}  =  ${_fmt(yVal)}',
          '',
          if (dxVal != null)
            '  dx/d$t  =  $dxStr |_{$t=${_fmt(tVal)}}  =  ${_fmt(dxVal)}',
          if (dyVal != null)
            '  dy/d$t  =  $dyStr |_{$t=${_fmt(tVal)}}  =  ${_fmt(dyVal)}',
          '',
          if (verticalTangent)
            '  dx/d$t = 0  →  VERTICAL TANGENT at this point.'
          else
            '  dy/dx  =  ${dyVal != null ? _fmt(dyVal) : '?'} / ${dxVal != null ? _fmt(dxVal) : '?'}  =  ${_fmt(r.slopeValue!)}',
          '',
          if (xVal != null && yVal != null)
            '  Point on curve:  (${_fmt(xVal)},  ${_fmt(yVal)})  at $t = ${_fmt(tVal)}',
        ],
      ));

      // ── STEP 6 — Tangent line ────────────────────────────────────────────
      if (r.tangentLineEquation != null &&
          xVal != null &&
          yVal != null &&
          !verticalTangent) {
        final m = r.slopeValue!;
        final b = yVal - m * xVal;
        steps.add(ClassroomStep(
          kind: StepKind.tangentNormal,
          label: 'Step 6',
          lines: [
            'Tangent line at  (${_fmt(xVal)}, ${_fmt(yVal)}):',
            '',
            '  Point-slope form:  y − y₀ = m(x − x₀)',
            '',
            '  m  =  ${_fmt(m)}',
            '  (x₀, y₀)  =  (${_fmt(xVal)}, ${_fmt(yVal)})',
            '',
            '  y − ${_fmt(yVal)}  =  ${_fmt(m)}(x − ${_fmt(xVal)})',
            '  y  =  ${_fmt(m)}x + ${_fmt(b)}',
            '',
            '  Tangent line:  ${r.tangentLineEquation}',
          ],
        ));
      }

      // ── STEP 7 — Normal line ─────────────────────────────────────────────
      if (r.normalLineEquation != null &&
          r.normalSlope != null &&
          xVal != null &&
          yVal != null &&
          !verticalTangent) {
        final mN = r.normalSlope!;
        final bN = yVal - mN * xVal;
        steps.add(ClassroomStep(
          kind: StepKind.tangentNormal,
          label: 'Step 7',
          lines: [
            'Normal line at  (${_fmt(xVal)}, ${_fmt(yVal)}):',
            '',
            '  m_normal  =  −1 / m_tangent',
            '            =  −1 / ${_fmt(r.slopeValue!)}',
            '            =  ${_fmt(mN)}',
            '',
            '  y − ${_fmt(yVal)}  =  ${_fmt(mN)}(x − ${_fmt(xVal)})',
            '  y  =  ${_fmt(mN)}x + ${_fmt(bN)}',
            '',
            '  Normal line:  ${r.normalLineEquation}',
          ],
        ));
      }
    }

    // ── RESULT ────────────────────────────────────────────────────────────
    steps.add(ClassroomStep(
      kind: StepKind.result,
      label: 'Answer',
      lines: [
        'dy/dx  =  $slopeStr',
        if (r.slopeValue != null)
          'Slope at $t = ${_fmt(r.point[t]!)}:   m = ${_fmt(r.slopeValue!)}',
        if (r.tangentLineEquation != null)
          'Tangent line:  ${r.tangentLineEquation}',
        if (r.normalLineEquation != null)
          'Normal line:   ${r.normalLineEquation}',
      ],
    ));

    return ClassroomSolution(
      problemTitle: 'Parametric Differentiation — ${r.originalInput}',
      type: r.type,
      steps: steps,
      result: r,
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// §7  CLASSROOM PRINTER
// ══════════════════════════════════════════════════════════════════════════════

class ClassroomPrinter {
  static const _rst = '\x1B[0m';
  static const _bold = '\x1B[1m';
  static const _dim = '\x1B[2m';
  static const _cyan = '\x1B[96m';
  static const _grn = '\x1B[92m';
  static const _yel = '\x1B[93m';
  static const _blu = '\x1B[94m';
  static const _mag = '\x1B[95m';
  static const _wht = '\x1B[97m';

  static const int _W = 72;

  static void printSolution(ClassroomSolution sol) {
    _divider();
    _titleBanner(sol.problemTitle, sol.type);
    for (final step in sol.steps) {
      _printStep(step);
    }
    _divider();
  }

  static void _divider() {
    _w('$_dim${'─' * _W}$_rst');
  }

  static void _titleBanner(String title, ProblemType type) {
    final badge = switch (type) {
      ProblemType.explicit => '${_grn}EXPLICIT$_rst',
      ProblemType.implicit => '${_yel}IMPLICIT$_rst',
      ProblemType.parametric => '${_mag}PARAMETRIC$_rst',
    };
    _w('');
    _w('$_bold$_wht${'━' * _W}$_rst');
    _w('$_bold$_wht  ▶  $title$_rst');
    _w('$_bold  Type: $badge$_rst');
    _w('$_bold$_wht${'━' * _W}$_rst');
    _w('');
  }

  static void _printStep(ClassroomStep step) {
    final lbl = step.label;
    final fill = _W - lbl.length - 2;

    switch (step.kind) {
      case StepKind.sectionHeader:
        _w('$_bold$_cyan  ╔══ ${lbl.toUpperCase()} ══$_rst');
        for (final l in step.lines) {
          _w('$_cyan  ║  $l$_rst');
        }
        _w('$_cyan  ╚${'═' * 40}$_rst');
        _w('');

      case StepKind.ruleStatement:
        _w('$_bold$_yel  ┌─ $lbl ─── [Rule] ${'─' * (fill - 14 < 0 ? 0 : fill - 14)}$_rst');
        for (final l in step.lines) {
          _w('$_yel  │$_rst  $l');
        }
        _w('$_yel  └${'─' * (_W - 4)}$_rst');
        _w('');

      case StepKind.algebra:
        _w('$_bold$_blu  ┌─ $lbl ─── [Algebra] ${'─' * (fill - 17 < 0 ? 0 : fill - 17)}$_rst');
        for (final l in step.lines) {
          final isMath = l.contains('=') ||
              l.contains('d/dx') ||
              l.contains('dy/dx') ||
              l.contains('dx/d') ||
              l.contains('dy/d');
          if (isMath && l.trim().isNotEmpty) {
            _w('$_blu  │$_rst$_bold  $l$_rst');
          } else {
            _w('$_blu  │$_rst  $l');
          }
        }
        _w('$_blu  └${'─' * (_W - 4)}$_rst');
        _w('');

      case StepKind.substitution:
        _w('$_bold$_grn  ┌─ $lbl ─── [Substitute] ${'─' * (fill - 20 < 0 ? 0 : fill - 20)}$_rst');
        for (final l in step.lines) {
          _w('$_grn  │$_rst  $l');
        }
        _w('$_grn  └${'─' * (_W - 4)}$_rst');
        _w('');

      case StepKind.tangentNormal:
        _w('$_bold$_mag  ┌─ $lbl ─── [Line] ${'─' * (fill - 14 < 0 ? 0 : fill - 14)}$_rst');
        for (final l in step.lines) {
          _w('$_mag  │$_rst  $l');
        }
        _w('$_mag  └${'─' * (_W - 4)}$_rst');
        _w('');

      case StepKind.note:
        _w('$_dim  ◦ $lbl:  ${step.lines.join(' ')}$_rst');
        _w('');

      case StepKind.result:
        _w('$_bold$_wht  ╔${'═' * (_W - 4)}╗$_rst');
        _w('$_bold$_wht  ║${_center('✓  ANSWER', _W - 4)}║$_rst');
        _w('$_bold$_wht  ╠${'═' * (_W - 4)}╣$_rst');
        for (final l in step.lines) {
          final padded = '  $l';
          final right = _W - 4 - padded.length;
          _w('$_bold$_wht  ║$_rst$_bold$padded${' ' * (right < 0 ? 0 : right)}$_wht║$_rst');
        }
        _w('$_bold$_wht  ╚${'═' * (_W - 4)}╝$_rst');
        _w('');
    }
  }

  static void _w(String s) => stdout.writeln(s);

  static String _center(String s, int w) {
    final pad = ((w - s.length) / 2).floor();
    final rpad = w - pad - s.length;
    return ' ' * pad + s + ' ' * (rpad < 0 ? 0 : rpad);
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// §8  SHARED UTILITIES
// ══════════════════════════════════════════════════════════════════════════════

String _fmt(double v) {
  if (v != v) return 'undefined';
  if (v.isInfinite) return v > 0 ? '+∞' : '−∞';
  if (v == v.truncateToDouble() && v.abs() < 1e10) return v.toInt().toString();
  final fracs = <double, String>{
    0.5: '1/2',
    -0.5: '−1/2',
    1 / 3: '1/3',
    -1 / 3: '−1/3',
    2 / 3: '2/3',
    -2 / 3: '−2/3',
    0.25: '1/4',
    -0.25: '−1/4',
    0.75: '3/4',
    -0.75: '−3/4',
    math.sqrt2: '√2',
    -math.sqrt2: '−√2',
    math.pi: 'π',
    -math.pi: '−π',
    math.e: 'e',
    -math.e: '−e',
  };
  for (final entry in fracs.entries) {
    if ((v - entry.key).abs() < 1e-9) return entry.value;
  }
  return v.toStringAsFixed(6).replaceAll(RegExp(r'\.?0+$'), '');
}

double? _evalSafe(Expr expr, Map<String, double> vals) {
  try {
    return ExprUtils.evaluate(expr, vals);
  } catch (_) {
    return null;
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// §9  CLI ARG PARSER
// ══════════════════════════════════════════════════════════════════════════════

(String, Map<String, double>) _parseArgs(List<String> args) {
  final eqParts = <String>[];
  final vals = <String, double>{};
  for (final arg in args) {
    final kv =
        RegExp(r'^([a-zA-Z_][a-zA-Z0-9_]*)=([-\d.eE+]+)$').firstMatch(arg);
    if (kv != null) {
      vals[kv.group(1)!] = double.parse(kv.group(2)!);
    } else {
      eqParts.add(arg);
    }
  }
  return (eqParts.join(' '), vals);
}

// ══════════════════════════════════════════════════════════════════════════════
// §10  MAIN — 14 curated classroom problems (6 explicit, 4 implicit, 4 parametric)
// ══════════════════════════════════════════════════════════════════════════════

void main(List<String> args) {
  if (args.isNotEmpty) {
    final (eq, vals) = _parseArgs(args);
    if (eq.isEmpty) {
      stderr.writeln(
          'Usage: dart solution_steps.dart "<equation>" [var=value ...]');
      stderr.writeln('');
      stderr.writeln('Examples:');
      stderr.writeln('  dart solution_steps.dart "y = x^3 - 2x + 1" x=2');
      stderr.writeln('  dart solution_steps.dart "x^2 + y^2 = 25" x=3 y=4');
      stderr
          .writeln('  dart solution_steps.dart "x=cos(t), y=sin(t)" t=1.5708');
      exit(1);
    }
    try {
      final result = SlopeSolver.solve(eq, pointValues: vals);
      final solution = SolutionBuilder.build(result);
      ClassroomPrinter.printSolution(solution);
    } catch (e) {
      stderr.writeln('Error: $e');
      exit(1);
    }
    return;
  }

  // ── Classroom problem set ──────────────────────────────────────────────────
  final problems = <(String, Map<String, double>, String)>[
    // Explicit
    ('y = x^3 - 3*x^2 + 2', {'x': 2.0}, 'Polynomial — Power + Sum Rule'),
    ('y = sin(x) * cos(x)', {'x': 0.0}, 'Trig product — Product Rule'),
    ('y = e^x * ln(x)', {'x': 1.0}, 'Exponential × Log — Product Rule'),
    (
      'y = (x^2 + 1) / (x - 1)',
      {'x': 3.0},
      'Rational function — Quotient Rule'
    ),
    ('y = (sin(x))^3', {'x': 1.5708}, 'Composite — Power + Chain Rule'),
    ('y = sqrt(x^2 + 1)', {'x': 2.0}, 'Square root — Chain Rule'),
    // Implicit
    ('x^2 + y^2 = 25', {'x': 3.0, 'y': 4.0}, 'Circle'),
    ('x^3 + y^3 = 6*x*y', {'x': 3.0, 'y': 3.0}, 'Folium of Descartes'),
    (
      '4*x^2 + 9*y^2 = 36',
      {'x': 0.0, 'y': 2.0},
      'Ellipse — horizontal tangent'
    ),
    (
      'x^2 - x*y + y^2 = 7',
      {'x': 1.0, 'y': 3.0},
      'Mixed xy term — Product Rule'
    ),
    // Parametric
    ('x=cos(t), y=sin(t)', {'t': 0.7854}, 'Unit circle — t = π/4'),
    ('x=t - sin(t), y=1 - cos(t)', {'t': 1.5708}, 'Cycloid — t = π/2'),
    ('x=cos(t)^3, y=sin(t)^3', {'t': 0.5236}, 'Astroid — t = π/6'),
    ('x=t^2 - 1, y=t^3 - t', {'t': 1.0}, 'Cubic parametric curve'),
  ];

  final total = problems.length;
  stdout.writeln('');
  stdout.writeln('╔${'═' * 70}╗');
  stdout.writeln(
      '║${_centerMain('CLASSROOM SOLUTION STEPS — SLOPE & DERIVATIVES', 70)}║');
  stdout.writeln(
      '║${_centerMain('$total worked examples  •  Explicit / Implicit / Parametric', 70)}║');
  stdout.writeln('╚${'═' * 70}╝');
  stdout.writeln('');

  int passed = 0, failed = 0;

  for (int i = 0; i < total; i++) {
    final (eq, vals, desc) = problems[i];
    stdout.writeln('Problem ${i + 1} of $total — $desc');
    try {
      final result = SlopeSolver.solve(eq, pointValues: vals);
      final solution = SolutionBuilder.build(result);
      ClassroomPrinter.printSolution(solution);
      passed++;
    } catch (e, st) {
      stderr.writeln('  !! Failed "$eq": $e');
      stderr.writeln(st.toString().split('\n').take(5).join('\n'));
      failed++;
    }
  }

  stdout.writeln('');
  stdout.writeln('╔${'═' * 70}╗');
  stdout.writeln('║${_centerMain('SESSION COMPLETE', 70)}║');
  stdout.writeln(
      '║${_centerMain('$passed solved  •  $failed errors  •  $total total', 70)}║');
  stdout.writeln('╚${'═' * 70}╝');
  stdout.writeln('');
}

String _centerMain(String s, int w) {
  final pad = ((w - s.length) / 2).floor();
  final rpad = w - pad - s.length;
  return ' ' * pad + s + ' ' * (rpad < 0 ? 0 : rpad);
}
