import 'package:calculus_system/modules/inequalities/core/base_inequality_screen.dart';
import 'package:calculus_system/modules/inequalities/core/linear_solver.dart';
import 'package:flutter/material.dart';

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
