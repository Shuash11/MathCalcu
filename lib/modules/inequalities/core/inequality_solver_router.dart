import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/modules/inequalities/core/inequality_core_solver.dart';
import 'package:calculus_system/modules/inequalities/core/linear_solver.dart';
import 'package:calculus_system/modules/inequalities/absolute/solver/absolute_solver.dart';
import 'package:calculus_system/modules/inequalities/quadratic/solver/quadratic_solver.dart';
import 'package:calculus_system/modules/inequalities/rational/solver/rational_solver.dart';
import 'package:calculus_system/modules/inequalities/radical/solver/radical_solver.dart';

class InequalitySolverRouter {
  static SolveResult solve(String input) {
    final normalized = InequalityCoreSolver.normalize(input);
    final type = InequalityCoreSolver.detectType(normalized);
    final baseType = _getBaseType(type);

    switch (baseType) {
      case 'linear':
        return LinearSolver.solve(input);
      case 'absolute':
        return AbsoluteSolver.solve(input);
      case 'quadratic':
        return QuadraticSolver.solve(input);
      case 'rational':
        return RationalSolver.solve(input);
      case 'radical':
      case 'sqrtRational':
        return RadicalSolver.solve(input);
      default:
        return SolveResult.error('Could not detect inequality type');
    }
  }

  static List<StepModel> getSteps(String input) {
    final normalized = InequalityCoreSolver.normalize(input);
    final type = InequalityCoreSolver.detectType(normalized);
    final baseType = _getBaseType(type);

    switch (baseType) {
      case 'linear':
        return LinearSolver.getSteps(input);
      case 'absolute':
        return AbsoluteSolver.getSteps(input);
      case 'quadratic':
        return QuadraticSolver.getSteps(input);
      case 'rational':
        return RationalSolver.getSteps(input);
      case 'radical':
      case 'sqrtRational':
        return RadicalSolver.getSteps(input);
      default:
        return [
          const StepModel(
            stepNumber: 1,
            title: 'Error',
            explanation: 'Could not detect inequality type',
            latex: r'\text{Unknown inequality type}',
          )
        ];
    }
  }

  static String _getBaseType(String detectedType) {
    // Strip -strict, -non-strict, or -continued suffix to get base type
    // Check for more specific suffixes first (-non-strict before -strict)
    if (detectedType.endsWith('-non-strict')) {
      return detectedType.substring(0, detectedType.length - '-non-strict'.length);
    }
    if (detectedType.endsWith('-strict')) {
      return detectedType.substring(0, detectedType.length - '-strict'.length);
    }
    if (detectedType.endsWith('-continued')) {
      return detectedType.substring(0, detectedType.length - '-continued'.length);
    }
    return detectedType;
  }

  static String detectType(String input) {
    final normalized = InequalityCoreSolver.normalize(input);
    return InequalityCoreSolver.detectType(normalized);
  }
}