import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'package:package_info_plus/package_info_plus.dart';

import 'update_checksum.dart';

/// Shared update conclusion consumed by the app entry point, the Settings
/// screen, and their widget tests.
enum UpdateStatus {
  updateAvailable,
  upToDate,
  unavailable,
}

class UpdateInfo {
  final UpdateStatus status;
  final String? installedVersion;
  final String latestVersion;
  final String releaseUrl;
  final String releaseNotes;

  /// Expected SHA-256 digests published with the release (null when the
  /// release predates checksum publication). Populated by [checkForUpdate]
  /// without extra I/O; [downloadAndInstall] re-resolves (fetching a
  /// `checksums.txt` manifest when needed) and refuses to install when no
  /// digest can be established.
  final String? apkSha256;
  final String? exeSha256;

  /// Manifest URL carrying the digests when no inline hash was published.
  final String? checksumUrl;

  const UpdateInfo({
    required this.status,
    this.installedVersion,
    this.latestVersion = '',
    this.releaseUrl = '',
    this.releaseNotes = '',
    this.apkSha256,
    this.exeSha256,
    this.checksumUrl,
  });

  bool get hasUpdate => status == UpdateStatus.updateAvailable;

  /// Digest for [binaryName] (`MathCalcu.apk` / `MathCalcu-Setup.exe`),
  /// or null when unknown.
  String? sha256ForBinary(String binaryName) {
    final lower = binaryName.toLowerCase();
    if (lower.endsWith('.apk')) return apkSha256;
    if (lower.endsWith('.exe')) return exeSha256;
    return null;
  }
}

/// Loads the installed package metadata. Injectable for tests.
typedef PackageInfoLoader = Future<PackageInfo> Function();

/// Fetches the latest-release payload. Injectable for tests.
typedef ReleaseFetcher = Future<http.Response> Function(
  Uri url,
  Map<String, String> headers,
);

/// Fetches a checksum manifest. Injectable for tests.
typedef ChecksumFetcher = Future<http.Response> Function(Uri url);

class UpdateService {
  static const String _owner = 'Shuash11';
  static const String _repo = 'MathCalcu';
  static const String _apiUrl =
      'https://api.github.com/repos/$_owner/$_repo/releases/latest';

  static const Map<String, String> _headers = {
    'Accept': 'application/vnd.github.v3+json',
  };

  /// Check for an update, normalizing installed and remote versions so
  /// surrounding whitespace, a single leading `v`, and build metadata
  /// never leak into the UI. Never throws — failures map to
  /// [UpdateStatus.unavailable].
  static Future<UpdateInfo> checkForUpdate({
    PackageInfoLoader? packageInfoLoader,
    ReleaseFetcher? releaseFetcher,
  }) async {
    String? installedVersion;
    try {
      final packageInfo =
          await (packageInfoLoader?.call() ?? PackageInfo.fromPlatform());
      installedVersion = _normalizeVersion(packageInfo.version);
      if (installedVersion == null) {
        return const UpdateInfo(status: UpdateStatus.unavailable);
      }
    } catch (_) {
      return const UpdateInfo(status: UpdateStatus.unavailable);
    }

    try {
      final fetch =
          releaseFetcher ?? ((url, headers) => http.get(url, headers: headers));
      final response = await fetch(Uri.parse(_apiUrl), _headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        return UpdateInfo(
          status: UpdateStatus.unavailable,
          installedVersion: installedVersion,
        );
      }

      final data = jsonDecode(response.body);
      if (data is! Map<String, dynamic>) {
        return UpdateInfo(
          status: UpdateStatus.unavailable,
          installedVersion: installedVersion,
        );
      }
      final latestVersion =
          _normalizeVersion(data['tag_name'] as String? ?? '');
      if (latestVersion == null) {
        return UpdateInfo(
          status: UpdateStatus.unavailable,
          installedVersion: installedVersion,
        );
      }

      final releaseUrl = data['html_url'] as String? ?? '';
      final releaseNotes = data['body'] as String? ?? '';
      final hasUpdate = _compareVersions(latestVersion, installedVersion) > 0;

      final apkResolved = UpdateChecksum.resolveFromReleaseJson(
        data,
        UpdateChecksum.androidBinary,
      );
      final exeResolved = UpdateChecksum.resolveFromReleaseJson(
        data,
        UpdateChecksum.windowsBinary,
      );

      return UpdateInfo(
        status:
            hasUpdate ? UpdateStatus.updateAvailable : UpdateStatus.upToDate,
        installedVersion: installedVersion,
        latestVersion: latestVersion,
        releaseUrl: releaseUrl,
        releaseNotes: releaseNotes,
        apkSha256: apkResolved.sha256Hex,
        exeSha256: exeResolved.sha256Hex,
        checksumUrl:
            apkResolved.checksumFileUrl ?? exeResolved.checksumFileUrl,
      );
    } catch (_) {
      return UpdateInfo(
        status: UpdateStatus.unavailable,
        installedVersion: installedVersion,
      );
    }
  }

