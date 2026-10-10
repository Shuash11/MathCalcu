import 'dart:math' as math;

import 'package:calculus_system/main.dart';
import 'package:calculus_system/screens/category_picker_screen.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:calculus_system/topics/calculus/finals/finals_theme.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// Accessibility Guideline baseline for the app shell screens.
///
/// Pumps the home screen (through the real [CalculusApp]) and the
/// category picker screen (through a minimal go_router, matching the
/// existing picker test pattern) and asserts the Material a11y
/// guidelines — Android 48dp tap targets, iOS 44dp tap targets,
/// labeled tap targets, and WCAG text contrast — in light and dark.
void main() {
  final guidelines = <String, AccessibilityGuideline>{
    'android tap target': androidTapTargetGuideline,
    'iOS tap target': iOSTapTargetGuideline,
    'labeled tap target': labeledTapTargetGuideline,
    'text contrast': textContrastGuideline,
  };

  guidelines.forEach((name, guideline) {
    testWidgets('home screen meets the $name guideline (both themes)', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();

      for (final isDark in [false, true]) {
        final theme = ThemeProvider();
        if (isDark) theme.toggleTheme();

        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(
          ChangeNotifierProvider.value(
            value: theme,
            child: const CalculusApp(),
          ),
        );
        await tester.pump();
        // Consume the startup update-check retry (3s timer) so no timer
        // outlives the test, matching app_update_flow_test.dart.
        await tester.pump(const Duration(seconds: 3));
        await tester.pump();

        await expectLater(tester, meetsGuideline(guideline));
      }

      handle.dispose();
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    });

    testWidgets(
      'category picker screen meets the $name guideline (both themes)',
      (tester) async {
        final handle = tester.ensureSemantics();

        for (final isDark in [false, true]) {
          final theme = ThemeProvider();
          if (isDark) theme.toggleTheme();

          tester.view.physicalSize = const Size(390, 844);
          tester.view.devicePixelRatio = 1.0;

          final router = GoRouter(
            initialLocation: '/midterm',
            routes: [
              GoRoute(
                path: '/midterm',
                builder: (context, state) => const CategoryPickerScreen(),
              ),
            ],
          );

          await tester.pumpWidget(
            ChangeNotifierProvider.value(
              value: theme,
              child: MaterialApp.router(routerConfig: router),
            ),
          );
          await tester.pump();
          // Stagger fade-in for the module cards (900ms controller).
          await tester.pump(const Duration(milliseconds: 900));

          await expectLater(tester, meetsGuideline(guideline));

          router.dispose();
        }

        handle.dispose();
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
      },
    );
  });

  testWidgets('finals token pairs meet 4.5:1 contrast (both themes)', (
    tester,
  ) async {
    double ratio(Color fg, Color bg) {
      double lum(Color c) {
        double channel(double v) => (v <= 0.03928)
            ? v / 12.92
            : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
        return 0.2126 * channel(c.r) +
            0.7152 * channel(c.g) +
            0.0722 * channel(c.b);
      }

      final l1 = lum(fg);
      final l2 = lum(bg);
      final lighter = math.max(l1, l2);
      final darker = math.min(l1, l2);
      return (lighter + 0.05) / (darker + 0.05);
    }

    for (final isDark in [false, true]) {
      final theme = ThemeProvider();
      if (isDark) theme.toggleTheme();

      Color? card;
      Color? primary;
      Color? danger;
      Color? tertiary;
      Color? dangerNowBg;
      Color? onErrorNowFg;

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: theme,
          child: Builder(
            builder: (context) {
              // Capture inside build so watch() is valid. The *Now helpers
              // are event-time (listen: false) — valid anywhere.
              card = FinalsTheme.card(context);
              primary = FinalsTheme.primaryFor(context);
              danger = FinalsTheme.dangerFor(context);
              tertiary = FinalsTheme.tertiaryFor(context);
              dangerNowBg = FinalsTheme.dangerNow(context);
              onErrorNowFg = FinalsTheme.onErrorNow(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      await tester.pump();

      final mode = isDark ? 'dark' : 'light';

      expect(
        ratio(primary!, card!),
        greaterThanOrEqualTo(4.5),
        reason: 'primaryFor on card fails in $mode',
      );
      expect(
        ratio(danger!, card!),
        greaterThanOrEqualTo(4.5),
        reason: 'dangerFor on card fails in $mode',
      );
      expect(
        ratio(tertiary!, card!),
        greaterThanOrEqualTo(4.5),
        reason: 'tertiaryFor on card fails in $mode',
      );
      // SnackBar content Text uses onErrorNow via contentTextStyle, so this
      // pairing is the meaningful check for the 13 migrated SnackBars.
      expect(
        ratio(onErrorNowFg!, dangerNowBg!),
        greaterThanOrEqualTo(4.5),
        reason: 'onErrorNow on dangerNow background fails in $mode',
      );
    }
  });
}
