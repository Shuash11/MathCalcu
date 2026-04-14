// lib/solvers/strategies/factoring_strategy.dart

import 'package:calculus_system/Finals/Joashua/Limits_Infinity/solver/ast_nodes.dart';
import 'package:calculus_system/Finals/Joashua/Limits_Infinity/solver/evaluator.dart';
import 'package:calculus_system/Finals/Joashua/Limits_Infinity/solver/limit_problem.dart';
import 'package:calculus_system/Finals/Joashua/Limits_Infinity/solver/simplifier.dart';
import 'package:calculus_system/Finals/Joashua/Limits_Infinity/solver/solutions.dart';
import 'limit_result_type.dart';

import 'solver_strategy.dart';

class FactoringStrategy implements SolverStrategy {
  final Simplifier _simplifier = Simplifier();
  final Evaluator _evaluator = Evaluator();
  
  @override
  bool canAttempt(ASTNode expression, LimitProblem problem) {
    // Only applies to finite limits with division
    if (problem.limitType != LimitType.finitePoint) return false;
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
    
    var steps = List<SolutionStep>.from(previousSteps);
    var value = problem.approachingValue!;
    
    if (expression is! BinaryOpNode || expression.operator != '/') {
      return SolveResult.unsolved(steps);
    }
    
    var numerator = expression.left;
    var denominator = expression.right;
    
    // Check if both numerator and denominator evaluate to 0
    var numVal = _evaluator.evaluate(numerator, problem.variable, value);
    var denVal = _evaluator.evaluate(denominator, problem.variable, value);
    
    if (numVal == null || denVal == null || 
        numVal.abs() > 0.001 || denVal.abs() > 0.001) {
      return SolveResult.unsolved(steps);
    }
    
    steps.add(SolutionStep(
      type: StepType.factoring,
      description: 'Both numerator and denominator equal 0 at ${problem.variable} = $value',
      expression: expression,
      explanation: 'This confirms the 0/0 indeterminate form. '
          'We attempt to factor both expressions to find a common factor.',
    ));
    
    // Try to factor numerator
    var factoredNum = _simplifier.tryFactor(numerator, problem.variable);
    if (factoredNum != null) {
      steps.add(SolutionStep(
        type: StepType.factoring,
        description: 'Factor the numerator',
        expression: factoredNum,
      ));
    }
    
    // Try to factor denominator
    var factoredDen = _simplifier.tryFactor(denominator, problem.variable);
    if (factoredDen != null) {
      steps.add(SolutionStep(
        type: StepType.factoring,
        description: 'Factor the denominator',
        expression: factoredDen,
      ));
    }
    
    // Try common factor cancellation
    var result = _tryCancelCommonFactors(
      factoredNum ?? numerator,
      factoredDen ?? denominator,
      problem.variable,
      value,
      steps,
    );
    
    if (result != null) return result;
    
    // Try polynomial long division approach
    result = _tryPolynomialSimplification(numerator, denominator, problem, steps);
    if (result != null) return result;
    
    return SolveResult.unsolved(steps);
  }
  
  SolveResult? _tryCancelCommonFactors(
    ASTNode numerator,
    ASTNode denominator,
    String variable,
    double value,
    List<SolutionStep> steps,
  ) {
    // Try to find (x - a) factor in both
    var linearFactor = BinaryOpNode(VariableNode(variable), '-', NumberNode(value));
    
    // Check if dividing by (x-a) is possible
    var numAfterDiv = _tryDivideByLinear(numerator, linearFactor, variable, value);
    var denAfterDiv = _tryDivideByLinear(denominator, linearFactor, variable, value);
    
    if (numAfterDiv != null && denAfterDiv != null) {
      steps.add(SolutionStep(
        type: StepType.cancellation,
        description: 'Cancel the common factor (${variable} - $value)',
        formula: '(${variable} - $value)/(${variable} - $value) = 1',
      ));
      
      var simplified = _simplifier.fullySimplify(
        BinaryOpNode(numAfterDiv, '/', denAfterDiv)
      );
      
      steps.add(SolutionStep(
        type: StepType.simplification,
        description: 'After cancellation, the expression simplifies to',
        expression: simplified,
      ));
      
      // Now try direct substitution
      var result = _evaluator.evaluate(simplified, variable, value);
      if (result != null && result.isFinite) {
        steps.add(SolutionStep(
          type: StepType.conclusion,
          description: 'Substitute ${variable} = $value into the simplified expression',
          expression: NumberNode(result),
          explanation: 'After factoring and canceling the common factor that was '
              'causing the 0/0 form, we can now directly substitute.',
        ));
        
        return SolveResult(
          solved: true,
          result: NumberNode(result),
          resultType: LimitResultType.finiteValue,
          steps: steps,
          method: 'Factoring and Cancellation',
        );
      }
    }
    
    return null;
  }
  
