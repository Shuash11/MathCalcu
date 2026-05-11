import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/modules/inequalities/radical/solver/radical_solver.dart';

import 'radical_models.dart';

class RadicalForms {
  static SolveResult solve(Object input) {
    final text = input is RadicalPrep ? input.original : input.toString();
    return RadicalSolver.solve(text);
  }
}
