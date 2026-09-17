import 'dart:convert';

import 'package:calculus_system/services/update_checksum.dart';
import 'package:calculus_system/services/update_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  group('UpdateChecksum.sha256Hex', () {
    test('matches the known SHA-256 vector for "abc"', () {
      expect(
        UpdateChecksum.sha256Hex('abc'.codeUnits),
        'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad',
      );
    });

    test('hashesEqual ignores case but rejects bad input', () {
      const hash =
          'BA7816BF8F01CFEA414140DE5DAE2223B00361A396177A9CB410FF61F20015AD';
      expect(
        UpdateChecksum.hashesEqual(
          hash.toLowerCase(),
          hash,
        ),
        isTrue,
      );
      expect(UpdateChecksum.hashesEqual(hash, '${hash}00'), isFalse);
      expect(UpdateChecksum.hashesEqual(hash, 'not-a-hash'), isFalse);
      expect(UpdateChecksum.isSha256Hex(hash), isTrue);
      expect(UpdateChecksum.isSha256Hex('xyz'), isFalse);
    });
  });

  group('UpdateChecksum.parseChecksumFile', () {
    test('parses GNU format with plain and starred names', () {
      const manifest =
          'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad  MathCalcu.apk\n'
          'ca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb *MathCalcu-Setup.exe\n';
      expect(
        UpdateChecksum.parseChecksumFile(manifest, 'MathCalcu.apk'),
        'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad',
      );
      expect(
        UpdateChecksum.parseChecksumFile(manifest, 'MathCalcu-Setup.exe'),
        'ca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb',
      );
    });

    test('parses BSD format and skips comments', () {
      const manifest = '# MathCalcu checksums\n'
          'SHA256 (MathCalcu.apk) = ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad\n';
      expect(
        UpdateChecksum.parseChecksumFile(manifest, 'MathCalcu.apk'),
        'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad',
      );
      expect(
        UpdateChecksum.parseChecksumFile(manifest, 'other.apk'),
        isNull,
      );
    });
  });

  group('UpdateChecksum.extractFromReleaseBody', () {
    test('prefers the digest on the binary line', () {
      const body =
          'APK: ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad MathCalcu.apk\n'
          'EXE: ca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb MathCalcu-Setup.exe\n';
      expect(
        UpdateChecksum.extractFromReleaseBody(body, 'MathCalcu.apk'),
        'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad',
      );
    });

    test('falls back to a lone body-wide digest, else null', () {
      expect(
        UpdateChecksum.extractFromReleaseBody(
          'sha256 ca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb done',
          'MathCalcu.apk',
        ),
        'ca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb',
      );
      expect(
        UpdateChecksum.extractFromReleaseBody(
          'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad and '
              'ca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb',
          'MathCalcu.apk',
        ),
        isNull,
      );
    });
  });

  group('UpdateChecksum.resolveFromReleaseJson', () {
    test('uses the per-asset digest first', () {
      final resolved = UpdateChecksum.resolveFromReleaseJson(
        {
          'assets': [
            {
              'name': 'MathCalcu.apk',
              'browser_download_url': 'https://example.com/a.apk',
              'digest':
                  'sha256:ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad',
            },
          ],
        },
        'MathCalcu.apk',
      );
      expect(resolved.sha256Hex,
          'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad');
    });

    test('falls back to a manifest URL', () {
      final resolved = UpdateChecksum.resolveFromReleaseJson(
        {
          'assets': [
            {
              'name': 'checksums.txt',
              'browser_download_url': 'https://example.com/checksums.txt',
            },
          ],
        },
        'MathCalcu.apk',
      );
      expect(resolved.sha256Hex, isNull);
      expect(resolved.checksumFileUrl, 'https://example.com/checksums.txt');
    });

    test('recognizes the published extensionless SHA256SUMS asset', () {
      final resolved = UpdateChecksum.resolveFromReleaseJson(
        {
          'assets': [
            {
              'name': 'MathCalcu.apk',
              'browser_download_url': 'https://example.com/a.apk',
            },
            {
              'name': 'SHA256SUMS',
              'browser_download_url': 'https://example.com/SHA256SUMS',
            },
            {
              'name': 'release-manifest.json',
              'browser_download_url':
                  'https://example.com/release-manifest.json',
            },
          ],
        },
        'MathCalcu.apk',
      );
      expect(resolved.sha256Hex, isNull);
      expect(resolved.checksumFileUrl, 'https://example.com/SHA256SUMS');
    });
  });

  group('UpdateService checksum wiring', () {
    test('checkForUpdate surfaces published digests', () async {
      final info = await UpdateService.checkForUpdate(
        packageInfoLoader: () async => PackageInfo(
          appName: 'MathCalcu',
          packageName: 'com.mathcalcu.app',
          version: '1.12.8',
          buildNumber: '1',
        ),
        releaseFetcher: (_, __) => Future.value(
          http.Response(
            jsonEncode({
              'tag_name': '1.12.9',
              'html_url':
                  'https://github.com/Shuash11/MathCalcu/releases/tag/v1.12.9',
              'body': 'Bug fixes',
              'assets': [
                {
                  'name': 'MathCalcu.apk',
                  'browser_download_url': 'https://example.com/a.apk',
                  'digest':
                      'sha256:ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad',
                },
              ],
            }),
            200,
          ),
        ),
      );

      expect(info.status, UpdateStatus.updateAvailable);
      expect(info.apkSha256,
          'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad');
      expect(info.sha256ForBinary('MathCalcu.apk'), info.apkSha256);
      expect(info.sha256ForBinary('other.bin'), isNull);
    });

    test('downloadAndInstall fails closed without a checksum', () async {
      final result = await UpdateService.downloadAndInstall(
        null,
        releaseFetcher: (_, __) =>
            Future.value(http.Response('not found', 404)),
      );
      expect(result, contains('cannot be verified'));
    });

    test('downloadAndInstall rejects a malformed override', () async {
      final result = await UpdateService.downloadAndInstall(
        null,
        expectedSha256: 'not-a-hash',
      );
      expect(result, contains('misconfigured'));
    });
  });
}
