// SHS Wave 1 tests: exp/log, interest, inverse, rational inequality, trig ratio.
// Mirrors test/topics/grade6/ style: validate + solve + steps, never-throw.
import 'package:calculus_system/core/base_equation.dart';
import 'package:calculus_system/topics/shs/solvers/shs_equations.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Render [tex] with an explicit recording `onErrorFallback`; assert it was NOT
/// invoked, i.e. the TeX parses. A count/presence check cannot catch a parse
/// failure, so every emitted LaTeX line is rendered for real.
Future<void> _expectTexParses(WidgetTester tester, String tex) async {
  var fellBack = false;
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Math.tex(
          tex,
          textStyle: const TextStyle(fontSize: 14),
          onErrorFallback: (e) {
            fellBack = true;
            return const SizedBox();
          },
        ),
      ),
    ),
  );
  await tester.pump();
  expect(fellBack, isFalse, reason: 'TeX failed to parse: $tex');
}

/// Parse a linear expression like '3x + 1', 'x - 2', '-3x - 1' into
/// (coefficient-of-x, constant). Used to evaluate the EMITTED answer string.
(double, double) _linear(String s) {
  s = s.replaceAll(' ', '');
  var coef = 0.0, k = 0.0;
  for (final m in RegExp(r'([+-]?)(\d*)(x?)').allMatches(s)) {
    if (m.group(2)!.isEmpty && m.group(3)!.isEmpty) continue;
    final sign = m.group(1) == '-' ? -1.0 : 1.0;
    final dg = m.group(2)!;
    if (m.group(3) == 'x') {
      coef += sign * (dg.isEmpty ? 1 : double.parse(dg));
    } else {
      k += sign * double.parse(dg);
    }
  }
  return (coef, k);
}

/// Split an answer like 'f⁻¹(x) = (3x + 1)/(x - 2)' into the four linear
/// coefficients (numX, numK, denX, denK) of the emitted fraction.
(double, double, double, double) _fracLin(String answer) {
  final body = answer.split(' = ').last.replaceAll('(', '').replaceAll(')', '');
  final parts = body.split('/');
  final n = _linear(parts[0]);
  final d = _linear(parts[1]);
  return (n.$1, n.$2, d.$1, d.$2);
}

/// Printable body of the answer fraction, e.g. '(3x + 1)/(x - 2)'.
String _ansBody(String answer) => answer.split(' = ').last;

/// Render a \frac{a}{b} TeX into the same '(a)/(b)' body shape.
String _texBody(String tex) {
  final m = RegExp(r'\\frac\{([^}]*)\}\{([^}]*)\}').firstMatch(tex);
  return m == null ? '' : '(${m.group(1)})/(${m.group(2)})';
}

