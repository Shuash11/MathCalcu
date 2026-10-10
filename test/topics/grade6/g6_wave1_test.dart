// G6 Wave 1 tests: fractions, decimals, GEMDAS, GCF/LCM, integers.
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
  group('G6-1 fractions (M6NS-Ia-86)', () {
    test('1/2 + 3/4 = 1 1/4', () {
      final eq = G6FractionEquation('1/2 + 3/4');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('1 1/4'));
      expect(r.points.single, closeTo(1.25, 1e-9));
      expect(eq.getSteps(), hasLength(4));
    });

    test('2 1/3 - 1 5/6 = 1/2', () {
      final eq = G6FractionEquation('2 1/3 - 1 5/6');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('1/2'));
      expect(r.points.single, closeTo(0.5, 1e-9));
    });

    test('3/4 x 1/2 multiplies across', () {
      final r = G6FractionEquation('3/4 × 1/2').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('3/8'));
    });

    test('zero denominator errors', () {
      final r = G6FractionEquation('1/0 + 1/2').solve();
      expect(r.hasError, isTrue);
      expect(r.errorMessage, contains('zero'));
    });

    test('empty input errors with example', () {
      final eq = G6FractionEquation('   ');
      expect(eq.validate(), isFalse);
      expect(eq.solve().hasError, isTrue);
    });
  });

  group('G6-2 decimals (M6NS-Ib-106)', () {
    test('3.25 x 1.2 = 3.9 terminating', () {
      final eq = G6DecimalEquation('3.25 × 1.2');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('3.9'));
      expect(r.answer, contains('terminating'));
      expect(eq.getSteps(), hasLength(4));
    });

    test('7.5 / 0.25 = 30', () {
      final r = G6DecimalEquation('7.5 ÷ 0.25').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('30'));
    });

    test('1.0 / 3.0 flags repeating', () {
      final r = G6DecimalEquation('1.0 ÷ 3.0').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('repeating'));
    });

    test('zero divisor errors', () {
      expect(G6DecimalEquation('5.5 ÷ 0.0').solve().hasError, isTrue);
    });

    test('integers-only rejected with hint', () {
      final eq = G6DecimalEquation('5 + 3');
      expect(eq.validate(), isFalse);
    });
  });

  group('G6-5 GEMDAS (M6NS-IIa-148)', () {
    test('8 + 2 x 5 = 18', () {
      final eq = G6GemdasEquation('8 + 2 × 5');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, '18');
      expect(eq.getSteps(), hasLength(4));
    });

    test('(10 - 2)^2 / 4 = 16', () {
      final r = G6GemdasEquation('(10 - 2)^2 ÷ 4').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, '16');
    });

    test('unbalanced parens error', () {
      final eq = G6GemdasEquation('(8 + 2 × 5');
      expect(eq.validate(), isFalse);
      expect(eq.solve().errorMessage, contains('Parentheses'));
    });

    test('letters rejected', () {
      expect(G6GemdasEquation('8 + x').validate(), isFalse);
    });
  });

  group('GCF / LCM', () {
    test('GCF(12, 18) = 6', () {
      final eq = G6GcfLcmEquation('GCF(12, 18)');
      expect(eq.validate(), isTrue);
      expect(eq.solve().answer, contains('6'));
      expect(eq.getSteps(), hasLength(4));
    });

    test('LCM(4, 6) = 12', () {
      expect(G6GcfLcmEquation('lcm 4 6').solve().answer, contains('12'));
    });

    test('non-positive rejected', () {
      expect(G6GcfLcmEquation('GCF(0, 5)').validate(), isFalse);
    });
  });

  group('G6-7 integers (M6NS-IIIb-150)', () {
    test('-5 + 8 = 3 with number-line data', () {
      final eq = G6IntegerEquation('-5 + 8');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('3'));
      expect(r.customData?.first['jumps'], isNotEmpty);
      expect(eq.getSteps(), hasLength(4));
    });

    test('compare -3 < 2 is True', () {
      final r = G6IntegerEquation('-3 < 2').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('True'));
    });

    test('decimals rejected as non-integers', () {
      final eq = G6IntegerEquation('-5.5 + 8');
      expect(eq.validate(), isFalse);
      expect(eq.solve().errorMessage, contains('Integers only'));
    });

    test('divide by zero errors', () {
      expect(G6IntegerEquation('5 ÷ 0').solve().hasError, isTrue);
    });
  });

  group('G6 wave1 LaTeX emission (Batch 1)', () {
    test('fractions: math steps carry TeX, the ×/÷ LCD step stays prose', () {
      final add = G6FractionEquation('1/2 + 3/4').getSteps();
      expect(add, hasLength(4));
      for (final s in add) {
        expect(s.latex, isNotNull, reason: s.title);
        expect(s.latex!, isNotEmpty, reason: s.title);
      }
      expect(add[1].latex, contains(r'\frac'));
      final mul = G6FractionEquation('3/4 × 1/2').getSteps();
      expect(mul, hasLength(4));
      expect(mul[1].latex, isNull); // "No LCD needed…" prose guidance
      for (final i in [0, 2, 3]) {
        expect(mul[i].latex, isNotNull, reason: mul[i].title);
        expect(mul[i].latex!, isNotEmpty, reason: mul[i].title);
      }
    });

    test(
      'decimals: math steps carry TeX, "compute" prose step stays prose',
      () {
        final steps = G6DecimalEquation('3.25 × 1.2').getSteps();
        expect(steps, hasLength(4));
        expect(steps[1].latex, isNull); // "Then handle the decimal places…"
        for (final i in [0, 2, 3]) {
          expect(steps[i].latex, isNotNull, reason: steps[i].title);
          expect(steps[i].latex!, isNotEmpty, reason: steps[i].title);
        }
        expect(steps[3].latex, contains(r'\frac'));
      },
    );

    test('gemdas: only stages with work carry TeX', () {
      final simple = G6GemdasEquation('8 + 2 × 5').getSteps();
      expect(simple, hasLength(4));
      expect(simple[0].latex, isNull); // no grouping symbols
      expect(simple[1].latex, isNull); // no exponents
      expect(simple[2].latex, isNotNull);
      expect(simple[3].latex, isNotNull);
      final grouped = G6GemdasEquation('(10 - 2)^2 ÷ 4').getSteps();
      expect(grouped[0].latex, isNotNull); // (10-2) = 8
      // The engine's exponent scan needs a digit before '^' — "(10-2)^2"
      // does not match, so the exponent stage is genuinely empty (prose).
      expect(grouped[1].latex, isNull);
      expect(grouped[2].latex, isNotNull); // 2 \div 4
      expect(grouped[3].latex, isNotNull);
    });

    test('every emitted wave1 TeX line is ASCII (no unicode math)', () {
      for (final eq in <BaseEquation>[
        G6FractionEquation('1/2 + 3/4'),
        G6FractionEquation('2 1/3 - 1 5/6'),
        G6FractionEquation('3/4 × 1/2'),
        G6FractionEquation('5/6 ÷ 2/3'),
        G6DecimalEquation('3.25 × 1.2'),
        G6DecimalEquation('7.5 ÷ 0.25'),
        G6DecimalEquation('1.0 ÷ 3.0'),
        G6GemdasEquation('8 + 2 × 5'),
        G6GemdasEquation('(10 - 2)^2 ÷ 4'),
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

    testWidgets('every emitted wave1 TeX line parses (recording fallback)', (
      tester,
    ) async {
      final cases = <BaseEquation>[
        G6FractionEquation('1/2 + 3/4'),
        G6FractionEquation('2 1/3 - 1 5/6'),
        G6FractionEquation('3/4 × 1/2'),
        G6FractionEquation('5/6 ÷ 2/3'),
        G6DecimalEquation('3.25 × 1.2'),
        G6DecimalEquation('7.5 ÷ 0.25'),
        G6DecimalEquation('1.0 ÷ 3.0'),
        G6DecimalEquation('0.5 + 0.25'),
        G6GemdasEquation('8 + 2 × 5'),
        G6GemdasEquation('(10 - 2)^2 ÷ 4'),
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

  group('G6 wave1 LaTeX emission (Batch 2)', () {
    test(
      'integers: math steps carry TeX, direction/count steps stay prose',
      () {
        final arith = G6IntegerEquation('-5 + 8').getSteps();
        expect(arith, hasLength(4));
        expect(arith[0].latex, isNotNull); // start position
        expect(arith[1].latex, isNull); // face-direction guidance
        expect(arith[2].latex, isNull); // counting guidance
        expect(arith[3].latex, '-5 + 8 = 3');
        final cmp = G6IntegerEquation('-3 < 2').getSteps();
        expect(cmp, hasLength(4));
        expect(cmp[0].latex, isNotNull);
        expect(cmp[1].latex, isNull);
        expect(cmp[2].latex, contains(r'\left|'));
        expect(cmp[3].latex, '-3 < 2');
        final mul = G6IntegerEquation('-3 × -4').getSteps();
        expect(mul[3].latex, r'-3 \times -4 = 12');
      },
    );

    test('gcf/lcm: math steps carry TeX + prime-factor sub-lines', () {
      final gcf = G6GcfLcmEquation('GCF(12, 18)').getSteps();
      expect(gcf, hasLength(4));
      for (final s in gcf) {
        expect(s.latex, isNotNull, reason: s.title);
        expect(s.latex!, isNotEmpty, reason: s.title);
      }
      expect(gcf[0].latex, r'\{12, 18\}');
      expect(gcf[2].latex, contains(r'\gcd'));
      expect(gcf[2].latex, contains('6'));
      expect(gcf[1].subLatex, isNotNull);
      expect(gcf[1].subLatex!, contains(r'12 = 2^{2} \cdot 3'));
      final lcm = G6GcfLcmEquation('lcm 4 6').getSteps();
      expect(lcm[2].latex, contains('LCM'));
      expect(lcm[2].latex, contains('12'));
    });

    test(
      'every emitted wave1-batch2 TeX line is ASCII (no unicode/control)',
      () {
        for (final eq in <BaseEquation>[
          G6IntegerEquation('-5 + 8'),
          G6IntegerEquation('7 - 12'),
          G6IntegerEquation('-3 × -4'),
          G6IntegerEquation('5 ÷ 2'),
          G6IntegerEquation('-3 < 2'),
          G6IntegerEquation('Compare -8 < -3'),
          G6GcfLcmEquation('GCF(12, 18)'),
          G6GcfLcmEquation('lcm 4 6'),
          G6GcfLcmEquation('gcd 20, 30'),
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
      'every emitted wave1-batch2 TeX line parses (recording fallback)',
      (tester) async {
        final cases = <BaseEquation>[
          G6IntegerEquation('-5 + 8'),
          G6IntegerEquation('7 - 12'),
          G6IntegerEquation('-3 × -4'),
          G6IntegerEquation('5 ÷ 2'),
          G6IntegerEquation('-3 < 2'),
          G6IntegerEquation('Compare -8 < -3'),
          G6GcfLcmEquation('GCF(12, 18)'),
          G6GcfLcmEquation('lcm 4 6'),
          G6GcfLcmEquation('gcd 20, 30'),
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
