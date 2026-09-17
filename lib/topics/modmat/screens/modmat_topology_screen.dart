import 'package:calculus_system/topics/grade6/screens/grade6_solver_screen.dart';
import 'package:calculus_system/topics/modmat/solvers/m13_topology_equation.dart';
import 'package:flutter/material.dart';

/// ModMat thin solver: Topology Basics. Route: /modmat/advanced/topology_basics.
class ModmatTopologyScreen extends StatelessWidget {
  const ModmatTopologyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Grade6SolverScreen(
      config: Grade6SolverConfig(
        title: 'Topology Basics',
        subtitle: 'Modern Math — Advanced',
        hint: 'e.g. (0,1)',
        helper: 'Open / closed / compact / connected in R.',
        depedCode: 'MODMAT-Advanced',
        icon: Icons.tune_rounded,
        createEquation: (input) => M13TopologyEquation(input),
      ),
    );
  }
}
