// ModMath wave-1 tests (Cycle 8): M1 propositional, M2 sets,
// M3 nPr/nCr, M4 bases, M5 det/inverse, M6 mod arithmetic.
import 'package:calculus_system/topics/modmat/solvers/modmat_equations.dart';
import 'package:calculus_system/topics/modmat/solvers/modmat_solver_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ModmatSolverRegistry wiring', () {
    test('14 specs, unique ids, byId round-trip', () {
      expect(ModmatSolverRegistry.specs, hasLength(14));
      final ids = ModmatSolverRegistry.specs.map((s) => s.id).toList();
      expect(ids.toSet(), hasLength(14));
      for (final s in ModmatSolverRegistry.specs) {
        expect(ModmatSolverRegistry.byId(s.id), isNotNull);
      }
      expect(ModmatSolverRegistry.byId('nope'), isNull);
    });
  });

  group('M1 propositional (truth tables)', () {
    test('p -> q is a contingency with 4 rows', () {
      final eq = M1PropositionalEquation('p -> q');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('contingency'));
      expect(r.points, hasLength(4));
      expect(eq.getSteps(), hasLength(4));
    });

    test('p OR NOT p is a tautology', () {
      final r = M1PropositionalEquation('p OR NOT p').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('tautology'));
    });

    test('p AND NOT p is a contradiction', () {
      final r = M1PropositionalEquation('p AND NOT p').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('contradiction'));
    });

    test('garbage + empty never throw', () {
      final eq = M1PropositionalEquation('hello');
      expect(eq.validate(), isFalse);
      expect(() => eq.solve(), returnsNormally);
      expect(() => eq.getSteps(), returnsNormally);
      expect(M1PropositionalEquation('   ').validate(), isFalse);
    });
  });

  group('M2 sets', () {
    test('{1,2,3} UNION {3,4} = {1,2,3,4}', () {
      final eq = M2SetsEquation('A={1,2,3} B={3,4} UNION');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('1, 2, 3, 4'));
      expect(eq.getSteps(), hasLength(3));
    });

    test('INTERSECT keeps shared elements', () {
      final r = M2SetsEquation('{1,2,3} INTERSECT {2,3,9}').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('2, 3'));
    });

    test('DIFF drops B elements', () {
      final r = M2SetsEquation('{1,2,3} DIFF {2}').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('1, 3'));
    });

    test('SUBSET True case', () {
      final r = M2SetsEquation('{1,2} SUBSET {1,2,3}').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('True'));
    });

    test('CARD counts, POWER sizes 2^n', () {
      expect(M2SetsEquation('{1,2,3} CARD').solve().answer, contains('3'));
      expect(M2SetsEquation('{1,2,3} POWER').solve().answer, contains('8'));
    });

    test('bare input without braces rejected', () {
      final eq = M2SetsEquation('hello world');
      expect(eq.validate(), isFalse);
      expect(() => eq.solve(), returnsNormally);
    });
  });

  group('M3 combinatorics (kills g10-combinatorics stub)', () {
    test('C(5,2) = 10', () {
      final eq = M3CombinatoricsEquation('C(5,2)');
      expect(eq.validate(), isTrue);
      expect(eq.solve().answer, 'C(5,2) = 10');
      expect(eq.getSteps(), hasLength(3));
    });

    test('P(5,2) = 20', () {
      expect(M3CombinatoricsEquation('P(5,2)').solve().answer, 'P(5,2) = 20');
    });

    test('5! = 120', () {
      expect(M3CombinatoricsEquation('5!').solve().answer, contains('120'));
    });

    test('r > n rejected', () {
      expect(M3CombinatoricsEquation('C(3,5)').validate(), isFalse);
    });

    test('garbage never throws', () {
      final eq = M3CombinatoricsEquation('xyz');
      expect(eq.validate(), isFalse);
      expect(() => eq.solve(), returnsNormally);
      expect(() => eq.getSteps(), returnsNormally);
    });
  });

  group('M4 base conversion', () {
    test('1011 base2 to base10 = 11', () {
      final eq = M4BaseConversionEquation('1011 base2 to base10');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('11 (base 10)'));
      expect(eq.getSteps(), hasLength(3));
    });

    test('FF hex to dec = 255', () {
      final r = M4BaseConversionEquation('FF hex to dec').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('255'));
    });

    test('255 dec to hex = FF', () {
      final r = M4BaseConversionEquation('255 dec to hex').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('FF'));
    });

    test('binary digits 2 rejected', () {
      expect(
          M4BaseConversionEquation('102 base2 to base10').validate(), isFalse);
    });

    test('garbage never throws', () {
      final eq = M4BaseConversionEquation('hello');
      expect(eq.validate(), isFalse);
      expect(() => eq.solve(), returnsNormally);
    });
  });

  group('M5 matrices (kills college-matrices stub)', () {
    test('det [[1,2],[3,4]] = -2', () {
      final eq = M5MatrixEquation('det [[1,2],[3,4]]');
      expect(eq.validate(), isTrue);
      expect(eq.solve().answer, contains('-2'));
      expect(eq.getSteps(), hasLength(3));
    });

    test('inv [[2,0],[0,2]] halves', () {
      final r = M5MatrixEquation('inv [[2,0],[0,2]]').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('0.5'));
    });

    test('3x3 det of identity = 1', () {
      final r = M5MatrixEquation('det [[1,0,0],[0,1,0],[0,0,1]]').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('1'));
    });

    test('singular matrix has no inverse', () {
      final r = M5MatrixEquation('inv [[1,2],[2,4]]').solve();
      expect(r.hasError, isTrue);
      expect(r.errorMessage, contains('Singular'));
    });

    test('garbage never throws', () {
      final eq = M5MatrixEquation('blah');
      expect(eq.validate(), isFalse);
      expect(() => eq.solve(), returnsNormally);
      expect(() => eq.getSteps(), returnsNormally);
    });
  });

  group('M6 modular (extends g6_gcf_lcm)', () {
    test('17 mod 5 = 2', () {
      final eq = M6ModularEquation('17 mod 5');
      expect(eq.validate(), isTrue);
      expect(eq.solve().answer, contains('2'));
      expect(eq.getSteps(), hasLength(3));
    });

    test('3^4 mod 5 = 1', () {
      final r = M6ModularEquation('3^4 mod 5').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('1'));
    });

    test('inv 3 mod 7 = 5', () {
      final r = M6ModularEquation('inv 3 mod 7').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('5'));
    });

    test('(12 + 30) mod 7 = 0', () {
      final r = M6ModularEquation('(12 + 30) mod 7').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('0'));
    });

    test('no inverse when gcd != 1', () {
      final r = M6ModularEquation('inv 2 mod 4').solve();
      expect(r.hasError, isTrue);
      expect(r.errorMessage, contains('No inverse'));
    });

    test('modulus 1 rejected', () {
      expect(M6ModularEquation('5 mod 1').validate(), isFalse);
    });

    test('garbage never throws', () {
      final eq = M6ModularEquation('xyz');
      expect(eq.validate(), isFalse);
      expect(() => eq.solve(), returnsNormally);
      expect(() => eq.getSteps(), returnsNormally);
    });
  });
}
