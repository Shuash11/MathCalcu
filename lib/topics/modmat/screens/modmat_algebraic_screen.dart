import 'package:calculus_system/topics/grade6/screens/grade6_solver_screen.dart';
import 'package:calculus_system/topics/modmat/solvers/m10_algebraic_structures_equation.dart';
import 'package:flutter/material.dart';

/// ModMat thin solver: Algebraic Structures. Route: /modmat/advanced/algebraic_structures.
class ModmatAlgebraicScreen extends StatelessWidget {
  const ModmatAlgebraicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Grade6SolverScreen(
      config: Grade6SolverConfig(
        title: 'Algebraic Structures',
        subtitle: 'Modern Math — Advanced',
        hint: 'e.g. Z5 + group',
        helper: 'Group / ring / field checks over Z_n.',
        depedCode: 'MODMAT-Advanced',
        icon: Icons.science_rounded,
        createEquation: (input) => M10AlgebraicStructuresEquation(input),
      ),
    );
  }
}
