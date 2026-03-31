import 'package:calculus_system/modules/inequalities/core/base_inequality_screen.dart';
import 'package:calculus_system/modules/inequalities/quadratic/solver/quadratic_solver.dart';
import 'package:flutter/material.dart';

class QuadraticScreen extends StatelessWidget {
  const QuadraticScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseInequalityScreen(
      title: 'Quadratic Inequality',
      subtitle: 'Inequalities Module',
      hint: 'e.g. x²−3x+2>0  or  √(x²)≤√9',
      solveFunction: QuadraticSolver.solve,
      stepsFunction: QuadraticSolver.getSteps,
    );
  }
}
