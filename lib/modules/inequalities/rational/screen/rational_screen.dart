import 'package:flutter/material.dart';
import '../../core/base_inequality_screen.dart';
import '../solver/rational_solver.dart';

class RationalScreen extends StatelessWidget {
  const RationalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseInequalityScreen(
      title: 'Rational Inequality',
      subtitle: 'Inequalities Module',
      hint: 'e.g. (x+2)/(x−1) > 0',
      solveFunction: RationalSolver.solve,
      stepsFunction: RationalSolver.getSteps,
    );
  }
}
