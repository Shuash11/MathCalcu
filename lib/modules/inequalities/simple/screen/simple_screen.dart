import 'package:flutter/material.dart';
import '../../core/base_inequality_screen.dart';
import '../../core/linear_solver.dart';

class SimpleScreen extends StatelessWidget {
  const SimpleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseInequalityScreen(
      title: 'Basic Inequality',
      subtitle: 'Inequalities Module',
      hint: 'e.g. 2x + 1 > 5',
      solveFunction: LinearSolver.solve,
      stepsFunction: LinearSolver.getSteps,
    );
  }
}
