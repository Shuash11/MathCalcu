import 'package:calculus_system/topics/grade6/screens/grade6_solver_screen.dart';
import 'package:calculus_system/topics/modmat/solvers/m2_sets_equation.dart';
import 'package:flutter/material.dart';

/// ModMat thin solver: Set Theory. Route: /modmat/foundations/set_theory.
class ModmatSetsScreen extends StatelessWidget {
  const ModmatSetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Grade6SolverScreen(
      config: Grade6SolverConfig(
        title: 'Set Theory',
        subtitle: 'Modern Math — Foundations',
        hint: 'e.g. A={1,2,3} B={3,4} UNION',
        helper: 'Union, intersect, difference, cardinality, power.',
        depedCode: 'MODMAT-Foundations',
        icon: Icons.category_rounded,
        createEquation: (input) => M2SetsEquation(input),
      ),
    );
  }
}
