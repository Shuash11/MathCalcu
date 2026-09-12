import 'dart:async';

import 'package:calculus_system/main.dart';
import 'package:calculus_system/services/update_service.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets(
      'shows the normalized up-to-date snackbar for equal and local-newer results',
      (tester) async {
    for (final versionCase in [
      (' v1.12.8+8 ', ' v1.12.8+release ', '1.12.8'),
      (' v1.12.9+9 ', ' v1.12.8+release ', '1.12.9'),
    ]) {
      await _pumpApp(
        tester,
        updateChecker: () => _checkWithRawValues(
          installedVersion: versionCase.$1,
          tagName: versionCase.$2,
        ),
      );

      expect(
        find.text('MathCalcu is up to date (v${versionCase.$3})'),
        findsOneWidget,
      );
      expect(find.text('Update available'), findsNothing);
      expect(find.textContaining('vv'), findsNothing);
      expect(find.textContaining('+'), findsNothing);
    }
  });

  testWidgets('uses the native offer only for a remote-newer result',
      (tester) async {
    for (final platform in [(true, false), (false, true)]) {
      var nativeOfferCount = 0;

      await _pumpApp(
        tester,
        updateChecker: () async => const UpdateInfo(
          status: UpdateStatus.updateAvailable,
          installedVersion: '1.12.8',
          latestVersion: '1.12.9',
          releaseUrl: 'https://example.com/releases/1.12.9',
        ),
        isWeb: false,
        isAndroid: () => platform.$1,
        isWindows: () => platform.$2,
        showNativeUpdate: (_, __) => nativeOfferCount += 1,
      );

      expect(nativeOfferCount, 1);
    }
  });

  testWidgets('uses the web offer before evaluating native platform checks',
      (tester) async {
    var webOfferCount = 0;

    await _pumpApp(
      tester,
      updateChecker: () async => const UpdateInfo(
        status: UpdateStatus.updateAvailable,
        installedVersion: '1.12.8',
        latestVersion: '1.12.9',
      ),
      isWeb: true,
      isAndroid: () => throw StateError('native platform was evaluated on web'),
      showWebUpdate: (_, __) => webOfferCount += 1,
    );

    expect(webOfferCount, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('uses the release-link offer on an unsupported native platform',
      (tester) async {
    UpdateInfo? releaseOffer;

    await _pumpApp(
      tester,
      updateChecker: () async => const UpdateInfo(
        status: UpdateStatus.updateAvailable,
        installedVersion: '1.12.8',
        latestVersion: '1.12.9',
        releaseUrl:
            'https://github.com/Shuash11/MathCalcu/releases/tag/v1.12.9',
      ),
      isWeb: false,
      isAndroid: () => false,
      isWindows: () => false,
      showReleaseLinkUpdate: (_, info) => releaseOffer = info,
    );

    expect(
      releaseOffer?.releaseUrl,
      'https://github.com/Shuash11/MathCalcu/releases/tag/v1.12.9',
    );
  });

  testWidgets('suppresses untrusted unsupported-native release URLs',
      (tester) async {
    const invalidReleaseUrls = [
      '',
      'http://github.com/Shuash11/MathCalcu/releases/tag/v1.12.9',
      '/Shuash11/MathCalcu/releases/tag/v1.12.9',
      'javascript:alert(1)',
      'file:///Shuash11/MathCalcu/releases/tag/v1.12.9',
      'custom://github.com/Shuash11/MathCalcu/releases/tag/v1.12.9',
      'https://example.com/Shuash11/MathCalcu/releases/tag/v1.12.9',
      'https://github.com/Other/MathCalcu/releases/tag/v1.12.9',
      'https://user@github.com/Shuash11/MathCalcu/releases/tag/v1.12.9',
    ];

    for (final releaseUrl in invalidReleaseUrls) {
      var releaseOfferCount = 0;
      await _pumpApp(
        tester,
        updateChecker: () async => UpdateInfo(
          status: UpdateStatus.updateAvailable,
          installedVersion: '1.12.8',
          latestVersion: '1.12.9',
          releaseUrl: releaseUrl,
        ),
        isWeb: false,
        isAndroid: () => false,
        isWindows: () => false,
        showReleaseLinkUpdate: (_, __) => releaseOfferCount += 1,
      );

      expect(releaseOfferCount, 0, reason: releaseUrl);
    }
  });

  testWidgets('does not offer unavailable results or invoke a failing checker',
      (tester) async {
    var offerCount = 0;

    await _pumpApp(
      tester,
      updateChecker: () async => const UpdateInfo(
        status: UpdateStatus.unavailable,
      ),
      isWeb: true,
      showWebUpdate: (_, __) => offerCount += 1,
    );

    expect(offerCount, 0);
    expect(find.text('Update available'), findsNothing);

    await _pumpApp(
      tester,
      updateChecker: () => Future<UpdateInfo>.error(StateError('offline')),
      isWeb: true,
      showWebUpdate: (_, __) => offerCount += 1,
    );

    expect(offerCount, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('does not offer a completed result without a navigator context',
      (tester) async {
    var offerCount = 0;

    await _pumpApp(
      tester,
      updateChecker: () async => const UpdateInfo(
        status: UpdateStatus.updateAvailable,
        installedVersion: '1.12.8',
        latestVersion: '1.12.9',
      ),
      navigatorContext: () => null,
      isWeb: true,
      showWebUpdate: (_, __) => offerCount += 1,
    );

    expect(offerCount, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ignores a delayed result after disposal', (tester) async {
    final delayed = Completer<UpdateInfo>();
    var offerCount = 0;
    var navigatorContextCalls = 0;

    await _pumpApp(
      tester,
      updateChecker: () => delayed.future,
      navigatorContext: () {
        navigatorContextCalls += 1;
        throw StateError('navigator context accessed after disposal');
      },
      isWeb: true,
      showWebUpdate: (_, __) => offerCount += 1,
    );
    await tester.pumpWidget(const SizedBox());
    delayed.complete(const UpdateInfo(
      status: UpdateStatus.updateAvailable,
      installedVersion: '1.12.8',
      latestVersion: '1.12.9',
    ));
    await tester.pump();

    expect(offerCount, 0);
    expect(navigatorContextCalls, 0);
    expect(tester.takeException(), isNull);
  });

  test('default CalculusApp constructor remains valid', () {
    expect(const CalculusApp(), isA<CalculusApp>());
  });

  testWidgets('runs one update check across a rebuild', (tester) async {
    var checkCount = 0;
    final theme = ThemeProvider();
    final app = CalculusApp(
      updateChecker: () async {
        checkCount += 1;
        return const UpdateInfo(status: UpdateStatus.unavailable);
      },
      navigatorContext: () => null,
    );

    await tester
        .pumpWidget(ChangeNotifierProvider.value(value: theme, child: app));
    await tester.pump();
    await tester.pump();
    await tester
        .pumpWidget(ChangeNotifierProvider.value(value: theme, child: app));
    await tester.pump();

    expect(checkCount, 1);
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

Future<void> _pumpApp(
  WidgetTester tester, {
  required Future<UpdateInfo> Function() updateChecker,
  bool? isWeb,
  bool Function()? isAndroid,
  bool Function()? isWindows,
  void Function(BuildContext, UpdateInfo)? showNativeUpdate,
  void Function(BuildContext, String)? showWebUpdate,
  void Function(BuildContext, UpdateInfo)? showReleaseLinkUpdate,
  BuildContext? Function()? navigatorContext,
}) async {
  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: CalculusApp(
        key: UniqueKey(),
        updateChecker: updateChecker,
        isWeb: isWeb,
        isAndroid: isAndroid,
        isWindows: isWindows,
        showNativeUpdate: showNativeUpdate,
        showWebUpdate: showWebUpdate,
        showReleaseLinkUpdate: showReleaseLinkUpdate,
        navigatorContext: navigatorContext,
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
}
