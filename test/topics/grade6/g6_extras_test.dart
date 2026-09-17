// G6 extras tests (Cycle 8 P2-1): GCF/LCM + Rate reachable via the
// backend registry (barrel already exports both engines).
import 'package:calculus_system/topics/grade6/solvers/g6_extras_registry.dart';
import 'package:calculus_system/topics/grade6/solvers/grade6_equations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('G6ExtrasRegistry wiring', () {
    test('2 specs, byId round-trip', () {
      expect(G6ExtrasRegistry.specs, hasLength(2));
      expect(G6ExtrasRegistry.byId('g6-gcf-lcm'), isNotNull);
      expect(G6ExtrasRegistry.byId('g6-rate'), isNotNull);
      expect(G6ExtrasRegistry.byId('nope'), isNull);
    });

    test('GCF(12, 18) = 6 via registry', () {
      final eq = G6ExtrasRegistry.byId('g6-gcf-lcm')!.create('GCF(12, 18)');
      expect(eq, isA<G6GcfLcmEquation>());
      expect(eq.validate(), isTrue);
      expect(eq.solve().answer, contains('6'));
      expect(eq.getSteps(), hasLength(4));
    });

    test('LCM(4, 6) = 12 via registry', () {
      final r = G6ExtrasRegistry.byId('g6-gcf-lcm')!.create('lcm 4 6').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('12'));
    });

    test('R=? D=120 T=2 gives 60 via registry', () {
      final eq = G6ExtrasRegistry.byId('g6-rate')!.create('R=? D=120 T=2');
      expect(eq, isA<G6RateEquation>());
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('60'));
      expect(eq.getSteps(), hasLength(3));
    });

    test('best-buy compare picks cheaper offer', () {
      final r = G6ExtrasRegistry.byId('g6-rate')!
          .create('compare 500g 120 vs 1kg 220')
          .solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('cheaper'));
    });

    test('meter reading bills use x rate', () {
      final r = G6ExtrasRegistry.byId('g6-rate')!
          .create('prev=1250 pres=1380 rate=12')
          .solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('130'));
    });

    test('garbage never throws', () {
      for (final spec in G6ExtrasRegistry.specs) {
        final bad = spec.create('hello world');
        expect(() => bad.solve(), returnsNormally);
        expect(() => bad.getSteps(), returnsNormally);
        expect(spec.create('   ').validate(), isFalse);
      }
    });
  });
}
