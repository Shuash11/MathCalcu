import 'package:calculus_system/modules/inequalities/core/base_inequality_screen.dart';
import 'package:calculus_system/modules/inequalities/core/linear_solver.dart';
import 'package:flutter/material.dart';

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
