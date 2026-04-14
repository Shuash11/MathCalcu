// lib/solvers/strategies/rationalization_strategy.dart

import 'package:calculus_system/Finals/Joashua/Limits_Infinity/solver/ast_nodes.dart';
import 'package:calculus_system/Finals/Joashua/Limits_Infinity/solver/evaluator.dart';
import 'package:calculus_system/Finals/Joashua/Limits_Infinity/solver/limit_problem.dart';
import 'package:calculus_system/Finals/Joashua/Limits_Infinity/solver/simplifier.dart';
import 'package:calculus_system/Finals/Joashua/Limits_Infinity/solver/solutions.dart';
import 'limit_result_type.dart';

import 'solver_strategy.dart';


class RationalizationStrategy implements SolverStrategy {
  final Simplifier _simplifier = Simplifier();
  final Evaluator _evaluator = Evaluator();
  
  @override
  bool canAttempt(ASTNode expression, LimitProblem problem) {
    if (problem.limitType != LimitType.finitePoint) return false;
    return _hasRadicalInDenominator(expression);
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
    var value = problem.approachingValue!;
    
    steps.add(SolutionStep(
      type: StepType.rationalization,
      description: 'Attempt rationalization to eliminate the radical',
      expression: expression,
      explanation: 'When dealing with expressions involving square roots that lead to '
          '0/0 form, we can multiply by the conjugate to rationalize.',
    ));
    
    // Try rationalizing
    var rationalized = _simplifier.rationalize(expression, problem.variable);
    if (rationalized == null) {
      return SolveResult.unsolved(steps);
    }
    
    steps.add(SolutionStep(
      type: StepType.rationalization,
      description: 'Multiply numerator and denominator by the conjugate',
      expression: rationalized,
    ));
    
    // Expand and simplify
    var expanded = _simplifier.expand(rationalized);
    var simplified = _simplifier.fullySimplify(expanded);
    
    steps.add(SolutionStep(
      type: StepType.simplification,
      description: 'Expand and simplify',
      expression: simplified,
    ));
    
    // Try evaluation
    var result = _evaluator.evaluate(simplified, problem.variable, value);
    if (result != null && result.isFinite) {
      steps.add(SolutionStep(
        type: StepType.conclusion,
        description: 'Substitute ${problem.variable} = $value',
        expression: NumberNode(result),
        explanation: 'After rationalization, the expression can be evaluated directly.',
      ));
      
      return SolveResult(
        solved: true,
        result: NumberNode(result),
        resultType: LimitResultType.finiteValue,
        steps: steps,
        method: 'Rationalization',
      );
    }
    
    return SolveResult.unsolved(steps);
  }
  
  bool _hasRadicalInDenominator(ASTNode node) {
    if (node is BinaryOpNode && node.operator == '/') {
      return _containsSqrt(node.right);
    }
    return false;
  }
  
  bool _containsSqrt(ASTNode node) {
    if (node is FunctionNode && node.name == 'sqrt') return true;
    if (node is BinaryOpNode) {
      return _containsSqrt(node.left) || _containsSqrt(node.right);
    }
    return false;
  }
}