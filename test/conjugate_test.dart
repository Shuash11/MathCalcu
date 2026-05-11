import 'package:flutter_test/flutter_test.dart';
import 'package:calculus_system/Finals/Joashua/Evaluating_limits/By_conjugate/solver/tokenizer.dart';
import 'package:calculus_system/Finals/Joashua/Evaluating_limits/By_conjugate/solver/parser.dart';
import 'package:calculus_system/Finals/Joashua/Evaluating_limits/By_conjugate/solver/solver_engine.dart';

void main() {
  group('By_conjugate Unicode handling', () {
    test('√(x+4) with parens should parse correctly', () {
      final tokenizer = Tokenizer('(√(x + 4) - 2) / x');
      final tokens = tokenizer.tokenize();
      print('Tokens: $tokens');

      final parser = Parser(tokens);
      final ast = parser.parse();
      print('AST tex: ${ast.toTex()}');
      expect(ast.toTex(), contains(r'\sqrt{x + 4}'));
    });

    test('√x without parens should parse correctly', () {
      final tokenizer = Tokenizer('√x + 4 - 2 / x');
      final tokens = tokenizer.tokenize();
      print('Tokens for √x + 4 - 2/x: $tokens');

      final parser = Parser(tokens);
      final ast = parser.parse();
      print('AST tex: ${ast.toTex()}');
      expect(ast.toTex(), contains(r'\sqrt{x}'));
      expect(ast.toTex(), isNot(contains(r'\sqrt{x + 4}')));
    });

    test('(√(x + 4) - 2) / x at x=0 should give 0/0', () {
      final engine = ConjugateSolverEngine();
      final result = engine.solve(ConjugateProblem(
        expression: '(√(x + 4) - 2) / x',
        approachValue: 0,
      ));

      print('Original: ${result.originalExpression}');
      print('Numerator at point: ${result.numeratorAtPoint}');
      print('Denominator at point: ${result.denominatorAtPoint}');
      print('Is indeterminate: ${result.isIndeterminate}');
      print('Solved: ${result.solved}');
      print('Final value: ${result.finalValue}');
      print('Error: ${result.errorMessage}');

      expect(result.isIndeterminate, isTrue);
    });

    test('√x / x at x=0 should give 0/0', () {
      final engine = ConjugateSolverEngine();
      final result = engine.solve(ConjugateProblem(
        expression: '√x / x',
        approachValue: 0,
      ));

      print('Original: ${result.originalExpression}');
      print('Numerator at point: ${result.numeratorAtPoint}');
      print('Denominator at point: ${result.denominatorAtPoint}');
      print('Is indeterminate: ${result.isIndeterminate}');
      print('Solved: ${result.solved}');
      print('Final value: ${result.finalValue}');
      print('Error: ${result.errorMessage}');

      expect(result.isIndeterminate, isTrue);
    });

    test('Mismatched parenthesis gives helpful error', () {
      final engine = ConjugateSolverEngine();
      final result = engine.solve(ConjugateProblem(
        expression: '√(x + 4) − 2) / x',
        approachValue: 0,
      ));

      print('Mismatched error: ${result.errorMessage}');
      expect(result.solved, isFalse);
      expect(result.errorMessage, isNotNull);
      expect(result.errorMessage!.toLowerCase().contains('parenthesis') || result.errorMessage!.contains('Unexpected ")"'), isTrue);
    });
  });
}