import 'package:calculus_system/topics/grade6/screens/grade6_solver_screen.dart';
import 'package:calculus_system/topics/shs/solvers/integral_sub_equation.dart';
import 'package:flutter/material.dart';

/// SHS thin solver: Definite Integrals & FTC. Route: /shs/definite-integral.
class ShsDefiniteIntegralScreen extends StatelessWidget {
  const ShsDefiniteIntegralScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Grade6SolverScreen(
      config: Grade6SolverConfig(
        title: 'Definite Integrals & FTC',
        subtitle: 'Shaded area under the curve',
        hint: 'e.g. ∫0^2 x^2 dx',
        helper: 'Formats: integral a^b f(x) dx',
        depedCode: 'SHS-BasicCalc',
        icon: Icons.area_chart_outlined,
        createEquation: (input) => IntegralSubEquation(input),
      ),
    );
  }
}
