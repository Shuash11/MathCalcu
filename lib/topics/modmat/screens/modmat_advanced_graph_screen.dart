import 'package:calculus_system/topics/grade6/screens/grade6_solver_screen.dart';
import 'package:calculus_system/topics/modmat/solvers/m14_advanced_graph_equation.dart';
import 'package:flutter/material.dart';

/// ModMat thin solver: Advanced Graph Theory. Route: /modmat/advanced/advanced_graph_theory.
class ModmatAdvancedGraphScreen extends StatelessWidget {
  const ModmatAdvancedGraphScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Grade6SolverScreen(
      config: Grade6SolverConfig(
        title: 'Advanced Graph Theory',
        subtitle: 'Modern Math — Advanced',
        hint: 'e.g. V=4 E={(0,1),(1,2)} bipartite',
        helper: 'Bipartite, coloring, planarity, shortest path.',
        depedCode: 'MODMAT-Advanced',
        icon: Icons.insights_rounded,
        createEquation: (input) => M14AdvancedGraphEquation(input),
      ),
    );
  }
}
