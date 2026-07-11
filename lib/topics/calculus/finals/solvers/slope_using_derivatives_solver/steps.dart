// solution_steps.dart
// Classroom Solution Steps â€” Slope Solver
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// Depends on: slope_solver.dart (share the same directory)
// Usage:
//   dart solution_steps.dart
//   dart solution_steps.dart "y = x^3 - 2x + 1" x=2
//   dart solution_steps.dart "x^2 + y^2 = 25" x=3 y=4
//   dart solution_steps.dart "x=cos(t), y=sin(t)" t=1.5708

// ignore_for_file: constant_identifier_names, prefer_const_constructors

import 'dart:math' as math;
import 'dart:io';

import 'slope_using_derivatives_solver.dart';

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// PASTE THE ENTIRE CONTENTS OF slope_solver.dart HERE (all classes up to main)
// then delete slope_solver's own main() â€” only the main() below is kept.
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

// â”€â”€â”€ Forward declarations satisfied by slope_solver content above â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// TokenType, Token, Tokenizer, Parser, Expr hierarchy (Num, Var, Const, BinOp,
// Pow, UnaryNeg, Func, DerivSym), ExprUtils, Simplifier, Differentiator,
// ProblemType, SlopeResult, SlopeSolver, StepExplainer, PrettyPrinter

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// Â§1  DATA MODEL
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

