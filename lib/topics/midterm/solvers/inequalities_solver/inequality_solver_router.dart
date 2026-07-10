import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/topics/midterm/solvers/inequalities_solver/generated_linear_solver.dart';
import 'package:calculus_system/topics/midterm/solvers/inequalities_solver/generated_absolute_solver.dart';
import 'package:calculus_system/topics/midterm/solvers/inequalities_solver/generated_quadratic_solver.dart';
import 'package:calculus_system/topics/midterm/solvers/inequalities_solver/generated_rational_solver.dart';
import 'package:calculus_system/topics/midterm/solvers/inequalities_solver/generated_radical_solver.dart';
import 'package:calculus_system/topics/midterm/solvers/inequalities_solver/inequality_core_solver.dart';

class InequalitySolverRouter {
  static SolveResult solve(String input) {
    final normalized = InequalityCoreSolver.normalize(input);
    final type = InequalityCoreSolver.detectType(normalized);
    final baseType = _getBaseType(type);

    switch (baseType) {
      case 'linear':
        return GeneratedLinearSolver.solve(input);
      case 'absolute':
        return GeneratedAbsoluteSolver.solve(input);
      case 'quadratic':
        return GeneratedQuadraticSolver.solve(input);
      case 'rational':
        return GeneratedRationalSolver.solve(input);
      case 'radical':
      case 'sqrtRational':
        return GeneratedRadicalSolver.solve(input);
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
        return GeneratedLinearSolver.getSteps(input);
      case 'absolute':
        return GeneratedAbsoluteSolver.getSteps(input);
      case 'quadratic':
        return GeneratedQuadraticSolver.getSteps(input);
      case 'rational':
        return GeneratedRationalSolver.getSteps(input);
      case 'radical':
      case 'sqrtRational':
        return GeneratedRadicalSolver.getSteps(input);
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
