import '../../solvers/diffeq_separable/diffeq_separable_equation.dart';
import 'package:calculus_system/topics/grade6/screens/grade6_solver_screen.dart';
import 'package:flutter/material.dart';

/// Finals thin solver: Differential Equations (separable).
class DiffeqScreen extends StatelessWidget {
  const DiffeqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Grade6SolverScreen(
      config: Grade6SolverConfig(
        title: 'Differential Equations',
        subtitle: 'separable equations',
        hint: 'e.g. dy/dx = x * y',
        helper: 'Format: dy/dx = f(x) * g(y) — elementary only (y^n, 1/y)',
        depedCode: 'FINALS-DiffEq',
        icon: Icons.auto_graph_rounded,
        createEquation: (input) => DiffeqSeparableEquation(input),
      ),
    );
  }
}
