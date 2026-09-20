// Cycle 11 Item 4 Slice 4c: wiring test — Taylor & Maclaurin Series
// registry entry resolves to its finals screen (the last slice of
// Cycle 11 Item 4).
import 'package:calculus_system/app_router.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:calculus_system/topics/calculus/finals/finals_module_registry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Taylor & Maclaurin Series registry route renders its screen',
      (tester) async {
    final entry = FinalsModuleRegistry.modules
        .singleWhere((m) => m.label == 'Taylor & Maclaurin Series');
    expect(entry.route, '/topics/calculus/finals/taylor');

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: ThemeProvider(),
        child: MaterialApp.router(routerConfig: AppRouter.router),
      ),
    );
    AppRouter.router.go(entry.route);
    await tester.pumpAndSettle();
    expect(find.textContaining('Taylor & Maclaurin Series'), findsWidgets);
    expect(find.text('Topic coming soon'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
