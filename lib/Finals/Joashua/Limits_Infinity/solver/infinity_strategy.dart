// lib/solvers/strategies/infinity_strategy.dart
// FIXED VERSION — bug notes are marked with "BUG FIX" comments.

import 'dart:math' show log;

import 'package:calculus_system/Finals/Joashua/Limits_Infinity/solver/ast_nodes.dart';
import 'package:calculus_system/Finals/Joashua/Limits_Infinity/solver/evaluator.dart';
import 'package:calculus_system/Finals/Joashua/Limits_Infinity/solver/limit_problem.dart';
import 'package:calculus_system/Finals/Joashua/Limits_Infinity/solver/simplifier.dart';
import 'package:calculus_system/Finals/Joashua/Limits_Infinity/solver/solutions.dart';
import 'package:calculus_system/Finals/Joashua/Limits_Infinity/solver/solver_strategy.dart';
import 'limit_result_type.dart';

class InfinityStrategy implements SolverStrategy {
  final Evaluator _evaluator = Evaluator();
  final Simplifier _simplifier = Simplifier();

  @override
  bool canAttempt(ASTNode expression, LimitProblem problem) {
    return problem.limitType == LimitType.positiveInfinity ||
        problem.limitType == LimitType.negativeInfinity;
  }

  @override
  SolveResult solve(
    ASTNode expression,
    LimitProblem problem,
    List<SolutionStep> previousSteps,
  ) {
    if (!canAttempt(expression, problem)) {
      return SolveResult.unsolved(previousSteps);
    }

    var steps = List<SolutionStep>.from(previousSteps);
    final isNegative = problem.limitType == LimitType.negativeInfinity;

    // -------------------------------------------------------------------------
    // STEP 1: Fully simplify BEFORE any analysis.
    // BUG FIX: _simplifier was instantiated but never called anywhere in the
    // original code.  Without simplification, raw ASTs like "2x + x" would
    // not be reduced to "3x", causing wrong degrees and coefficients downstream.
    // -------------------------------------------------------------------------
    final simplified = _simplifier.fullySimplify(expression);

    if (simplified.toString() != expression.toString()) {
      steps.add(SolutionStep(
        type: StepType.simplification,
        description: 'Simplify the expression first',
        expression: simplified,
        explanation:
            'Simplifying before analysis ensures accurate leading-term '
            'extraction and growth-rate comparison.',
      ));
    }

    // All downstream analysis uses the simplified expression.
    final expr = simplified;

    steps.add(SolutionStep(
      type: StepType.infinityAnalysis,
      description:
          'Analyzing behavior as ${problem.variable} → ${problem.limitPointString}',
      explanation:
          'When evaluating limits at infinity, we compare growth rates:\n'
          '• Logarithmic: ln(x), log(x)\n'
          '• Polynomial: x, x², x³, ...\n'
          '• Exponential: eˣ, 2ˣ, 10ˣ, ...\n'
          '• Factorial: x!\n\n'
          'Higher growth rates dominate at infinity.',
    ));

    // -------------------------------------------------------------------------
    // STEP 2: Numeric / symbolic evaluation on the simplified expression.
    // -------------------------------------------------------------------------
    final evalResult = _evaluator.evaluateAtInfinity(
      expr,
      problem.variable,
      negative: isNegative,
    );

    final limit = isNegative ? evalResult.leftLimit : evalResult.rightLimit;

    if (limit != null) {
      switch (limit.type) {
        case LimitResultType.finiteValue:
          steps.add(SolutionStep(
            type: StepType.conclusion,
            description: 'The expression converges to a finite value',
            expression: NumberNode(limit.value!),
            explanation:
                'As ${problem.variable} grows without bound, the expression '
                'approaches ${limit.value}.',
          ));
          return SolveResult(
            solved: true,
            result: NumberNode(limit.value!),
            resultType: LimitResultType.finiteValue,
            steps: steps,
            method: 'Infinity Analysis',
          );

        case LimitResultType.positiveInfinity:
          steps.add(SolutionStep(
            type: StepType.conclusion,
            description: 'The expression grows without bound',
            expression: InfinityNode(false),
            explanation:
                'The dominant terms cause the expression to approach +∞.',
          ));
          return SolveResult(
            solved: true,
            result: InfinityNode(false),
            resultType: LimitResultType.positiveInfinity,
            steps: steps,
            method: 'Infinity Analysis',
          );

        case LimitResultType.negativeInfinity:
          steps.add(SolutionStep(
            type: StepType.conclusion,
            description: 'The expression decreases without bound',
            expression: InfinityNode(true),
            explanation:
                'The dominant terms cause the expression to approach -∞.',
          ));
          return SolveResult(
            solved: true,
            result: InfinityNode(true),
            resultType: LimitResultType.negativeInfinity,
            steps: steps,
            method: 'Infinity Analysis',
          );

        case LimitResultType.doesNotExist:
          steps.add(SolutionStep(
            type: StepType.conclusion,
            description: 'The limit does not exist',
            expression: null,
            explanation:
                'The expression oscillates and does not approach a single value.',
          ));
          return SolveResult(
            solved: true,
            result: null,
            resultType: LimitResultType.doesNotExist,
            steps: steps,
            method: 'Infinity Analysis',
          );

        default:
          break;
      }
    }

    // -------------------------------------------------------------------------
    // STEP 3: Leading-term analysis for rational functions f(x) / g(x).
    // Guard: expression must be BinaryOpNode('/') before accessing .left/.right.
    // -------------------------------------------------------------------------
    if (expr is BinaryOpNode && expr.operator == '/') {
      // BUG FIX: Simplify numerator and denominator individually so that
      // combined like-terms are resolved before degree/coefficient extraction.
      final simplifiedRatio = BinaryOpNode(
        _simplifier.fullySimplify(expr.left),
        '/',
        _simplifier.fullySimplify(expr.right),
      );

      final leadingResult =
          _analyzeLeadingTerms(simplifiedRatio, problem, steps);
      if (leadingResult != null) return leadingResult;
    }

    // -------------------------------------------------------------------------
    // STEP 4: Exponential growth analysis.
    // -------------------------------------------------------------------------
    final expResult = _analyzeExponentialGrowth(expr, problem, steps);
    if (expResult != null) return expResult;

    return SolveResult.unsolved(steps);
  }