  ASTNode? _tryDivideByLinear(ASTNode node, ASTNode divisor, String variable, double root) {
    // For a polynomial, use synthetic division
    var terms = node.getTerms();
    if (terms.isEmpty) return null;
    
    // Get coefficients
    var maxDegree = terms.map((t) => t.polynomialDegree(variable) ?? 0).reduce((a, b) => a > b ? a : b);
    var coefficients = List<double>.filled(maxDegree + 1, 0);
    
    for (var term in terms) {
      var deg = term.polynomialDegree(variable);
      if (deg == null) continue;
      var coeff = _getCoefficient(term, variable);
      if (coeff != null) {
        coefficients[deg] += coeff;
      }
    }
    
    // Check if root is actually a root (constant term should be 0 or cancel)
    if (coefficients[0].abs() > 0.001) return null;
    
    // Synthetic division by (x - root)
    var resultCoeffs = <double>[];
    var carry = 0.0;
    
    for (var i = maxDegree; i >= 1; i--) {
      var newCoeff = coefficients[i] + carry;
      resultCoeffs.add(newCoeff);
      carry = newCoeff * root;
    }
    
    // Build result polynomial
    if (resultCoeffs.isEmpty) return null;
    
    var resultTerms = <ASTNode>[];
    for (var i = 0; i < resultCoeffs.length; i++) {
      // ✅ FIX: Convert int to double using .toDouble()
      var degree = resultCoeffs.length - 1 - i;
      var coeff = resultCoeffs[i];
      
      if (coeff.abs() < 0.0001) continue;
      
      ASTNode term;
      if (degree == 0) {
        term = NumberNode(coeff);
      } else if (degree == 1) {
        if (coeff == 1) {
          term = VariableNode(variable);
        } else {
          term = BinaryOpNode(NumberNode(coeff), '*', VariableNode(variable));
        }
      } else {
        // ✅ FIXED: Added .toDouble() to convert int to double
        term = BinaryOpNode(
          NumberNode(coeff),
          '*',
          BinaryOpNode(VariableNode(variable), '^', NumberNode(degree.toDouble()))
        );
      }
      resultTerms.add(term);
    }
    
    if (resultTerms.isEmpty) return NumberNode(0);
    if (resultTerms.length == 1) return resultTerms.first;
    
    var result = resultTerms.first;
    for (var i = 1; i < resultTerms.length; i++) {
      result = BinaryOpNode(result, '+', resultTerms[i]);
    }
    
    return result;
  }
  
  double? _getCoefficient(ASTNode term, String variable) {
    if (term is NumberNode) return term.value;
    if (term is VariableNode && term.name == variable) return 1;
    if (term is UnaryMinusNode) {
      var inner = _getCoefficient(term.operand, variable);
      return inner != null ? -inner : null;
    }
    if (term is BinaryOpNode && term.operator == '*') {
      if (term.left.tryEvaluate() != null) {
        var rightCoeff = _getCoefficient(term.right, variable);
        return rightCoeff != null ? term.left.tryEvaluate()! * rightCoeff : null;
      }
    }
    return null;
  }
  
  SolveResult? _tryPolynomialSimplification(
    ASTNode numerator,
    ASTNode denominator,
    LimitProblem problem,
    List<SolutionStep> steps,
  ) {
    // Try expanding and simplifying
    var expandedNum = _simplifier.expand(numerator);
    var expandedDen = _simplifier.expand(denominator);
    
    var simplified = _simplifier.fullySimplify(
      BinaryOpNode(expandedNum, '/', expandedDen)
    );
    
    if (simplified.toString() != BinaryOpNode(numerator, '/', denominator).toString()) {
      steps.add(SolutionStep(
        type: StepType.expansion,
        description: 'Expand and simplify the expression',
        expression: simplified,
      ));
      
      var value = problem.approachingValue!;
      var result = _evaluator.evaluate(simplified, problem.variable, value);
      
      if (result != null && result.isFinite) {
        steps.add(SolutionStep(
          type: StepType.conclusion,
          description: 'Substitute ${problem.variable} = $value',
          expression: NumberNode(result),
        ));
        
        return SolveResult(
          solved: true,
          result: NumberNode(result),
          resultType: LimitResultType.finiteValue,
          steps: steps,
          method: 'Expansion and Simplification',
        );
      }
    }
    
    return null;
  }
}