void main() {
  group('ExpLog (g11-logarithms)', () {
    test('2^x = 32 gives x = 5', () {
      final eq = ExpLogEquation('2^x = 32');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('5'));
      expect(r.points.single, closeTo(5, 1e-9));
      expect(eq.getSteps(), hasLength(4));
    });

    test('log2(x)+log2(x-2)=3 gives x = 4', () {
      final eq = ExpLogEquation('log2(x)+log2(x-2) = 3');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('4'));
    });

    test('missing operator errors, never throws', () {
      final eq = ExpLogEquation('hello world');
      expect(eq.validate(), isFalse);
      expect(() => eq.solve(), returnsNormally);
      expect(() => eq.getSteps(), returnsNormally);
      expect(eq.solve().hasError, isTrue);
    });

    test('empty input errors with example', () {
      final eq = ExpLogEquation('   ');
      expect(eq.validate(), isFalse);
      expect(eq.solve().hasError, isTrue);
    });

    test('math steps carry LaTeX, guidance stays prose', () {
      final s = ExpLogEquation('2^x = 32').getSteps();
      expect(s, hasLength(4));
      expect(s[0].latex, isNull); // one-to-one / domain rule
      expect(s[1].latex, r'x = \frac{\log_{b}(\text{RHS}) - k}{m}');
      expect(s[2].latex, 'x = 5');
      expect(s[3].latex, isNull); // verify-domain rule

      final ls = ExpLogEquation('log2(x)+log2(x-2) = 3').getSteps();
      expect(ls[1].latex, r'\log_{b} A + \log_{b} B = \log_{b}(AB)');
      expect(ls[2].latex, 'x = 4');
    });
  });

  group('Interest (g11-interest)', () {
    test('compound P=10000 r=5% t=2', () {
      final eq = InterestEquation('P = 10000, r = 5%, t = 2, compound');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('11'));
      expect(eq.getSteps(), hasLength(3));
    });

    test('simple interest computes total', () {
      final r = InterestEquation('P = 10000, r = 5%, t = 2, simple').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('Total'));
    });

    test('missing mode errors, never throws', () {
      final eq = InterestEquation('P = 100, r = 5%');
      expect(eq.validate(), isFalse);
      expect(() => eq.solve(), returnsNormally);
      expect(eq.solve().hasError, isTrue);
    });

    test('empty input errors', () {
      expect(InterestEquation('  ').validate(), isFalse);
    });

    test('formula + result carry LaTeX, rate step stays prose', () {
      final s = InterestEquation('P = 10000, r = 5%, t = 2, compound')
          .getSteps();
      expect(s, hasLength(3));
      expect(s[0].latex, r'F = P(1 + \frac{r}{m})^{mt}');
      expect(s[1].latex, isNull); // '5% → 0.05.' guidance
      expect(s[2].latex, startsWith(r'F = '));

      final sim = InterestEquation('P = 10000, r = 5%, t = 2, simple')
          .getSteps();
      expect(sim[0].latex, r'I = Prt,\quad F = P + I');
      expect(sim[1].latex, isNull);
      expect(sim[2].latex, isNotNull);
    });
  });

  group('Inverse function (g11-inverse-functions)', () {
    test('f(x)=2x+3 inverts', () {
      final eq = InverseFunctionEquation('f(x) = 2x + 3');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('⁻¹'));
      expect(eq.getSteps(), hasLength(4));
    });

    test('constant has no inverse', () {
      final r = InverseFunctionEquation('f(x) = 5').solve();
      expect(r.hasError, isTrue);
    });

    test('garbage never throws', () {
      final eq = InverseFunctionEquation('blah');
      expect(() => eq.solve(), returnsNormally);
      expect(() => eq.getSteps(), returnsNormally);
      expect(eq.solve().hasError, isTrue);
    });

    test('only the inverse result carries LaTeX; method steps prose', () {
      final s = InverseFunctionEquation('f(x) = 2x + 3').getSteps();
      expect(s, hasLength(4));
      expect(s[0].latex, isNull);
      expect(s[1].latex, isNull);
      expect(s[2].latex, isNull);
      expect(s[3].latex, r'f^{-1}(x) = \frac{x - 3}{2}');
    });
  });

  group('Inverse function sign fix (BUG A: fractional inverse negation)', () {
    // Locks down BUG A: the fractional inverse f(x)=(ax+b)/(cx+d) was emitted
    // as the exact NEGATION of the correct formula. The wrong numerator
    // (dx-b instead of b-dx) was built in TWO places — numS in solve() and
    // numTex in getSteps() — so both are fixed in lockstep here.
    test('inverse of (2x+1)/(x-3) is (3x+1)/(x-2) exactly', () {
      final eq = InverseFunctionEquation('f(x) = (2x + 1)/(x - 3)');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, 'f⁻¹(x) = (3x + 1)/(x - 2)');
    });

    test(
      'round-trip: f(f^-1(y)) == y and f^-1(f(t)) == t for several values',
      () {
        // The strongest guard: it catches ANY sign error, not just this string.
        final r = InverseFunctionEquation('f(x) = (2x + 1)/(x - 3)').solve();
        expect(r.hasError, isFalse);
        final (nc, nk, dc, dk) = _fracLin(r.answer);
        double inv(double y) => (nc * y + nk) / (dc * y + dk);
        double f(double x) => (2 * x + 1) / (x - 3);
        // NB: y = 2 is the pole of f^-1 (denominator x-2), so it is excluded.
        for (final y in <double>[-1.5, 0.0, 5.0, -4.0, 3.0]) {
          expect(f(inv(y)), closeTo(y, 1e-9), reason: 'f(f^-1($y)) != $y');
        }
        for (final t in <double>[-2.0, 0.0, 1.0, 4.0]) {
          expect(inv(f(t)), closeTo(t, 1e-9), reason: 'f^-1(f($t)) != $t');
        }
      },
    );

    test('step-4 TeX equals the answer fraction (lockstep guard)', () {
      // Guards against fixing solve() but not getSteps(): the steps must not
      // show the negated formula while the answer shows the corrected one.
      final eq = InverseFunctionEquation('f(x) = (2x + 1)/(x - 3)');
      final r = eq.solve();
      final s = eq.getSteps();
      expect(s, hasLength(4));
      expect(s[3].latex, r'f^{-1}(x) = \frac{3x + 1}{x - 2}');
      expect(_texBody(s[3].latex!), _ansBody(r.answer));
    });

    testWidgets('step-4 inverse TeX parses (recording fallback) + ASCII', (
      tester,
    ) async {
      final s = InverseFunctionEquation('f(x) = (2x + 1)/(x - 3)').getSteps();
      final tex = s[3].latex!;
      var checked = 0;
      expect(
        tex.codeUnits.every((c) => c >= 0x20 && c <= 0x7e),
        isTrue,
        reason: 'non-ASCII TeX: $tex',
      );
      checked++;
      await _expectTexParses(tester, tex);
      expect(checked, greaterThan(0));
    });
  });

  group('Rational inequality (g11-rational-inequality)', () {
    test('(x-1)/(x+2) > 0 splits intervals', () {
      final eq = RationalInequalityEquation('(x - 1)/(x + 2) > 0');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.intervalNotation, contains('∪'));
      expect(eq.getSteps(), hasLength(4));
    });

    test('missing comparator rejected', () {
      final eq = RationalInequalityEquation('(x-1)/(x+2)');
      expect(eq.validate(), isFalse);
      expect(() => eq.solve(), returnsNormally);
    });

    test('empty never throws', () {
      final eq = RationalInequalityEquation('  ');
      expect(eq.validate(), isFalse);
      expect(() => eq.getSteps(), returnsNormally);
    });

    test('only the interval result carries LaTeX; prose steps null', () {
      final s = RationalInequalityEquation('(x - 1)/(x + 2) > 0').getSteps();
      expect(s, hasLength(4));
      expect(s[0].latex, isNull);
      expect(s[1].latex, isNull);
      expect(s[2].latex, isNull);
      expect(s[3].latex, contains(r'-\infty'));
      expect(s[3].latex, contains(r'\cup'));

      final empty = RationalInequalityEquation('(x)/(x) > 1').getSteps();
      expect(empty[3].latex, r'\emptyset');
    });
  });

  group('Trig ratio (g9-trig-ratios)', () {
    test('sin 30 = 0.5', () {
      final eq = TrigRatioEquation('sin 30');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.points.single, closeTo(0.5, 1e-9));
      expect(eq.getSteps(), hasLength(3));
    });

    test('opp=3 hyp=6 solves triangle', () {
      final r = TrigRatioEquation('opp = 3, hyp = 6').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('30'));
    });

    test('nonsense never throws', () {
      final eq = TrigRatioEquation('xyz');
      expect(eq.validate(), isFalse);
      expect(() => eq.solve(), returnsNormally);
      expect(() => eq.getSteps(), returnsNormally);
    });

    test('ratio/triangle result carries LaTeX; guidance prose', () {
      final s = TrigRatioEquation('sin 30').getSteps();
      expect(s, hasLength(3));
      expect(s[0].latex, isNull);
      expect(s[1].latex, isNull);
      expect(s[2].latex, r'\sin(30^{\circ}) = 0.5');

      final t = TrigRatioEquation('opp = 3, hyp = 6').getSteps();
      expect(t[0].latex, isNull);
      expect(t[1].latex, isNull);
      expect(t[2].latex, r'\theta = 30^{\circ}');
    });
  });

  group('SHS wave1 LaTeX contract', () {
    final cases = <BaseEquation>[
      ExpLogEquation('2^x = 32'),
      ExpLogEquation('log2(x)+log2(x-2) = 3'),
      InterestEquation('P = 10000, r = 5%, t = 2, compound'),
      InterestEquation('P = 10000, r = 5%, t = 2, simple'),
      InterestEquation('R = 1000, i = 1%, n = 12, annuity'),
      InterestEquation('loan L = 100000, i = 1%, n = 12'),
      InverseFunctionEquation('f(x) = 2x + 3'),
      InverseFunctionEquation('f(x) = (2x + 1)/(x - 3)'),
      RationalInequalityEquation('(x - 1)/(x + 2) > 0'),
      RationalInequalityEquation('(x)/(x) > 1'),
      TrigRatioEquation('sin 30'),
      TrigRatioEquation('cos 60'),
      TrigRatioEquation('tan 45'),
      TrigRatioEquation('opp = 3, hyp = 6'),
      TrigRatioEquation('adj = 4, hyp = 8'),
      TrigRatioEquation('opp = 3, adj = 4'),
      TrigRatioEquation('sin = 0.5 find angle'),
    ];

    test('every emitted wave1 TeX line is ASCII', () {
      var checked = 0;
      for (final eq in cases) {
        for (final s in eq.getSteps()) {
          for (final tex in <String?>[s.latex, ...?s.subLatex]) {
            if (tex == null) continue;
            expect(
              tex.codeUnits.every((c) => c >= 0x20 && c <= 0x7e),
              isTrue,
              reason: '$tex (${s.title})',
            );
            checked++;
          }
        }
      }
      expect(checked, greaterThan(0));
    });

    testWidgets('every emitted wave1 TeX line parses (recording fallback)', (
      tester,
    ) async {
      var checked = 0;
      for (final eq in cases) {
        for (final s in eq.getSteps()) {
          if (s.latex != null && s.latex!.isNotEmpty) {
            await _expectTexParses(tester, s.latex!);
            checked++;
          }
          for (final line in s.subLatex ?? const <String>[]) {
            if (line.trim().isNotEmpty) {
              await _expectTexParses(tester, line);
              checked++;
            }
          }
        }
      }
      expect(checked, greaterThan(0));
    });
  });
}
