import 'package:calculus_system/topics/grade6/solvers/grade6_equations.dart';
import 'package:calculus_system/topics/grade6/screens/grade6_solver_screen.dart';
import 'package:flutter/material.dart';

class Grade6FractionsScreen extends StatelessWidget {
  const Grade6FractionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Grade6SolverScreen(
      config: Grade6SolverConfig(
        title: 'Fractions: Add & Subtract',
        subtitle: 'Mixed & improper — exact + decimal',
        hint: 'e.g. 2 1/3 + 1 1/2',
        helper: 'Formats: a/b, mixed a b/c, + - × ÷',
        depedCode: 'M6NS-Ia-86',
        icon: Icons.pie_chart_outline_rounded,
        createEquation: (input) => G6FractionEquation(input),
      ),
    );
  }
}
