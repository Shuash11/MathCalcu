import 'package:calculus_system/calculator/calculator_screen.dart';
import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/home/widgets/home_card.dart';
import 'package:calculus_system/shared/widgets/module_card.dart';
import 'package:calculus_system/shared/widgets/solution_steps_modal.dart';
import 'package:calculus_system/shared/widgets/steps_drawer.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:calculus_system/topics/calculus/finals/screens/evaluating_limits_screen/by_substitution/substitution_limit_screen.dart';
import 'package:calculus_system/theme/app_design.dart';
import 'package:calculus_system/services/update_service.dart';
import 'package:calculus_system/widgets/donate_sheet.dart';
import 'package:calculus_system/widgets/update_dialog.dart';
import 'package:calculus_system/widgets/web_update_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

Widget _app(Widget child, ThemeProvider theme) {
  return ChangeNotifierProvider.value(
    value: theme,
    child: MaterialApp(home: Scaffold(body: child)),
  );
}

Widget _fullApp(Widget child, ThemeProvider theme) {
  return ChangeNotifierProvider.value(
    value: theme,
    child: MaterialApp(home: Scaffold(body: child)),
  );
}

ThemeProvider _theme(bool isDark) {
  final theme = ThemeProvider();
  if (isDark) theme.toggleTheme();
  return theme;
}

void _mockClipboard() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(SystemChannels.platform, (call) async => null);
}

