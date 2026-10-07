import 'package:calculus_system/topics/college/solvers/college_solver_registry.dart';
import 'package:calculus_system/topics/grade6/screens/grade6_solver_screen.dart';
import 'package:material_ui/material_ui.dart';

/// College Stats thin solver: descriptive stats + regression + z-test.
/// Route: /college/statistics. Wires CollegeStatsEquation (first
/// CollegeSolverRegistry spec) with the shared Phase-1 solver shell.
class CollegeStatsScreen extends StatelessWidget {
  const CollegeStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spec = CollegeSolverRegistry.byId('college-stats');
    return Grade6SolverScreen(
      config: Grade6SolverConfig(
        title: 'Hypothesis Testing & Regression',
        subtitle: 'College — stats, regression, z-test',
        hint: spec?.hint ?? 'e.g. 4,7,9 stats',
        helper: spec?.helper ??
            'Mean / median / mode / SD + regression + z-test.',
        depedCode: 'College-Stats',
        icon: Icons.scatter_plot_outlined,
        createEquation: (input) => CollegeStatsEquation(input),
      ),
    );
  }
}
