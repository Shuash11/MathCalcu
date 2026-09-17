// Cycle 9 F1+F3 wiring: every dead engine is reachable from the UI.
//
// Pure-Dart registry cross-checks (no widgets, runs fast):
// - each ModmatSolverRegistry spec (M1–M6) maps to a wired ModMat
//   leaf route (screen + GoRouter destination landed);
// - each QuadraticsSolverRegistry spec maps to a solverAvailable
//   curriculum topic (discoverable via pickers/search/history).
import 'package:calculus_system/core/curriculum_registry.dart';
import 'package:calculus_system/topics/modmat/modmat_module_registry.dart';
import 'package:calculus_system/topics/modmat/solvers/modmat_solver_registry.dart';
import 'package:calculus_system/topics/quadratics/solvers/quadratics_solver_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Cycle 9 F1+F2: ModMat M1–M14 engines are UI-wired', () {
    const specToRoute = {
      'modmat-propositional': '/modmat/foundations/propositional_logic',
      'modmat-predicate': '/modmat/foundations/predicate_logic',
      'modmat-sets': '/modmat/foundations/set_theory',
      'modmat-relations': '/modmat/foundations/relations_functions',
      'modmat-proof': '/modmat/foundations/proof_techniques',
      'modmat-bases': '/modmat/foundations/number_systems',
      'modmat-combinatorics': '/modmat/foundations/combinatorics_basics',
      'modmat-graph-basics': '/modmat/foundations/graph_theory_basics',
      'modmat-advanced-graph': '/modmat/advanced/advanced_graph_theory',
      'modmat-algebraic-structures': '/modmat/advanced/algebraic_structures',
      'modmat-real-analysis': '/modmat/advanced/real_analysis',
      'modmat-matrices': '/modmat/advanced/linear_algebra',
      'modmat-modular': '/modmat/advanced/number_theory',
      'modmat-topology': '/modmat/advanced/topology_basics',
    };

    test('registry carries the 14 specs (wave 1 + wave 2)', () {
      expect(
        ModmatSolverRegistry.specs.map((s) => s.id).toSet(),
        specToRoute.keys.toSet(),
      );
    });

    test('every spec route is leaf-wired (gate open, destination exists)', () {
      for (final entry in specToRoute.entries) {
        expect(ModmatModuleRegistry.isLeafRoute(entry.value), isTrue,
            reason: entry.key);
        expect(ModmatModuleRegistry.isRouteAvailable(entry.value), isTrue,
            reason: entry.key);
      }
      expect(
        ModmatModuleRegistry.wiredLeafRoutes,
        containsAll(specToRoute.values),
      );
    });

    test('every spec builds a solving engine', () {
      for (final spec in ModmatSolverRegistry.specs) {
        final result = spec.create('test').solve();
        expect(result, isNotNull, reason: spec.id);
      }
    });
  });

  group('Cycle 9 F1+F3: quadratics engines are registry-discoverable', () {
    const specToRoute = {
      'g9-quadratic-formula': '/grade9/quadratic-formula',
      'g9-radical-equations': '/grade9/radical-equations',
      'g9-variation': '/grade9/variation',
      'g10-sequences': '/grade10/sequences',
      'g10-polynomial-division': '/grade10/polynomial-division',
    };

    test('registry still carries the 5 specs', () {
      expect(
        QuadraticsSolverRegistry.specs.map((s) => s.id).toSet(),
        specToRoute.keys.toSet(),
      );
    });

    test('every spec has a solverAvailable curriculum topic at its route', () {
      for (final entry in specToRoute.entries) {
        final topic = CurriculumRegistry.allTopics().firstWhere(
          (t) => t.id == entry.key,
          orElse: () => throw StateError('missing topic ${entry.key}'),
        );
        expect(topic.solverAvailable, isTrue, reason: entry.key);
        expect(topic.route, entry.value, reason: entry.key);
      }
    });

    test('every spec builds a solving engine', () {
      for (final spec in QuadraticsSolverRegistry.specs) {
        final result = spec.create('test').solve();
        expect(result, isNotNull, reason: spec.id);
      }
    });
  });

  group('Cycle 9 F3: repointed stubs resolve to wired finals screens', () {
    test('limits intro + derivatives are solver-backed', () {
      final limits = CurriculumRegistry.allTopics()
          .firstWhere((t) => t.id == 'g11-limits-intro');
      final derivatives = CurriculumRegistry.allTopics()
          .firstWhere((t) => t.id == 'g12-derivatives');
      expect(limits.solverAvailable, isTrue);
      expect(limits.route, '/topics/calculus/finals/limits');
      expect(derivatives.solverAvailable, isTrue);
      expect(derivatives.route, '/topics/calculus/finals/derivatives');
    });

    test('stale /grade11 + /grade12 stub routes are gone', () {
      expect(CurriculumRegistry.getByRoute('/grade11/limits-intro'), isNull);
      expect(CurriculumRegistry.getByRoute('/grade12/derivatives'), isNull);
    });
  });
}