void main() {
  testWidgets('calculator equality key has a theme-aware readable foreground',
      (WidgetTester tester) async {
    final theme = ThemeProvider()..toggleTheme();
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_app(const CalculatorScreen(), theme));

    final equality = tester.widget<Text>(find.text('='));
    expect((equality.style?.color), theme.surface);
  });

  testWidgets('module cards use the active theme accent and expose one action',
      (WidgetTester tester) async {
    final theme = ThemeProvider()..toggleTheme();
    await tester.pumpWidget(
      _app(
        ModuleCard(
          icon: Icons.functions_rounded,
          title: 'Inequalities',
          subtitle: 'Solve inequalities',
          accentColor: const Color(0xFF334155),
          onTap: () {},
        ),
        theme,
      ),
    );

    expect(
      (tester.widget<Icon>(find.byIcon(Icons.functions_rounded))).color,
      theme.accentColor,
    );
    expect(find.bySemanticsLabel('Inequalities'), findsOneWidget);
  });

  testWidgets('home cards expose one labeled action with a readable icon',
      (WidgetTester tester) async {
    final theme = ThemeProvider()..toggleTheme();
    await tester.pumpWidget(
      _app(
        HomeCard(
          icon: Icons.calculate_rounded,
          label: 'Calculator',
          accent: theme.accentColor,
          onTap: () {},
        ),
        theme,
      ),
    );

    expect(find.bySemanticsLabel('Calculator'), findsOneWidget);
    expect(
      (tester.widget<Icon>(find.byIcon(Icons.calculate_rounded))).color,
      theme.surface,
    );
  });

  testWidgets('O3/O4 update dialogs render actual widgets in both themes',
      (WidgetTester tester) async {
    const info = UpdateInfo(
      latestVersion: '1.2.3',
      currentVersion: '1.2.2',
      releaseUrl: 'https://example.invalid/release',
      releaseNotes: 'Accessibility fixes',
      hasUpdate: true,
    );

    for (final isDark in [false, true]) {
      final theme = _theme(isDark);
      await tester.pumpWidget(_app(const SizedBox(), theme));
      showUpdateDialog(tester.element(find.byType(Scaffold)), info);
      await tester.pumpAndSettle();

      expect(find.text('Update available'), findsOneWidget);
      expect(find.text('Version 1.2.3'), findsOneWidget);
      expect(tester.getSize(find.byType(FilledButton)).height,
          greaterThanOrEqualTo(44));
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Later'));
      await tester.pumpAndSettle();

      showWebUpdateDialog(tester.element(find.byType(Scaffold)), '1.2.3');
      await tester.pumpAndSettle();
      expect(find.text('Update available'), findsOneWidget);
      expect(find.text('Version 1.2.3'), findsOneWidget);
      expect(tester.getSize(find.byType(FilledButton)).height,
          greaterThanOrEqualTo(44));
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Later'));
      await tester.pumpAndSettle();
    }
  });

  testWidgets(
      'O5/O6 donate sheet and QR dialog render actual widgets in both themes',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final isDark in [false, true]) {
      final theme = _theme(isDark);
      await tester.pumpWidget(_app(const SizedBox(), theme));
      showDonateSheet(tester.element(find.byType(Scaffold)));
      await tester.pumpAndSettle();

      expect(find.text('Buy us a Coffee'), findsOneWidget);
      expect(find.bySemanticsLabel('Zoom donation QR code'), findsOneWidget);
      await tester
          .ensureVisible(find.bySemanticsLabel('Zoom donation QR code'));
      await tester.tap(find.bySemanticsLabel('Zoom donation QR code'));
      await tester.pumpAndSettle();
      expect(find.text('Tap anywhere to close'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Tap anywhere to close'));
      await tester.pumpAndSettle();
      Navigator.of(tester.element(find.byType(Scaffold))).pop();
      await tester.pumpAndSettle();
    }
  });

  testWidgets(
      'O7/O8 steps drawer and solution modal render actual widgets in both themes',
      (WidgetTester tester) async {
    const steps = [StepModel(stepNumber: 1, latex: r'x = 2')];
    for (final isDark in [false, true]) {
      final theme = _theme(isDark);
      await tester.pumpWidget(_app(const SizedBox(), theme));
      final context = tester.element(find.byType(Scaffold));
      showStepsDrawer(
        context: context,
        steps: steps,
        accentColor: theme.accentColor,
        title: 'Steps',
      );
      await tester.pumpAndSettle();
      expect(find.text('1 steps'), findsOneWidget);
      expect(find.bySemanticsLabel('Copy solution'), findsOneWidget);
      expect(tester.getSize(find.bySemanticsLabel('Copy solution')).height,
          greaterThanOrEqualTo(44));
      await tester.tap(find.bySemanticsLabel('Close solution steps'));
      await tester.pumpAndSettle();

      showSolutionStepsModal(
        context: tester.element(find.byType(Scaffold)),
        title: 'Solution Steps',
        design: AppDesign.app,
        child: const Text('Proof body'),
      );
      await tester.pumpAndSettle();
      expect(find.text('Solution Steps'), findsOneWidget);
      expect(find.text('Proof body'), findsOneWidget);
      expect(
        tester.getSize(find.bySemanticsLabel('Close solution steps')).height,
        greaterThanOrEqualTo(44),
      );
      expect(tester.takeException(), isNull);
      await tester.tap(find.bySemanticsLabel('Close solution steps'));
      await tester.pumpAndSettle();
    }
  });

  testWidgets('O9-O14 finals input and variable picker render in both themes',
      (WidgetTester tester) async {
    for (final isDark in [false, true]) {
      final theme = _theme(isDark);
      await tester.pumpWidget(
        _fullApp(SubstitutionLimitScreen(key: ValueKey(isDark)), theme),
      );
      await tester.pump(const Duration(milliseconds: 700));
      await tester.tap(find.bySemanticsLabel('Insert variable x'));
      await tester.pumpAndSettle();

      expect(find.text('Select Limit Variable'), findsOneWidget);
      expect(find.text('y'), findsOneWidget);
      await tester.tap(find.text('y'));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Insert variable y'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('O15 steps drawer copy reports feedback in both themes',
      (WidgetTester tester) async {
    _mockClipboard();
    addTearDown(() => TestDefaultBinaryMessengerBinding
        .instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));

    for (final isDark in [false, true]) {
      final theme = _theme(isDark);
      await tester.pumpWidget(_app(const SizedBox(), theme));
      showStepsDrawer(
        context: tester.element(find.byType(Scaffold)),
        steps: const [StepModel(stepNumber: 1, latex: r'x = 2')],
        accentColor: theme.accentColor,
        title: 'Steps',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Copy solution'));
      await tester.pump();
      expect(find.text('Solution copied to clipboard'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Close solution steps'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('O15 donate sheet copy reports feedback in both themes',
      (WidgetTester tester) async {
    _mockClipboard();
    addTearDown(() => TestDefaultBinaryMessengerBinding
        .instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));

    for (final isDark in [false, true]) {
      final theme = _theme(isDark);
      await tester.pumpWidget(_app(const SizedBox(), theme));
      showDonateSheet(tester.element(find.byType(Scaffold)));
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();
      final copy = find.text('Copy');
      await tester.tap(copy);
      await tester.pump();

      expect(find.text('Number copied!'), findsOneWidget);
      expect(tester.takeException(), isNull);
      Navigator.of(tester.element(find.byType(Scaffold))).pop();
      await tester.pumpAndSettle();
    }
  });
}
