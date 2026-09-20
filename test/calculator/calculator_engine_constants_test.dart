// Cycle 10 Item 9: constant + factorial support tests for CalculatorEngine.
// Written BEFORE the fix to prove the gaps:
//  - 'e' (Euler's number) threw FormatException despite 'pi' being supported,
//  - 'n!' threw FormatException instead of evaluating small factorials.
import 'dart:math' as math;
import 'package:calculus_system/calculator/calculator_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CalculatorEngine e constant (Cycle 10 Item 9)', () {
    test('e is Euler\'s number', () {
      expect(CalculatorEngine.evaluate('e'), closeTo(math.e, 1e-9));
    });

    test('e^2 is e squared', () {
      expect(CalculatorEngine.evaluate('e^2'), closeTo(math.e * math.e, 1e-9));
    });

    test('pi + e works alongside pi', () {
      expect(
        CalculatorEngine.evaluate('pi + e'),
        closeTo(math.pi + math.e, 1e-9),
      );
    });

    test('exp(1) is still the function, not the constant', () {
      expect(CalculatorEngine.evaluate('exp(1)'), closeTo(math.e, 1e-9));
    });
  });

  group('CalculatorEngine factorial (Cycle 10 Item 9)', () {
    test('5! is 120', () {
      expect(CalculatorEngine.evaluate('5!'), closeTo(120, 1e-9));
    });

    test('0! is 1', () {
      expect(CalculatorEngine.evaluate('0!'), closeTo(1, 1e-9));
    });

    test('3! + 4! is 30', () {
      expect(CalculatorEngine.evaluate('3! + 4!'), closeTo(30, 1e-9));
    });

    test('2 * 3! is 12', () {
      expect(CalculatorEngine.evaluate('2 * 3!'), closeTo(12, 1e-9));
    });

    test('fractional 1.5! still throws', () {
      expect(() => CalculatorEngine.evaluate('1.5!'), throwsFormatException);
    });

    test('171! (beyond double range) still throws', () {
      expect(() => CalculatorEngine.evaluate('171!'), throwsFormatException);
    });
  });
}
