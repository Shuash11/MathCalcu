// solution_steps.dart
// Classroom Solution Steps — Slope Solver
// ════════════════════════════════════════
// Depends on: slope_solver.dart (share the same directory)
// Library only — consumed by the slope screens; no CLI entrypoint.

// ignore_for_file: constant_identifier_names, prefer_const_constructors

import 'dart:math' as math;

import 'slope_using_derivatives_solver.dart';

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
/// Supports nested sub-steps (children containers) and a short hint.
class ClassroomStep {
  final StepKind kind;
  final String label; // short label shown in the left gutter e.g. "Step 3"
  final List<String> lines; // one or more display lines
  final String? hint; // short italic instruction like "Apply the Power Rule"
  final List<ClassroomStep>? subSteps; // nested child containers

  const ClassroomStep({
    required this.kind,
    required this.label,
    required this.lines,
    this.hint,
    this.subSteps,
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
    final fLatex = f.toLatexString();
    final rawLatex = r.derivative.toLatexString();
    final simpLatex = r.simplifiedDerivative.toLatexString();
    final hasPoint = r.point.containsKey(x);
    final showSimplify =
        r.derivative.toMathString() != r.simplifiedDerivative.toMathString();
    final ruleLines = DerivativeNarrator.narrate(f, x);

    // ── Given ───
    steps.add(ClassroomStep(
      kind: StepKind.sectionHeader,
      label: 'Given',
      lines: [
        '$y = $fLatex',
        if (hasPoint) 'Find slope at $x = ${_fmt(r.point[x]!)}',
      ],
    ));

    // ── Differentiate (rules + result merged) ───
    steps.add(ClassroomStep(
      kind: StepKind.algebra,
      label: 'Differentiate',
      hint: 'Apply differentiation rules to find $y\'($x)',
      lines: [
        '\\frac{d$y}{d$x} = \\frac{d}{d$x}[ $fLatex ]',
        '',
        ...ruleLines,
        '',
        '\\frac{d$y}{d$x} = $rawLatex',
      ],
    ));

    // ── Simplify (separate, only if different) ───
    if (showSimplify) {
      steps.add(ClassroomStep(
        kind: StepKind.algebra,
        label: 'Simplify',
        hint: 'Combine like terms and reduce',
        lines: [
          '\\frac{d$y}{d$x} = $simpLatex',
        ],
      ));
    }

    // ── Evaluate ───
    if (hasPoint && r.slopeValue != null) {
      final xv = r.point[x]!;
      steps.add(ClassroomStep(
        kind: StepKind.substitution,
        label: 'Evaluate',
        hint: 'Substitute $x = ${_fmt(xv)} into the derivative',
        lines: [
          'm = $simpLatex  at  $x = ${_fmt(xv)}',
          '',
          'm = ${_fmt(r.slopeValue!)}',
        ],
      ));

      // ── Tangent Line ─── (tangent ONLY)
      final yVal = _evalSafe(r.functionExpr, r.point);
      if (yVal != null && r.tangentLineEquation != null) {
        final m = r.slopeValue!;
        steps.add(ClassroomStep(
          kind: StepKind.tangentNormal,
          label: 'Tangent Line',
          hint: 'Use point-slope form: y - y₀ = m(x - x₀)',
          lines: [
            'm = ${_fmt(m)},  (x₀, y₀) = (${_fmt(xv)}, ${_fmt(yVal)})',
            '',
            'y - ${_fmt(yVal)} = ${_fmt(m)}(x - ${_fmt(xv)})',
            'y = ${_fmt(m)}x + ${_fmt(yVal - m * xv)}',
            '',
            '${r.tangentLineEquation}',
          ],
        ));
      }

      // ── Normal Line ─── (normal ONLY)
      if (yVal != null &&
          r.normalLineEquation != null &&
          r.normalSlope != null) {
        final mN = r.normalSlope!;
        steps.add(ClassroomStep(
          kind: StepKind.tangentNormal,
          label: 'Normal Line',
          hint: 'm_normal = -1 / m_tangent',
          lines: [
            'm_normal = -1 / ${_fmt(r.slopeValue!)} = ${_fmt(mN)}',
            '',
            'y - ${_fmt(yVal)} = ${_fmt(mN)}(x - ${_fmt(xv)})',
            'y = ${_fmt(mN)}x + ${_fmt(yVal - mN * xv)}',
            '',
            '${r.normalLineEquation}',
          ],
        ));
      }
    }

    // ── Result ───
    steps.add(ClassroomStep(
      kind: StepKind.result,
      label: 'Answer',
      lines: [
        '\\frac{d$y}{d$x} = $simpLatex',
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
    final lhsLatex = r.leftSide?.toLatexString() ?? '';
    final rhsLatex = r.rightSide?.toLatexString() ?? '';
    final dLatex = r.leftDerivative?.toLatexString() ?? '';
    final dRLatex = r.rightDerivative?.toLatexString() ?? '';
    final diffLatex = r.derivative.toLatexString();
    final slopeLatex = r.implicitSlopeExpr?.toLatexString() ??
        r.simplifiedDerivative.toLatexString();
    final hasPoint = r.point.containsKey('x') && r.point.containsKey('y');
    final hasDyDx = ExprUtils.containsDerivSym(r.derivative);
    final dLRuleLines = r.leftSide != null
        ? DerivativeNarrator.narrate(r.leftSide!, 'x')
        : <String>[];
    final dRRuleLines = r.rightSide != null
        ? DerivativeNarrator.narrate(r.rightSide!, 'x')
        : <String>[];

    // ── GIVEN ───
    steps.add(ClassroomStep(
      kind: StepKind.sectionHeader,
      label: 'Given',
      lines: [
        '$lhsLatex  =  $rhsLatex',
        'Find:  \\frac{dy}{dx}  using Implicit Differentiation'
            '${hasPoint ? '  at  (${_fmt(r.point['x']!)}, ${_fmt(r.point['y']!)})' : ''}',
      ],
    ));

    // ── Differentiate LHS ───
    steps.add(ClassroomStep(
      kind: StepKind.algebra,
      label: 'Diff LHS',
      hint: 'Differentiate left side with respect to x, treat y as y(x)',
      lines: [
        '\\frac{d}{dx}[ $lhsLatex ]',
        ...dLRuleLines.map((l) => '  → $l'),
        '',
        '= $dLatex',
      ],
    ));

    // ── Differentiate RHS ───
    steps.add(ClassroomStep(
      kind: StepKind.algebra,
      label: 'Diff RHS',
      hint: 'Differentiate right side with respect to x',
      lines: [
        '\\frac{d}{dx}[ $rhsLatex ]',
        ...dRRuleLines.map((l) => '  → $l'),
        '',
        '= $dRLatex',
      ],
    ));

    // ── Combine ───
    steps.add(ClassroomStep(
      kind: StepKind.algebra,
      label: 'Combine',
      hint: 'Set the derivatives equal',
      lines: [
        '$dLatex  =  $dRLatex',
        if (hasDyDx) ...[
          '',
          '$diffLatex  =  0',
        ],
      ],
    ));

    // ── Move Terms ───
    if (hasDyDx) {
      final (c, rem) = Simplifier.extractDerivCoeff(r.derivative, 'y');
      final cLatex = c.toLatexString();
      final negRem = Simplifier.simplify(UnaryNeg(rem));
      final negRemLatex = negRem.toLatexString();
      steps.add(ClassroomStep(
        kind: StepKind.algebra,
        label: 'Move Terms',
        hint: 'Move non-dy/dx terms to the right side',
        lines: [
          '$cLatex \\cdot \\frac{dy}{dx} = $negRemLatex',
        ],
      ));

      // ── Isolate dy/dx ───
      final rawSlope = BinOp(negRem, '/', c);
      final rawSlopeLatex = rawSlope.toLatexString();
      final showSimplify = rawSlopeLatex != slopeLatex;
      steps.add(ClassroomStep(
        kind: StepKind.algebra,
        label: 'Isolate dy/dx',
        hint: 'Divide by the coefficient of dy/dx',
        lines: [
          '\\frac{dy}{dx} = $rawSlopeLatex',
        ],
      ));

      // ── Simplify (only if needed) ───
      if (showSimplify) {
        steps.add(ClassroomStep(
          kind: StepKind.algebra,
          label: 'Simplify',
          hint: 'Reduce to lowest terms',
          lines: [
            '\\frac{dy}{dx} = $slopeLatex',
          ],
        ));
      }
    }

    // ── Evaluate ───
    if (hasPoint && r.slopeValue != null) {
      final xVal = r.point['x']!;
      final yVal = r.point['y']!;
      steps.add(ClassroomStep(
        kind: StepKind.substitution,
        label: 'Evaluate',
        hint:
            'Substitute x = ${_fmt(xVal)}, y = ${_fmt(yVal)} into the slope formula',
        lines: [
          '\\frac{dy}{dx} = $slopeLatex  at  (${_fmt(xVal)}, ${_fmt(yVal)})',
          '',
          'm = ${_fmt(r.slopeValue!)}',
        ],
      ));

      // ── Tangent Line ─── (tangent ONLY)
      if (r.tangentLineEquation != null) {
        final m = r.slopeValue!;
        final b = yVal - m * xVal;
        steps.add(ClassroomStep(
          kind: StepKind.tangentNormal,
          label: 'Tangent Line',
          hint: 'Use point-slope form: y - y₀ = m(x - x₀)',
          lines: [
            'm = ${_fmt(m)},  (x₀, y₀) = (${_fmt(xVal)}, ${_fmt(yVal)})',
            '',
            'y - ${_fmt(yVal)} = ${_fmt(m)}(x - ${_fmt(xVal)})',
            'y = ${_fmt(m)}x + ${_fmt(b)}',
            '',
            '${r.tangentLineEquation}',
          ],
        ));
      }

      // ── Normal Line ─── (normal ONLY)
      if (r.normalLineEquation != null && r.normalSlope != null) {
        final mN = r.normalSlope!;
        final bN = yVal - mN * xVal;
        steps.add(ClassroomStep(
          kind: StepKind.tangentNormal,
          label: 'Normal Line',
          hint: 'm_normal = -1 / m_tangent',
          lines: [
            'm_normal = -1 / ${_fmt(r.slopeValue!)} = ${_fmt(mN)}',
            '',
            'y - ${_fmt(yVal)} = ${_fmt(mN)}(x - ${_fmt(xVal)})',
            'y = ${_fmt(mN)}x + ${_fmt(bN)}',
            '',
            '${r.normalLineEquation}',
          ],
        ));
      }
    }

    // ── RESULT ───
    steps.add(ClassroomStep(
      kind: StepKind.result,
      label: 'Answer',
      lines: [
        'dy/dx  =  $slopeLatex',
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
    final xLatex = r.paramXExpr?.toLatexString() ?? '';
    final yLatex = r.paramYExpr?.toLatexString() ?? '';
    final dxLatex = r.dxDt?.toLatexString() ?? '';
    final dyLatex = r.dyDt?.toLatexString() ?? '';
    final slopeLatex = r.simplifiedDerivative.toLatexString();
    final dxRuleLines = r.paramXExpr != null
        ? DerivativeNarrator.narrate(r.paramXExpr!, t)
        : <String>[];
    final dyRuleLines = r.paramYExpr != null
        ? DerivativeNarrator.narrate(r.paramYExpr!, t)
        : <String>[];

    // ── GIVEN ───
    steps.add(ClassroomStep(
      kind: StepKind.sectionHeader,
      label: 'Given',
      lines: [
        'x(t)  =  $xLatex',
        'y(t)  =  $yLatex',
        'Find:  dy/dx  using Parametric Differentiation${r.point.containsKey(t) ? '  at  t = ${_fmt(r.point[t]!)}' : ''}',
      ],
    ));

    // ── Find Derivatives (merged: concept hint + diff x + diff y) ───
    steps.add(ClassroomStep(
      kind: StepKind.algebra,
      label: 'Find Derivatives',
      hint:
          'Use Chain Rule: dy/dx = (dy/dt)/(dx/dt). Differentiate x(t) and y(t) with respect to t',
      lines: [
        '\\frac{dx}{dt}:',
        ...dxRuleLines.map((l) => '  → $l'),
        '  dx/dt  =  $dxLatex',
        '',
        '\\frac{dy}{dt}:',
        ...dyRuleLines.map((l) => '  → $l'),
        '  dy/dt  =  $dyLatex',
      ],
    ));

    // ── Form Slope ───
    final dxE = r.dxDt;
    final dyE = r.dyDt;
    final rawRatioLatex = dxE != null && dyE != null
        ? BinOp(dyE, '/', dxE).toLatexString()
        : slopeLatex;
    final showSimplify = rawRatioLatex != slopeLatex;

    steps.add(ClassroomStep(
      kind: StepKind.algebra,
      label: 'Form Slope',
      hint: 'Apply parametric slope formula: dy/dx = (dy/dt)/(dx/dt)',
      lines: [
        '\\frac{dy}{dx} = \\frac{ $dyLatex }{ $dxLatex }',
        if (showSimplify) ...[
          '  = $rawRatioLatex',
          '',
          'Simplify:',
        ],
        '\\frac{dy}{dx} = $slopeLatex',
      ],
    ));

    // ── Evaluate ───
    if (r.point.containsKey(t) && r.slopeValue != null) {
      final tVal = r.point[t]!;
      final xVal = _evalSafe(r.paramXExpr!, r.point);
      final yVal = _evalSafe(r.paramYExpr!, r.point);
      final dxVal = _evalSafe(r.dxDt!, r.point);
      final dyVal = _evalSafe(r.dyDt!, r.point);

      final verticalTangent = dxVal != null && dxVal.abs() < 1e-12;

      steps.add(ClassroomStep(
        kind: StepKind.substitution,
        label: 'Evaluate',
        hint: 'Substitute t = ${_fmt(tVal)} into each derivative',
        lines: [
          if (dxVal != null)
            'dx/dt at t=${_fmt(tVal)}  =  $dxLatex  =  ${_fmt(dxVal)}',
          if (dyVal != null)
            'dy/dt at t=${_fmt(tVal)}  =  $dyLatex  =  ${_fmt(dyVal)}',
          '',
          if (verticalTangent)
            'dx/dt = 0  →  Vertical tangent at this point.'
          else ...[
            'dy/dx  =  ${_fmt(dyVal ?? 0)} / ${_fmt(dxVal ?? 1)}  =  ${_fmt(r.slopeValue!)}',
          ],
          if (xVal != null && yVal != null)
            'Point:  (${_fmt(xVal)}, ${_fmt(yVal)})',
        ],
      ));

      // ── Tangent Line ─── (tangent ONLY)
      if (r.tangentLineEquation != null &&
          xVal != null &&
          yVal != null &&
          !verticalTangent) {
        final m = r.slopeValue!;
        final b = yVal - m * xVal;
        steps.add(ClassroomStep(
          kind: StepKind.tangentNormal,
          label: 'Tangent Line',
          hint: 'Use point-slope form: y - y₀ = m(x - x₀)',
          lines: [
            'm = ${_fmt(m)},  (x₀, y₀) = (${_fmt(xVal)}, ${_fmt(yVal)})',
            '',
            'y - ${_fmt(yVal)} = ${_fmt(m)}(x - ${_fmt(xVal)})',
            'y = ${_fmt(m)}x + ${_fmt(b)}',
            '',
            '${r.tangentLineEquation}',
          ],
        ));
      }

      // ── Normal Line ─── (normal ONLY)
      if (r.normalLineEquation != null &&
          r.normalSlope != null &&
          xVal != null &&
          yVal != null &&
          !verticalTangent) {
        final mN = r.normalSlope!;
        final bN = yVal - mN * xVal;
        steps.add(ClassroomStep(
          kind: StepKind.tangentNormal,
          label: 'Normal Line',
          hint: 'm_normal = -1 / m_tangent',
          lines: [
            'm_normal = -1 / ${_fmt(r.slopeValue!)} = ${_fmt(mN)}',
            '',
            'y - ${_fmt(yVal)} = ${_fmt(mN)}(x - ${_fmt(xVal)})',
            'y = ${_fmt(mN)}x + ${_fmt(bN)}',
            '',
            '${r.normalLineEquation}',
          ],
        ));
      }
    }

    // ── RESULT ───
    steps.add(ClassroomStep(
      kind: StepKind.result,
      label: 'Answer',
      lines: [
        'dy/dx  =  $slopeLatex',
        if (r.slopeValue != null)
          'Slope at t = ${_fmt(r.point[t]!)}:   m = ${_fmt(r.slopeValue!)}',
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
