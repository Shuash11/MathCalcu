// G6 Wave 2 tests: percent, ratio/proportion, rate (speed/best-buy/meter).
import 'package:calculus_system/core/base_equation.dart';
import 'package:calculus_system/topics/grade6/solvers/grade6_equations.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Render [tex] with an explicit recording `onErrorFallback` and assert it was
/// NOT invoked, i.e. the TeX parses (Phase B technique for the LaTeX waves).
/// A count/presence-only check cannot catch a parse failure.
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

void main() {
  group('G6-3 percent (M6NS-Ic-131)', () {
    test('25% of 200 = 50', () {
      final eq = G6PercentEquation('25% of 200');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('50'));
      expect(eq.getSteps(), hasLength(3));
    });

    test('R=? P=50 B=200 gives 25%', () {
      final r = G6PercentEquation('R=? P=50 B=200').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('25%'));
    });

    test('B=? P=50 R=25% gives 200', () {
      final r = G6PercentEquation('B=? P=50 R=25%').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('200'));
    });

    test('500 less 20% discounts to 400', () {
      final r = G6PercentEquation('500 less 20%').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('400'));
    });

    test('500 + 12% tax totals 560', () {
      final r = G6PercentEquation('500 + 12% tax').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('560'));
    });

    test('P=1000 R=5% T=2 interest', () {
      final r = G6PercentEquation('P=1000 R=5% T=2').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('100'));
      expect(r.answer, contains('1100.00'));
    });

    test('zero base rate lookup errors', () {
      expect(G6PercentEquation('R=? P=50 B=0').solve().hasError, isTrue);
    });
  });

  group('G6-4 ratio & proportion (M6NS-Id-140)', () {
    test('12:18 simplifies to 2:3', () {
      final eq = G6RatioEquation('12:18');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, '2:3');
      expect(r.customData?.first['bars'], hasLength(2));
      expect(eq.getSteps(), hasLength(4));
    });

    test('3/4 = x/20 gives x=15', () {
      final eq = G6RatioEquation('3/4 = x/20');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('15'));
      expect(eq.getSteps(), hasLength(4));
    });

    test('direct variation finds k', () {
      final r = G6RatioEquation('direct x=4 y=12').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('k = 3'));
    });

    test('inverse variation finds k', () {
      final r = G6RatioEquation('inverse x=4 y=6').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('k = 24'));
    });

    test('partitive 120 in 2:3', () {
      final r = G6RatioEquation('divide 120 in 2:3').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('48'));
      expect(r.answer, contains('72'));
    });

    test('non-positive ratio rejected', () {
      expect(G6RatioEquation('0:5').validate(), isFalse);
    });
  });

  group('G6-6 algebra (M6AL-IIIa-28)', () {
    test('x + 7 = 15 gives x=8', () {
      final eq = G6AlgebraEquation('x + 7 = 15');
      expect(eq.validate(), isTrue);
      expect(eq.solve().answer, contains('8'));
      expect(eq.getSteps(), hasLength(3));
    });

    test('3n = 21 gives n=7', () {
      expect(G6AlgebraEquation('3n = 21').solve().answer, contains('7'));
    });

    test('x/4 = 5 gives x=20', () {
      expect(G6AlgebraEquation('x/4 = 5').solve().answer, contains('20'));
    });

    test('two equals signs rejected', () {
      expect(G6AlgebraEquation('x = 2 = 3').validate(), isFalse);
    });

    // BUG A: 'constant - variable' shape lands the constant in the coefficient
    // slot, so the operand reads 0 and the answer is wrong (was 'x = -8').
    test('BUG A: 20 - x = 8 gives x=12, no phantom 0 - x', () {
      final eq = G6AlgebraEquation('20 - x = 8');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, 'x = 12');
      final steps = eq.getSteps();
      expect(steps, hasLength(3));
      for (final s in steps) {
        // '0 - x' as a leading operand (boundary-aware, so '20 - x' passes).
        expect(
          RegExp(r'(^|[^0-9])0 - x').hasMatch(s.latex ?? ''),
          isFalse,
          reason: s.title,
        );
        expect(s.explanation, isNot(contains('with 0 ')), reason: s.title);
      }
      // prose and TeX both carry the real equation.
      expect(steps[0].latex, '20 - x = 8');
      expect(steps[1].latex, 'x = 20 - 8');
      expect(steps[0].explanation, contains('20'));
    });

    // BUG A regression: the four documented shapes stay byte-identical.
    test('BUG A regression: documented shapes unchanged', () {
      expect(G6AlgebraEquation('x + 7 = 15').solve().answer, 'x = 8');
      expect(G6AlgebraEquation('3n = 21').solve().answer, 'n = 7');
      expect(G6AlgebraEquation('x/4 = 5').solve().answer, 'x = 20');
      expect(G6AlgebraEquation('15 = x + 7').solve().answer, 'x = 8');
    });
  });

  group('G6 rate: speed, best-buy, meter', () {
    test('R=? D=120 T=2 gives 60', () {
      final eq = G6RateEquation('R=? D=120 T=2');
      expect(eq.validate(), isTrue);
      expect(eq.solve().answer, contains('60'));
      expect(eq.getSteps(), hasLength(3));
    });

    test('D=? R=60 T=2 gives 120', () {
      expect(G6RateEquation('D=? R=60 T=2').solve().answer, contains('120'));
    });

    test('best-buy picks cheaper unit price', () {
      final r = G6RateEquation('compare 500g 120 vs 1kg 220').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('Second'));
    });

    test('meter reading bills use x rate', () {
      final r = G6RateEquation('prev=1250 pres=1380 rate=12').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('130'));
      expect(r.answer, contains('1560.00'));
    });

    test('reversed meter errors', () {
      expect(
        G6RateEquation('prev=1380 pres=1250 rate=12').solve().hasError,
        isTrue,
      );
    });
  });

  group('G6 wave2 LaTeX emission (Batch 1)', () {
    test('percent: every step across all six modes carries TeX', () {
      for (final input in const [
        '25% of 200',
        'R=? P=50 B=200',
        'B=? P=50 R=25%',
        '500 less 20%',
        '500 + 12% tax',
        'P=1000 R=5% T=2',
      ]) {
        final steps = G6PercentEquation(input).getSteps();
        expect(steps, hasLength(3), reason: input);
        for (final s in steps) {
          expect(s.latex, isNotNull, reason: '$input — ${s.title}');
          expect(s.latex!, isNotEmpty, reason: '$input — ${s.title}');
        }
      }
      final of = G6PercentEquation('25% of 200').getSteps();
      expect(of[1].latex, contains(r'\frac'));
      expect(of[2].latex, contains('50'));
    });

    test('ratio: math steps carry TeX, guidance steps stay prose', () {
      final simplify = G6RatioEquation('12:18').getSteps();
      expect(simplify, hasLength(4));
      expect(simplify[3].latex, isNull); // bar-strip guidance
      for (final i in [0, 1, 2]) {
        expect(simplify[i].latex, isNotNull, reason: simplify[i].title);
      }
      final proportion = G6RatioEquation('3/4 = x/20').getSteps();
      expect(proportion, hasLength(4));
      for (final i in [0, 1, 2]) {
        expect(proportion[i].latex, isNull); // generic prose guidance
      }
      expect(proportion[3].latex, isNotNull);
      final direct = G6RatioEquation('direct x=4 y=12').getSteps();
      expect(direct[0].latex, contains('y = kx'));
      expect(direct[1].latex, isNotNull);
      expect(direct[2].latex, isNull); // "Substitute x to predict y."
      final inverse = G6RatioEquation('inverse x=4 y=6').getSteps();
      for (final s in inverse) {
        expect(s.latex, isNotNull, reason: s.title);
      }
      final partitive = G6RatioEquation('divide 120 in 2:3').getSteps();
      expect(partitive, hasLength(4));
      expect(partitive[1].latex, isNull);
      expect(partitive[2].latex, isNotNull);
      expect(partitive[3].latex, isNull); // "Check the sum" guidance
    });

    test('algebra: every step carries the equation / inverse / check TeX', () {
      final cases = {
        'x + 7 = 15': ['x + 7 = 15', r'x = 15 - 7', 'x = 8'],
        '3n = 21': ['3n = 21', r'n = \frac{21}{3}', 'n = 7'],
        'x/4 = 5': [r'\frac{x}{4} = 5', r'x = 5 \times 4', 'x = 20'],
      };
      cases.forEach((input, expected) {
        final steps = G6AlgebraEquation(input).getSteps();
        expect(steps, hasLength(3), reason: input);
        for (var i = 0; i < 3; i++) {
          expect(steps[i].latex, expected[i], reason: '$input step ${i + 1}');
        }
      });
    });

    test('every emitted wave2 TeX line is ASCII (no unicode math)', () {
      for (final eq in <BaseEquation>[
        G6PercentEquation('25% of 200'),
        G6PercentEquation('R=? P=50 B=200'),
        G6PercentEquation('B=? P=50 R=25%'),
        G6PercentEquation('500 less 20%'),
        G6PercentEquation('500 + 12% tax'),
        G6PercentEquation('P=1000 R=5% T=2'),
        G6RatioEquation('12:18'),
        G6RatioEquation('3/4 = x/20'),
        G6RatioEquation('direct x=4 y=12'),
        G6RatioEquation('inverse x=4 y=6'),
        G6RatioEquation('divide 120 in 2:3'),
        G6AlgebraEquation('x + 7 = 15'),
        G6AlgebraEquation('3n = 21'),
        G6AlgebraEquation('x/4 = 5'),
        G6AlgebraEquation('20 - x = 8'),
      ]) {
        for (final s in eq.getSteps()) {
          final tex = s.latex;
          if (tex != null) {
            expect(tex.contains('²'), isFalse, reason: s.title);
            expect(tex.contains('π'), isFalse, reason: s.title);
          }
          for (final line in s.subLatex ?? const <String>[]) {
            expect(line.contains('²'), isFalse, reason: s.title);
            expect(line.contains('π'), isFalse, reason: s.title);
          }
        }
      }
    });

    testWidgets('every emitted wave2 TeX line parses (recording fallback)', (
      tester,
    ) async {
      final cases = <BaseEquation>[
        G6PercentEquation('25% of 200'),
        G6PercentEquation('R=? P=50 B=200'),
        G6PercentEquation('B=? P=50 R=25%'),
        G6PercentEquation('500 less 20%'),
        G6PercentEquation('500 + 12% tax'),
        G6PercentEquation('P=1000 R=5% T=2'),
        G6RatioEquation('12:18'),
        G6RatioEquation('3/4 = x/20'),
        G6RatioEquation('direct x=4 y=12'),
        G6RatioEquation('inverse x=4 y=6'),
        G6RatioEquation('divide 120 in 2:3'),
        G6AlgebraEquation('x + 7 = 15'),
        G6AlgebraEquation('3n = 21'),
        G6AlgebraEquation('x/4 = 5'),
        G6AlgebraEquation('20 - x = 8'),
      ];
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

  group('G6 wave2 LaTeX emission (Batch 2)', () {
    test('rate: math steps carry TeX, unit-conversion/price prose stays', () {
      final speed = G6RateEquation('R=? D=120 T=2').getSteps();
      expect(speed, hasLength(3));
      expect(speed[0].latex, r'R = \frac{D}{T}');
      expect(speed[1].latex, r'R = \frac{120}{2}');
      expect(speed[2].latex, contains('60'));
      final dist = G6RateEquation('D=? R=60 T=2').getSteps();
      expect(dist, hasLength(3));
      expect(dist[0].latex, r'D = R \times T');
      expect(dist[1].latex, r'D = 60 \times 2');
      expect(dist[2].latex, 'D = 120');
      final time = G6RateEquation('T=? D=120 R=40').getSteps();
      expect(time, hasLength(3));
      expect(time[1].latex, r'T = \frac{120}{40}');
      expect(time[2].latex, contains('3'));
    });

    test('rate best-buy + meter carry TeX (peso sign stays prose-only)', () {
      final buy = G6RateEquation('compare 500g 120 vs 1kg 220').getSteps();
      expect(buy, hasLength(3));
      expect(buy[0].latex, isNotNull);
      expect(buy[1].latex, r'\frac{\text{price}}{\text{quantity}}');
      expect(buy[2].latex, isNotNull);
      expect(buy[2].latex!.contains('₱'), isFalse);
      final meter = G6RateEquation('prev=1250 pres=1380 rate=12').getSteps();
      expect(meter, hasLength(3));
      expect(meter[0].latex, '1380 - 1250');
      expect(meter[1].latex, r'130 \times 12');
      expect(meter[2].latex, contains('1560'));
    });

    test(
      'every emitted wave2-batch2 TeX line is ASCII (no unicode/control)',
      () {
        for (final eq in <BaseEquation>[
          G6RateEquation('R=? D=120 T=2'),
          G6RateEquation('D=? R=60 T=2'),
          G6RateEquation('T=? D=120 R=40'),
          G6RateEquation('compare 500g 120 vs 1kg 220'),
          G6RateEquation('prev=1250 pres=1380 rate=12'),
        ]) {
          for (final s in eq.getSteps()) {
            for (final tex in <String?>[s.latex, ...?s.subLatex]) {
              if (tex == null) {
                continue;
              }
              expect(
                tex.codeUnits.every((c) => c >= 0x20 && c <= 0x7e),
                isTrue,
                reason: '$tex (${s.title})',
              );
            }
          }
        }
      },
    );

    testWidgets(
      'every emitted wave2-batch2 TeX line parses (recording fallback)',
      (tester) async {
        final cases = <BaseEquation>[
          G6RateEquation('R=? D=120 T=2'),
          G6RateEquation('D=? R=60 T=2'),
          G6RateEquation('T=? D=120 R=40'),
          G6RateEquation('compare 500g 120 vs 1kg 220'),
          G6RateEquation('prev=1250 pres=1380 rate=12'),
        ];
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
      },
    );
  });
}
