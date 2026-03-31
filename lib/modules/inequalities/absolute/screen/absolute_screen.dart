import 'package:calculus_system/modules/inequalities/absolute/solver/absolute_solver.dart';
import 'package:calculus_system/modules/inequalities/core/base_inequality_screen.dart';
import 'package:flutter/material.dart';

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
