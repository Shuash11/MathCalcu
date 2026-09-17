import 'package:calculus_system/topics/grade6/screens/grade6_solver_screen.dart';
import 'package:calculus_system/topics/quadratics/solvers/radical_equation.dart';
import 'package:flutter/material.dart';

/// Quadratics thin solver: Radical Equations. Route: /grade9/radical-equations.
class QuadraticsRadicalScreen extends StatelessWidget {
  const QuadraticsRadicalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Grade6SolverScreen(
      config: Grade6SolverConfig(
        title: 'Radical Equations',
        subtitle: 'G9 — extraneous roots rejected',
        hint: 'e.g. sqrt(x + 5) = 3',
        helper: 'Radical equation — extraneous roots rejected.',
        depedCode: 'G9-Radicals',
        icon: Icons.functions_rounded,
        createEquation: (input) => RadicalEquation(input),
      ),
    );
  }
}
