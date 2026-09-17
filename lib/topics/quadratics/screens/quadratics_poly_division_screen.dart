import 'package:calculus_system/topics/grade6/screens/grade6_solver_screen.dart';
import 'package:calculus_system/topics/quadratics/solvers/polynomial_division_equation.dart';
import 'package:flutter/material.dart';

/// Quadratics thin solver: Polynomial Division. Route: /grade10/polynomial-division.
class QuadraticsPolyDivisionScreen extends StatelessWidget {
  const QuadraticsPolyDivisionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Grade6SolverScreen(
      config: Grade6SolverConfig(
        title: 'Polynomial Division',
        subtitle: 'G10 — quotient + remainder',
        hint: 'e.g. (x^2 + 5x + 6) / (x + 2)',
        helper: 'Polynomial long / synthetic division.',
        depedCode: 'G10-Polynomials',
        icon: Icons.call_split_rounded,
        createEquation: (input) => PolyDivisionEquation(input),
      ),
    );
  }
}
