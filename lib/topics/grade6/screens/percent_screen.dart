import 'package:calculus_system/topics/grade6/solvers/grade6_equations.dart';
import 'package:calculus_system/topics/grade6/screens/grade6_solver_screen.dart';
import 'package:flutter/material.dart';

class Grade6PercentScreen extends StatelessWidget {
  const Grade6PercentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Grade6SolverScreen(
      config: Grade6SolverConfig(
        title: 'Percent of a Number & Discount',
        subtitle: 'Rate × base, ₱ discount',
        hint: 'e.g. 25% of 200',
        helper: 'Formats: 25% of 200, 500 -20%',
        depedCode: 'M6NS-Ic-131',
        icon: Icons.percent_rounded,
        createEquation: (input) => G6PercentEquation(input),
      ),
    );
  }
}
