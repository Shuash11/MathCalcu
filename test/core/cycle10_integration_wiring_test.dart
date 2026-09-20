// Slice 8.5: wiring test — Integration Techniques registry entry resolves to
// its finals screen (the last slice of Item 8).
import 'package:calculus_system/app_router.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:calculus_system/topics/calculus/finals/finals_module_registry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Integration Techniques registry route renders its screen',
      (tester) async {
    final entry = FinalsModuleRegistry.modules
        .singleWhere((m) => m.label == 'Integration Techniques');
    expect(entry.route, '/topics/calculus/finals/integration');

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: ThemeProvider(),
        child: MaterialApp.router(routerConfig: AppRouter.router),
      ),
    );
    AppRouter.router.go(entry.route);
    await tester.pumpAndSettle();
    expect(find.textContaining('Integration Techniques'), findsWidgets);
    expect(find.text('Topic coming soon'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
