// Cycle 10 Item 1: parser-hardening regression tests for CalculatorEngine.
// Written BEFORE any engine fix to prove the bugs:
//  - '**' preprocess was a no-op (2**3 threw instead of 8),
//  - evaluate() returned result.$1 without verifying the parser consumed
//    the whole string (2pi / 2(3+4) / 5sin(2) silently dropped remainder),
//  - _parseUnary had no unary + (+5 threw).
import 'package:calculus_system/calculator/calculator_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CalculatorEngine ** -> ^ (Cycle 10 Item 1)', () {
    test('2**3 is 8', () {
      expect(CalculatorEngine.evaluate('2**3'), closeTo(8, 1e-9));
    });

    test('3**2 is 9', () {
      expect(CalculatorEngine.evaluate('3**2'), closeTo(9, 1e-9));
    });

    test('(2+3)**2 is 25', () {
      expect(CalculatorEngine.evaluate('(2+3)**2'), closeTo(25, 1e-9));
    });

    test('2**-3 is 0.125', () {
      expect(CalculatorEngine.evaluate('2**-3'), closeTo(0.125, 1e-9));
    });

    test('2**2**3 is right-associative 256', () {
      expect(CalculatorEngine.evaluate('2**2**3'), closeTo(256, 1e-9));
    });
  });

  group('CalculatorEngine whole-string parse (Cycle 10 Item 1)', () {
    test('2pi throws instead of silently returning 2', () {
      expect(() => CalculatorEngine.evaluate('2pi'), throwsFormatException);
    });

    test('2(3+4) throws instead of silently returning 2', () {
      expect(
        () => CalculatorEngine.evaluate('2(3+4)'),
        throwsFormatException,
      );
    });

    test('5sin(2) throws instead of silently returning 5', () {
      expect(
        () => CalculatorEngine.evaluate('5sin(2)'),
        throwsFormatException,
      );
    });

    test('leading/trailing whitespace is consumed, not treated as garbage', () {
      expect(CalculatorEngine.evaluate('  12 / 4  '), closeTo(3, 1e-9));
    });
  });

  group('CalculatorEngine unary + (Cycle 10 Item 1)', () {
    test('+5 is 5', () {
      expect(CalculatorEngine.evaluate('+5'), closeTo(5, 1e-9));
    });

    test('+5*2 is 10', () {
      expect(CalculatorEngine.evaluate('+5*2'), closeTo(10, 1e-9));
    });

    test('+-5 is -5', () {
      expect(CalculatorEngine.evaluate('+-5'), closeTo(-5, 1e-9));
    });

    test('-2**2 is -4 (unary binds looser than ^)', () {
      expect(CalculatorEngine.evaluate('-2**2'), closeTo(-4, 1e-9));
    });
  });
}
