// ModMath wave-2 tests (Cycle 9 F2): M7 predicate, M8 relations,
// M9 real analysis, M10 algebraic structures, M11 graph basics,
// M12 proof, M13 topology, M14 advanced graph + college-stats (F4).
import 'package:calculus_system/topics/college/solvers/college_solver_registry.dart';
import 'package:calculus_system/topics/modmat/solvers/modmat_equations.dart';
import 'package:calculus_system/topics/modmat/solvers/modmat_solver_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ModmatSolverRegistry wave 2 wiring', () {
    test('14 specs, unique ids, byId round-trip', () {
      expect(ModmatSolverRegistry.specs, hasLength(14));
      final ids = ModmatSolverRegistry.specs.map((s) => s.id).toList();
      expect(ids.toSet(), hasLength(14));
      for (final s in ModmatSolverRegistry.specs) {
        expect(ModmatSolverRegistry.byId(s.id), isNotNull);
      }
      expect(ModmatSolverRegistry.byId('nope'), isNull);
    });

    test('college-stats registry resolves', () {
      expect(CollegeSolverRegistry.specs, hasLength(1));
      expect(CollegeSolverRegistry.byId('college-stats'), isNotNull);
      expect(CollegeSolverRegistry.byId('nope'), isNull);
    });
  });

  group('M7 predicate', () {
    test('forall x in {1,2,3}: x > 0 is True', () {
      final eq = M7PredicateEquation('forall x in {1,2,3}: x > 0');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('True'));
      expect(eq.getSteps(), hasLength(3));
    });

    test('exists finds a witness', () {
      final r = M7PredicateEquation('exists x in {1,2}: x > 5').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('False'));
    });

    test('garbage + empty never throw', () {
      final eq = M7PredicateEquation('hello');
      expect(eq.validate(), isFalse);
      expect(() => eq.solve(), returnsNormally);
      expect(() => eq.getSteps(), returnsNormally);
      expect(M7PredicateEquation('   ').validate(), isFalse);
    });
  });

  group('M8 relations', () {
    test('identity on {1,2} is an equivalence relation', () {
      final eq = M8RelationsEquation('R={(1,1),(2,2)} on {1,2}');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('equivalence'));
      expect(eq.getSteps(), hasLength(3));
    });

    test('<= style relation is a partial order', () {
      final r = M8RelationsEquation('R={(1,1),(2,2),(1,2)} on {1,2}').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('partial order'));
    });

    test('garbage never throws', () {
      final eq = M8RelationsEquation('hello');
      expect(eq.validate(), isFalse);
      expect(() => eq.solve(), returnsNormally);
      expect(() => eq.getSteps(), returnsNormally);
    });
  });

  group('M9 real analysis', () {
    test('lim (2n+1)/(n+3) = 2', () {
      final eq = M9RealAnalysisEquation('lim (2n+1)/(n+3)');
      expect(eq.validate(), isTrue);
      expect(eq.solve().answer, contains('2'));
      expect(eq.getSteps(), hasLength(3));
    });

    test('lim 1/n = 0', () {
      expect(M9RealAnalysisEquation('lim 1/n').solve().answer, contains('0'));
    });

    test('garbage never throws', () {
      final eq = M9RealAnalysisEquation('xyz');
      expect(eq.validate(), isFalse);
      expect(() => eq.solve(), returnsNormally);
      expect(() => eq.getSteps(), returnsNormally);
    });
  });

  group('M10 algebraic structures', () {
    test('(Z5,+) is an abelian group', () {
      final eq = M10AlgebraicStructuresEquation('Z5 + group');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('abelian group'));
      expect(eq.getSteps(), hasLength(3));
    });

    test('(Z4,x) is NOT a group; Z7 is a field', () {
      expect(M10AlgebraicStructuresEquation('Z4 * group').solve().answer,
          contains('NOT a group'));
      expect(M10AlgebraicStructuresEquation('Z7 field').solve().answer,
          contains('is a field'));
    });

    test('garbage never throws', () {
      final eq = M10AlgebraicStructuresEquation('xyz');
      expect(eq.validate(), isFalse);
      expect(() => eq.solve(), returnsNormally);
    });
  });

  group('M11 graph basics', () {
    test('path P4 metrics', () {
      final eq = M11GraphBasicsEquation('V=4 E={(0,1),(1,2),(2,3)}');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('is a tree'));
      expect(eq.getSteps(), hasLength(3));
    });

    test('triangle has Euler circuit', () {
      final r = M11GraphBasicsEquation('V=3 E={(0,1),(1,2),(0,2)}').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('circuit'));
    });

    test('garbage never throws', () {
      final eq = M11GraphBasicsEquation('xyz');
      expect(eq.validate(), isFalse);
      expect(() => eq.solve(), returnsNormally);
    });
  });

  group('M12 proof (induction)', () {
    test('sum k at n=5 is 15', () {
      final eq = M12ProofEquation('induction sum k n=5');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('15'));
      expect(eq.getSteps(), hasLength(3));
    });

    test('sum k^2 at n=3 is 14', () {
      expect(M12ProofEquation('induction sum k^2 n=3').solve().answer,
          contains('14'));
    });

    test('garbage never throws', () {
      final eq = M12ProofEquation('xyz');
      expect(eq.validate(), isFalse);
      expect(() => eq.solve(), returnsNormally);
    });
  });

  group('M13 topology', () {
    test('(0,1) is open, not compact', () {
      final eq = M13TopologyEquation('(0,1)');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('open'));
      expect(eq.getSteps(), hasLength(3));
    });

    test('[0,1] is compact', () {
      expect(M13TopologyEquation('[0,1]').solve().answer, contains('compact'));
    });

    test('garbage never throws', () {
      final eq = M13TopologyEquation('a to b');
      expect(eq.validate(), isFalse);
      expect(() => eq.solve(), returnsNormally);
    });
  });

  group('M14 advanced graph', () {
    test('path is bipartite', () {
      final eq =
          M14AdvancedGraphEquation('V=4 E={(0,1),(1,2),(2,3)} bipartite');
      expect(eq.validate(), isTrue);
      expect(eq.solve().answer, contains('yes'));
      expect(eq.getSteps(), hasLength(3));
    });

    test('shortest path BFS', () {
      final r =
          M14AdvancedGraphEquation('V=4 E={(0,1),(1,2),(2,3)} shortest 0->3')
              .solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('length 3'));
    });

    test('garbage never throws', () {
      final eq = M14AdvancedGraphEquation('xyz');
      expect(eq.validate(), isFalse);
      expect(() => eq.solve(), returnsNormally);
    });
  });

  group('College stats (F4)', () {
    test('4,7,9 descriptive stats', () {
      final eq = CollegeStatsEquation('4,7,9 stats');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('mean='));
      expect(r.answer, contains('median=7'));
      expect(eq.getSteps(), hasLength(3));
    });

    test('regression y=2x line', () {
      final r = CollegeStatsEquation('x:1,2,3 y:2,4,6 regress').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('r = 1'));
    });

    test('z-test rejects far mean', () {
      final r = CollegeStatsEquation('ztest mean=72 mu=70 sd=10 n=25').solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('z = 1'));
    });

    test('garbage never throws', () {
      final eq = CollegeStatsEquation('xyz');
      expect(eq.validate(), isFalse);
      expect(() => eq.solve(), returnsNormally);
      expect(() => eq.getSteps(), returnsNormally);
    });
  });
}
