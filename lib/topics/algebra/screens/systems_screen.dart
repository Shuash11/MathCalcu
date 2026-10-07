import 'package:calculus_system/topics/algebra/solvers/algebra_equations.dart';
import 'package:calculus_system/topics/grade6/screens/grade6_solver_screen.dart';
import 'package:material_ui/material_ui.dart';

/// G8 thin solver: Linear Systems. Route: /grade8/systems. Wires
/// System2x2Equation (elimination + substitution check).
class G8SystemsScreen extends StatelessWidget {
  const G8SystemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Grade6SolverScreen(
      config: Grade6SolverConfig(
        title: 'Linear Systems',
        subtitle: 'G8 — two equations, intersection point',
        hint: 'e.g. x + y = 5, x - y = 1',
        helper: 'Two equations in x and y — intersection point.',
        depedCode: 'G8-Systems',
        icon: Icons.grid_on_rounded,
        createEquation: (input) => System2x2Equation(input),
      ),
    );
  }
}
