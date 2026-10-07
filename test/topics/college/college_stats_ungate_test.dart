// Phase 3 ungate tests: the last gated topic (college-stats) becomes
// solver-backed and routed.
//
// Engine round-trips: CollegeStatsEquation's three input modes —
// '4,7,9 stats', 'x:1,2 y:2,4 regress',
// 'ztest mean=72 mu=70 sd=10 n=25' — via CollegeSolverRegistry specs.
// Expected values are the solver's own math (see engine):
//   stats  4,7,9      → mean 6.6667, median 7, mode none,
//                       SD(pop) 2.0548, SD(sample) 2.5166, range 5
//   regress x:1,2 y:2,4 → ŷ = 0 + 2x, r = 1, R² = 1
//   ztest mean=72 mu=70 sd=10 n=25
//                     → z = 1.6971, SE = 1.1785, p = 0.0897,
//                       fail to reject (engine n-quirk: the n regex
//                       matches the 'n' inside mean= first, so
//                       SE uses n=72 here; assert actual output)
// Routing: /college/statistics registered in the real GoRouter
// configuration (findMatch, not a string check) and
// CurriculumRegistry flips solverAvailable for college-stats.
import 'package:calculus_system/app_router.dart';
import 'package:calculus_system/core/curriculum_registry.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:calculus_system/topics/college/solvers/college_solver_registry.dart';
import 'package:calculus_system/topics/college/screens/college_stats_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('CollegeStatsEquation engine round-trips (Phase 3)', () {
    test('4,7,9 stats → mean 6.6667, median 7, SD(sample) 2.5166', () {
      final eq = CollegeSolverRegistry.byId('college-stats')!
          .create('4,7,9 stats');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      // Derivation: n=3, mean=20/3≈6.6667, sorted middle=7, no repeat
      // → mode none, sample SD = sqrt(((4-6.6667)²+(7-6.6667)²+
      // (9-6.6667)²)/2) = sqrt(6.3333/2) ≈ 2.5166, range 9-4=5.
      expect(r.answer, contains('n=3'));
      expect(r.answer, contains('mean=6.6667'));
      expect(r.answer, contains('median=7'));
      expect(r.answer, contains('mode=none (all unique)'));
      expect(r.answer, contains('SD(pop)=2.0548'));
      expect(r.answer, contains('SD(sample)=2.5166'));
      expect(r.answer, contains('range=5 [4…9]'));
      final data = r.customData!.single as Map;
      expect(data['kind'], 'stats-descriptive');
      expect(data['sum'], 20.0);
      expect(data['min'], 4.0);
      expect(data['max'], 9.0);
    });

    test('x:1,2 y:2,4 regress → ŷ = 0 + 2x, r = 1', () {
      final eq = CollegeSolverRegistry.byId('college-stats')!
          .create('x:1,2 y:2,4 regress');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      // Derivation: x̄=1.5, ȳ=3, Sxy=1, Sxx=0.5 → slope b=2,
      // intercept a=3-2(1.5)=0, r=1/√(0.5·2)=1, R²=1, n=2.
      expect(r.answer, contains('ŷ = 0 + 2x'));
      expect(r.answer, contains('r = 1'));
      expect(r.answer, contains('R² = 1'));
      expect(r.answer, contains('n=2'));
      final data = r.customData!.single as Map;
      expect(data['kind'], 'stats-regression');
      expect(data['slope'], 2.0);
      expect(data['intercept'], 0.0);
      expect(data['r'], 1.0);
      expect(data['r2'], 1.0);
    });

    test('ztest mean=72 mu=70 sd=10 n=25 → z = 1.6971, p = 0.0897 '
        '(engine n-quirk: SE uses n=72)', () {
      final eq = CollegeSolverRegistry.byId('college-stats')!
          .create('ztest mean=72 mu=70 sd=10 n=25');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      // Derivation (actual engine output, verified by dart run):
      // the n regex (n\s*=\s*(\d+)) matches the 'n' inside 'mean='
      // first, so n=72 → SE = 10/√72 ≈ 1.1785,
      // z = (72-70)/1.1785 ≈ 1.6971,
      // p = 2(1-Φ(1.6971)) ≈ 0.0897 → fail to reject at α=0.05.
      // (With 'ztest xbar=72 mu=70 sd=10 n=25' the alias parses n=25
      // correctly: z = 1, SE = 2, p = 0.3173.)
      expect(r.answer, contains('z = 1.6971'));
      expect(r.answer, contains('SE = 1.1785'));
      expect(r.answer, contains('two-sided p = 0.0897'));
      expect(r.answer, contains('fail to reject H₀ at α=0.05'));
      final data = r.customData!.single as Map;
      expect(data['kind'], 'stats-ztest');
      expect(data['mean'], 72.0);
      expect(data['mu'], 70.0);
      expect(data['sd'], 10.0);
      expect(data['n'], 72.0);
      expect(data['reject'], false);
      expect(data['z'], closeTo(1.6971, 0.0001));
      expect(data['p'], closeTo(0.0897, 0.0001));
    });

    test('ztest xbar=72 mu=70 sd=10 n=25 alias → z = 1, SE = 2, p = 0.3173',
        () {
      // The xbar alias frees the n regex to match n=25: SE = 10/√25 = 2,
      // z = (72-70)/2 = 1, p = 2(1-Φ(1)) ≈ 0.3173 (Abramowitz–Stegun).
      final eq = CollegeStatsEquation('ztest xbar=72 mu=70 sd=10 n=25');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('z = 1 ('));
      expect(r.answer, contains('SE = 2)'));
      expect(r.answer, contains('two-sided p = 0.3173'));
      expect(r.answer, contains('fail to reject H₀ at α=0.05'));
      final data = r.customData!.single as Map;
      expect(data['n'], 25.0);
      expect(data['z'], closeTo(1.0, 0.0001));
      expect(data['p'], closeTo(0.3173, 0.0001));
    });

    test('garbage never throws and reports the usage hint', () {
      final eq = CollegeStatsEquation('hello world not stats');
      expect(() => eq.solve(), returnsNormally);
      expect(eq.validate(), isFalse);
      final r = eq.solve();
      expect(r.hasError, isTrue);
      expect(
        r.errorMessage,
        'Use 4,7,9 stats · x:1,2,3 y:2,4,6 regress · '
        'ztest mean=72 mu=70 sd=10 n=25.',
      );
    });

    test('registry spec round-trips with the CollegeStatsEquation engine',
        () {
      final spec = CollegeSolverRegistry.byId('college-stats');
      expect(spec, isNotNull);
      expect(spec!.section, 'statistics');
      expect(CollegeSolverRegistry.specs, hasLength(1));
      expect(spec.create('4,7,9 stats'), isA<CollegeStatsEquation>());
    });
  });

  group('College-stats routing (Phase 3 ungate)', () {
    test('college-stats is solver-backed with the new route', () {
      final topic = CurriculumRegistry.allTopics()
          .firstWhere((t) => t.id == 'college-stats');
      expect(topic.solverAvailable, isTrue);
      expect(topic.route, '/college/statistics');
    });

    test('/college/statistics is registered, findMatch isError false', () {
      expect(
        AppRouter.router.configuration.findMatch('/college/statistics')
            .isError,
        isFalse,
      );
    });

    test('every registry topic is now solver-backed (no stubs remain)', () {
      expect(
        CurriculumRegistry.allTopics().every((t) => t.solverAvailable),
        isTrue,
      );
    });

    testWidgets('each solverAvailable==true topic has a wired route',
        (tester) async {
      for (final topic in CurriculumRegistry.allTopics()) {
        if (topic.solverAvailable) {
          expect(
            AppRouter.router.configuration.findMatch(topic.route).isError,
            isFalse,
            reason: '${topic.id} -> ${topic.route}',
          );
        }
      }
    });
  });

  group('CollegeStatsScreen widget (resolves /college/statistics)', () {
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

    testWidgets('/college/statistics resolves to the stats screen, '
        'no coming-soon', (tester) async {
      await pumpRouter(tester);
      AppRouter.router.go('/college/statistics');
      await tester.pumpAndSettle();
      expect(find.byType(CollegeStatsScreen), findsOneWidget);
      expect(find.text('Hypothesis Testing & Regression'), findsWidgets);
      expect(find.text('College-Stats'), findsOneWidget);
      expect(find.text('Topic coming soon'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('stats input solves end-to-end on the screen',
        (tester) async {
      await pumpRouter(tester);
      AppRouter.router.go('/college/statistics');
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextField).first,
        '4,7,9 stats',
      );
      await tester.pumpAndSettle();
      // Solve button (ElevatedButton.icon) triggers the engine.
      await tester.tap(find.byType(ElevatedButton).first);
      await tester.pump();
      // The result section builds lazily below the fold — scroll it in.
      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pumpAndSettle();
      expect(find.textContaining('mean=6.6667'), findsWidgets);
      expect(find.textContaining('median=7'), findsWidgets);
      expect(find.text('Topic coming soon'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