  static final RegExp _corePattern = RegExp(r'^\d+(\.\d+)*$');
  static final RegExp _buildPattern =
      RegExp(r'^[0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*$');

  /// Normalize a raw version string to its numeric core (`1.12.8`).
  /// Returns null when the string is not a valid semver-ish version.
  static String? _normalizeVersion(String raw) {
    var cleaned = raw.trim();
    if (cleaned.startsWith('v') || cleaned.startsWith('V')) {
      cleaned = cleaned.substring(1);
    }
    if (cleaned.isEmpty) return null;
    final plusIndex = cleaned.indexOf('+');
    final core = plusIndex < 0 ? cleaned : cleaned.substring(0, plusIndex);
    final build = plusIndex < 0 ? null : cleaned.substring(plusIndex + 1);
    if (!_corePattern.hasMatch(core)) return null;
    if (build != null && !_buildPattern.hasMatch(build)) return null;
    return core;
  }

  /// Compare two semver strings (e.g. "1.2.3" vs "2.0.1").
  /// Handles pre-release suffixes (e.g. "1.0.2-rc1" → major=1, minor=0, patch=2).
  /// Handles variable-length segments (covers all, not just 3).
  static int _compareVersions(String a, String b) {
    final _clean =
        (String s) => int.tryParse(s.replaceAll(RegExp(r'[^0-9].*$'), '')) ?? 0;
    final aParts = a.split('.').map(_clean).toList();
    final bParts = b.split('.').map(_clean).toList();
    final maxLen =
        aParts.length > bParts.length ? aParts.length : bParts.length;

    for (int i = 0; i < maxLen; i++) {
      final aVal = i < aParts.length ? aParts[i] : 0;
      final bVal = i < bParts.length ? bParts[i] : 0;
      if (aVal != bVal) return aVal - bVal;
    }
    return 0;
  }

  static const MethodChannel _installerChannel =
      MethodChannel('com.mathcalcu/installer');

  /// Check if the app has permission to install packages (Android 8+).
  /// Always returns true on other platforms.
  static Future<bool> canInstallPackages() async {
    if (!Platform.isAndroid) return true;
    try {
      return await _installerChannel.invokeMethod('canInstallPackages');
    } catch (_) {
      return true;
    }
  }

