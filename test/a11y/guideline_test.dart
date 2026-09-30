import 'package:calculus_system/main.dart';
import 'package:calculus_system/screens/category_picker_screen.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:flutter/material.dart';
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
    testWidgets('home screen meets the $name guideline (both themes)',
        (tester) async {
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
    });
  });
}
