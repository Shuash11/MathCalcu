// lib/solvers/strategies/direct_substitution.dart

import 'package:calculus_system/Finals/Joashua/Limits_Infinity/solver/ast_nodes.dart';
import 'package:calculus_system/Finals/Joashua/Limits_Infinity/solver/evaluator.dart';
import 'package:calculus_system/Finals/Joashua/Limits_Infinity/solver/limit_problem.dart';
import 'package:calculus_system/Finals/Joashua/Limits_Infinity/solver/solutions.dart';
import 'limit_result_type.dart';

import 'solver_strategy.dart';


class DirectSubstitutionStrategy implements SolverStrategy {
  final Evaluator _evaluator = Evaluator();
  
  @override
  bool canAttempt(ASTNode expression, LimitProblem problem) => true;
  
  @override
  SolveResult solve(
    ASTNode expression,
    LimitProblem problem,
    List<SolutionStep> previousSteps,
  ) {
    var steps = List<SolutionStep>.from(previousSteps);
    
    if (problem.limitType == LimitType.finitePoint) {
      var value = problem.approachingValue!;
      var result = _evaluator.evaluate(expression, problem.variable, value);
      
      steps.add(SolutionStep(
        type: StepType.substitution,
        description: 'Substitute ${problem.variable} = $value into the expression',
        expression: expression.substitute(problem.variable, NumberNode(value)).simplify(),
      ));
      
      if (result != null && result.isFinite) {
        steps.add(SolutionStep(
          type: StepType.conclusion,
          description: 'The expression evaluates to a finite value',
          expression: NumberNode(result),
          explanation: 'Since direct substitution gives a valid finite number, '
              'the limit exists and equals this value.',
        ));
        
        return SolveResult(
          solved: true,
          result: NumberNode(result),
          resultType: LimitResultType.finiteValue,
          steps: steps,
          method: 'Direct Substitution',
        );
      }
      
      if (result == double.infinity) {
        steps.add(SolutionStep(
          type: StepType.conclusion,
          description: 'The expression approaches positive infinity',
          expression: InfinityNode(false),
        ));
        return SolveResult(
          solved: true,
          result: InfinityNode(false),
          resultType: LimitResultType.positiveInfinity,
          steps: steps,
          method: 'Direct Substitution',
        );
      }
      
      if (result == double.negativeInfinity) {
        steps.add(SolutionStep(
          type: StepType.conclusion,
          description: 'The expression approaches negative infinity',
          expression: InfinityNode(true),
        ));
        return SolveResult(
          solved: true,
          result: InfinityNode(true),
          resultType: LimitResultType.negativeInfinity,
          steps: steps,
          method: 'Direct Substitution',
        );
      }
      
      // Result is NaN or undefined - indeterminate form
      steps.add(SolutionStep(
        type: StepType.formDetection,
        description: 'Direct substitution gives an indeterminate form',
        explanation: 'The result is undefined, indicating an indeterminate form '
            'such as 0/0 or ∞/∞. We need to use other techniques.',
      ));
      
      return SolveResult.unsolved(steps);
    }
    
    return SolveResult.unsolved(steps);
  }
}