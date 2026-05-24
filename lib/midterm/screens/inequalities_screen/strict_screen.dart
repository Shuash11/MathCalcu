import 'package:calculus_system/midterm/solvers/inequalities_solver/generated_linear_solver.dart';
import 'base_inequality_screen.dart';
import 'package:flutter/material.dart';

class StrictScreen extends StatelessWidget {
  const StrictScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseInequalityScreen(
      title: 'Strict Inequality',
      subtitle: 'Inequalities Module',
      hint: 'e.g. 2x + 3 > 7',
      solveFunction: GeneratedLinearSolver.solve,
      stepsFunction: GeneratedLinearSolver.getSteps,
    );
  }
}
