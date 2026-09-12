import 'package:calculus_system/topics/grade6/solvers/grade6_equations.dart';
import 'package:calculus_system/topics/grade6/screens/grade6_solver_screen.dart';
import 'package:flutter/material.dart';

class Grade6PieScreen extends StatelessWidget {
  const Grade6PieScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Grade6SolverScreen(
      config: Grade6SolverConfig(
        title: 'Pie Chart & Data',
        subtitle: '% to degrees (% × 3.6°)',
        hint: 'e.g. Math 40, Science 30, English 30',
        helper: 'Comma values or label:value, must sum > 0',
        depedCode: 'M6SP-IVe-1',
        icon: Icons.pie_chart_rounded,
        graphKind: Grade6GraphKind.pie,
        createEquation: (input) => G6PieEquation(input),
      ),
    );
  }
}
