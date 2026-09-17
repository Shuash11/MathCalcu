import 'package:calculus_system/core/module_registry.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:calculus_system/topics/modmat/modmat_module_registry.dart';
import 'package:calculus_system/topics/modmat/modmat_picker_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

void main() {
  late GoRouter router;

  setUp(() {
    router = _buildRouter();
  });

  tearDown(() {
    router.dispose();
  });

  group('ModmatModuleRegistry.search', () {
    test(
        'trims and matches titles and subtitles from both sections case-insensitively',
        () {
      expect(
        ModmatModuleRegistry.search('  PrOpOsItIoNaL  ').single.module.label,
        'Propositional Logic',
      );
      expect(
        ModmatModuleRegistry.search('truth tables').single.module.label,
        'Propositional Logic',
      );
      expect(
        ModmatModuleRegistry.search('real analysis').single.module.label,
        'Real Analysis',
      );
      expect(
        ModmatModuleRegistry.search('EIGENVALUES').single.module.label,
        'Linear Algebra',
      );
    });

    test('preserves registry order and section labels', () {
      final hits = ModmatModuleRegistry.search('theory');

      expect(
        hits.map((hit) => hit.module.label),
        [
          'Set Theory',
          'Graph Theory Basics',
          'Advanced Graph Theory',
          'Number Theory'
        ],
      );
      expect(
        hits.map((hit) => hit.section),
        ['Foundations', 'Foundations', 'Advanced', 'Advanced'],
      );
    });

    test(
        'reads future entries from either canonical registry list at call time',
        () {
      const futureFoundation = ModuleEntry(
        label: 'Future Foundation',
        subtitle: 'Temporary registry coverage',
        route: '/test/future-foundation',
        icon: Icons.add_rounded,
        accent: Colors.teal,
      );
      const futureAdvanced = ModuleEntry(
        label: 'Future Advanced',
        subtitle: 'Temporary registry coverage',
        route: '/test/future-advanced',
        icon: Icons.add_rounded,
        accent: Colors.teal,
      );

      ModmatModuleRegistry.foundationsModules.add(futureFoundation);
      ModmatModuleRegistry.advancedModules.add(futureAdvanced);
      addTearDown(() {
        ModmatModuleRegistry.foundationsModules.remove(futureFoundation);
        ModmatModuleRegistry.advancedModules.remove(futureAdvanced);
      });

      final hits = ModmatModuleRegistry.search('temporary registry coverage');

      expect(hits.map((hit) => hit.module.route), [
        futureFoundation.route,
        futureAdvanced.route,
      ]);
      expect(hits.map((hit) => hit.section), ['Foundations', 'Advanced']);
    });
  });

  testWidgets('empty and whitespace-only input retain the section cards',
      (tester) async {
    await _pumpPicker(tester, router);

    expect(find.text('Open Foundations'), findsOneWidget);
    // F6 chips sliver pushes the second card below the first paint:
    // scroll so the lazy SliverList builds it.
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pump();
    expect(find.text('Open Advanced'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('modmat-search-field')), '   ');
    await tester.pump();

    expect(find.text('Open Foundations'), findsOneWidget);
    expect(find.text('Open Advanced'), findsOneWidget);
  });

  testWidgets(
      'shows direct section-labelled results for title and subtitle matches',
      (tester) async {
    await _pumpPicker(tester, router);

    await tester.enterText(
      find.byKey(const Key('modmat-search-field')),
      '  EIGENVALUES ',
    );
    await tester.pump();

    expect(find.text('Linear Algebra'), findsOneWidget);
    expect(
      find.byKey(
        const Key('modmat-search-result-/modmat/advanced/linear_algebra'),
      ),
      findsOneWidget,
    );
    // No Foundations-section hit for this query.
    expect(find.text('Set Theory'), findsNothing);
    expect(find.text('Graph Theory Basics'), findsNothing);
  });

  testWidgets('shows an intentional no-results state and clears the query',
      (tester) async {
    await _pumpPicker(tester, router);

    await tester.enterText(
      find.byKey(const Key('modmat-search-field')),
      'not-a-modern-math-topic',
    );
    await tester.pump();

    expect(find.byKey(const Key('modmat-search-field')), findsOneWidget);
    expect(find.text('No topics found'), findsOneWidget);
    expect(find.byKey(const Key('modmat-search-clear')), findsOneWidget);

    await tester.tap(find.byKey(const Key('modmat-search-clear')));
    await tester.pump();

    expect(find.text('Open Foundations'), findsOneWidget);
    // Same lazy-build scroll as above for the second card.
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pump();
    expect(find.text('Open Advanced'), findsOneWidget);
  });

  testWidgets('activating a wave-2 leaf result navigates (no gate)',
      (tester) async {
    await _pumpPicker(tester, router);
    // Predicate Logic is wired (Cycle 9 F1+F2) — pushes through.
    final module = ModmatModuleRegistry.foundationsModules[1];

    await tester.enterText(
      find.byKey(const Key('modmat-search-field')),
      module.label,
    );
    await tester.pump();
    await tester.tap(find.byKey(Key('modmat-search-result-${module.route}')));
    await tester.pumpAndSettle();

    // Cycle 9: all 14 leaves are wired — the tap navigates.
    expect(find.text('Navigated to ${module.route}'), findsOneWidget);
    expect(find.textContaining("isn't built yet"), findsNothing);
  });

  testWidgets('activating a wired leaf result navigates (no gate)',
      (tester) async {
    await _pumpPicker(tester, router);
    // Propositional Logic is wired (Cycle 9 F1) — pushes through.
    final module = ModmatModuleRegistry.foundationsModules.first;

    await tester.enterText(
      find.byKey(const Key('modmat-search-field')),
      module.label,
    );
    await tester.pump();
    await tester.tap(find.byKey(Key('modmat-search-result-${module.route}')));
    await tester.pumpAndSettle();

    expect(find.text('Navigated to ${module.route}'), findsOneWidget);
    expect(find.textContaining("isn't built yet"), findsNothing);
  });

  testWidgets('unknown leaf-like routes stay gated at registry level',
      (tester) async {
    // No widget push can land here: the allowlist is explicit.
    expect(
      ModmatModuleRegistry.isRouteAvailable('/modmat/foundations/nope'),
      isFalse,
    );
    expect(
      ModmatModuleRegistry.isRouteAvailable(
        '/modmat/foundations/propositional_logic',
      ),
      isTrue,
    );
  });

  testWidgets('search results support keyboard activation', (tester) async {
    await _pumpPicker(tester, router);
    final module = ModmatModuleRegistry.foundationsModules[1];

    await tester.enterText(
      find.byKey(const Key('modmat-search-field')),
      module.label,
    );
    await tester.pump();
    // Focus order: field → clear button → 3 subject chips → result
    // card (F6 chips are focusable). Five tabs reach the card.
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    // Cycle 9: keyboard activation navigates the same as taps.
    expect(find.text('Navigated to ${module.route}'), findsOneWidget);
    expect(find.textContaining("isn't built yet"), findsNothing);
  });

  testWidgets(
      'has no overflow at narrow and wide widths in light and dark themes',
      (tester) async {
    for (final width in [320.0, 1280.0]) {
      for (final isDark in [false, true]) {
        await _pumpPicker(tester, router, width: width, isDark: isDark);
        await tester.enterText(
          find.byKey(const Key('modmat-search-field')),
          'theory',
        );
        await tester.pump();

        expect(find.text('Search results'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    }
  });

  testWidgets('F6: subject filter chips are mounted (All + sections)',
      (tester) async {
    await _pumpPicker(tester, router);

    expect(find.text('All'), findsOneWidget);
    // Chip labels share names with the section cards, so both match.
    expect(find.text('Foundations'), findsWidgets);
    expect(find.text('Advanced'), findsWidgets);
  });

  testWidgets('F6: section chip filters the browse list', (tester) async {
    await _pumpPicker(tester, router);

    await tester.tap(find.text('Foundations').first);
    await tester.pump();

    expect(find.text('Open Foundations'), findsOneWidget);
    expect(find.text('Open Advanced'), findsNothing);

    await tester.tap(find.text('Advanced').first);
    await tester.pump();

    expect(find.text('Open Advanced'), findsOneWidget);
    expect(find.text('Open Foundations'), findsNothing);
  });

  testWidgets('F6: section chip ANDs with the text query', (tester) async {
    await _pumpPicker(tester, router);

    await tester.enterText(
      find.byKey(const Key('modmat-search-field')),
      'theory',
    );
    await tester.pump();
    expect(find.text('Search results'), findsOneWidget);

    await tester.tap(find.text('Foundations').first);
    await tester.pump();

    expect(find.text('Set Theory'), findsOneWidget);
    expect(find.text('Graph Theory Basics'), findsOneWidget);
    expect(find.text('Advanced Graph Theory'), findsNothing);
    expect(find.text('Number Theory'), findsNothing);
  });
}

GoRouter _buildRouter() {
  return GoRouter(
    initialLocation: '/picker',
    routes: [
      GoRoute(
        path: '/picker',
        builder: (context, state) => const ModmatPickerScreen(),
      ),
      ...[
        ...ModmatModuleRegistry.foundationsModules,
        ...ModmatModuleRegistry.advancedModules,
      ].map(
        (module) => GoRoute(
          path: module.route,
          builder: (context, state) => Scaffold(
            body: Text('Navigated to ${module.route}'),
          ),
        ),
      ),
    ],
  );
}

Future<void> _pumpPicker(
  WidgetTester tester,
  GoRouter router, {
  double width = 800,
  bool isDark = false,
}) async {
  final theme = ThemeProvider();
  if (isDark) {
    theme.toggleTheme();
  }

  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(size: Size(width, 900)),
      child: ChangeNotifierProvider.value(
        value: theme,
        child: MaterialApp.router(routerConfig: router),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 250));
}
