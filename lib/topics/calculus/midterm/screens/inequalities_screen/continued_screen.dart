import 'package:calculus_system/topics/calculus/midterm/solvers/inequalities_solver/generated_linear_solver.dart';
import 'base_inequality_screen.dart';
import 'package:flutter/material.dart';

class ContinuedScreen extends StatelessWidget {
  const ContinuedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseInequalityScreen(
      title: 'Continued Inequality',
      subtitle: 'Inequalities Module',
      hint: 'e.g. 1 < 2x + 3 < 9  or  âˆ’5 ≠¤ 2x âˆ’ 1 < 7',
      solveFunction: GeneratedLinearSolver.solve,
      stepsFunction: GeneratedLinearSolver.getSteps,
    );
  }
}
