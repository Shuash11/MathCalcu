import 'package:calculus_system/topics/grade6/screens/grade6_solver_screen.dart';
import 'package:calculus_system/topics/shs/solvers/related_rates_equation.dart';
import 'package:flutter/material.dart';

/// SHS thin solver: Max/Min & Related Rates. Route: /shs/optimization.
class ShsOptimizationScreen extends StatelessWidget {
  const ShsOptimizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Grade6SolverScreen(
      config: Grade6SolverConfig(
        title: 'Max / Min & Related Rates',
        subtitle: 'Optimization — graph + diagram',
        hint: 'e.g. maximize area, P=40',
        helper: 'Formats: constraint + objective',
        depedCode: 'SHS-BasicCalc',
        icon: Icons.insights_rounded,
        createEquation: (input) => RelatedRatesEquation(input),
      ),
    );
  }
}
