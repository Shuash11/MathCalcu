import 'package:calculus_system/topics/midterm/solvers/inequalities_solver/generated_radical_solver.dart';
import 'package:flutter/material.dart';
import 'base_inequality_screen.dart';

class RadicalScreen extends StatelessWidget {
  const RadicalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseInequalityScreen(
      title: 'Radical Inequality',
      subtitle: 'Inequalities Module',
      hint: 'e.g. sqrt(x + 4) < 3  (type sqrt(...) for square root)',
      solveFunction: GeneratedRadicalSolver.solve,
      stepsFunction: GeneratedRadicalSolver.getSteps,
    );
  }
}
