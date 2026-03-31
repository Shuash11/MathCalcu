import 'package:calculus_system/modules/inequalities/core/base_inequality_screen.dart';
import 'package:calculus_system/modules/inequalities/core/linear_solver.dart';
import 'package:flutter/material.dart';

class StrictScreen extends StatelessWidget {
  const StrictScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseInequalityScreen(
      title: 'Strict Inequality',
      subtitle: 'Inequalities Module',
      hint: 'e.g. 2x + 3 > 7',
      solveFunction: LinearSolver.solve,
      stepsFunction: LinearSolver.getSteps,
    );
  }
}
