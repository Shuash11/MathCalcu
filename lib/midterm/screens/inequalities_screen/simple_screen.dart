import 'package:calculus_system/midterm/solvers/inequalities_solver/generated_linear_solver.dart';
import 'base_inequality_screen.dart';
import 'package:flutter/material.dart';

class SimpleScreen extends StatelessWidget {
  const SimpleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseInequalityScreen(
      title: 'Basic Inequality',
      subtitle: 'Inequalities Module',
      hint: 'e.g. 2x + 1 > 5  or  3x − 4 ≤ 8',
      solveFunction: GeneratedLinearSolver.solve,
      stepsFunction: GeneratedLinearSolver.getSteps,
    );
  }
}
