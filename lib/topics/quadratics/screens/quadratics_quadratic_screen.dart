import 'package:calculus_system/topics/grade6/screens/grade6_solver_screen.dart';
import 'package:calculus_system/topics/quadratics/solvers/quadratic_equation.dart';
import 'package:flutter/material.dart';

/// Quadratics thin solver: Quadratic Formula. Route: /grade9/quadratic-formula.
class QuadraticsQuadraticScreen extends StatelessWidget {
  const QuadraticsQuadraticScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Grade6SolverScreen(
      config: Grade6SolverConfig(
        title: 'Quadratic Formula',
        subtitle: 'G9 — discriminant + formula',
        hint: 'e.g. x^2 - 5x + 6 = 0',
        helper: 'Quadratic = 0 form — discriminant + formula.',
        depedCode: 'G9-Quadratics',
        icon: Icons.square_foot_rounded,
        createEquation: (input) => QuadraticEquation(input),
      ),
    );
  }
}
