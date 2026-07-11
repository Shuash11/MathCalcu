import 'package:calculus_system/topics/calculus/midterm/solvers/inequalities_solver/generated_absolute_solver.dart';
import 'package:flutter/material.dart';
import 'base_inequality_screen.dart';

class AbsoluteScreen extends StatelessWidget {
  const AbsoluteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseInequalityScreen(
      title: 'Absolute Value Inequality',
      subtitle: 'Inequalities Module',
      hint: 'e.g. |x ?? 4| < 2  or  |2x + 1| ≠? 5',
      solveFunction: GeneratedAbsoluteSolver.solve,
      stepsFunction: GeneratedAbsoluteSolver.getSteps,
    );
  }
}
