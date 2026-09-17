import 'package:calculus_system/topics/grade6/screens/grade6_solver_screen.dart';
import 'package:calculus_system/topics/modmat/solvers/m5_matrix_equation.dart';
import 'package:flutter/material.dart';

/// ModMat thin solver: Linear Algebra. Route: /modmat/advanced/linear_algebra.
class ModmatMatricesScreen extends StatelessWidget {
  const ModmatMatricesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Grade6SolverScreen(
      config: Grade6SolverConfig(
        title: 'Linear Algebra',
        subtitle: 'Modern Math — Advanced',
        hint: 'e.g. det [[1,2],[3,4]]',
        helper: 'Determinant + inverse for 2x2 / 3x3.',
        depedCode: 'MODMAT-Advanced',
        icon: Icons.grid_on_rounded,
        createEquation: (input) => M5MatrixEquation(input),
      ),
    );
  }
}
