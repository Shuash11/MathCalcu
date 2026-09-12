import 'package:calculus_system/topics/grade6/solvers/grade6_equations.dart';
import 'package:calculus_system/topics/grade6/screens/grade6_solver_screen.dart';
import 'package:flutter/material.dart';

class Grade6ProbabilityScreen extends StatelessWidget {
  const Grade6ProbabilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Grade6SolverScreen(
      config: Grade6SolverConfig(
        title: 'Simple Probability (Intro)',
        subtitle: 'Favorable over total',
        hint: 'e.g. P(red) in 3R + 2B',
        helper: 'Use 3 out of 5, 3/5, or P(red) in 3R + 2B',
        depedCode: 'M6SP-IVg-2',
        icon: Icons.casino_outlined,
        createEquation: (input) => G6ProbabilityEquation(input),
      ),
    );
  }
}
