import 'package:calculus_system/modules/inequalities/radical/solver/radical_solver.dart';

void main() {
  final tests = [
    '√(2x-1) >= x-2',
    '√(x-1) > 2',
    '√(3x+2) <= 4',
    '√(x) >= 1',
    '√(2x+1) < x+1',
  ];

  for (final t in tests) {
    print('Input: $t');
    final r = RadicalSolver.solve(t);
    print('Answer: ${r.answer}');
    print('Interval: ${r.intervalNotation}');
    print('Points: ${r.points}');
    print('');
  }
}