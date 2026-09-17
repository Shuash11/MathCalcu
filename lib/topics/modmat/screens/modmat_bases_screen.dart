import 'package:calculus_system/topics/grade6/screens/grade6_solver_screen.dart';
import 'package:calculus_system/topics/modmat/solvers/m4_base_conversion_equation.dart';
import 'package:flutter/material.dart';

/// ModMat thin solver: Number Systems. Route: /modmat/foundations/number_systems.
class ModmatBasesScreen extends StatelessWidget {
  const ModmatBasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Grade6SolverScreen(
      config: Grade6SolverConfig(
        title: 'Number Systems',
        subtitle: 'Modern Math — Foundations',
        hint: 'e.g. 1011 base2 to base10',
        helper: 'Binary / octal / decimal / hex conversion.',
        depedCode: 'MODMAT-Foundations',
        icon: Icons.numbers_rounded,
        createEquation: (input) => M4BaseConversionEquation(input),
      ),
    );
  }
}
