import 'package:calculus_system/topics/grade6/screens/grade6_solver_screen.dart';
import 'package:calculus_system/topics/modmat/solvers/m1_propositional_equation.dart';
import 'package:flutter/material.dart';

/// ModMat thin solver: Propositional Logic. Route: /modmat/foundations/propositional_logic.
class ModmatPropositionalScreen extends StatelessWidget {
  const ModmatPropositionalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Grade6SolverScreen(
      config: Grade6SolverConfig(
        title: 'Propositional Logic',
        subtitle: 'Modern Math — Foundations',
        hint: 'e.g. p -> q',
        helper: 'Truth tables over p, q (, r) — tautology check.',
        depedCode: 'MODMAT-Foundations',
        icon: Icons.functions_rounded,
        createEquation: (input) => M1PropositionalEquation(input),
      ),
    );
  }
}
