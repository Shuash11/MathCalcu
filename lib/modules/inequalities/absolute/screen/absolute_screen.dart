import 'package:flutter/material.dart';
import '../../core/base_inequality_screen.dart';
import '../solver/absolute_solver.dart';

class AbsoluteScreen extends StatelessWidget {
  const AbsoluteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseInequalityScreen(
      title: 'Absolute Value Inequality',
      subtitle: 'Inequalities Module',
      hint: 'e.g. |x − 4| < 2',
      solveFunction: AbsoluteSolver.solve,
      stepsFunction: AbsoluteSolver.getSteps,
    );
  }
}
