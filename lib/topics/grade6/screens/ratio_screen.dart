import 'package:calculus_system/topics/grade6/solvers/grade6_equations.dart';
import 'package:calculus_system/topics/grade6/screens/grade6_solver_screen.dart';
import 'package:flutter/material.dart';

class Grade6RatioScreen extends StatelessWidget {
  const Grade6RatioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Grade6SolverScreen(
      config: Grade6SolverConfig(
        title: 'Ratio & Proportion',
        subtitle: 'Simplify, missing term, sharing',
        hint: 'e.g. 12:18 or 3/4 = x/20',
        helper: 'Use : or / and x for unknown',
        depedCode: 'M6NS-Id-140',
        icon: Icons.balance_rounded,
        graphKind: Grade6GraphKind.ratioBars,
        createEquation: (input) => G6RatioEquation(input),
      ),
    );
  }
}
