import '../../solvers/partial_derivatives/partial_derivatives_equation.dart';
import 'package:calculus_system/topics/grade6/screens/grade6_solver_screen.dart';
import 'package:flutter/material.dart';

/// Finals thin solver: Partial Derivatives.
class PartialDerivativesScreen extends StatelessWidget {
  const PartialDerivativesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Grade6SolverScreen(
      config: Grade6SolverConfig(
        title: 'Partial Derivatives',
        subtitle: 'd/dx • d/dy • multivariable functions',
        hint: 'e.g. d/dx x^2*y',
        helper: 'Formats: d/dx expression, d/dy expression',
        depedCode: 'FINALS-Partials',
        icon: Icons.terrain_rounded,
        createEquation: (input) => PartialDerivativesEquation(input),
      ),
    );
  }
}