  // ---------------------------------------------------------------------------
  // Leading-term analysis for rational functions  f(x) / g(x)
  // ---------------------------------------------------------------------------

  /// [expression] is already confirmed to be a BinaryOpNode('/') by the caller.
  SolveResult? _analyzeLeadingTerms(
    BinaryOpNode expression,
    LimitProblem problem,
    List<SolutionStep> steps,
  ) {
    final numerator = expression.left;
    final denominator = expression.right;

    final numDegree = numerator.polynomialDegree(problem.variable);
    final denDegree = denominator.polynomialDegree(problem.variable);

    if (numDegree == null || denDegree == null) return null;

    final numLeadingCoeff =
        _getLeadingCoefficient(numerator, problem.variable, numDegree);
    final denLeadingCoeff =
        _getLeadingCoefficient(denominator, problem.variable, denDegree);

    if (numLeadingCoeff == null || denLeadingCoeff == null) return null;

    // Guard: zero denominator leading coefficient would cause division by zero.
    if (denLeadingCoeff == 0) return null;

    steps.add(SolutionStep(
      type: StepType.leadingTerm,
      description: 'Identify leading terms',
      expression: expression,
      explanation: 'Numerator degree: $numDegree\n'
          'Denominator degree: $denDegree\n'
          'Leading coefficients: $numLeadingCoeff / $denLeadingCoeff',
    ));

    final degreeDiff = numDegree - denDegree;
    final coeffRatio = numLeadingCoeff / denLeadingCoeff;

    if (degreeDiff > 0) {
      // Numerator grows faster → ±∞.
      //
      // BUG FIX: The original only checked whether the problem direction was
      // negativeInfinity AND degreeDiff was odd — it completely ignored the
      // sign of coeffRatio.  e.g. lim(-3x³/x²) as x→+∞ would incorrectly
      // return +∞ instead of -∞.
      //
      // Correct logic:
      //   sign(x^degreeDiff) as x→+∞  = +1  (always)
      //   sign(x^degreeDiff) as x→-∞  = -1  if degreeDiff is odd, +1 if even
      //
      //   final direction = sign(coeffRatio) * sign(x^degreeDiff)
      final isNegativeInfinity =
          problem.limitType == LimitType.negativeInfinity;
      final xPowerSign = (isNegativeInfinity && degreeDiff.isOdd) ? -1.0 : 1.0;
      final limitSign = coeffRatio.sign * xPowerSign;

      final goesNegative = limitSign < 0;
      final result = InfinityNode(goesNegative);

      steps.add(SolutionStep(
        type: StepType.conclusion,
        description:
            'Numerator degree ($numDegree) > Denominator degree ($denDegree)',
        expression: result,
        explanation: 'The numerator has higher degree so the fraction grows '
            'without bound.\n'
            'Leading coefficient ratio: $numLeadingCoeff / $denLeadingCoeff '
            '= ${coeffRatio.toStringAsFixed(6)}\n'
            'Direction x→${isNegativeInfinity ? '-∞' : '+∞'}, '
            'degree-difference parity: ${degreeDiff.isOdd ? 'odd' : 'even'}\n'
            '→ limit = ${goesNegative ? '-∞' : '+∞'}',
      ));

      return SolveResult(
        solved: true,
        result: result,
        resultType: goesNegative
            ? LimitResultType.negativeInfinity
            : LimitResultType.positiveInfinity,
        steps: steps,
        method: 'Leading Term Analysis',
      );
    } else if (degreeDiff < 0) {
      // Denominator grows faster → 0.
      steps.add(SolutionStep(
        type: StepType.conclusion,
        description:
            'Numerator degree ($numDegree) < Denominator degree ($denDegree)',
        expression: NumberNode(0),
        explanation:
            'Since the denominator has higher degree, the fraction approaches 0.',
      ));

      return SolveResult(
        solved: true,
        result: NumberNode(0),
        resultType: LimitResultType.finiteValue,
        steps: steps,
        method: 'Leading Term Analysis',
      );
    } else {
      // Equal degrees → ratio of leading coefficients.
      steps.add(SolutionStep(
        type: StepType.conclusion,
        description:
            'Equal degrees — limit equals ratio of leading coefficients',
        expression: NumberNode(coeffRatio),
        explanation:
            'When degrees are equal, the limit is the ratio of leading '
            'coefficients: $numLeadingCoeff / $denLeadingCoeff = $coeffRatio',
      ));

      return SolveResult(
        solved: true,
        result: NumberNode(coeffRatio),
        resultType: LimitResultType.finiteValue,
        steps: steps,
        method: 'Leading Term Analysis',
      );
    }
  }

