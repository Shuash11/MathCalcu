// Cycle 8 middle-end routing wave: registry invariants for the
// never-dead-end guarantee.
//
// Covers: bySubject/subjects APIs (Topics hub subject cards, G6
// chips), AND-token search, SHS gating (solverAvailable == false
// until SHS screens land), ModMat leaf gating, and UnifiedHit
// stub classification. Pure-Dart (no widgets) so it runs fast.
import 'package:calculus_system/app_router.dart';
import 'package:calculus_system/core/curriculum_registry.dart';
import 'package:calculus_system/search/unified_search.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:calculus_system/topics/modmat/modmat_module_registry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('CurriculumRegistry.bySubject', () {
    test('exact subject, case-insensitive, trims', () {
      final fractions = CurriculumRegistry.bySubject('Fractions');
      expect(fractions.map((t) => t.id), ['g6-1-fractions']);
      expect(
        CurriculumRegistry.bySubject('  fractions '),
        hasLength(1),
      );
      expect(
        CurriculumRegistry.bySubject('TRIGONOMETRY').map((t) => t.id),
        containsAll(['g9-trig-ratios', 'g11-trig-equations']),
      );
    });

    test('All/empty returns everything, unknown returns []', () {
      expect(
        CurriculumRegistry.bySubject('All'),
        hasLength(CurriculumRegistry.allTopics().length),
      );
      expect(
        CurriculumRegistry.bySubject('  '),
        hasLength(CurriculumRegistry.allTopics().length),
      );
      expect(CurriculumRegistry.bySubject('nope'), isEmpty);
    });

    test('subjects are distinct and cover every topic', () {
      final subjects = CurriculumRegistry.subjects;
      expect(subjects.toSet(), hasLength(subjects.length));
      for (final topic in CurriculumRegistry.allTopics()) {
        expect(subjects, contains(topic.subject));
      }
    });

    test('grade6Subjects matches the 11 G6 seed topics', () {
      expect(CurriculumRegistry.grade6Subjects, hasLength(11));
    });
  });

  group('Grade6ModuleRegistry subject filter (chips)', () {
    test('bySubject narrows to one subject', () {
      expect(
        Grade6ModuleRegistry.bySubject('Ratio & Proportion').map((t) => t.id),
        ['g6-4-ratio'],
      );
      expect(Grade6ModuleRegistry.bySubject('All'), hasLength(11));
      expect(Grade6ModuleRegistry.bySubject('unknown'), isEmpty);
    });

    test('subjects delegate to the central registry', () {
      expect(
        Grade6ModuleRegistry.subjects,
        CurriculumRegistry.grade6Subjects,
      );
    });
  });

  group('AND-token search', () {
    test('multi-token query requires every token', () {
      final hits = CurriculumRegistry.search('trig G11');
      expect(hits, isNotEmpty);
      for (final hit in hits) {
        final haystack =
            '${hit.topic.label} ${hit.topic.subtitle} ${hit.topic.subject} '
                    '${hit.topic.gradeLevel} ${hit.topic.tags.join(' ')}'
                .toLowerCase();
        expect(haystack, contains('trig'));
        expect(haystack, contains('g11'));
      }
      // 'trig G9' must not leak G11 topics.
      final g9 = CurriculumRegistry.search('trig G9');
      expect(
        g9.any((h) => h.topic.gradeLevel == 'G11'),
        isFalse,
      );
    });

    test('single-token behavior is unchanged', () {
      expect(
        CurriculumRegistry.search('logarithm')
            .any((h) => h.topic.id == 'g11-logarithms'),
        isTrue,
      );
      expect(
        ModmatModuleRegistry.search('EIGENVALUES').single.module.label,
        'Linear Algebra',
      );
      expect(
        ModmatModuleRegistry.search('truth tables').single.module.label,
        'Propositional Logic',
      );
    });

    test('blank query returns []', () {
      expect(CurriculumRegistry.search('   '), isEmpty);
      expect(Grade6ModuleRegistry.search(''), isEmpty);
      expect(ModmatModuleRegistry.search('  '), isEmpty);
      expect(UnifiedSearch.search(''), isEmpty);
    });
  });

  group('SHS wiring (P1-2: engines + screens + routes, no dead pushes)', () {
    const shsIds = [
      'g9-trig-ratios',
      'g11-logarithms',
      'g11-interest',
      'g11-inverse-functions',
      'g11-rational-inequality',
      'g11-trig-equations',
      'g11-trig-identities',
      'g12-definite-integral',
      'g12-optimization',
      'college-lhopital',
    ];

    test('all 10 /shs/* entries are solver-backed with routes', () {
      for (final id in shsIds) {
        final topic =
            CurriculumRegistry.allTopics().firstWhere((t) => t.id == id);
        expect(topic.solverAvailable, isTrue, reason: id);
        expect(topic.route.startsWith('/shs/'), isTrue, reason: id);
      }
    });

    test('every solverAvailable==true topic has a wired route', () {
      for (final topic in CurriculumRegistry.allTopics()) {
        if (topic.solverAvailable) {
          // Cycle 9: wired families are /grade6/*, /shs/*,
          // /grade9/* + /grade10/* (quadratics thin screens) and
          // /topics/calculus/finals/* (G11-limits + G12-derivatives
          // reuse the existing finals screens).
          final wired = topic.route.startsWith('/grade6/') ||
              topic.route.startsWith('/shs/') ||
              topic.route.startsWith('/grade9/') ||
              topic.route.startsWith('/grade10/') ||
              topic.route.startsWith('/topics/calculus/');
          expect(wired, isTrue, reason: '${topic.id} -> ${topic.route}');
        }
      }
    });

    test('G6 seed stays fully available', () {
      expect(
        CurriculumRegistry.grade6Topics.every((t) => t.solverAvailable),
        isTrue,
      );
    });
  });

  group('ModmatModuleRegistry route availability', () {
    test('all 14 leaves are wired (screens + GoRoutes landed)', () {
      // Cycle 9 F1+F2: M1–M6 wave 1 + M7–M14 wave 2.
      const wired = [
        '/modmat/foundations/propositional_logic',
        '/modmat/foundations/predicate_logic',
        '/modmat/foundations/set_theory',
        '/modmat/foundations/relations_functions',
        '/modmat/foundations/proof_techniques',
        '/modmat/foundations/number_systems',
        '/modmat/foundations/combinatorics_basics',
        '/modmat/foundations/graph_theory_basics',
        '/modmat/advanced/advanced_graph_theory',
        '/modmat/advanced/algebraic_structures',
        '/modmat/advanced/real_analysis',
        '/modmat/advanced/linear_algebra',
        '/modmat/advanced/number_theory',
        '/modmat/advanced/topology_basics',
      ];
      for (final m in [
        ...ModmatModuleRegistry.foundationsModules,
        ...ModmatModuleRegistry.advancedModules,
      ]) {
        expect(ModmatModuleRegistry.isLeafRoute(m.route), isTrue,
            reason: m.route);
        expect(ModmatModuleRegistry.isRouteAvailable(m.route),
            wired.contains(m.route),
            reason: m.route);
      }
      expect(
        ModmatModuleRegistry.wiredLeafRoutes,
        unorderedEquals(wired),
      );
      expect(
        ModmatModuleRegistry.isRouteAvailable('/topics/modmat'),
        isTrue,
      );
      expect(
        ModmatModuleRegistry.isRouteAvailable('/topics/modmat/foundations'),
        isTrue,
      );
      expect(
        ModmatModuleRegistry.isRouteAvailable('/topics/modmat/advanced'),
        isTrue,
      );
    });

    test('Cycle 9 F1+F3 topics are solver-backed with wired routes', () {
      const ids = [
        'g9-quadratic-formula',
        'g9-radical-equations',
        'g9-variation',
        'g10-sequences',
        'g10-polynomial-division',
        'g11-limits-intro',
        'g12-derivatives',
      ];
      for (final id in ids) {
        final topic =
            CurriculumRegistry.allTopics().firstWhere((t) => t.id == id);
        expect(topic.solverAvailable, isTrue, reason: id);
      }
      expect(
        CurriculumRegistry.allTopics()
            .firstWhere((t) => t.id == 'g11-limits-intro')
            .route,
        '/topics/calculus/finals/limits',
      );
      expect(
        CurriculumRegistry.allTopics()
            .firstWhere((t) => t.id == 'g12-derivatives')
            .route,
        '/topics/calculus/finals/derivatives',
      );
    });
  });

  group('UnifiedHit.isStub', () {
    test('wired modmat leaves and future paths classify correctly', () {
      // Cycle 9: all 14 M1–M14 leaves are solver-backed, not stubs.
      final wiredHits = UnifiedSearch.search('propositional');
      expect(wiredHits, isNotEmpty);
      for (final hit in wiredHits
          .where((h) => h.route.startsWith('/modmat/foundations/'))) {
        expect(hit.isStub, isFalse, reason: hit.route);
      }
      final wave2Hits = UnifiedSearch.search('predicate');
      expect(wave2Hits, isNotEmpty);
      for (final hit in wave2Hits
          .where((h) => h.route.startsWith('/modmat/foundations/'))) {
        expect(hit.isStub, isFalse, reason: hit.route);
      }
      // Gated SHS curriculum hits are stubs too.
      final gated = CurriculumRegistry.allTopics().firstWhere(
          (t) => !t.solverAvailable,
          orElse: () => throw StateError('expected a gated stub'));
      final gatedHit = UnifiedSearch.search(gated.label.split(' ').first)
          .firstWhere((h) => h.curriculumTopic?.id == gated.id);
      expect(gatedHit.isStub, isTrue, reason: gated.id);
      // Wired SHS hits are not stubs.
      final shs = UnifiedSearch.search('logarithm');
      expect(
        shs.firstWhere((h) => h.curriculumTopic?.id == 'g11-logarithms').isStub,
        isFalse,
      );
      // Wired G6 hits are not stubs.
      final g6 = UnifiedSearch.search('ratio');
      expect(
        g6.where((h) => h.curriculumTopic?.id == 'g6-4-ratio').single.isStub,
        isFalse,
      );
    });
  });

  group('AppRouter destinations (real router, no dead pushes)', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(const {});
    });

    tearDown(() {
      AppRouter.router.go('/');
    });

    Future<void> pumpRouter(WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: ThemeProvider(),
          child: MaterialApp.router(routerConfig: AppRouter.router),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('every registry /shs/* route resolves to a screen',
        (tester) async {
      await pumpRouter(tester);
      const routesToTitles = {
        '/shs/trig-ratios': 'Trig Ratios',
        '/shs/logarithms': 'Logarithms & Exponents',
        '/shs/interest': 'Simple & Compound Interest',
        '/shs/inverse-functions': 'Inverse Functions',
        '/shs/rational-inequality': 'Rational Inequalities',
        '/shs/trig-equations': 'Trig Equations',
        '/shs/trig-identities': 'Trig Identities',
        '/shs/definite-integral': 'Definite Integrals',
        '/shs/optimization': 'Max / Min',
        '/shs/lhopital': "L'Hôpital",
      };
      for (final entry in routesToTitles.entries) {
        AppRouter.router.go(entry.key);
        await tester.pumpAndSettle();
        expect(find.textContaining(entry.value), findsWidgets,
            reason: entry.key);
        expect(find.text('Topic coming soon'), findsNothing, reason: entry.key);
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('Cycle 9: modmat leaves + grade9/10 routes resolve',
        (tester) async {
      await pumpRouter(tester);
      const routesToTitles = {
        '/modmat/foundations/propositional_logic': 'Propositional Logic',
        '/modmat/foundations/predicate_logic': 'Predicate Logic',
        '/modmat/foundations/set_theory': 'Set Theory',
        '/modmat/foundations/relations_functions': 'Relations & Functions',
        '/modmat/foundations/proof_techniques': 'Proof Techniques',
        '/modmat/foundations/number_systems': 'Number Systems',
        '/modmat/foundations/combinatorics_basics': 'Combinatorics',
        '/modmat/foundations/graph_theory_basics': 'Graph Theory Basics',
        '/modmat/advanced/advanced_graph_theory': 'Advanced Graph Theory',
        '/modmat/advanced/algebraic_structures': 'Algebraic Structures',
        '/modmat/advanced/real_analysis': 'Real Analysis',
        '/modmat/advanced/linear_algebra': 'Linear Algebra',
        '/modmat/advanced/number_theory': 'Number Theory',
        '/modmat/advanced/topology_basics': 'Topology Basics',
        '/grade9/quadratic-formula': 'Quadratic Formula',
        '/grade9/radical-equations': 'Radical Equations',
        '/grade9/variation': 'Direct & Inverse Variation',
        '/grade10/sequences': 'Arithmetic Sequences',
        '/grade10/polynomial-division': 'Polynomial Division',
      };
      for (final entry in routesToTitles.entries) {
        AppRouter.router.go(entry.key);
        await tester.pumpAndSettle();
        expect(find.textContaining(entry.value), findsWidgets,
            reason: entry.key);
        expect(find.text('Topic coming soon'), findsNothing, reason: entry.key);
        expect(tester.takeException(), isNull);
      }
      // F3 repoints land on the existing finals screens.
      AppRouter.router.go('/topics/calculus/finals/limits');
      await tester.pumpAndSettle();
      expect(find.text('Topic coming soon'), findsNothing);
      expect(tester.takeException(), isNull);

      AppRouter.router.go('/topics/calculus/finals/derivatives');
      await tester.pumpAndSettle();
      expect(find.text('Topic coming soon'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('/topics/shs and /topics/hub pickers resolve', (tester) async {
      await pumpRouter(tester);
      AppRouter.router.go('/topics/shs');
      await tester.pumpAndSettle();
      expect(find.text('Topic coming soon'), findsNothing);
      expect(tester.takeException(), isNull);

      AppRouter.router.go('/topics/hub');
      await tester.pumpAndSettle();
      expect(find.text('Topic coming soon'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('unknown locations land on the coming-soon screen',
        (tester) async {
      await pumpRouter(tester);
      AppRouter.router.go('/no-such-topic-xyz');
      await tester.pumpAndSettle();
      expect(find.text('Topic coming soon'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
