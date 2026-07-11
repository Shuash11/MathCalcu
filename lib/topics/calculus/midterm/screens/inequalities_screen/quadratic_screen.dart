import 'package:calculus_system/topics/calculus/midterm/solvers/inequalities_solver/generated_quadratic_solver.dart';
import 'package:flutter/material.dart';
import 'base_inequality_screen.dart';

class QuadraticScreen extends StatelessWidget {
  const QuadraticScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseInequalityScreen(
      title: 'Quadratic Inequality',
      subtitle: 'Inequalities Module',
      hint: 'e.g. x? ?? 5x + 6 < 0  or  x? + 2x ≠? 3',
      solveFunction: GeneratedQuadraticSolver.solve,
      stepsFunction: GeneratedQuadraticSolver.getSteps,
    );
  }
}
