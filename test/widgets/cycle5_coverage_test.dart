import 'package:calculus_system/models/developer.dart';
import 'package:calculus_system/notes/notes_screen.dart';
import 'package:calculus_system/screens/about_sheets.dart';
import 'package:calculus_system/screens/developers_screen.dart';
import 'package:calculus_system/search/global_search_screen.dart';
import 'package:calculus_system/search/unified_search.dart';
import 'package:calculus_system/shared/widgets/curriculum_result_card.dart';
import 'package:calculus_system/widgets/developer_tile.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _wrap(Widget child, ThemeProvider theme) {
  return ChangeNotifierProvider.value(
    value: theme,
    child: MaterialApp(home: Scaffold(body: child)),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(const {});
  });

  group('NotesScreen (F4)', () {
    testWidgets('renders title, placeholder copy, and icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(const NotesScreen(), ThemeProvider()));
      await tester.pumpAndSettle();

      expect(find.text('Notes'), findsOneWidget);
      expect(find.text('Coming soon!'), findsOneWidget);
      expect(find.byIcon(Icons.note_alt_rounded), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('DevelopersScreen (F4)', () {
    testWidgets('renders header and one tile per developer',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(const DevelopersScreen(), ThemeProvider()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Developers'), findsOneWidget);
      expect(find.text(developers.first.name), findsWidgets);
      // Tiles lazy-build in the ListView; at least the visible ones exist
      // and the registry backs every row.
      expect(find.byType(DeveloperTile), findsWidgets);
      expect(find.byType(ListView), findsOneWidget);
      expect(developers, isNotEmpty);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tapping a tile expands its details',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(const DevelopersScreen(), ThemeProvider()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DeveloperTile).first);
      await tester.pumpAndSettle();

      expect(find.text('Email'), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });

  group('UnifiedSearch (F4 unit)', () {
    test('blank query returns empty list', () {
      expect(UnifiedSearch.search(''), isEmpty);
      expect(UnifiedSearch.search('   '), isEmpty);
    });

    test('midterm query fans out (slope)', () {
      final hits = UnifiedSearch.search('slope');
      expect(hits, isNotEmpty);
      expect(hits.any((h) => h.label.toLowerCase().contains('slope')), isTrue);
      expect(hits.any((h) => h.source == 'Midterm'), isTrue);
    });

    test('curriculum query fans out (ratio)', () {
      final hits = UnifiedSearch.search('ratio');
      expect(hits, isNotEmpty);
    });

    test('unknown query returns empty list', () {
      expect(UnifiedSearch.search('zzzz_no_such_topic_xyz'), isEmpty);
    });

    test('isStub guards future routes only', () {
      const wired = UnifiedHit(
        label: 'slope',
        subtitle: 'Find slope between two points',
        route: '/slope',
        icon: Icons.show_chart,
        source: 'Midterm',
      );
      expect(wired.isStub, isFalse);

      const future = UnifiedHit(
        label: 'Future',
        subtitle: 'Not wired',
        route: '/grade9/future',
        icon: Icons.school_rounded,
        source: 'G9',
      );
      expect(future.isStub, isTrue);
    });
  });

  group('GlobalSearchScreen (F4)', () {
    testWidgets('renders search field with default hint section',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(const GlobalSearchScreen(), ThemeProvider()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Search'), findsOneWidget);
      expect(
        find.text('Search topics, e.g. ratio, pie, derivative'),
        findsOneWidget,
      );
      expect(find.textContaining('Try "ratio"'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('typing a known topic shows result cards',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(const GlobalSearchScreen(), ThemeProvider()),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField),
        'slope',
      );
      await tester.pumpAndSettle();

      expect(find.byType(UnifiedResultCard), findsWidgets);
      expect(find.byTooltip('Clear search'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('unknown query shows empty state with clear action',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(const GlobalSearchScreen(), ThemeProvider()),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField),
        'zzzz_no_such_topic_xyz',
      );
      await tester.pumpAndSettle();

      expect(find.text('No topics found'), findsOneWidget);
      expect(find.text('Clear search'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('AboutSheet (F4)', () {
    testWidgets('shows MathCalc header, divider, and developer cards',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(const SizedBox(), ThemeProvider()));
      showAboutSheet(tester.element(find.byType(Scaffold)));
      await tester.pumpAndSettle();

      expect(find.text('MathCalc'), findsOneWidget);
      expect(find.text('DEVELOPERS'), findsOneWidget);
      expect(find.text(developers.first.name), findsWidgets);
      expect(find.byType(DeveloperTile), findsWidgets);
      expect(tester.takeException(), isNull);

      Navigator.of(tester.element(find.byType(Scaffold))).pop();
      await tester.pumpAndSettle();
    });
  });
}
