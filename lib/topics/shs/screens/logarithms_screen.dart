import 'package:calculus_system/topics/grade6/screens/grade6_solver_screen.dart';
import 'package:calculus_system/topics/shs/solvers/exp_log_equation.dart';
import 'package:flutter/material.dart';

/// SHS thin solver: Logarithms & Exponents. Route: /shs/logarithms.
class ShsLogarithmsScreen extends StatelessWidget {
  const ShsLogarithmsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Grade6SolverScreen(
      config: Grade6SolverConfig(
        title: 'Logarithms & Exponents',
        subtitle: 'GenMath — log curve',
        hint: 'e.g. 2^x=32',
        helper: 'Formats: b^x=rhs, log_b(v)',
        depedCode: 'SHS-GenMath',
        icon: Icons.trending_up_rounded,
        createEquation: (input) => ExpLogEquation(input),
      ),
    );
  }
}
