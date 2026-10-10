// Alias-robustness tests for the z-test branch of CollegeStatsEquation.
// Covers: comma-separated key=value pairs, the greek sigma literal
// (U+03C3) as an sd alias, the combining-macron x-bar form (x + U+0304)
// as a mean alias, and the retained hijack guard ('max=5' must NOT be
// read as x=5 / mean). Mirrors the accessors used by
// college_stats_ungate_test.dart (validate()/solve()/customData).
import 'package:calculus_system/topics/college/solvers/college_stats_equation.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Render [tex] with a recording `onErrorFallback`; true when it parsed.
Future<bool> _parses(WidgetTester tester, String tex) async {
  var fellBack = false;
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Math.tex(
          tex,
          onErrorFallback: (e) {
            fellBack = true;
            return const SizedBox();
          },
        ),
      ),
    ),
  );
  await tester.pump();
  return !fellBack;
}

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

    test(
      'comma-separated keys accepted',
      () => ok('ztest mean=72,mu=70,sd=10,n=25'),
    );

    test(
      'greek sigma literal accepted',
      () => ok('ztest x=72 mu=70 σ=10 n=25'),
    );

    test(
      'combining-macron x-bar accepted',
      () => ok('ztest x\u0304=72 mu=70 s=10 n=25'),
    );

    test('hijack guard retained (no false mean)', () {
      // 'max=5': the char before 'x' is 'a', not whitespace/comma/start,
      // so numOf('x') must not match; with no other mean alias present
      // the input is rejected rather than silently using mean=5.
      final eq = CollegeStatsEquation('ztest max=5 mu=70 sd=10 n=25');
      expect(eq.validate(), isFalse);
      expect(eq.solve().hasError, isTrue);
    });
  });

  group('College stats LaTeX coverage', () {
    List<String> texOf(CollegeStatsEquation eq) => [
      for (final s in eq.getSteps())
        if (s.latex != null) s.latex!,
      for (final s in eq.getSteps()) ...?s.subLatex,
    ];

    test('per-mode math steps carry real-value TeX; prose stays null', () {
      final d = CollegeStatsEquation('4,7,9 stats').getSteps();
      expect(d, hasLength(3));
      expect(d[0].latex, isNull); // 'summarize the data' guidance -> prose
      expect(
        d[1].latex,
        '\\bar{x} = \\frac{\\sum x}{n},\\quad '
        '\\sigma = \\sqrt{\\frac{\\sum (x - \\bar{x})^{2}}{n}}',
      );
      expect(d[2].latex, '\\bar{x} = 6.6667');
      expect(d[2].subLatex, ['\\sigma = 2.0548,\\quad s = 2.5166']);

      final reg = CollegeStatsEquation('x:1,2,3 y:2,4,6 regress').getSteps();
      expect(reg, hasLength(3));
      expect(reg[0].latex, isNull);
      expect(
        reg[1].latex,
        'b = \\frac{S_{xy}}{S_{xx}},\\quad a = \\bar{y} - b\\bar{x}',
      );
      expect(reg[2].latex, '\\hat{y} = 0 + 2x');
      expect(reg[2].subLatex, ['r = 1,\\quad R^{2} = 1']);

      final z = CollegeStatsEquation('ztest mean=72 mu=70 sd=10 n=25')
          .getSteps();
      expect(z, hasLength(3));
      expect(z[0].latex, isNull);
      expect(
        z[1].latex,
        'z = \\frac{\\bar{x} - \\mu_{0}}{\\sigma / \\sqrt{n}}',
      );
      expect(z[2].latex, 'z = 1');
      expect(z[2].subLatex, ['p = 0.3173']);

      final bad = CollegeStatsEquation('hello world').getSteps();
      expect(bad, hasLength(1));
      expect(bad[0].latex, isNull); // invalid-input prose -> null
    });

    test('every emitted line is non-empty ASCII; guard counts', () {
      final inputs = <CollegeStatsEquation>[
        CollegeStatsEquation('4,7,9 stats'),
        CollegeStatsEquation('10, 20, 30, 40 stats'),
        CollegeStatsEquation('x:1,2,3 y:2,4,6 regress'),
        CollegeStatsEquation('x:1,2,3,4 y:1,3,5,7 regress'),
        CollegeStatsEquation('ztest mean=72 mu=70 sd=10 n=25'),
        CollegeStatsEquation('ztest x=100 mu=95 sd=12 n=36'),
      ];
      var checked = 0;
      for (final eq in inputs) {
        for (final t in texOf(eq)) {
          expect(t, isNotEmpty);
          expect(
            t.codeUnits.every((c) => c >= 0x20 && c <= 0x7e),
            isTrue,
            reason: 'non-ASCII TeX: $t',
          );
          checked++;
        }
      }
      expect(checked, greaterThan(0));
    });

    testWidgets('all college-stats TeX parses; malformed TeX fires fallback', (
      tester,
    ) async {
      final inputs = <CollegeStatsEquation>[
        CollegeStatsEquation('4,7,9 stats'),
        CollegeStatsEquation('10, 20, 30, 40 stats'),
        CollegeStatsEquation('x:1,2,3 y:2,4,6 regress'),
        CollegeStatsEquation('x:1,2,3,4 y:1,3,5,7 regress'),
        CollegeStatsEquation('ztest mean=72 mu=70 sd=10 n=25'),
        CollegeStatsEquation('ztest x=100 mu=95 sd=12 n=36'),
      ];
      var checked = 0;
      for (final eq in inputs) {
        for (final t in texOf(eq)) {
          expect(await _parses(tester, t), isTrue, reason: 'unparsed TeX: $t');
          checked++;
        }
      }
      expect(checked, greaterThan(0));
      // Guard: a deliberately-malformed string MUST fire the fallback.
      expect(await _parses(tester, '\\frac{1}{'), isFalse);
    });
  });
}
