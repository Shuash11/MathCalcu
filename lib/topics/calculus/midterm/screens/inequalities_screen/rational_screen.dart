import 'package:calculus_system/topics/calculus/midterm/solvers/inequalities_solver/generated_rational_solver.dart';
import 'base_inequality_screen.dart';
import 'package:flutter/material.dart';

class RationalScreen extends StatelessWidget {
  const RationalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseInequalityScreen(
      title: 'Rational Inequality',
      subtitle: 'Inequalities Module',
      hint: 'e.g. (x+2)/(x–1) > 0  or  (x-3)/(x+4) ≤ 0',
      solveFunction: GeneratedRationalSolver.solve,
      stepsFunction: GeneratedRationalSolver.getSteps,
    );
  }
}