/// Semantic category of a single classroom step.
enum StepKind {
  sectionHeader, // bold title line  e.g. "â”€â”€ GIVEN â”€â”€"
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

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// Â§2  DERIVATIVE NARRATOR
//     Converts an Expr AST node into the name of the differentiation rule
//     applied at the top level, with a short justification phrase.
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

class DerivativeNarrator {
  /// Returns lines such as:
  ///   "Power Rule:  d/dx[uâ¿] = nÂ·uâ¿â»Â¹Â·u'"
  ///   "Product Rule: d/dx[fÂ·g] = f'g + fg'"
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
        ...narrate(expr.operand, wrtVar).map((s) => '  â†³ inner: $s'),
      ];
    }
    if (expr is BinOp) {
      switch (expr.op) {
        case '+':
          return ['Sum Rule:  d/d$wrtVar[f + g] = f\' + g\''];
        case '-':
          return ['Difference Rule:  d/d$wrtVar[f âˆ’ g] = f\' âˆ’ g\''];
        case '*':
          return [
            'Product Rule:  d/d$wrtVar[fÂ·g] = f\'Â·g + fÂ·g\'',
            '  where  f = ${expr.left.toMathString()}',
            '         g = ${expr.right.toMathString()}',
          ];
        case '/':
          return [
            'Quotient Rule:  d/d$wrtVar[f/g] = (f\'g âˆ’ fg\') / gÂ²',
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
          'Power Rule:  d/d$wrtVar[uâ¿] = nÂ·uâ¿â»Â¹Â·u\'  (with Chain Rule)',
          '  where  u = ${expr.base.toMathString()}',
          '         n = ${expr.exponent.toMathString()}',
        ];
      }
      if (!baseHasVar && expHasVar) {
        return [
          'Exponential Rule:  d/d$wrtVar[aáµ˜] = aáµ˜Â·ln(a)Â·u\'',
          '  where  a = ${expr.base.toMathString()}',
          '         u = ${expr.exponent.toMathString()}',
        ];
      }
      return [
        'General Power Rule:  d/d$wrtVar[fáµ] = fáµÂ·(g\'Â·ln f + gÂ·f\'/f)',
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
        return ['d/d$wrtVar[sin u] = cos u Â· u\'$chain', '  where  u = $u'];
      case 'cos':
        return ['d/d$wrtVar[cos u] = âˆ’sin u Â· u\'$chain', '  where  u = $u'];
      case 'tan':
        return [
          'd/d$wrtVar[tan u] = secÂ²u Â· u\'  =  u\' / cosÂ²u$chain',
          '  where  u = $u'
        ];
      case 'cot':
        return [
          'd/d$wrtVar[cot u] = âˆ’cscÂ²u Â· u\'  =  âˆ’u\' / sinÂ²u$chain',
          '  where  u = $u'
        ];
      case 'sec':
        return [
          'd/d$wrtVar[sec u] = sec u Â· tan u Â· u\'  =  sin u Â· u\' / cosÂ²u$chain',
          '  where  u = $u'
        ];
      case 'csc':
        return [
          'd/d$wrtVar[csc u] = âˆ’csc u Â· cot u Â· u\'  =  âˆ’cos u Â· u\' / sinÂ²u$chain',
          '  where  u = $u'
        ];
      case 'asin':
      case 'arcsin':
        return [
          'd/d$wrtVar[arcsin u] = u\' / âˆš(1 âˆ’ uÂ²)$chain',
          '  where  u = $u'
        ];
      case 'acos':
      case 'arccos':
        return [
          'd/d$wrtVar[arccos u] = âˆ’u\' / âˆš(1 âˆ’ uÂ²)$chain',
          '  where  u = $u'
        ];
      case 'atan':
      case 'arctan':
        return [
          'd/d$wrtVar[arctan u] = u\' / (1 + uÂ²)$chain',
          '  where  u = $u'
        ];
      case 'sinh':
        return ['d/d$wrtVar[sinh u] = cosh u Â· u\'$chain', '  where  u = $u'];
      case 'cosh':
        return ['d/d$wrtVar[cosh u] = sinh u Â· u\'$chain', '  where  u = $u'];
      case 'tanh':
        return ['d/d$wrtVar[tanh u] = u\' / coshÂ²u$chain', '  where  u = $u'];
      case 'ln':
        return ['d/d$wrtVar[ln u] = u\' / u$chain', '  where  u = $u'];
      case 'log':
        return [
          'd/d$wrtVar[logâ‚â‚€ u] = u\' / (u Â· ln 10)$chain',
          '  where  u = $u'
        ];
      case 'exp':
        return ['d/d$wrtVar[eáµ˜] = eáµ˜ Â· u\'$chain', '  where  u = $u'];
      case 'sqrt':
        return ['d/d$wrtVar[âˆšu] = u\' / (2âˆšu)$chain', '  where  u = $u'];
      case 'abs':
        return [
          'd/d$wrtVar[|u|] = u Â· u\' / |u|   (u â‰  0)$chain',
          '  where  u = $u'
        ];
      case 'cbrt':
        return [
          'd/d$wrtVar[âˆ›u] = u\' / (3 Â· u^(2/3))$chain',
          '  where  u = $u'
        ];
      default:
        return [
          'd/d$wrtVar[${expr.name}(u)] Â· u\'  (Chain Rule)',
          '  where  u = $u'
        ];
    }
  }
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// Â§3  SOLUTION BUILDER â€” dispatches to the three sub-builders
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

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

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// Â§4  EXPLICIT SOLUTION BUILDER   y = f(x)
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

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
    final showSimplify = r.derivative.toMathString() != r.simplifiedDerivative.toMathString();
    final ruleLines = DerivativeNarrator.narrate(f, x);

    // â”€â”€ Given â”€â”€â”€
    steps.add(ClassroomStep(
      kind: StepKind.sectionHeader,
      label: 'Given',
      lines: [
        '$y = $fLatex',
        if (hasPoint) 'Find slope at $x = ${_fmt(r.point[x]!)}',
      ],
    ));

    // â”€â”€ Differentiate (rules + result merged) â”€â”€â”€
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

    // â”€â”€ Simplify (separate, only if different) â”€â”€â”€
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

    // â”€â”€ Evaluate â”€â”€â”€
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

      // â”€â”€ Tangent Line â”€â”€â”€ (tangent ONLY)
      final yVal = _evalSafe(r.functionExpr, r.point);
      if (yVal != null && r.tangentLineEquation != null) {
        final m = r.slopeValue!;
        steps.add(ClassroomStep(
          kind: StepKind.tangentNormal,
          label: 'Tangent Line',
          hint: 'Use point-slope form: y - yâ‚€ = m(x - xâ‚€)',
          lines: [
            'm = ${_fmt(m)},  (xâ‚€, yâ‚€) = (${_fmt(xv)}, ${_fmt(yVal)})',
            '',
            'y - ${_fmt(yVal)} = ${_fmt(m)}(x - ${_fmt(xv)})',
            'y = ${_fmt(m)}x + ${_fmt(yVal - m * xv)}',
            '',
            '${r.tangentLineEquation}',
          ],
        ));
      }

      // â”€â”€ Normal Line â”€â”€â”€ (normal ONLY)
      if (yVal != null && r.normalLineEquation != null && r.normalSlope != null) {
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

    // â”€â”€ Result â”€â”€â”€
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
      problemTitle: 'Explicit Differentiation â€” ${r.originalInput}',
      type: r.type,
      steps: steps,
      result: r,
    );
  }
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// Â§5  IMPLICIT SOLUTION BUILDER   F(x,y) = G(x,y)
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

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

    // â”€â”€ GIVEN â”€â”€â”€
    steps.add(ClassroomStep(
      kind: StepKind.sectionHeader,
      label: 'Given',
      lines: [
        '$lhsLatex  =  $rhsLatex',
        'Find:  \\frac{dy}{dx}  using Implicit Differentiation'
            '${hasPoint ? '  at  (${_fmt(r.point['x']!)}, ${_fmt(r.point['y']!)})' : ''}',
      ],
    ));

    // â”€â”€ Differentiate LHS â”€â”€â”€
    steps.add(ClassroomStep(
      kind: StepKind.algebra,
      label: 'Diff LHS',
      hint: 'Differentiate left side with respect to x, treat y as y(x)',
      lines: [
        '\\frac{d}{dx}[ $lhsLatex ]',
        ...dLRuleLines.map((l) => '  â†’ $l'),
        '',
        '= $dLatex',
      ],
    ));

    // â”€â”€ Differentiate RHS â”€â”€â”€
    steps.add(ClassroomStep(
      kind: StepKind.algebra,
      label: 'Diff RHS',
      hint: 'Differentiate right side with respect to x',
      lines: [
        '\\frac{d}{dx}[ $rhsLatex ]',
        ...dRRuleLines.map((l) => '  â†’ $l'),
        '',
        '= $dRLatex',
      ],
    ));

    // â”€â”€ Combine â”€â”€â”€
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

    // â”€â”€ Move Terms â”€â”€â”€
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

      // â”€â”€ Isolate dy/dx â”€â”€â”€
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

      // â”€â”€ Simplify (only if needed) â”€â”€â”€
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

    // â”€â”€ Evaluate â”€â”€â”€
    if (hasPoint && r.slopeValue != null) {
      final xVal = r.point['x']!;
      final yVal = r.point['y']!;
      steps.add(ClassroomStep(
        kind: StepKind.substitution,
        label: 'Evaluate',
        hint: 'Substitute x = ${_fmt(xVal)}, y = ${_fmt(yVal)} into the slope formula',
        lines: [
          '\\frac{dy}{dx} = $slopeLatex  at  (${_fmt(xVal)}, ${_fmt(yVal)})',
          '',
          'm = ${_fmt(r.slopeValue!)}',
        ],
      ));

      // â”€â”€ Tangent Line â”€â”€â”€ (tangent ONLY)
      if (r.tangentLineEquation != null) {
        final m = r.slopeValue!;
        final b = yVal - m * xVal;
        steps.add(ClassroomStep(
          kind: StepKind.tangentNormal,
          label: 'Tangent Line',
          hint: 'Use point-slope form: y - yâ‚€ = m(x - xâ‚€)',
          lines: [
            'm = ${_fmt(m)},  (xâ‚€, yâ‚€) = (${_fmt(xVal)}, ${_fmt(yVal)})',
            '',
            'y - ${_fmt(yVal)} = ${_fmt(m)}(x - ${_fmt(xVal)})',
            'y = ${_fmt(m)}x + ${_fmt(b)}',
            '',
            '${r.tangentLineEquation}',
          ],
        ));
      }

      // â”€â”€ Normal Line â”€â”€â”€ (normal ONLY)
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

    // â”€â”€ RESULT â”€â”€â”€
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
      problemTitle: 'Implicit Differentiation â€” ${r.originalInput}',
      type: r.type,
      steps: steps,
      result: r,
    );
  }
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// Â§6  PARAMETRIC SOLUTION BUILDER   x = f(t),  y = g(t)
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

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

    // â”€â”€ GIVEN â”€â”€â”€
    steps.add(ClassroomStep(
      kind: StepKind.sectionHeader,
      label: 'Given',
      lines: [
        'x(t)  =  $xLatex',
        'y(t)  =  $yLatex',
        'Find:  dy/dx  using Parametric Differentiation${r.point.containsKey(t) ? '  at  t = ${_fmt(r.point[t]!)}' : ''}',
      ],
    ));

    // â”€â”€ Find Derivatives (merged: concept hint + diff x + diff y) â”€â”€â”€
    steps.add(ClassroomStep(
      kind: StepKind.algebra,
      label: 'Find Derivatives',
      hint: 'Use Chain Rule: dy/dx = (dy/dt)/(dx/dt). Differentiate x(t) and y(t) with respect to t',
      lines: [
        '\\frac{dx}{dt}:',
        ...dxRuleLines.map((l) => '  â†’ $l'),
        '  dx/dt  =  $dxLatex',
        '',
        '\\frac{dy}{dt}:',
        ...dyRuleLines.map((l) => '  â†’ $l'),
        '  dy/dt  =  $dyLatex',
      ],
    ));

    // â”€â”€ Form Slope â”€â”€â”€
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

    // â”€â”€ Evaluate â”€â”€â”€
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
            'dx/dt = 0  â†’  Vertical tangent at this point.'
          else ...[
            'dy/dx  =  ${_fmt(dyVal ?? 0)} / ${_fmt(dxVal ?? 1)}  =  ${_fmt(r.slopeValue!)}',
          ],
          if (xVal != null && yVal != null)
            'Point:  (${_fmt(xVal)}, ${_fmt(yVal)})',
        ],
      ));

      // â”€â”€ Tangent Line â”€â”€â”€ (tangent ONLY)
      if (r.tangentLineEquation != null &&
          xVal != null &&
          yVal != null &&
          !verticalTangent) {
        final m = r.slopeValue!;
        final b = yVal - m * xVal;
        steps.add(ClassroomStep(
          kind: StepKind.tangentNormal,
          label: 'Tangent Line',
          hint: 'Use point-slope form: y - yâ‚€ = m(x - xâ‚€)',
          lines: [
            'm = ${_fmt(m)},  (xâ‚€, yâ‚€) = (${_fmt(xVal)}, ${_fmt(yVal)})',
            '',
            'y - ${_fmt(yVal)} = ${_fmt(m)}(x - ${_fmt(xVal)})',
            'y = ${_fmt(m)}x + ${_fmt(b)}',
            '',
            '${r.tangentLineEquation}',
          ],
        ));
      }

      // â”€â”€ Normal Line â”€â”€â”€ (normal ONLY)
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

    // â”€â”€ RESULT â”€â”€â”€
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
      problemTitle: 'Parametric Differentiation â€” ${r.originalInput}',
      type: r.type,
      steps: steps,
      result: r,
    );
  }
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// Â§7  CLASSROOM PRINTER
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

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
    _w('$_dim${'â”€' * _W}$_rst');
  }

  static void _titleBanner(String title, ProblemType type) {
    final badge = switch (type) {
      ProblemType.explicit => '${_grn}EXPLICIT$_rst',
      ProblemType.implicit => '${_yel}IMPLICIT$_rst',
      ProblemType.parametric => '${_mag}PARAMETRIC$_rst',
    };
    _w('');
    _w('$_bold$_wht${'â”' * _W}$_rst');
    _w('$_bold$_wht  â–¶  $title$_rst');
    _w('$_bold  Type: $badge$_rst');
    _w('$_bold$_wht${'â”' * _W}$_rst');
    _w('');
  }

  static void _printStep(ClassroomStep step) {
    final lbl = step.label;
    final fill = _W - lbl.length - 2;

    switch (step.kind) {
      case StepKind.sectionHeader:
        _w('$_bold$_cyan  â•”â•â• ${lbl.toUpperCase()} â•â•$_rst');
        if (step.hint != null) _w('$_dim  â•‘  â‡¢ ${step.hint}$_rst');
        for (final l in step.lines) {
          _w('$_cyan  â•‘  $l$_rst');
        }
        _w('$_cyan  â•š${'â•' * 40}$_rst');
        _w('');

      case StepKind.ruleStatement:
        _w('$_bold$_yel  â”Œâ”€ $lbl â”€â”€â”€ [Rule] ${'â”€' * (fill - 14 < 0 ? 0 : fill - 14)}$_rst');
        if (step.hint != null) _w('$_dim$_yel  â”‚  â‡¢ ${step.hint}$_rst');
        for (final l in step.lines) {
          _w('$_yel  â”‚$_rst  $l');
        }
        _w('$_yel  â””${'â”€' * (_W - 4)}$_rst');
        _w('');

      case StepKind.algebra:
        _w('$_bold$_blu  â”Œâ”€ $lbl â”€â”€â”€ [Algebra] ${'â”€' * (fill - 17 < 0 ? 0 : fill - 17)}$_rst');
        if (step.hint != null) _w('$_dim$_blu  â”‚  â‡¢ ${step.hint}$_rst');
        for (final l in step.lines) {
          final isMath = l.contains('=') ||
              l.contains('d/dx') ||
              l.contains('dy/dx') ||
              l.contains('dx/d') ||
              l.contains('dy/d');
          if (isMath && l.trim().isNotEmpty) {
            _w('$_blu  â”‚$_rst$_bold  $l$_rst');
          } else {
            _w('$_blu  â”‚$_rst  $l');
          }
        }
        _w('$_blu  â””${'â”€' * (_W - 4)}$_rst');
        _w('');

      case StepKind.substitution:
        _w('$_bold$_grn  â”Œâ”€ $lbl â”€â”€â”€ [Substitute] ${'â”€' * (fill - 20 < 0 ? 0 : fill - 20)}$_rst');
        if (step.hint != null) _w('$_dim$_grn  â”‚  â‡¢ ${step.hint}$_rst');
        for (final l in step.lines) {
          _w('$_grn  â”‚$_rst  $l');
        }
        _w('$_grn  â””${'â”€' * (_W - 4)}$_rst');
        _w('');

      case StepKind.tangentNormal:
        _w('$_bold$_mag  â”Œâ”€ $lbl â”€â”€â”€ [Line] ${'â”€' * (fill - 14 < 0 ? 0 : fill - 14)}$_rst');
        if (step.hint != null) _w('$_dim$_mag  â”‚  â‡¢ ${step.hint}$_rst');
        for (final l in step.lines) {
          _w('$_mag  â”‚$_rst  $l');
        }
        _w('$_mag  â””${'â”€' * (_W - 4)}$_rst');
        _w('');

      case StepKind.note:
        _w('$_dim  â—¦ $lbl:  ${step.lines.join(' ')}$_rst');
        _w('');

      case StepKind.result:
        _w('$_bold$_wht  â•”${'â•' * (_W - 4)}â•—$_rst');
        _w('$_bold$_wht  â•‘${_center('âœ“  ANSWER', _W - 4)}â•‘$_rst');
        _w('$_bold$_wht  â• ${'â•' * (_W - 4)}â•£$_rst');
        if (step.hint != null) _w('$_dim$_wht  â•‘  â‡¢ ${step.hint}$_rst');
        for (final l in step.lines) {
          final padded = '  $l';
          final right = _W - 4 - padded.length;
          _w('$_bold$_wht  â•‘$_rst$_bold$padded${' ' * (right < 0 ? 0 : right)}$_whtâ•‘$_rst');
        }
        _w('$_bold$_wht  â•š${'â•' * (_W - 4)}â•$_rst');
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

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// Â§8  SHARED UTILITIES
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

String _fmt(double v) {
  if (v != v) return 'undefined';
  if (v.isInfinite) return v > 0 ? '+âˆž' : 'âˆ’âˆž';
  if (v == v.truncateToDouble() && v.abs() < 1e10) return v.toInt().toString();
  final fracs = <double, String>{
    0.5: '1/2',
    -0.5: 'âˆ’1/2',
    1 / 3: '1/3',
    -1 / 3: 'âˆ’1/3',
    2 / 3: '2/3',
    -2 / 3: 'âˆ’2/3',
    0.25: '1/4',
    -0.25: 'âˆ’1/4',
    0.75: '3/4',
    -0.75: 'âˆ’3/4',
    math.sqrt2: 'âˆš2',
    -math.sqrt2: 'âˆ’âˆš2',
    math.pi: 'Ï€',
    -math.pi: 'âˆ’Ï€',
    math.e: 'e',
    -math.e: 'âˆ’e',
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

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// Â§9  CLI ARG PARSER
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

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

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// Â§10  MAIN â€” 14 curated classroom problems (6 explicit, 4 implicit, 4 parametric)
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

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

  // â”€â”€ Classroom problem set â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  final problems = <(String, Map<String, double>, String)>[
    // Explicit
    ('y = x^3 - 3*x^2 + 2', {'x': 2.0}, 'Polynomial â€” Power + Sum Rule'),
    ('y = sin(x) * cos(x)', {'x': 0.0}, 'Trig product â€” Product Rule'),
    ('y = e^x * ln(x)', {'x': 1.0}, 'Exponential Ã— Log â€” Product Rule'),
    (
      'y = (x^2 + 1) / (x - 1)',
      {'x': 3.0},
      'Rational function â€” Quotient Rule'
    ),
    ('y = (sin(x))^3', {'x': 1.5708}, 'Composite â€” Power + Chain Rule'),
    ('y = sqrt(x^2 + 1)', {'x': 2.0}, 'Square root â€” Chain Rule'),
    // Implicit
    ('x^2 + y^2 = 25', {'x': 3.0, 'y': 4.0}, 'Circle'),
    ('x^3 + y^3 = 6*x*y', {'x': 3.0, 'y': 3.0}, 'Folium of Descartes'),
    (
      '4*x^2 + 9*y^2 = 36',
      {'x': 0.0, 'y': 2.0},
      'Ellipse â€” horizontal tangent'
    ),
    (
      'x^2 - x*y + y^2 = 7',
      {'x': 1.0, 'y': 3.0},
      'Mixed xy term â€” Product Rule'
    ),
    // Parametric
    ('x=cos(t), y=sin(t)', {'t': 0.7854}, 'Unit circle â€” t = Ï€/4'),
    ('x=t - sin(t), y=1 - cos(t)', {'t': 1.5708}, 'Cycloid â€” t = Ï€/2'),
    ('x=cos(t)^3, y=sin(t)^3', {'t': 0.5236}, 'Astroid â€” t = Ï€/6'),
    ('x=t^2 - 1, y=t^3 - t', {'t': 1.0}, 'Cubic parametric curve'),
  ];

  final total = problems.length;
  stdout.writeln('');
  stdout.writeln('â•”${'â•' * 70}â•—');
  stdout.writeln(
      'â•‘${_centerMain('CLASSROOM SOLUTION STEPS â€” SLOPE & DERIVATIVES', 70)}â•‘');
  stdout.writeln(
      'â•‘${_centerMain('$total worked examples  â€¢  Explicit / Implicit / Parametric', 70)}â•‘');
  stdout.writeln('â•š${'â•' * 70}â•');
  stdout.writeln('');

  int passed = 0, failed = 0;

  for (int i = 0; i < total; i++) {
    final (eq, vals, desc) = problems[i];
    stdout.writeln('Problem ${i + 1} of $total â€” $desc');
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
  stdout.writeln('â•”${'â•' * 70}â•—');
  stdout.writeln('â•‘${_centerMain('SESSION COMPLETE', 70)}â•‘');
  stdout.writeln(
      'â•‘${_centerMain('$passed solved  â€¢  $failed errors  â€¢  $total total', 70)}â•‘');
  stdout.writeln('â•š${'â•' * 70}â•');
  stdout.writeln('');
}

String _centerMain(String s, int w) {
  final pad = ((w - s.length) / 2).floor();
  final rpad = w - pad - s.length;
  return ' ' * pad + s + ' ' * (rpad < 0 ? 0 : rpad);
}
