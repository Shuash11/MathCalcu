// lib/solvers/strategies/lhopital_strategy.dart

import 'package:calculus_system/Finals/Joashua/Limits_Infinity/solver/ast_nodes.dart';
import 'package:calculus_system/Finals/Joashua/Limits_Infinity/solver/diffirentiatior.dart';
import 'package:calculus_system/Finals/Joashua/Limits_Infinity/solver/evaluator.dart';
import 'package:calculus_system/Finals/Joashua/Limits_Infinity/solver/limit_problem.dart';
import 'package:calculus_system/Finals/Joashua/Limits_Infinity/solver/simplifier.dart';
import 'package:calculus_system/Finals/Joashua/Limits_Infinity/solver/solutions.dart';
import 'limit_result_type.dart';
import 'solver_strategy.dart';


class LhopitalStrategy implements SolverStrategy {
  final Differentiator _differentiator = Differentiator();
  final Evaluator _evaluator = Evaluator();
  final Simplifier _simplifier = Simplifier();
  
  static const int maxApplications = 5;
  
  @override
  bool canAttempt(ASTNode expression, LimitProblem problem) {
    if (expression is! BinaryOpNode || expression.operator != '/') return false;
    return true;
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
    
    final binaryExpr = expression as BinaryOpNode;
    return _applyLhopital(
      binaryExpr.left,
      binaryExpr.right,
      problem,
      List<SolutionStep>.from(previousSteps),
      0,
    );
  }
  
