// lib/solvers/strategies/trigonometric_strategy.dart

import 'package:calculus_system/Finals/Joashua/Limits_Infinity/solver/ast_nodes.dart';
import 'package:calculus_system/Finals/Joashua/Limits_Infinity/solver/evaluator.dart';
import 'package:calculus_system/Finals/Joashua/Limits_Infinity/solver/limit_problem.dart';
import 'package:calculus_system/Finals/Joashua/Limits_Infinity/solver/simplifier.dart';
import 'package:calculus_system/Finals/Joashua/Limits_Infinity/solver/solutions.dart';
import 'limit_result_type.dart';
import 'package:calculus_system/Finals/Joashua/Limits_Infinity/solver/solver_strategy.dart';

class TrigonometricStrategy implements SolverStrategy {
  final Evaluator _evaluator = Evaluator();
  final Simplifier _simplifier = Simplifier();

  // Known special limits
  static const Map<String, double> _specialLimits = {
    'sin(x)/x': 1.0,
    'x/sin(x)': 1.0,
    'tan(x)/x': 1.0,
    'x/tan(x)': 1.0,
    '(1-cos(x))/x²': 0.5,
    'x²/(1-cos(x))': 2.0,
  };

  @override
  bool canAttempt(ASTNode expression, LimitProblem problem) {
    if (problem.limitType != LimitType.finitePoint) return false;
    if (problem.approachingValue != 0) return false;
    return _containsTrigFunction(expression);
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

    // Check for special limit patterns
    var specialResult =
        _checkSpecialLimits(expression, problem.variable, steps);
    if (specialResult != null) return specialResult;

    // Try to transform the expression to match a special limit
    var transformed = _tryTransformToSpecialLimit(expression, problem.variable);
    if (transformed != null) {
      steps.add(SolutionStep(
        type: StepType.trigIdentity,
        description: 'Transform the expression to match a known special limit',
        expression: transformed,
      ));

      specialResult = _checkSpecialLimits(transformed, problem.variable, steps);
      if (specialResult != null) return specialResult;
    }

    // Try using Taylor series approximations
    var taylorResult =
        _tryTaylorApproximation(expression, problem.variable, steps);
    if (taylorResult != null) return taylorResult;

    return SolveResult.unsolved(steps);
  }

  bool _containsTrigFunction(ASTNode node) {
    if (node is FunctionNode) {
      return ['sin', 'cos', 'tan', 'cot', 'sec', 'csc'].contains(node.name);
    }
    if (node is BinaryOpNode) {
      return _containsTrigFunction(node.left) ||
          _containsTrigFunction(node.right);
    }
    return false;
  }

  SolveResult? _checkSpecialLimits(
      ASTNode expression, String variable, List<SolutionStep> steps) {
    var exprStr = expression.toString();

    // Check for direct matches
    for (var entry in _specialLimits.entries) {
      var pattern = entry.key.replaceAll('x', variable);
      if (exprStr == pattern || exprStr.contains(pattern)) {
        steps.add(SolutionStep(
          type: StepType.specialLimit,
          description: 'Recognize the special limit',
          expression: expression,
          formula:
              'lim($variable→0) ${entry.key.replaceAll('x', variable)} = ${entry.value}',
          explanation:
              'This is a standard trigonometric limit that can be derived '
              'using the squeeze theorem or L\'Hôpital\'s Rule.',
        ));

        steps.add(SolutionStep(
          type: StepType.conclusion,
          description: 'The limit equals the known value',
          expression: NumberNode(entry.value),
        ));

        return SolveResult(
          solved: true,
          result: NumberNode(entry.value),
          resultType: LimitResultType.finiteValue,
          steps: steps,
          method: 'Special Trigonometric Limit',
        );
      }
    }

    return null;
  }

  ASTNode? _tryTransformToSpecialLimit(ASTNode expression, String variable) {
    // Handle sin(ax)/(bx) = (a/b) * sin(ax)/(ax)
    if (expression is BinaryOpNode && expression.operator == '/') {
      if (expression.left is FunctionNode &&
          (expression.left as FunctionNode).name == 'sin') {
        var sinArg = (expression.left as FunctionNode).argument;
        // If sin(ax)/x, rewrite as a * sin(ax)/(ax)
        if (sinArg is BinaryOpNode &&
            sinArg.operator == '*' &&
            sinArg.left is NumberNode &&
            sinArg.right is VariableNode) {
          var a = (sinArg.left as NumberNode).value;
          return BinaryOpNode(NumberNode(a), '*',
              BinaryOpNode(FunctionNode('sin', sinArg), '/', sinArg));
        }
      }
    }

    return null;
  }

  SolveResult? _tryTaylorApproximation(
      ASTNode expression, String variable, List<SolutionStep> steps) {
    // Taylor series around 0:
    // sin(x) ≈ x - x³/6 + x⁵/120 - ...
    // cos(x) ≈ 1 - x²/2 + x⁴/24 - ...
    // tan(x) ≈ x + x³/3 + 2x⁵/15 + ...

    steps.add(SolutionStep(
      type: StepType.trigIdentity,
      description: 'Use Taylor series approximation near 0',
      explanation: 'For small x:\n'
          '• sin(x) ≈ x\n'
          '• cos(x) ≈ 1 - x²/2\n'
          '• tan(x) ≈ x',
    ));

    // Replace trig functions with their linear approximations
    var approximated = _taylorApproximate(expression, variable);

    steps.add(SolutionStep(
      type: StepType.simplification,
      description: 'After Taylor approximation',
      expression: approximated,
    ));

    var simplified = _simplifier.fullySimplify(approximated);

    steps.add(SolutionStep(
      type: StepType.simplification,
      description: 'Simplify the approximation',
      expression: simplified,
    ));

    var result = _evaluator.evaluate(simplified, variable, 0);
    if (result != null && result.isFinite) {
      steps.add(SolutionStep(
        type: StepType.conclusion,
        description: 'The limit equals the constant term of the approximation',
        expression: NumberNode(result),
        explanation: 'By taking the Taylor approximation and letting x→0, '
            'we get the limit as the constant term.',
      ));

      return SolveResult(
        solved: true,
        result: NumberNode(result),
        resultType: LimitResultType.finiteValue,
        steps: steps,
        method: 'Taylor Series Approximation',
      );
    }

    return null;
  }

  ASTNode _taylorApproximate(ASTNode node, String variable) {
    if (node is FunctionNode) {
      var arg = node.argument;

      switch (node.name) {
        case 'sin':
          // sin(x) ≈ x for small x
          if (arg is VariableNode && arg.name == variable) {
            return arg;
          }
          // sin(ax) ≈ ax
          if (arg is BinaryOpNode &&
              arg.operator == '*' &&
              arg.left.tryEvaluate() != null) {
            return arg;
          }
          break;
        case 'cos':
          // cos(x) ≈ 1 - x²/2
          if (arg is VariableNode && arg.name == variable) {
            return BinaryOpNode(
                NumberNode(1),
                '-',
                BinaryOpNode(
                    BinaryOpNode(arg, '^', NumberNode(2)), '/', NumberNode(2)));
          }
          break;
        case 'tan':
          // tan(x) ≈ x
          if (arg is VariableNode && arg.name == variable) {
            return arg;
          }
          break;
      }
      return node;
    }

    if (node is BinaryOpNode) {
      return BinaryOpNode(_taylorApproximate(node.left, variable),
          node.operator, _taylorApproximate(node.right, variable));
    }

    if (node is UnaryMinusNode) {
      return UnaryMinusNode(_taylorApproximate(node.operand, variable));
    }

    return node;
  }
}
