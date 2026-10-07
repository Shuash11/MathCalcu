import 'package:calculus_system/topics/grade6/solvers/grade6_equations.dart';
import 'package:calculus_system/topics/grade6/screens/grade6_solver_screen.dart';
import 'package:material_ui/material_ui.dart';

/// G7 Algebra thin solver: Signed Numbers & Number Line.
/// Route: /grade7/signed-numbers. Wires G6IntegerEquation
/// (arithmetic + comparisons) with the number-line graph painter.
class G7SignedNumbersScreen extends StatelessWidget {
  const G7SignedNumbersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Grade6SolverScreen(
      config: Grade6SolverConfig(
        title: 'Signed Numbers',
        subtitle: 'G7 — compare, add, subtract on the line',
        hint: 'e.g. -8 - (-3)',
        helper: 'Integers only — use - sign, + - × ÷ < >',
        depedCode: 'G7-Integers',
        icon: Icons.remove_circle_outline_rounded,
        graphKind: Grade6GraphKind.numberLine,
        createEquation: (input) => G6IntegerEquation(input),
      ),
    );
  }
}