  SolveResult _applyLhopital(
    ASTNode numerator,
    ASTNode denominator,
    LimitProblem problem,
    List<SolutionStep> steps,
    int applicationCount,
  ) {
    if (applicationCount >= maxApplications) {
      steps.add(SolutionStep(
        type: StepType.error,
        description: 'Maximum L\'Hôpital\'s Rule applications reached',
        explanation: 'L\'Hôpital\'s Rule has been applied $maxApplications times '
            'without resolving the indeterminate form.',
      ));
      return SolveResult.unsolved(steps);
    }
    
    // Differentiate numerator and denominator
    var derivNum = _simplifier.fullySimplify(
      _differentiator.differentiate(numerator, problem.variable)
    );
    var derivDen = _simplifier.fullySimplify(
      _differentiator.differentiate(denominator, problem.variable)
    );
    
    applicationCount++;
    
    steps.add(SolutionStep(
      type: StepType.lhopital,
      description: 'Apply L\'Hôpital\'s Rule (application #${applicationCount})',
      expression: BinaryOpNode(derivNum, '/', derivDen),
      formula: 'If lim f(x)/g(x) is 0/0 or ∞/∞, then lim f(x)/g(x) = lim f\'(x)/g\'(x)',
      explanation: 'Since we have an indeterminate form, we differentiate both '
          'the numerator and denominator separately.',
    ));
    
    // Try to evaluate the new limit
    if (problem.limitType == LimitType.finitePoint) {
      var value = problem.approachingValue!;
      var numVal = _evaluator.evaluate(derivNum, problem.variable, value);
      var denVal = _evaluator.evaluate(derivDen, problem.variable, value);
      
      steps.add(SolutionStep(
        type: StepType.substitution,
        description: 'Substitute ${problem.variable} = $value',
        expression: BinaryOpNode(
          derivNum.substitute(problem.variable, NumberNode(value)).simplify(),
          '/',
          derivDen.substitute(problem.variable, NumberNode(value)).simplify()
        ),
      ));
      
      // Check for determinate result
      if (numVal != null && denVal != null && denVal.abs() > 0.001) {
        var result = numVal / denVal;
        
        if (result.isFinite) {
          steps.add(SolutionStep(
            type: StepType.conclusion,
            description: 'The limit evaluates to a finite value',
            expression: NumberNode(result),
            explanation: 'After applying L\'Hôpital\'s Rule ${applicationCount} time(s), '
                'direct substitution now gives a valid result.',
          ));
          
          return SolveResult(
            solved: true,
            result: NumberNode(result),
            resultType: LimitResultType.finiteValue,
            steps: steps,
            method: "L'Hôpital's Rule",
            lhopitalCount: applicationCount,
          );
        }
        
        if (result == double.infinity) {
          steps.add(SolutionStep(
            type: StepType.conclusion,
            description: 'The limit approaches positive infinity',
            expression: InfinityNode(false),
          ));
          return SolveResult(
            solved: true,
            result: InfinityNode(false),
            resultType: LimitResultType.positiveInfinity,
            steps: steps,
            method: "L'Hôpital's Rule",
            lhopitalCount: applicationCount,
          );
        }
        
        if (result == double.negativeInfinity) {
          steps.add(SolutionStep(
            type: StepType.conclusion,
            description: 'The limit approaches negative infinity',
            expression: InfinityNode(true),
          ));
          return SolveResult(
            solved: true,
            result: InfinityNode(true),
            resultType: LimitResultType.negativeInfinity,
            steps: steps,
            method: "L'Hôpital's Rule",
            lhopitalCount: applicationCount,
          );
        }
      }
      
      // Still indeterminate - recurse
      if (numVal != null && denVal != null &&
          (numVal.abs() < 0.001 && denVal.abs() < 0.001 ||
           numVal.abs() > 1e10 && denVal.abs() > 1e10)) {
        steps.add(SolutionStep(
          type: StepType.formDetection,
          description: 'Still an indeterminate form, apply L\'Hôpital\'s Rule again',
        ));
        return _applyLhopital(derivNum, derivDen, problem, steps, applicationCount);
      }
    } else {
      // Infinity case - check behavior at large values
      var evalResult = _evaluator.evaluateAtInfinity(
        BinaryOpNode(derivNum, '/', derivDen),
        problem.variable,
        negative: problem.limitType == LimitType.negativeInfinity,
      );
      
      var limit = problem.limitType == LimitType.negativeInfinity 
          ? evalResult.leftLimit 
          : evalResult.rightLimit;
      
      if (limit != null && limit.type == LimitResultType.finiteValue) {
        steps.add(SolutionStep(
          type: StepType.conclusion,
          description: 'As ${problem.variable} → ${problem.limitPointString}, the expression approaches',
          expression: NumberNode(limit.value!),
        ));
        return SolveResult(
          solved: true,
          result: NumberNode(limit.value!),
          resultType: LimitResultType.finiteValue,
          steps: steps,
          method: "L'Hôpital's Rule",
          lhopitalCount: applicationCount,
        );
      }
      
      if (limit != null && limit.type == LimitResultType.positiveInfinity) {
        steps.add(SolutionStep(
          type: StepType.conclusion,
          description: 'The limit approaches positive infinity',
          expression: InfinityNode(false),
        ));
        return SolveResult(
          solved: true,
          result: InfinityNode(false),
          resultType: LimitResultType.positiveInfinity,
          steps: steps,
          method: "L'Hôpital's Rule",
          lhopitalCount: applicationCount,
        );
      }
      
      if (limit != null && limit.type == LimitResultType.negativeInfinity) {
        steps.add(SolutionStep(
          type: StepType.conclusion,
          description: 'The limit approaches negative infinity',
          expression: InfinityNode(true),
        ));
        return SolveResult(
          solved: true,
          result: InfinityNode(true),
          resultType: LimitResultType.negativeInfinity,
          steps: steps,
          method: "L'Hôpital's Rule",
          lhopitalCount: applicationCount,
        );
      }
      
      // Try again
      steps.add(SolutionStep(
        type: StepType.formDetection,
        description: 'Still indeterminate, applying L\'Hôpital\'s Rule again',
      ));
      return _applyLhopital(derivNum, derivDen, problem, steps, applicationCount);
    }
    
    return SolveResult.unsolved(steps);
  }
}