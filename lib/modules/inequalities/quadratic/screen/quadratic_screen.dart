import 'package:flutter/material.dart';
import '../../core/base_inequality_screen.dart';
import '../solver/quadratic_solver.dart';

class QuadraticScreen extends StatelessWidget {
  const QuadraticScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseInequalityScreen(
      title: 'Quadratic Inequality',
      subtitle: 'Inequalities Module',
      hint: 'e.g. x² − 5x + 6 < 0',
      solveFunction: QuadraticSolver.solve,
      stepsFunction: QuadraticSolver.getSteps,
    );
  }
}
