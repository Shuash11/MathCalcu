// Alias-robustness tests for the z-test branch of CollegeStatsEquation.
// Covers: comma-separated key=value pairs, the greek sigma literal
// (U+03C3) as an sd alias, the combining-macron x-bar form (x + U+0304)
// as a mean alias, and the retained hijack guard ('max=5' must NOT be
// read as x=5 / mean). Mirrors the accessors used by
// college_stats_ungate_test.dart (validate()/solve()/customData).
import 'package:calculus_system/topics/college/solvers/college_stats_equation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ztest alias robustness', () {
    // Every alias form must resolve to mean=72, mu=70, sd=10, n=25
    // → SE = 10/sqrt(25) = 2, z = (72-70)/2 = 1.
    void ok(String input) {
      final eq = CollegeStatsEquation(input);
      expect(eq.validate(), isTrue, reason: input);
      final r = eq.solve();
      expect(r.hasError, isFalse, reason: input);
      expect(r.answer, contains('z = 1 (SE = 2)'), reason: input);
      final data = r.customData!.single as Map;
      expect(data['mean'], 72.0, reason: input);
      expect(data['mu'], 70.0, reason: input);
      expect(data['sd'], 10.0, reason: input);
      expect(data['n'], 25.0, reason: input);
      expect(data['z'], closeTo(1.0, 0.0001), reason: input);
    }

    test('comma-separated keys accepted',
        () => ok('ztest mean=72,mu=70,sd=10,n=25'));

    test('greek sigma literal accepted',
        () => ok('ztest x=72 mu=70 σ=10 n=25'));

    test('combining-macron x-bar accepted',
        () => ok('ztest x\u0304=72 mu=70 s=10 n=25'));

    test('hijack guard retained (no false mean)', () {
      // 'max=5': the char before 'x' is 'a', not whitespace/comma/start,
      // so numOf('x') must not match; with no other mean alias present
      // the input is rejected rather than silently using mean=5.
      final eq = CollegeStatsEquation('ztest max=5 mu=70 sd=10 n=25');
      expect(eq.validate(), isFalse);
      expect(eq.solve().hasError, isTrue);
    });
  });
}
