import 'package:calculus_system/topics/grade6/screens/grade6_solver_screen.dart';
import 'package:calculus_system/topics/shs/solvers/inverse_function_equation.dart';
import 'package:flutter/material.dart';

/// SHS thin solver: Inverse Functions. Route: /shs/inverse-functions.
class ShsInverseFunctionsScreen extends StatelessWidget {
  const ShsInverseFunctionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Grade6SolverScreen(
      config: Grade6SolverConfig(
        title: 'Inverse Functions',
        subtitle: 'Swap x and y — one-to-one check',
        hint: 'e.g. f(x)=2x+3',
        helper: 'Formats: f(x)=mx+b',
        depedCode: 'SHS-GenMath',
        icon: Icons.swap_horiz_rounded,
        createEquation: (input) => InverseFunctionEquation(input),
      ),
    );
  }
}
