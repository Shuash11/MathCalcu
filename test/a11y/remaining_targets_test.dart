// Cycle 2 Phase 2: labels for the remaining unlabeled tap targets —
// the finals picker screen, the finals about sheet developer cards,
// the five evaluating-limits method screens, and the factoring
// answer card.
//
// Every tappable widget on these surfaces now carries a Semantics
// label (or IconButton tooltip), so screen readers announce the
// control instead of reading an unnamed "button". Pumps the nearest
// pumpable parent for each target the way their existing tests do,
// and asserts the Flutter labeledTapTargetGuideline in light and dark.
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:calculus_system/topics/calculus/finals/finals_picker_screen.dart';
import 'package:calculus_system/topics/calculus/finals/screens/evaluating_limits_screen/by_conjugate/conjugate_limit_screen.dart';
import 'package:calculus_system/topics/calculus/finals/screens/evaluating_limits_screen/by_factoring/factoring_answer_card.dart';
import 'package:calculus_system/topics/calculus/finals/screens/evaluating_limits_screen/by_factoring/factoring_limit_screen.dart';
import 'package:calculus_system/topics/calculus/finals/screens/evaluating_limits_screen/by_lcd/lcd_limit_screen.dart';
import 'package:calculus_system/topics/calculus/finals/screens/evaluating_limits_screen/by_lhopital/lhopital_limit_screen.dart';
import 'package:calculus_system/topics/calculus/finals/screens/evaluating_limits_screen/by_substitution/substitution_limit_screen.dart';
import 'package:calculus_system/topics/calculus/finals/widgetsScreens/finals_about_sheets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  bool isDark = false,
}) async {
  final theme = ThemeProvider();
  if (isDark) theme.toggleTheme();

  tester.view.physicalSize = const Size(390, 2000);
  tester.view.devicePixelRatio = 1.0;

  await tester.pumpWidget(
    // FinalsTheme/AccentGlow read ThemeProvider via context.watch in
    // build; MaterialApp + Scaffold supply the Material ancestor the
    // sheets and TextFields require. Nested Scaffolds on screens that
    // build their own are harmless in tests.
    ChangeNotifierProvider.value(
      value: theme,
      child: MaterialApp(home: Scaffold(body: child)),
    ),
  );
  await tester.pump();
}

