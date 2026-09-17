import 'package:calculus_system/topics/grade6/screens/grade6_solver_screen.dart';
import 'package:calculus_system/topics/modmat/solvers/m11_graph_basics_equation.dart';
import 'package:flutter/material.dart';

/// ModMat thin solver: Graph Theory Basics. Route: /modmat/foundations/graph_theory_basics.
class ModmatGraphBasicsScreen extends StatelessWidget {
  const ModmatGraphBasicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Grade6SolverScreen(
      config: Grade6SolverConfig(
        title: 'Graph Theory Basics',
        subtitle: 'Modern Math — Foundations',
        hint: 'e.g. V=4 E={(0,1),(1,2),(2,3)}',
        helper: 'Degrees, connectivity, tree and Euler read-off.',
        depedCode: 'MODMAT-Foundations',
        icon: Icons.account_tree_rounded,
        createEquation: (input) => M11GraphBasicsEquation(input),
      ),
    );
  }
}
