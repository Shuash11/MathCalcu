import 'package:calculus_system/topics/grade6/screens/grade6_solver_screen.dart';
import 'package:calculus_system/topics/shs/solvers/rational_inequality_equation.dart';
import 'package:flutter/material.dart';

/// SHS thin solver: Rational Inequalities. Route: /shs/rational-inequality.
class ShsRationalInequalityScreen extends StatelessWidget {
  const ShsRationalInequalityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Grade6SolverScreen(
      config: Grade6SolverConfig(
        title: 'Rational Inequalities',
        subtitle: 'Sign chart — asymptotes',
        hint: 'e.g. (x-1)/(x+2)>0',
        helper: 'Formats: (ax+b)/(cx+d) </>/≤/≥ 0',
        depedCode: 'SHS-GenMath',
        icon: Icons.compare_arrows_rounded,
        createEquation: (input) => RationalInequalityEquation(input),
      ),
    );
  }
}
