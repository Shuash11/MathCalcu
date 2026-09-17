import 'package:calculus_system/topics/grade6/screens/grade6_solver_screen.dart';
import 'package:calculus_system/topics/modmat/solvers/m6_modular_equation.dart';
import 'package:flutter/material.dart';

/// ModMat thin solver: Number Theory. Route: /modmat/advanced/number_theory.
class ModmatModularScreen extends StatelessWidget {
  const ModmatModularScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Grade6SolverScreen(
      config: Grade6SolverConfig(
        title: 'Number Theory',
        subtitle: 'Modern Math — Advanced',
        hint: 'e.g. 17 mod 5',
        helper: 'Residues, powers, inverses — extends G6 GCF/LCM.',
        depedCode: 'MODMAT-Advanced',
        icon: Icons.pin_rounded,
        createEquation: (input) => M6ModularEquation(input),
      ),
    );
  }
}