void main() {
  group('Finals picker labeled tap targets', () {
    testWidgets('meets labeledTapTargetGuideline in both themes',
        (tester) async {
      final handle = tester.ensureSemantics();

      for (final isDark in [false, true]) {
        await _pump(
          tester,
          const FinalsPickerScreen(),
          isDark: isDark,
        );
        // Stagger timers (120–920ms) fire during this pump; the 600ms
        // fade controllers then need additional frames — without
        // pumpAndSettle the cards stay at opacity 0 and their semantics
        // subtrees are dropped from the tree.
        await tester.pump(const Duration(milliseconds: 1100));
        await tester.pumpAndSettle();

        expect(find.text('Back to finals'), findsNothing);
        // IconButton tooltips surface in the semantics tooltip property.
        expect(find.byTooltip('Back to finals'), findsOneWidget);
        // The Evaluating Limits card is labeled by the shared ModuleCard.
        expect(
          find.bySemanticsLabel('Evaluating Limits'),
          findsOneWidget,
        );
        await expectLater(
          tester,
          meetsGuideline(labeledTapTargetGuideline),
        );
      }

      handle.dispose();
    });

    testWidgets('module card label pushes the module route', (tester) async {
      final handle = tester.ensureSemantics();

      final router = GoRouter(
        initialLocation: '/finals/limits',
        routes: [
          GoRoute(
            path: '/finals/limits',
            builder: (context, state) => const FinalsPickerScreen(),
          ),
        ],
      );

      await _pump(
        tester,
        MaterialApp.router(routerConfig: router),
      );
      // Stagger timers + 600ms fade controllers (see group test above).
      await tester.pump(const Duration(milliseconds: 1100));
      await tester.pumpAndSettle();

      // The Evaluating Limits card carries its Semantics label from the
      // shared ModuleCard wrapper.
      await tester.tap(find.bySemanticsLabel('Evaluating Limits'));
      await tester.pump(const Duration(milliseconds: 200));

      // onTap pushes /topics/calculus/finals/limits through the router
      // above the screen (pumped via MaterialApp.router here) which has
      // no matching route, so go_router pushes its error page on top of
      // the picker. Assert the navigation intent directly via the
      // router location: how long the picker stays mounted depends on
      // the error page's entrance transition, which changed when the
      // Material import moved to package:material_ui.
      expect(
        router.routeInformationProvider.value.uri,
        Uri.parse('/topics/calculus/finals/limits'),
      );

      router.dispose();
      handle.dispose();
    });
  });

  group('Finals about sheet developer cards', () {
    testWidgets('meets labeledTapTargetGuideline in both themes',
        (tester) async {
      final handle = tester.ensureSemantics();

      for (final isDark in [false, true]) {
        await _pump(tester, const SizedBox.shrink(), isDark: isDark);
        showFinalsAboutSheet(tester.element(find.byType(Scaffold)));
        await tester.pumpAndSettle();

        expect(find.text('DEVELOPERS'), findsOneWidget);
        expect(
          find.bySemanticsLabel('Expand developer info'),
          findsWidgets,
        );
        await expectLater(
          tester,
          meetsGuideline(labeledTapTargetGuideline),
        );
        Navigator.of(tester.element(find.byType(Scaffold))).pop();
        await tester.pumpAndSettle();
      }

      handle.dispose();
    });

    testWidgets('developer card toggle flips its label', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, const SizedBox.shrink());
      showFinalsAboutSheet(tester.element(find.byType(Scaffold)));
      await tester.pumpAndSettle();

      await tester.tap(find.bySemanticsLabel('Expand developer info').first);
      await tester.pumpAndSettle();
      expect(
        find.bySemanticsLabel('Collapse developer info'),
        findsOneWidget,
      );

      Navigator.of(tester.element(find.byType(Scaffold))).pop();
      await tester.pumpAndSettle();
      handle.dispose();
    });
  });

  group('Evaluating-limits method screens', () {
    testWidgets(
        'all five method screens meet labeledTapTargetGuideline '
        'in both themes', (tester) async {
      final handle = tester.ensureSemantics();

      const screens = <Widget>[
        ConjugateLimitScreen(),
        FactoringLimitScreen(),
        LCDLimitScreen(),
        LhopitalLimitScreen(),
        SubstitutionLimitScreen(),
      ];

      for (final isDark in [false, true]) {
        for (final screen in screens) {
          await _pump(tester, screen, isDark: isDark);
          // Defaults show the input-only surface (the answer card renders
          // only after a solve); settle any pending timers from a prior
          // solve within the same test if one is pending.
          await tester.pump(const Duration(milliseconds: 400));

          // The back button is a tooltip-only IconButton.
          expect(find.byTooltip('Back to limits'), findsOneWidget);
          await expectLater(
            tester,
            meetsGuideline(labeledTapTargetGuideline),
          );
        }
      }

      handle.dispose();
    });
  });

  group('Factoring answer card', () {
    testWidgets('meets labeledTapTargetGuideline in both themes',
        (tester) async {
      final handle = tester.ensureSemantics();

      for (final isDark in [false, true]) {
        await _pump(
          tester,
          SingleChildScrollView(
            child: FactoringAnswerCard(
              answer: 1,
              method: 'Factoring',
              isShowingSteps: true,
              onTap: () {},
            ),
          ),
          isDark: isDark,
        );
        await tester.pump(const Duration(milliseconds: 400));

        expect(
          find.bySemanticsLabel('View limit solution steps'),
          findsOneWidget,
        );
        await expectLater(
          tester,
          meetsGuideline(labeledTapTargetGuideline),
        );
      }

      handle.dispose();
    });
  });
}