  /// Open system settings for "Install unknown apps" permission.
  static Future<bool> openInstallSettings() async {
    if (!Platform.isAndroid) return false;
    try {
      await _installerChannel.invokeMethod('openInstallSettings');
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Clean up any leftover temp APK/EXE files from previous updates.
  static Future<void> cleanupTempFiles() async {
    try {
      final dir = await getTemporaryDirectory();
      for (final name in ['MathCalcu.apk', 'MathCalcu-Setup.exe']) {
        final file = File('${dir.path}/$name');
        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (_) {}
  }

  /// Shared sniffing: reject HTML error pages masquerading as binaries.
  /// Returns an error message, or null when the head looks binary.
  static String? _sniffHtmlError(
      List<int> bytes, int totalBytes, String binaryName) {
    if (totalBytes < 1000) {
      return 'Downloaded file is too small ($totalBytes bytes). Please try again.';
    }

    // Check first bytes for HTML content (GitHub redirect/error pages)
    final head = String.fromCharCodes(bytes.take(20));
    if (head.contains('<!') ||
        head.contains('<html') ||
        head.contains('Not Found')) {
      return 'Downloaded an error page instead of $binaryName. '
          'Please try again.';
    }
    return null;
  }

  /// Validate that downloaded bytes are a real APK (not an HTML error page).
  /// Returns null if valid, or an error message string.
  static String? _validateApkBytes(List<int> bytes, int totalBytes) {
    final sniffed = _sniffHtmlError(bytes, totalBytes, 'APK');
    if (sniffed != null) return sniffed;

    // APK files start with the ZIP magic number: PK (0x04, 0x03)
    if (bytes.length >= 2 && bytes[0] == 0x50 && bytes[1] == 0x4B) {
      return null; // Valid ZIP/APK header
    }

    // Could be an APK variant or the file is still downloading — allow it
    // but log a warning
    debugPrint('UpdateService: APK header check: first bytes = '
        '${bytes.take(4).map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}');
    return null;
  }

  /// Validate that downloaded bytes are a real Windows installer (not an
  /// HTML error page). Returns null if valid, or an error message string.
  static String? _validateExeBytes(List<int> bytes, int totalBytes) {
    final sniffed = _sniffHtmlError(bytes, totalBytes, 'installer');
    if (sniffed != null) return sniffed;

    // PE executables start with the MZ magic number (0x4D, 0x5A)
    if (bytes.length >= 2 && bytes[0] == 0x4D && bytes[1] == 0x5A) {
      return null; // Valid EXE header
    }

    debugPrint('UpdateService: EXE header check: first bytes = '
        '${bytes.take(4).map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}');
    return null;
  }

  /// Resolve the expected SHA-256 for [binaryName] from release metadata,
  /// fetching a checksum manifest when the release only publishes one.
  /// Returns null when no digest can be established.
  static Future<String?> _resolveExpectedSha256({
    required String binaryName,
    ReleaseFetcher? releaseFetcher,
    ChecksumFetcher? checksumFetcher,
  }) async {
    try {
      final fetch =
          releaseFetcher ?? ((url, headers) => http.get(url, headers: headers));
      final response = await fetch(Uri.parse(_apiUrl), _headers)
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      if (data is! Map<String, dynamic>) return null;

      final resolved =
          UpdateChecksum.resolveFromReleaseJson(data, binaryName);
      if (resolved.hasDirectHash) return resolved.sha256Hex;

      final manifestUrl = resolved.checksumFileUrl;
      if (manifestUrl == null) return null;
      final manifestUri = Uri.tryParse(manifestUrl);
      if (manifestUri == null ||
          !manifestUri.isAbsolute ||
          manifestUri.scheme != 'https') {
        return null;
      }

      final manifestFetch =
          checksumFetcher ?? ((url) => http.get(url));
      final manifest = await manifestFetch(manifestUri)
          .timeout(const Duration(seconds: 10));
      if (manifest.statusCode != 200) return null;
      return UpdateChecksum.parseChecksumFile(manifest.body, binaryName);
    } catch (_) {
      return null;
    }
  }

  /// Download the latest release binary, verify its SHA-256 checksum, and
  /// trigger installation. Refuses to install when no published checksum can
  /// be established or the digest mismatches (fail closed).
  /// Returns null on success, or an error message string on failure.
  ///
  /// [expectedSha256] overrides checksum resolution (tests / callers that
  /// already ran [checkForUpdate]); [releaseFetcher] and [checksumFetcher]
  /// inject the metadata and manifest downloads for tests.
  static Future<String?> downloadAndInstall(
    void Function(double progress)? onProgress, {
    String? expectedSha256,
    ReleaseFetcher? releaseFetcher,
    ChecksumFetcher? checksumFetcher,
  }) async {
    try {
      // Clean up any leftover temp files from previous attempts
      await cleanupTempFiles();

      final isWin = Platform.isWindows;
      final binaryName =
          isWin ? UpdateChecksum.windowsBinary : UpdateChecksum.androidBinary;
      final url =
          'https://github.com/$_owner/$_repo/releases/latest/download/$binaryName';

      // Establish integrity expectations BEFORE downloading (fail fast when
      // the release publishes nothing to verify against).
      var expected = expectedSha256?.trim().toLowerCase();
      if (expected != null &&
          expected.isNotEmpty &&
          !UpdateChecksum.isSha256Hex(expected)) {
        return 'Update verification misconfigured: invalid expected checksum.';
      }
      expected = (expected == null || expected.isEmpty) ? null : expected;
      expected ??= await _resolveExpectedSha256(
        binaryName: binaryName,
        releaseFetcher: releaseFetcher,
        checksumFetcher: checksumFetcher,
      );
      if (expected == null) {
        return 'Update cannot be verified: no SHA-256 checksum is published '
            'for $binaryName. Please download it manually from the releases page.';
      }
      final verifiedSha = expected;

      final client = http.Client();
      try {
        final request = http.Request('GET', Uri.parse(url));
        request.headers['Accept'] = 'application/octet-stream';
        final response = await client.send(request).timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            client.close();
            throw TimeoutException('Connection timed out');
          },
        );

        if (response.statusCode != 200) {
          return 'Server returned ${response.statusCode}';
        }

        // Verify we're getting binary content, not HTML
        final contentType = response.headers['content-type'] ?? '';
        if (contentType.contains('text/html')) {
          return 'Download failed: got HTML instead of $binaryName. '
              'Please try again.';
        }

        final contentLength = response.contentLength ?? 0;
        final bool hasKnownSize = contentLength > 0;
        final bytes = <int>[];
        final completer = Completer<String?>();

        response.stream.timeout(
          const Duration(minutes: 5),
          onTimeout: (sink) {
            sink.addError(TimeoutException('Download timed out'));
            sink.close();
          },
        ).listen(
          (chunk) {
            bytes.addAll(chunk);
            if (onProgress != null) {
              if (hasKnownSize) {
                onProgress(bytes.length / contentLength);
              }
              // If contentLength is -1 (chunked), progress stays at 0
              // — the UI shows indeterminate progress
            }
          },
          onDone: () async {
            try {
              if (bytes.isEmpty) {
                completer.complete('Download failed: file is empty');
                client.close();
                return;
              }

              // Validate binary content before writing
              final validationError = isWin
                  ? _validateExeBytes(bytes, bytes.length)
                  : _validateApkBytes(bytes, bytes.length);
              if (validationError != null) {
                completer.complete(validationError);
                client.close();
                return;
              }

              // Integrity gate: never write or launch an unverified payload.
              final actualSha256 = UpdateChecksum.sha256Hex(bytes);
              if (!UpdateChecksum.hashesEqual(actualSha256, verifiedSha)) {
                completer.complete(
                  'Download verification failed: checksum mismatch for '
                  '$binaryName. The file may be corrupted or tampered with. '
                  'Please try again.',
                );
                client.close();
                return;
              }

              final dir = await getTemporaryDirectory();
              final file = File('${dir.path}/$binaryName');
              await file.writeAsBytes(bytes);
              final fileSize = await file.length();
              if (fileSize == 0) {
                completer.complete('Download failed: file is empty');
                client.close();
                return;
              }

              if (Platform.isAndroid) {
                try {
                  await _installerChannel
                      .invokeMethod('installApk', {'apkPath': file.path});
                  completer.complete(null);
                } on PlatformException catch (e) {
                  if (e.message == 'NEED_PERMISSION') {
                    completer.complete('NEED_PERMISSION');
                  } else if (e.message == 'SIGNATURE_MISMATCH') {
                    completer.complete(
                      'Cannot update: app signature mismatch. '
                      'Uninstall the current app first, then install the new version.',
                    );
                  } else {
                    completer.complete(e.message ?? e.toString());
                  }
                } catch (e) {
                  completer.complete(e.toString());
                }
              } else if (isWin) {
                await Process.start(file.path, ['/SILENT']);
                await Future.delayed(const Duration(seconds: 1));
                exit(0);
              } else {
                completer.complete('Updates not supported on this platform');
              }
            } catch (e) {
              completer.complete(e.toString());
            } finally {
              client.close();
            }
          },
          onError: (e) {
            completer.complete('Download failed: ${e.toString()}');
            client.close();
          },
        );

        return await completer.future;
      } catch (e) {
        client.close();
        if (e is TimeoutException) {
          return 'Download failed: connection timed out. Please check your internet and try again.';
        }
        rethrow;
      }
    } catch (e) {
      if (e is TimeoutException) {
        return 'Download failed: connection timed out. Please check your internet and try again.';
      }
      return e.toString();
    }
  }
}
