// G6 Wave 1 tests: fractions, decimals, GEMDAS, GCF/LCM, integers.
import 'package:calculus_system/topics/grade6/solvers/grade6_equations.dart';
import 'package:flutter_test/flutter_test.dart';

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
}
