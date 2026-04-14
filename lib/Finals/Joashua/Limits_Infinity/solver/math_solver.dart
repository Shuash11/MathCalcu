// lib/math_solver.dart

import 'package:calculus_system/Finals/Joashua/Limits_Infinity/solver/ast_nodes.dart';
import 'package:calculus_system/Finals/Joashua/Limits_Infinity/solver/expression_parser.dart';
import 'package:calculus_system/Finals/Joashua/Limits_Infinity/solver/limit_problem.dart';
import 'package:calculus_system/Finals/Joashua/Limits_Infinity/solver/limit_solver.dart';
import 'package:calculus_system/Finals/Joashua/Limits_Infinity/solver/solutions.dart';



/// Main entry point for the math solver
class MathSolver {
  static final LimitSolver _limitSolver = LimitSolver();
  
  /// Solve a limit problem
  static LimitSolution solveLimit(LimitProblem problem) {
    return _limitSolver.solve(problem);
  }
  
  /// Solve a limit with simple notation
  /// Example: solveLimitSimple("(x^2 - 1)/(x - 1)", "x->1")
  static LimitSolution solveLimitSimple(
    String expression,
    String approach, {
    String variable = 'x',
    LimitDirection direction = LimitDirection.both,
  }) {
    var problem = LimitProblem.fromNotation(
      expression: expression,
      approach: approach,
      variable: variable,
      direction: direction,
    );
    return _limitSolver.solve(problem);
  }
  
  /// Solve a limit approaching a finite value
  static LimitSolution solveLimitAtPoint(
    String expression, {
    String variable = 'x',
    required double atValue,
    LimitDirection direction = LimitDirection.both,
  }) {
    var problem = LimitProblem(
      expression: expression,
      variable: variable,
      limitType: LimitType.finitePoint,
      approachingValue: atValue,
      direction: direction,
    );
    return _limitSolver.solve(problem);
  }
  
  /// Solve a limit at positive infinity
  static LimitSolution solveLimitAtInfinity(
    String expression, {
    String variable = 'x',
  }) {
    var problem = LimitProblem(
      expression: expression,
      variable: variable,
      limitType: LimitType.positiveInfinity,
    );
    return _limitSolver.solve(problem);
  }
  
  /// Solve a limit at negative infinity
  static LimitSolution solveLimitAtNegativeInfinity(
    String expression, {
    String variable = 'x',
  }) {
    var problem = LimitProblem(
      expression: expression,
      variable: variable,
      limitType: LimitType.negativeInfinity,
    );
    return _limitSolver.solve(problem);
  }
  
  /// Parse and evaluate an expression at a point
  static double? evaluateAt(String expression, String variable, double value) {
    try {
      var ast = parseExpression(expression);
      var substituted = ast.substitute(variable, NumberNode(value));
      return substituted.tryEvaluate();
    } catch (e) {
      return null;
    }
  }
  
  /// Differentiate an expression symbolically
  static String differentiate(String expression, [String variable = 'x']) {
    try {
      var ast = parseExpression(expression);
      var derivative = ast.differentiate(variable);
      var simplified = derivative.simplify();
      return simplified.toString();
    } catch (e) {
      return 'Error: $e';
    }
  }
}