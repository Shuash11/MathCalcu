import 'package:calculus_system/midterm/solvers/inequalities_solver/generated_linear_solver.dart';
import 'base_inequality_screen.dart';
import 'package:flutter/material.dart';

class NonStrictScreen extends StatelessWidget {
  const NonStrictScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseInequalityScreen(
      title: 'Non-strict Inequality',
      subtitle: 'Inequalities Module',
      hint: 'e.g. 3x − 1 ≤ 8  or  2 ≤ 5 + 3x < 11',
      solveFunction: GeneratedLinearSolver.solve,
      stepsFunction: GeneratedLinearSolver.getSteps,
    );
  }
}
