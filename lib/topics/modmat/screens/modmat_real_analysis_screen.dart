import 'package:calculus_system/topics/grade6/screens/grade6_solver_screen.dart';
import 'package:calculus_system/topics/modmat/solvers/m9_real_analysis_equation.dart';
import 'package:flutter/material.dart';

/// ModMat thin solver: Real Analysis. Route: /modmat/advanced/real_analysis.
class ModmatRealAnalysisScreen extends StatelessWidget {
  const ModmatRealAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Grade6SolverScreen(
      config: Grade6SolverConfig(
        title: 'Real Analysis',
        subtitle: 'Modern Math — Advanced',
        hint: 'e.g. lim (2n+1)/(n+3)',
        helper: 'Sequence limits at infinity via comparison.',
        depedCode: 'MODMAT-Advanced',
        icon: Icons.trending_up_rounded,
        createEquation: (input) => M9RealAnalysisEquation(input),
      ),
    );
  }
}
