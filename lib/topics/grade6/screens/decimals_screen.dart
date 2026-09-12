import 'package:calculus_system/topics/grade6/solvers/grade6_equations.dart';
import 'package:calculus_system/topics/grade6/screens/grade6_solver_screen.dart';
import 'package:flutter/material.dart';

class Grade6DecimalsScreen extends StatelessWidget {
  const Grade6DecimalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Grade6SolverScreen(
      config: Grade6SolverConfig(
        title: 'Decimals: Multiply & Divide',
        subtitle: 'Place value & rounding',
        hint: 'e.g. 3.25 × 1.2',
        helper: 'Use . for decimals, × ÷ or * /',
        depedCode: 'M6NS-Ib-106',
        icon: Icons.exposure_rounded,
        createEquation: (input) => G6DecimalEquation(input),
      ),
    );
  }
}
