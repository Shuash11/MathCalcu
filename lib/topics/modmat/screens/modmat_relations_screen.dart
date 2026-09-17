import 'package:calculus_system/topics/grade6/screens/grade6_solver_screen.dart';
import 'package:calculus_system/topics/modmat/solvers/m8_relations_equation.dart';
import 'package:flutter/material.dart';

/// ModMat thin solver: Relations & Functions. Route: /modmat/foundations/relations_functions.
class ModmatRelationsScreen extends StatelessWidget {
  const ModmatRelationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Grade6SolverScreen(
      config: Grade6SolverConfig(
        title: 'Relations & Functions',
        subtitle: 'Modern Math — Foundations',
        hint: 'e.g. R={(1,1),(2,2)} on {1,2}',
        helper: 'Reflexive / symmetric / transitive checks.',
        depedCode: 'MODMAT-Foundations',
        icon: Icons.swap_horiz_rounded,
        createEquation: (input) => M8RelationsEquation(input),
      ),
    );
  }
}
