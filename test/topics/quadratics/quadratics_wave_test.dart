// Quadratics wave tests (Cycle 8 P1-2): registry wiring + solve smoke.
import 'package:calculus_system/topics/quadratics/solvers/quadratics_solver_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QuadraticsSolverRegistry wiring', () {
    test('5 specs, unique ids, byId round-trip', () {
      expect(QuadraticsSolverRegistry.specs, hasLength(5));
      final ids = QuadraticsSolverRegistry.specs.map((s) => s.id).toList();
      expect(ids.toSet(), hasLength(5));
      for (final s in QuadraticsSolverRegistry.specs) {
        expect(QuadraticsSolverRegistry.byId(s.id), isNotNull);
      }
      expect(QuadraticsSolverRegistry.byId('nope'), isNull);
    });

    test('each spec creates a working equation', () {
      const inputs = {
        'g9-quadratic-formula': 'x^2 - 5x + 6 = 0',
        'g9-radical-equations': 'sqrt(x + 5) = 3',
        'g9-variation': 'direct, x = 2, y = 10, x = 5',
        'g10-sequences': 'arith a1 = 2, d = 3, n = 5',
        'g10-polynomial-division': '(x^3 + 2x^2 - 5x + 1)/(x - 1)',
      };
      for (final spec in QuadraticsSolverRegistry.specs) {
        final eq = spec.create(inputs[spec.id]!);
        expect(eq.validate(), isTrue, reason: spec.id);
        final r = eq.solve();
        expect(r.hasError, isFalse, reason: spec.id);
        expect(eq.getSteps(), isNotEmpty, reason: spec.id);
      }
    });

    test('x^2 - 5x + 6 = 0 gives roots 2 and 3', () {
      final r = QuadraticsSolverRegistry.byId('g9-quadratic-formula')!
          .create('x^2 - 5x + 6 = 0')
          .solve();
      expect(r.answer, contains('2'));
      expect(r.answer, contains('3'));
    });

    test('sqrt(x + 5) = 3 gives x = 4', () {
      final r = QuadraticsSolverRegistry.byId('g9-radical-equations')!
          .create('sqrt(x + 5) = 3')
          .solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('4'));
    });

    test('arith a1=2 d=3 n=5 gives a(5)=14 S(5)=40', () {
      final r = QuadraticsSolverRegistry.byId('g10-sequences')!
          .create('arith a1 = 2, d = 3, n = 5')
          .solve();
      expect(r.answer, contains('14'));
      expect(r.answer, contains('40'));
    });

    test('garbage never throws, empty fails validation', () {
      for (final spec in QuadraticsSolverRegistry.specs) {
        final bad = spec.create('hello world');
        expect(() => bad.solve(), returnsNormally);
        expect(() => bad.getSteps(), returnsNormally);
        expect(spec.create('   ').validate(), isFalse);
      }
    });
  });
}
