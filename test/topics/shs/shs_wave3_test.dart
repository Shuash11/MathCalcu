// SHS wave 3 tests (Cycle 8 P1-2): all 10 registry specs resolve and
// solve their hint example; garbage never throws.
import 'package:calculus_system/topics/shs/solvers/shs_solver_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ShsSolverRegistry wiring', () {
    test('10 specs, unique ids, byId round-trip', () {
      expect(ShsSolverRegistry.specs, hasLength(10));
      final ids = ShsSolverRegistry.specs.map((s) => s.id).toList();
      expect(ids.toSet(), hasLength(10));
      for (final s in ShsSolverRegistry.specs) {
        expect(ShsSolverRegistry.byId(s.id), isNotNull);
      }
      expect(ShsSolverRegistry.byId('nope'), isNull);
    });

    test('each spec creates a working equation', () {
      const inputs = {
        'g9-trig-ratios': 'sin 30',
        'g11-logarithms': '2^x = 32',
        'g11-interest': 'P = 10000, r = 5%, t = 2, compound',
        'g11-inverse-functions': 'f(x) = 2x + 3',
        'g11-rational-inequality': '(x - 1)/(x + 2) > 0',
        'g11-trig-equations': 'sin x = 1/2',
        'g11-trig-identities': 'prove: sin^2 + cos^2 = 1',
        'g12-definite-integral': 'def a = 0, b = 2, f = x^2',
        'g12-optimization': 'max xy, x + y = 20',
        'college-lhopital': 'lim x->0 sin(x)/x',
      };
      for (final spec in ShsSolverRegistry.specs) {
        final eq = spec.create(inputs[spec.id]!);
        expect(eq.validate(), isTrue, reason: spec.id);
        final r = eq.solve();
        expect(r.hasError, isFalse, reason: spec.id);
        expect(eq.getSteps(), isNotEmpty, reason: spec.id);
      }
    });

    test('sin x = 1/2 solves on [0, 2pi)', () {
      final r = ShsSolverRegistry.byId('g11-trig-equations')!
          .create('sin x = 1/2')
          .solve();
      expect(r.hasError, isFalse);
      expect(r.points, isNotEmpty);
    });

    test('lhopital lim x->0 sin(x)/x = 1', () {
      final r = ShsSolverRegistry.byId('college-lhopital')!
          .create('lim x->0 sin(x)/x')
          .solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('1'));
    });

    test('garbage never throws, empty fails validation', () {
      for (final spec in ShsSolverRegistry.specs) {
        final bad = spec.create('hello world');
        expect(() => bad.solve(), returnsNormally);
        expect(() => bad.getSteps(), returnsNormally);
        expect(spec.create('   ').validate(), isFalse);
      }
    });
  });
}
