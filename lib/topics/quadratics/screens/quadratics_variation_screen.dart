import 'package:calculus_system/topics/grade6/screens/grade6_solver_screen.dart';
import 'package:calculus_system/topics/quadratics/solvers/variation_equation.dart';
import 'package:flutter/material.dart';

/// Quadratics thin solver: Variation. Route: /grade9/variation.
class QuadraticsVariationScreen extends StatelessWidget {
  const QuadraticsVariationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Grade6SolverScreen(
      config: Grade6SolverConfig(
        title: 'Direct & Inverse Variation',
        subtitle: 'G9 — find k first',
        hint: 'e.g. y = kx, y = 10, x = 2',
        helper: 'Direct / inverse / joint variation — find k first.',
        depedCode: 'G9-Variation',
        icon: Icons.swap_calls_rounded,
        createEquation: (input) => VariationEquation(input),
      ),
    );
  }
}
