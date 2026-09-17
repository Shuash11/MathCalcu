import 'package:calculus_system/topics/grade6/screens/grade6_solver_screen.dart';
import 'package:calculus_system/topics/modmat/solvers/m12_proof_equation.dart';
import 'package:flutter/material.dart';

/// ModMat thin solver: Proof Techniques. Route: /modmat/foundations/proof_techniques.
class ModmatProofScreen extends StatelessWidget {
  const ModmatProofScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Grade6SolverScreen(
      config: Grade6SolverConfig(
        title: 'Proof Techniques',
        subtitle: 'Modern Math — Foundations',
        hint: 'e.g. induction sum k n=5',
        helper: 'Induction outlines for sums and powers.',
        depedCode: 'MODMAT-Foundations',
        icon: Icons.verified_rounded,
        createEquation: (input) => M12ProofEquation(input),
      ),
    );
  }
}