  /// BUG FIX: Original returned on the FIRST term matching [degree].
  /// e.g. "2x² + 3x²" would report leading coefficient 2 instead of 5.
  /// Now accumulates ALL terms at [degree] before returning.
  double? _getLeadingCoefficient(ASTNode node, String variable, int degree) {
    final terms = node.getTerms();
    double? total;
    for (final term in terms) {
      final termDegree = term.polynomialDegree(variable);
      if (termDegree == degree) {
        final coeff = _extractCoefficient(term, variable);
        if (coeff == null) return null; // unknown term — bail out entirely
        total = (total ?? 0) + coeff;
      }
    }
    return total;
  }

  double? _extractCoefficient(ASTNode term, String variable) {
    if (term is NumberNode) return term.value;
    if (term is VariableNode) return term.name == variable ? 1.0 : null;
    if (term is UnaryMinusNode) {
      final inner = _extractCoefficient(term.operand, variable);
      return inner != null ? -inner : null;
    }
    if (term is BinaryOpNode) {
      switch (term.operator) {
        case '*':
          // coeff * expr  or  expr * coeff
          final leftVal = term.left.tryEvaluate();
          if (leftVal != null) return leftVal;
          final rightVal = term.right.tryEvaluate();
          if (rightVal != null) return rightVal;
          break;
        case '^':
          // var^n — implicit coefficient 1
          if (term.left is VariableNode &&
              (term.left as VariableNode).name == variable) {
            return 1.0;
          }
          break;
      }
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Exponential growth analysis
  // ---------------------------------------------------------------------------

  SolveResult? _analyzeExponentialGrowth(
    ASTNode expression,
    LimitProblem problem,
    List<SolutionStep> steps,
  ) {
    if (!_containsExponential(expression)) return null;

    steps.add(SolutionStep(
      type: StepType.infinityAnalysis,
      description: 'Expression contains exponential terms',
      explanation: 'Exponential functions grow faster than any polynomial. '
          'The exponential term will dominate the behavior.',
    ));

    // Only meaningful as a ratio — guard before accessing .left / .right.
    if (expression is! BinaryOpNode || expression.operator != '/') {
      return null;
    }

    final numRate =
        _getExponentialGrowthRate(expression.left, problem.variable);
    final denRate =
        _getExponentialGrowthRate(expression.right, problem.variable);

    if (numRate != null && denRate != null) {
      if (numRate > denRate) {
        // BUG FIX: Original code set goesNegative based on result.isInfinity(),
        // which is always true for any InfinityNode — so the ternary always
        // picked positiveInfinity regardless of direction.
        // Correct: determine direction first, then build the node.
        final goesNegative =
            problem.limitType == LimitType.negativeInfinity && numRate < 0;
        final result = InfinityNode(goesNegative);

        steps.add(SolutionStep(
          type: StepType.conclusion,
          description: 'Numerator exponential (ln-rate $numRate) dominates '
              'denominator (ln-rate $denRate)',
          expression: result,
          explanation: 'The numerator exponential grows faster; '
              'limit = ${goesNegative ? '-∞' : '+∞'}.',
        ));

        return SolveResult(
          solved: true,
          result: result,
          resultType: goesNegative
              ? LimitResultType.negativeInfinity
              : LimitResultType.positiveInfinity,
          steps: steps,
          method: 'Exponential Growth Analysis',
        );
      } else if (denRate > numRate) {
        steps.add(SolutionStep(
          type: StepType.conclusion,
          description: 'Denominator exponential (ln-rate $denRate) dominates '
              'numerator (ln-rate $numRate)',
          expression: NumberNode(0),
          explanation: 'The denominator exponential grows faster; limit = 0.',
        ));

        return SolveResult(
          solved: true,
          result: NumberNode(0),
          resultType: LimitResultType.finiteValue,
          steps: steps,
          method: 'Exponential Growth Analysis',
        );
      }
      // Equal rates — fall through; let evaluator or another strategy handle it.
    }

    return null;
  }

  bool _containsExponential(ASTNode node) {
    if (node is FunctionNode && (node.name == 'exp' || node.name == 'ln'))
      return true;
    if (node is BinaryOpNode) {
      // Also detect base^variable patterns like 2^x.
      if (node.operator == '^') {
        final baseVal = node.left.tryEvaluate();
        if (baseVal != null && baseVal > 0 && baseVal != 1) {
          if (_referencesVariable(node.right)) return true;
        }
      }
      return _containsExponential(node.left) ||
          _containsExponential(node.right);
    }
    return false;
  }

  /// Returns true if [node] contains any VariableNode.
  bool _referencesVariable(ASTNode node) {
    if (node is VariableNode) return true;
    if (node is BinaryOpNode) {
      return _referencesVariable(node.left) || _referencesVariable(node.right);
    }
    if (node is UnaryMinusNode) return _referencesVariable(node.operand);
    if (node is FunctionNode) return _referencesVariable(node.argument);
    return false;
  }

  /// Returns the natural-log growth rate for an exponential sub-expression,
  /// or null if [node] is not a recognised exponential form.
  ///
  /// Supports:
  ///   exp(k*x)  →  k
  ///   e^(k*x)   →  k          (base evaluates to e)
  ///   b^(k*x)   →  k * ln(b)  (any positive constant base b ≠ 1)
  double? _getExponentialGrowthRate(ASTNode node, String variable) {
    // exp(argument)
    if (node is FunctionNode && node.name == 'exp') {
      return _getLinearCoefficient(node.argument, variable) ?? 1.0;
    }
    // base^(linear in variable) — BUG FIX: original only handled FunctionNode
    // 'exp' and missed base^x forms entirely.
    if (node is BinaryOpNode && node.operator == '^') {
      final baseVal = node.left.tryEvaluate();
      if (baseVal != null && baseVal > 0 && baseVal != 1) {
        final k = _getLinearCoefficient(node.right, variable);
        if (k != null && k != 0) return k * log(baseVal);
      }
    }
    return null;
  }

  /// Returns the coefficient k such that [node] = k * [variable],
  /// or null if [node] is not a degree-1 expression in [variable].
  double? _getLinearCoefficient(ASTNode node, String variable) {
    if (node is VariableNode && node.name == variable) return 1.0;
    if (node is NumberNode) return null; // constant, not linear in variable
    if (node is UnaryMinusNode) {
      final inner = _getLinearCoefficient(node.operand, variable);
      return inner != null ? -inner : null;
    }
    if (node is BinaryOpNode && node.operator == '*') {
      // k * x
      final leftVal = node.left.tryEvaluate();
      if (leftVal != null &&
          node.right is VariableNode &&
          (node.right as VariableNode).name == variable) {
        return leftVal;
      }
      // x * k
      final rightVal = node.right.tryEvaluate();
      if (rightVal != null &&
          node.left is VariableNode &&
          (node.left as VariableNode).name == variable) {
        return rightVal;
      }
    }
    return null;
  }
}
