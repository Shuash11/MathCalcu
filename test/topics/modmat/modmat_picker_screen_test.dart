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

    expect(find.text('Foundations'), findsOneWidget);
    expect(find.text('Advanced'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('modmat-search-field')), '   ');
    await tester.pump();

    expect(find.text('Foundations'), findsOneWidget);
    expect(find.text('Advanced'), findsOneWidget);
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
    expect(find.text('Advanced'), findsOneWidget);
    expect(find.text('Foundations'), findsNothing);
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

    expect(find.text('Foundations'), findsOneWidget);
    expect(find.text('Advanced'), findsOneWidget);
  });

  testWidgets('activating a result uses its exact registry route',
      (tester) async {
    await _pumpPicker(tester, router);
    final module = ModmatModuleRegistry.foundationsModules.first;

    await tester.enterText(
      find.byKey(const Key('modmat-search-field')),
      module.label,
    );
    await tester.pump();
    await tester.tap(find.byKey(Key('modmat-search-result-${module.route}')));
    await tester.pumpAndSettle();

    expect(find.text('Navigated to ${module.route}'), findsOneWidget);
  });

  testWidgets('search results support keyboard activation', (tester) async {
    await _pumpPicker(tester, router);
    final module = ModmatModuleRegistry.foundationsModules.first;

    await tester.enterText(
      find.byKey(const Key('modmat-search-field')),
      module.label,
    );
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    expect(find.text('Navigated to ${module.route}'), findsOneWidget);
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
