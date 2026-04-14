// lib/solvers/limit_solver.dart

import 'package:calculus_system/Finals/Joashua/Limits_Infinity/solver/ast_nodes.dart';
import 'package:calculus_system/Finals/Joashua/Limits_Infinity/solver/direct_substitution.dart';
import 'package:calculus_system/Finals/Joashua/Limits_Infinity/solver/evaluator.dart';
import 'package:calculus_system/Finals/Joashua/Limits_Infinity/solver/expression_parser.dart';
import 'package:calculus_system/Finals/Joashua/Limits_Infinity/solver/factoring_strategy.dart';
import 'package:calculus_system/Finals/Joashua/Limits_Infinity/solver/infinity_strategy.dart' show InfinityStrategy;
import 'package:calculus_system/Finals/Joashua/Limits_Infinity/solver/lhopital_strategy.dart';
import 'package:calculus_system/Finals/Joashua/Limits_Infinity/solver/limit_problem.dart';
import 'package:calculus_system/Finals/Joashua/Limits_Infinity/solver/rationalization_strategy.dart';
import 'package:calculus_system/Finals/Joashua/Limits_Infinity/solver/simplifier.dart';
import 'package:calculus_system/Finals/Joashua/Limits_Infinity/solver/solutions.dart';
import 'package:calculus_system/Finals/Joashua/Limits_Infinity/solver/solver_strategy.dart';
import 'package:calculus_system/Finals/Joashua/Limits_Infinity/solver/trigenometric_strategy.dart';
import 'limit_result_type.dart';



/// Main limit solver that orchestrates all strategies
class LimitSolver {
  final List<SolverStrategy> _strategies;
  final Evaluator _evaluator = Evaluator();
  final Simplifier _simplifier = Simplifier();
  
  LimitSolver() : _strategies = [
    DirectSubstitutionStrategy(),
    FactoringStrategy(),
    TrigonometricStrategy(),
    RationalizationStrategy(),
    LhopitalStrategy(),
    InfinityStrategy(),
  ];
  
  /// Solve a limit problem
  LimitSolution solve(LimitProblem problem) {
    var steps = <SolutionStep>[];
    
    // Initial step
    steps.add(SolutionStep(
      type: StepType.initial,
      description: 'Evaluate the limit',
      expression: null,
    ));
    
    try {
      // Parse the expression
      var expression = parseExpression(problem.expression);
      var simplifiedExpr = _simplifier.fullySimplify(expression);
      
      steps.add(SolutionStep(
        type: StepType.initial,
        description: 'Original expression (simplified)',
        expression: simplifiedExpr,
      ));
      
      // Try each strategy in order
      for (var strategy in _strategies) {
        if (strategy.canAttempt(simplifiedExpr, problem)) {
          var result = strategy.solve(simplifiedExpr, problem, steps);
          
          if (result.solved) {
            return LimitSolution(
              problemNotation: problem.fullNotation,
              steps: result.steps,
              result: result.result,
              resultType: result.resultType,
              lhopitalCount: result.lhopitalCount,
              methodUsed: result.method,
            );
          }
          
          steps = result.steps;
        }
      }
      
      // If no strategy worked, try numeric approximation
      return _numericFallback(simplifiedExpr, problem, steps);
      
    } catch (e) {
      steps.add(SolutionStep(
        type: StepType.error,
        description: 'Error: ${e.toString()}',
      ));
      
      return LimitSolution(
        problemNotation: problem.fullNotation,
        steps: steps,
        resultType: LimitResultType.indeterminate,
      );
    }
  }
  
  /// Numeric fallback when symbolic methods fail
  LimitSolution _numericFallback(
    ASTNode expression,
    LimitProblem problem,
    List<SolutionStep> steps,
  ) {
    steps.add(SolutionStep(
      type: StepType.infinityAnalysis,
      description: 'Using numeric approximation as fallback',
      explanation: 'Symbolic methods did not yield a definitive answer. '
          'Using numerical evaluation to estimate the limit.',
    ));
    
    if (problem.limitType == LimitType.finitePoint) {
      var evalResult = _evaluator.evaluateApproaching(
        expression,
        problem.variable,
        problem.approachingValue!,
      );
      
      if (evalResult.limitsMatch && evalResult.leftLimit != null) {
        var limit = evalResult.leftLimit!;
        
        switch (limit.type) {
          case LimitResultType.finiteValue:
            steps.add(SolutionStep(
              type: StepType.conclusion,
              description: 'Numeric approximation suggests the limit is approximately ${limit.value?.toStringAsFixed(6)}',
              expression: NumberNode(limit.value!),
              explanation: 'Values from both sides converge to approximately ${limit.value}.',
            ));
            return LimitSolution(
              problemNotation: problem.fullNotation,
              steps: steps,
              result: NumberNode(limit.value!),
              resultType: LimitResultType.finiteValue,
              methodUsed: 'Numeric Approximation',
            );
            
          case LimitResultType.positiveInfinity:
            steps.add(SolutionStep(
              type: StepType.conclusion,
              description: 'Values grow without bound',
              expression: InfinityNode(false),
            ));
            return LimitSolution(
              problemNotation: problem.fullNotation,
              steps: steps,
              result: InfinityNode(false),
              resultType: LimitResultType.positiveInfinity,
              methodUsed: 'Numeric Approximation',
            );
            
          case LimitResultType.negativeInfinity:
            steps.add(SolutionStep(
              type: StepType.conclusion,
              description: 'Values decrease without bound',
              expression: InfinityNode(true),
            ));
            return LimitSolution(
              problemNotation: problem.fullNotation,
              steps: steps,
              result: InfinityNode(true),
              resultType: LimitResultType.negativeInfinity,
              methodUsed: 'Numeric Approximation',
            );
            
          default:
            break;
        }
      } else if (evalResult.leftLimit != null && evalResult.rightLimit != null &&
                 !evalResult.limitsMatch) {
        steps.add(SolutionStep(
          type: StepType.conclusion,
          description: 'Left and right limits do not match',
          expression: null,
          explanation: 'Left limit: ${evalResult.leftLimit?.value ?? "different"}\n'
              'Right limit: ${evalResult.rightLimit?.value ?? "different"}\n'
              'Since the one-sided limits differ, the two-sided limit does not exist.',
        ));
        return LimitSolution(
          problemNotation: problem.fullNotation,
          steps: steps,
          resultType: LimitResultType.doesNotExist,
          methodUsed: 'Numeric Approximation',
        );
      }
    }
    
    steps.add(SolutionStep(
      type: StepType.conclusion,
      description: 'Could not determine the limit',
      expression: null,
      explanation: 'The limit could not be determined using available methods. '
          'It may require advanced techniques or may not exist.',
    ));
    
    return LimitSolution(
      problemNotation: problem.fullNotation,
      steps: steps,
      resultType: LimitResultType.indeterminate,
    );
  }
}