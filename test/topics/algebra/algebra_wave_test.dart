// Algebra wave tests (Cycle 8 P1-2): every registry spec resolves,
// validates its hint example, solves without throwing, and emits steps.
import 'package:calculus_system/topics/algebra/solvers/algebra_solver_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AlgebraSolverRegistry wiring', () {
    test('4 specs, unique ids, byId round-trip', () {
      expect(AlgebraSolverRegistry.specs, hasLength(4));
      final ids = AlgebraSolverRegistry.specs.map((s) => s.id).toList();
      expect(ids.toSet(), hasLength(4));
      for (final s in AlgebraSolverRegistry.specs) {
        expect(AlgebraSolverRegistry.byId(s.id), isNotNull);
      }
      expect(AlgebraSolverRegistry.byId('nope'), isNull);
    });

    test('each spec creates a working equation', () {
      const inputs = {
        'g7-linear-equations': '2x - 5 = 9',
        'g8-factoring': 'x^2 + 5x + 6',
        'g8-rational-equations': '1/x + 1/2 = 3/4',
        'g8-systems': 'x + y = 5, x - y = 1',
      };
      for (final spec in AlgebraSolverRegistry.specs) {
        final eq = spec.create(inputs[spec.id]!);
        expect(eq.validate(), isTrue, reason: spec.id);
        final r = eq.solve();
        expect(r.hasError, isFalse, reason: spec.id);
        expect(eq.getSteps(), isNotEmpty, reason: spec.id);
      }
    });

    test('2x - 5 = 9 gives x = 7', () {
      final eq = AlgebraSolverRegistry.byId('g7-linear-equations')!
          .create('2x - 5 = 9');
      expect(eq.solve().answer, contains('7'));
    });

    test('x^2 + 5x + 6 factors to (x+2)(x+3)', () {
      final r = AlgebraSolverRegistry.byId('g8-factoring')!
          .create('x^2 + 5x + 6')
          .solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('(x+2)(x+3)'));
    });

    test('system x+y=5, x-y=1 gives (3, 2)', () {
      final r = AlgebraSolverRegistry.byId('g8-systems')!
          .create('x + y = 5, x - y = 1')
          .solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('3'));
      expect(r.answer, contains('2'));
    });

    test('1/x + 1/2 = 3/4 gives x = 4 (fractional RHS)', () {
      final r = AlgebraSolverRegistry.byId('g8-rational-equations')!
          .create('1/x + 1/2 = 3/4')
          .solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('4'));
    });

    test('garbage never throws, empty fails validation', () {
      for (final spec in AlgebraSolverRegistry.specs) {
        final bad = spec.create('hello world');
        expect(() => bad.solve(), returnsNormally);
        expect(() => bad.getSteps(), returnsNormally);
        expect(spec.create('   ').validate(), isFalse);
      }
    });
  });
}
