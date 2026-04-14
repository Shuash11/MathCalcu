// lib/solvers/strategies/solver_strategy.dart

import 'package:calculus_system/Finals/Joashua/Limits_Infinity/solver/ast_nodes.dart';
import 'package:calculus_system/Finals/Joashua/Limits_Infinity/solver/limit_problem.dart';
import 'package:calculus_system/Finals/Joashua/Limits_Infinity/solver/solutions.dart';
import 'limit_result_type.dart';

/// Result of a solve attempt
class SolveResult {
  final bool solved;
  final ASTNode? result;
  final LimitResultType resultType;
  final List<SolutionStep> steps;
  final String method;
  final int lhopitalCount;
  
  const SolveResult({
    required this.solved,
    this.result,
    required this.resultType,
    required this.steps,
    required this.method,
    this.lhopitalCount = 0,
  });
  
  factory SolveResult.unsolved(List<SolutionStep> steps) {
    return SolveResult(
      solved: false,
      resultType: LimitResultType.indeterminate,
      steps: steps,
      method: '',
      lhopitalCount: 0,
    );
  }
}

/// Interface for limit solving strategies
abstract class SolverStrategy {
  /// Attempt to solve the limit
  SolveResult solve(
    ASTNode expression,
    LimitProblem problem,
    List<SolutionStep> previousSteps,
  );
  
  /// Check if this strategy might be applicable
  bool canAttempt(ASTNode expression, LimitProblem problem);
}