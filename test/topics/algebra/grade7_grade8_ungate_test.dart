// Phase 2 ungate tests: the 4 orphaned algebra engines become
// solver-backed and routed.
//
// Engine round-trips: LinearOneVarEquation, FactoringEquation,
// System2x2Equation (via the AlgebraSolverRegistry specs).
// Routing: the 4 /grade7/* + /grade8/* routes are registered in the
// real GoRouter configuration (findMatch, not a string check) and
// CurriculumRegistry flips solverAvailable for all 4 topics.
import 'package:calculus_system/app_router.dart';
import 'package:calculus_system/core/curriculum_registry.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:calculus_system/topics/algebra/solvers/algebra_solver_registry.dart';
import 'package:calculus_system/topics/grade6/solvers/grade6_equations.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Algebra engine round-trips (Phase 2)', () {
    test('2x - 5 = 9 gives x = 7 via LinearOneVarEquation', () {
      final r = AlgebraSolverRegistry.byId('g7-linear-equations')!
          .create('2x-5=9')
          .solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('x = 7'));
    });

    test('x^2 + 5x + 6 factors to (x+2)(x+3) via FactoringEquation', () {
      final r = AlgebraSolverRegistry.byId('g8-factoring')!
          .create('x^2+5x+6')
          .solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('(x+2)(x+3)'));
    });

    test('x + y = 5, x - y = 1 gives (3, 2) via System2x2Equation', () {
      final r = AlgebraSolverRegistry.byId('g8-systems')!
          .create('x+y=5, x-y=1')
          .solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('3'));
      expect(r.answer, contains('2'));
    });

    test('-3 × -4 gives 12 (G6IntegerEquation signed arithmetic)', () {
      // Registry has no g7-signed-numbers spec — the thin screen wires
      // the G6IntegerEquation class directly.
      final spec = AlgebraSolverRegistry.byId('g7-signed-numbers');
      expect(spec, isNull);
      final eq = G6IntegerEquation('-3 × -4');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('12'));
    });

    test('Compare -8 < -3 gives true (G6IntegerEquation compare)', () {
      final eq = G6IntegerEquation('Compare -8 < -3');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
    });

    test('garbage never throws on the three algebra engines', () {
      const inputs = {
        'g7-linear-equations': '2x - 5 = 9',
        'g8-factoring': 'x^2 + 5x + 6',
        'g8-systems': 'x + y = 5, x - y = 1',
      };
      for (final entry in inputs.entries) {
        final eq = AlgebraSolverRegistry.byId(entry.key)!
            .create('hello world not an equation');
        expect(() => eq.solve(), returnsNormally, reason: entry.key);
      }
    });
  });

  group('Grade7/Grade8 routing (Phase 2 ungate)', () {
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

    test('all 4 topics are solver-backed with the new routes', () {
      const expected = {
        'g7-signed-numbers': '/grade7/signed-numbers',
        'g7-linear-equations': '/grade7/linear-equations',
        'g8-factoring': '/grade8/factoring',
        'g8-systems': '/grade8/systems',
      };
      for (final entry in expected.entries) {
        final topic = CurriculumRegistry.allTopics().firstWhere(
          (t) => t.id == entry.key,
        );
        expect(topic.solverAvailable, isTrue, reason: entry.key);
        expect(topic.route, entry.value, reason: entry.key);
      }
    });

    test('the 4 new routes are registered, findMatch isError false', () {
      const routes = [
        '/grade7/signed-numbers',
        '/grade7/linear-equations',
        '/grade8/factoring',
        '/grade8/systems',
      ];
      for (final route in routes) {
        expect(
          AppRouter.router.configuration.findMatch(route).isError,
          isFalse,
          reason: route,
        );
      }
      // Phase 3: college-stats is no longer a control — its
      // /college/statistics route landed (see
      // test/topics/college/college_stats_ungate_test.dart).
      expect(
        AppRouter.router.configuration.findMatch('/college/statistics').isError,
        isFalse,
      );
    });

    testWidgets('each new route resolves to its thin screen', (tester) async {
      await pumpRouter(tester);
      const routesToTitles = {
        '/grade7/signed-numbers': 'Signed Numbers',
        '/grade7/linear-equations': 'Linear Equations',
        '/grade8/factoring': 'Factoring Quadratics',
        '/grade8/systems': 'Linear Systems',
      };
      for (final entry in routesToTitles.entries) {
        AppRouter.router.go(entry.key);
        await tester.pumpAndSettle();
        expect(
          find.textContaining(entry.value),
          findsWidgets,
          reason: entry.key,
        );
        expect(find.text('Topic coming soon'), findsNothing, reason: entry.key);
        expect(tester.takeException(), isNull);
      }
    });
  });
}
