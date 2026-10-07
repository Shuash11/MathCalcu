import 'package:calculus_system/topics/calculus/midterm/solvers/inequalities_solver/generated_linear_solver.dart';
import 'base_inequality_screen.dart';
import 'package:material_ui/material_ui.dart';

class StrictScreen extends StatelessWidget {
  const StrictScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseInequalityScreen(
      title: 'Strict Inequality',
      subtitle: 'Inequalities Module',
      hint: 'e.g. 2x + 3 > 7  or  5 − x < 2',
      solveFunction: GeneratedLinearSolver.solve,
      stepsFunction: GeneratedLinearSolver.getSteps,
    );
  }
}
