import 'package:calculus_system/topics/grade6/screens/grade6_solver_screen.dart';
import 'package:calculus_system/topics/quadratics/solvers/sequence_equation.dart';
import 'package:flutter/material.dart';

/// Quadratics thin solver: Sequences. Route: /grade10/sequences.
class QuadraticsSequencesScreen extends StatelessWidget {
  const QuadraticsSequencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Grade6SolverScreen(
      config: Grade6SolverConfig(
        title: 'Arithmetic Sequences',
        subtitle: 'G10 — nth term + sum',
        hint: 'e.g. arith a1 = 2, d = 3, n = 5',
        helper: 'Arithmetic or geometric — nth term + sum.',
        depedCode: 'G10-Sequences',
        icon: Icons.more_horiz_rounded,
        createEquation: (input) => SequenceEquation(input),
      ),
    );
  }
}
