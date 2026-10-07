import 'package:calculus_system/topics/algebra/solvers/algebra_equations.dart';
import 'package:calculus_system/topics/grade6/screens/grade6_solver_screen.dart';
import 'package:material_ui/material_ui.dart';

/// G8 thin solver: Factoring Quadratics. Route: /grade8/factoring.
/// Wires FactoringEquation (GCF, DOTS, monic trinomial).
class G8FactoringScreen extends StatelessWidget {
  const G8FactoringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Grade6SolverScreen(
      config: Grade6SolverConfig(
        title: 'Factoring Quadratics',
        subtitle: 'G8 — GCF, difference of squares, trinomial',
        hint: 'e.g. x^2 + 5x + 6',
        helper: 'Quadratic in x — GCF, difference of squares, trinomial.',
        depedCode: 'G8-Factoring',
        icon: Icons.extension_rounded,
        createEquation: (input) => FactoringEquation(input),
      ),
    );
  }
}
