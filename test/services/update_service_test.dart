import 'dart:async';

import 'package:calculus_system/services/update_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  group('UpdateService.checkForUpdate', () {
    test('normalizes whitespace, one leading v, and valid build metadata',
        () async {
      for (final installedVersion in [
        '1.12.8',
        ' v1.12.8 ',
        '1.12.8+8',
        '1.12.8+build.42-release',
      ]) {
        final result = await _check(
          installedVersion: installedVersion,
          tagName: ' v1.12.8+release.42-build ',
        );

        expect(result.status, UpdateStatus.upToDate);
        expect(result.installedVersion, '1.12.8');
        expect(result.latestVersion, '1.12.8');
        expect(result.hasUpdate, isFalse);
      }
    });

    test('compares multi-digit and unequal-length numeric components',
        () async {
      final multiDigit = await _check(
        installedVersion: '1.9',
        tagName: '1.12',
      );
      final equalLength = await _check(
        installedVersion: '1.2',
        tagName: '1.2.0',
      );
      final longerRemote = await _check(
        installedVersion: '1.2',
        tagName: '1.2.0.1',
      );

      expect(multiDigit.status, UpdateStatus.updateAvailable);
      expect(equalLength.status, UpdateStatus.upToDate);
      expect(longerRemote.status, UpdateStatus.updateAvailable);
    });

    test('offers an update only when the remote version is newer', () async {
      final remoteNewer = await _check(
        installedVersion: '1.12.8',
        tagName: '1.12.9',
      );
      final equal = await _check(
        installedVersion: '1.12.8',
        tagName: '1.12.8',
      );
      final localNewer = await _check(
        installedVersion: '1.12.9',
        tagName: '1.12.8',
      );

      expect(remoteNewer.status, UpdateStatus.updateAvailable);
      expect(remoteNewer.hasUpdate, isTrue);
      expect(equal.status, UpdateStatus.upToDate);
      expect(equal.hasUpdate, isFalse);
      expect(localNewer.status, UpdateStatus.upToDate);
      expect(localNewer.hasUpdate, isFalse);
    });

    test('preserves normalized versions and release details on success',
        () async {
      final result = await _check(
        installedVersion: ' v1.12.8+8 ',
        tagName: ' v1.13.0+9 ',
        releaseUrl:
            'https://github.com/Shuash11/MathCalcu/releases/tag/v1.13.0',
        releaseNotes: 'Release notes',
      );

      expect(result.status, UpdateStatus.updateAvailable);
      expect(result.installedVersion, '1.12.8');
      expect(result.latestVersion, '1.13.0');
      expect(result.releaseUrl, contains('v1.13.0'));
      expect(result.releaseNotes, 'Release notes');
    });

    test('returns unavailable for invalid installed versions and tags',
        () async {
      for (final invalidInstalled in ['', '1..2', '1.two', '1.2+']) {
        final result = await _check(
          installedVersion: invalidInstalled,
          tagName: '1.12.9',
        );

        expect(result.status, UpdateStatus.unavailable);
        expect(result.hasUpdate, isFalse);
      }

      for (final invalidTag in ['', 'v', '1..2', '1.two', '1.2+']) {
        final result = await _check(
          installedVersion: '1.12.8',
          tagName: invalidTag,
        );

        expect(result.status, UpdateStatus.unavailable);
        expect(result.installedVersion, '1.12.8');
        expect(result.hasUpdate, isFalse);
      }
    });

    test('returns unavailable for malformed installed build metadata',
        () async {
      for (final installedVersion in _malformedBuildMetadata) {
        final result = await _check(
          installedVersion: installedVersion,
          tagName: '1.12.9',
        );

        expect(result.status, UpdateStatus.unavailable);
        expect(result.hasUpdate, isFalse);
      }
    });

    test('returns unavailable for malformed remote build metadata', () async {
      for (final tagName in _malformedBuildMetadata) {
        final result = await _check(
          installedVersion: '1.12.8',
          tagName: tagName.replaceFirst('1.12.8', '1.12.9'),
        );

        expect(result.status, UpdateStatus.unavailable);
        expect(result.hasUpdate, isFalse);
      }
    });

    test('returns unavailable for non-200 and malformed JSON responses',
        () async {
      final non200 = await _check(
        installedVersion: '1.12.8',
        response: http.Response('not found', 404),
      );
      final malformedJson = await _check(
        installedVersion: '1.12.8',
        response: http.Response('not json', 200),
      );

      expect(non200.status, UpdateStatus.unavailable);
      expect(non200.installedVersion, '1.12.8');
      expect(malformedJson.status, UpdateStatus.unavailable);
      expect(malformedJson.installedVersion, '1.12.8');
    });

    test('returns unavailable for HTTP errors and timeouts', () async {
      final httpFailure = await _check(
        installedVersion: '1.12.8',
        releaseFetcher: (_, __) => Future<http.Response>.error(
          StateError('network unavailable'),
        ),
      );
      final timeout = await _check(
        installedVersion: '1.12.8',
        releaseFetcher: (_, __) => Future<http.Response>.error(
          TimeoutException('request timed out'),
        ),
      );

      expect(httpFailure.status, UpdateStatus.unavailable);
      expect(httpFailure.installedVersion, '1.12.8');
      expect(timeout.status, UpdateStatus.unavailable);
      expect(timeout.installedVersion, '1.12.8');
    });

    test('returns unavailable when package metadata loading fails', () async {
      final result = await UpdateService.checkForUpdate(
        packageInfoLoader: () => Future<PackageInfo>.error(
          StateError('package metadata unavailable'),
        ),
        releaseFetcher: (_, __) => Future.value(
          http.Response('{"tag_name":"1.12.9"}', 200),
        ),
      );

      expect(result.status, UpdateStatus.unavailable);
      expect(result.installedVersion, isNull);
      expect(result.hasUpdate, isFalse);
    });
  });
}

const _malformedBuildMetadata = [
  '1.12.8+?',
  '1.12.8+.',
  '1.12.8+foo..bar',
  '1.12.8+foo.',
  '1.12.8+.foo',
  '1.12.8+foo+bar',
  '1.12.8+foo bar',
  '1.12.8+foo_bar',
];

Future<UpdateInfo> _check({
  required String installedVersion,
  String tagName = '1.12.9',
  String releaseUrl = 'https://example.com/release',
  String releaseNotes = 'Notes',
  http.Response? response,
  ReleaseFetcher? releaseFetcher,
}) {
  return UpdateService.checkForUpdate(
    packageInfoLoader: () async => PackageInfo(
      appName: 'MathCalcu',
      packageName: 'com.mathcalcu.app',
      version: installedVersion,
      buildNumber: '1',
    ),
    releaseFetcher: releaseFetcher ??
        (_, __) => Future.value(
              response ??
                  http.Response(
                    '{"tag_name":"$tagName","html_url":"$releaseUrl","body":"$releaseNotes"}',
                    200,
                  ),
            ),
  );
}
