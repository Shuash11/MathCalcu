// Task 7 regression: CalculatorEngine must skip whitespace between
// tokens instead of stopping at the first space. Preserves existing
// behavior for compact expressions.
import 'package:calculus_system/calculator/calculator_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CalculatorEngine whitespace handling', () {
    test('compact expression still works', () {
      expect(CalculatorEngine.evaluate('2+3*4'), closeTo(14, 1e-9));
    });

    test('spaces around + and *', () {
      expect(CalculatorEngine.evaluate('8 + 2 * 5'), closeTo(18, 1e-9));
    });

    test('spaces inside parentheses and around operator', () {
      expect(
        CalculatorEngine.evaluate('( 2 + 3 ) * 4'),
        closeTo(20, 1e-9),
      );
    });

    test('space between function name and paren', () {
      expect(CalculatorEngine.evaluate('sqrt (16)'), closeTo(4, 1e-9));
    });

    test('spaces around division and subtraction', () {
      expect(
        CalculatorEngine.evaluate('10 - 2 / 2'),
        closeTo(9, 1e-9),
      );
    });

    test('tabs and newlines are skipped', () {
      expect(CalculatorEngine.evaluate('2\t+\n3'), closeTo(5, 1e-9));
    });

    test('leading and trailing spaces', () {
      expect(CalculatorEngine.evaluate('  7 - 2  '), closeTo(5, 1e-9));
    });

    test('exponent with spaces', () {
      expect(
        CalculatorEngine.evaluate('(10 - 2) ^ 2 / 4'),
        closeTo(16, 1e-9),
      );
    });
  });
}
