import 'package:flutter/material.dart';
import '../../core/base_inequality_screen.dart';
import '../../core/linear_solver.dart';

class ContinuedScreen extends StatelessWidget {
  const ContinuedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseInequalityScreen(
      title: 'Continued Inequality',
      subtitle: 'Inequalities Module',
      hint: 'e.g. 1 < 2x + 3 < 9',
      solveFunction: LinearSolver.solve,
      stepsFunction: LinearSolver.getSteps,
    );
  }
}
