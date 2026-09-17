import 'package:calculus_system/topics/grade6/screens/grade6_solver_screen.dart';
import 'package:calculus_system/topics/shs/solvers/interest_equation.dart';
import 'package:flutter/material.dart';

/// SHS thin solver: Simple & Compound Interest. Route: /shs/interest.
class ShsInterestScreen extends StatelessWidget {
  const ShsInterestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Grade6SolverScreen(
      config: Grade6SolverConfig(
        title: 'Simple & Compound Interest',
        subtitle: 'GenMath — growth bars',
        hint: 'e.g. P=10000, r=5%, t=2',
        helper: 'Formats: P, r, t — simple or compound',
        depedCode: 'SHS-GenMath',
        icon: Icons.savings_outlined,
        createEquation: (input) => InterestEquation(input),
      ),
    );
  }
}
