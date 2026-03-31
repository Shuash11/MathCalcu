import 'package:flutter/material.dart';
import 'package:calculus_system/modules/inequalities/core/base_inequality_screen.dart';
import 'package:calculus_system/modules/inequalities/radical/solver/radical_solver.dart';

class RadicalScreen extends StatelessWidget {
  const RadicalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseInequalityScreen(
      title: 'Radical Inequality',
      subtitle: 'Inequalities Module',
      hint: 'e.g. √(2x) < 4',
      solveFunction: RadicalSolver.solve,
      stepsFunction: RadicalSolver.getSteps,
    );
  }
}
