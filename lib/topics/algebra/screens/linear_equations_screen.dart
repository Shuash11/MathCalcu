import 'package:calculus_system/topics/algebra/solvers/algebra_equations.dart';
import 'package:calculus_system/topics/grade6/screens/grade6_solver_screen.dart';
import 'package:material_ui/material_ui.dart';

/// G7 Algebra thin solver: Linear Equations. Route:
/// /grade7/linear-equations. Wires LinearOneVarEquation.
class G7LinearEquationsScreen extends StatelessWidget {
  const G7LinearEquationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Grade6SolverScreen(
      config: Grade6SolverConfig(
        title: 'Linear Equations',
        subtitle: 'G7 — one variable, two steps',
        hint: 'e.g. 2x - 5 = 9',
        helper: 'Linear in x — one variable, both sides allowed.',
        depedCode: 'G7-Algebra',
        icon: Icons.linear_scale_rounded,
        createEquation: (input) => LinearOneVarEquation(input),
      ),
    );
  }
}
