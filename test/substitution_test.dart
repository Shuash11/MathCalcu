import 'package:flutter_test/flutter_test.dart';
import 'package:calculus_system/Finals/Joashua/Evaluating_limits/By_Substitution/solver/substitution_engine.dart';
import 'package:calculus_system/Finals/Joashua/Evaluating_limits/By_Substitution/solver/tokenizer.dart';
import 'package:calculus_system/Finals/Joashua/Evaluating_limits/By_Substitution/solver/smart_parser.dart';
import 'package:calculus_system/Finals/Joashua/Evaluating_limits/By_Substitution/solver/expressions_evaluator.dart';

void main() {
  group('SubstitutionEngine', () {
    final engine = SubstitutionEngine();

    group('Basic expressions', () {
      test('x -> 2 of x should equal 2', () {
        final result =
            engine.solve(LimitProblem(expression: 'x', approachValue: 2));
        expect(result.substitutionSucceeded, isTrue);
        expect(result.finalValue, equals(2.0));
      });

      test('x -> 3 of x^2 should equal 9', () {
        final result =
            engine.solve(LimitProblem(expression: 'x^2', approachValue: 3));
        expect(result.substitutionSucceeded, isTrue);
        expect(result.finalValue, equals(9.0));
      });

      test('x -> 1 of 2x + 3 should equal 5', () {
        final result =
            engine.solve(LimitProblem(expression: '2x+3', approachValue: 1));
        expect(result.substitutionSucceeded, isTrue);
        expect(result.finalValue, equals(5.0));
      });

      test('x -> 4 of x^2 - 2x + 1 should equal 9', () {
        final result = engine
            .solve(LimitProblem(expression: 'x^2-2x+1', approachValue: 4));
        expect(result.substitutionSucceeded, isTrue);
        expect(result.finalValue, equals(9.0));
      });
    });

    group('Fraction expressions', () {
      test('x -> 2 of 1/x should equal 0.5', () {
        final result =
            engine.solve(LimitProblem(expression: '1/x', approachValue: 2));
        expect(result.substitutionSucceeded, isTrue);
        expect(result.finalValue, equals(0.5));
      });

      test('x -> 3 of (x+1)/(x-1) should equal 2', () {
        final result = engine
            .solve(LimitProblem(expression: '(x+1)/(x-1)', approachValue: 3));
        expect(result.substitutionSucceeded, isTrue);
        expect(result.finalValue, equals(2.0));
      });

      test('x -> 0 of 1/x should be infinity', () {
        final result =
            engine.solve(LimitProblem(expression: '1/x', approachValue: 0));
        expect(result.substitutionSucceeded, isFalse);
        expect(result.classification,
            equals(LimitClassification.positiveInfinity));
      });

      test('x -> 1 of x/(x+1) should equal 0.5', () {
        final result =
            engine.solve(LimitProblem(expression: 'x/(x+1)', approachValue: 1));
        expect(result.substitutionSucceeded, isTrue);
        expect(result.finalValue, equals(0.5));
      });
    });

    group('Indeterminate forms (0/0)', () {
      test('x -> 1 of (x-1)/(x-1) should be indeterminate', () {
        final result = engine
            .solve(LimitProblem(expression: '(x-1)/(x-1)', approachValue: 1));
        expect(result.substitutionSucceeded, isFalse);
        expect(result.needsDifferentMethod, isTrue);
        expect(result.classification, equals(LimitClassification.undefined));
      });

      test('x -> 2 of (x^2-4)/(x-2) should be indeterminate', () {
        final result = engine
            .solve(LimitProblem(expression: '(x^2-4)/(x-2)', approachValue: 2));
        expect(result.substitutionSucceeded, isFalse);
        expect(result.needsDifferentMethod, isTrue);
      });

      test('x -> 0 of (x)/(x) should be indeterminate', () {
        final result =
            engine.solve(LimitProblem(expression: 'x/x', approachValue: 0));
        expect(result.substitutionSucceeded, isFalse);
        expect(result.needsDifferentMethod, isTrue);
      });
    });

    group('Complex expressions', () {
      test('x -> 0 of sqrt(x+1) should equal 1', () {
        final result = engine
            .solve(LimitProblem(expression: 'sqrt(x+1)', approachValue: 0));
        expect(result.substitutionSucceeded, isTrue);
        expect(result.finalValue, closeTo(1.0, 0.0001));
      });

      test('x -> 5 of abs(x-5) should equal 0', () {
        final result = engine
            .solve(LimitProblem(expression: 'abs(x-5)', approachValue: 5));
        expect(result.substitutionSucceeded, isTrue);
        expect(result.finalValue, equals(0.0));
      });

      test('x -> -1 of sqrt(x+2) should equal 1', () {
        final result = engine
            .solve(LimitProblem(expression: 'sqrt(x+2)', approachValue: -1));
        expect(result.substitutionSucceeded, isTrue);
        expect(result.finalValue, closeTo(1.0, 0.0001));
      });
    });

    group('Negative infinity limits', () {
      test('x -> 0+ of 1/x should be positive infinity', () {
        final result =
            engine.solve(LimitProblem(expression: '1/x', approachValue: 0));
        expect(result.classification,
            equals(LimitClassification.positiveInfinity));
      });
    });
  });
}
