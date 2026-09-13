import 'dart:async';

import 'package:calculus_system/app_router.dart';
import 'package:calculus_system/screens/settings_screen.dart';
import 'package:calculus_system/services/update_service.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets(
      'renders shared update conclusions with normalized version display',
      (tester) async {
    await _pumpSettings(
      tester,
      () => _checkWithRawValues(
        installedVersion: ' v1.12.8+8 ',
        tagName: ' v1.12.9+release ',
      ),
    );
    expect(find.text('v1.12.8 — update to v1.12.9'), findsOneWidget);

    await _pumpSettings(
      tester,
      () => _checkWithRawValues(
        installedVersion: ' v1.12.8+8 ',
        tagName: ' v1.12.8+release ',
      ),
    );
    expect(find.text('v1.12.8 — up to date'), findsOneWidget);

    await _pumpSettings(
      tester,
      () => _checkWithRawValues(
        installedVersion: ' v1.12.9+9 ',
        tagName: ' v1.12.8+release ',
      ),
    );
    expect(find.text('v1.12.9 — up to date'), findsOneWidget);
    expect(find.textContaining('vv'), findsNothing);
    expect(find.textContaining('+'), findsNothing);
  });

  testWidgets('keeps an unavailable shared status non-offering',
      (tester) async {
    await _pumpSettings(
      tester,
      () async => const UpdateInfo(
        status: UpdateStatus.unavailable,
        installedVersion: '1.12.8',
      ),
    );

    expect(find.text('v1.12.8 — update status unavailable'), findsOneWidget);
    expect(find.textContaining('update to'), findsNothing);

    await _pumpSettings(
      tester,
      () => Future<UpdateInfo>.error(StateError('network unavailable')),
    );
    expect(find.text('Update status unavailable'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ignores delayed shared status completion after disposal',
      (tester) async {
    final delayed = Completer<UpdateInfo>();

    await _pumpSettings(tester, () => delayed.future);
    await tester.pumpWidget(const SizedBox());
    delayed.complete(const UpdateInfo(
      status: UpdateStatus.upToDate,
      installedVersion: '1.12.8',
      latestVersion: '1.12.8',
    ));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('manual check presents dialog when update is available',
      (tester) async {
    var dialogCount = 0;
    UpdateInfo? dialogInfo;

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: MaterialApp(
          home: SettingsScreen(
            key: UniqueKey(),
            updateChecker: () async => const UpdateInfo(
              status: UpdateStatus.updateAvailable,
              installedVersion: '1.12.8',
              latestVersion: '1.12.9',
              releaseUrl:
                  'https://github.com/Shuash11/MathCalcu/releases/tag/v1.12.9',
            ),
            isWeb: false,
            isAndroid: () => true,
            isWindows: () => false,
            showNativeUpdate: (_, info) {
              dialogCount += 1;
              dialogInfo = info;
            },
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('Check for updates'), findsOneWidget);
    await tester.tap(find.text('Check for updates'));
    await tester.pump();
    await tester.pump();

    expect(dialogCount, 1);
    expect(dialogInfo?.latestVersion, '1.12.9');
    expect(tester.takeException(), isNull);
  });

  test('default SettingsScreen constructor remains valid for AppRouter', () {
    expect(const SettingsScreen(), isA<SettingsScreen>());
    expect(AppRouter.router, isNotNull);
  });
}

Future<UpdateInfo> _checkWithRawValues({
  required String installedVersion,
  required String tagName,
}) {
  return UpdateService.checkForUpdate(
    packageInfoLoader: () async => PackageInfo(
      appName: 'MathCalcu',
      packageName: 'com.mathcalcu.app',
      version: installedVersion,
      buildNumber: '1',
    ),
    releaseFetcher: (_, __) => Future.value(
      http.Response(
        '{"tag_name":"$tagName"}',
        200,
      ),
    ),
  );
}

Future<void> _pumpSettings(
  WidgetTester tester,
  Future<UpdateInfo> Function() updateChecker,
) async {
  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: MaterialApp(
        home: SettingsScreen(
          key: UniqueKey(),
          updateChecker: updateChecker,
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 700));
}
