import 'package:calculus_system/topics/grade6/screens/grade6_solver_screen.dart';
import 'package:calculus_system/topics/modmat/solvers/m3_combinatorics_equation.dart';
import 'package:flutter/material.dart';

/// ModMat thin solver: Combinatorics. Route: /modmat/foundations/combinatorics_basics.
class ModmatCombinatoricsScreen extends StatelessWidget {
  const ModmatCombinatoricsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Grade6SolverScreen(
      config: Grade6SolverConfig(
        title: 'Combinatorics',
        subtitle: 'Modern Math — Foundations',
        hint: 'e.g. C(5,2)',
        helper: 'nPr / nCr / factorial counting.',
        depedCode: 'MODMAT-Foundations',
        icon: Icons.calculate_rounded,
        createEquation: (input) => M3CombinatoricsEquation(input),
      ),
    );
  }
}
