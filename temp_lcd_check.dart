import 'package:calculus_system/Finals/Joashua/Evaluating_limits/By_LCD/library/math_limits_library.dart';

void main() {
  final cases = [
    ['(1/x-1/3)/(x-3)', 'x', '3'],
    ['(1/sqrt(x)-1/3)/(x-9)', 'x', '9'],
    ['(sqrt(x)-3)/(x-9)', 'x', '9'],
  ];
  for (final c in cases) {
    final sol = LimitEngine.solve(c[0], c[1], double.parse(c[2]));
    print('expr=${c[0]} ans=${sol.finalAnswer} frac=${sol.fractionalAnswer} method=${sol.methodUsed}');
    for (final s in sol.steps) {
      print(s);
    }
    print('---');
  }
}
