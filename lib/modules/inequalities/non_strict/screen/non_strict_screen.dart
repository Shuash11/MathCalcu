import 'package:flutter/material.dart';
import '../../core/base_inequality_screen.dart';
import '../../core/linear_solver.dart';

class NonStrictScreen extends StatelessWidget {
  const NonStrictScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseInequalityScreen(
      title: 'Non-strict Inequality',
      subtitle: 'Inequalities Module',
      hint: 'e.g. 3x − 1 ≤ 8  or  2 ≤ 5 + 3x < 11',
      solveFunction: LinearSolver.solve,
      stepsFunction: LinearSolver.getSteps,
    );
  }
}
