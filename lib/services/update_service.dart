import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class UpdateInfo {
  final String latestVersion;
  final String currentVersion;
  final String releaseUrl;
  final String releaseNotes;
  final bool hasUpdate;

  const UpdateInfo({
    required this.latestVersion,
    required this.currentVersion,
    required this.releaseUrl,
    required this.releaseNotes,
    required this.hasUpdate,
  });
}

class UpdateService {
  static const String _owner = 'Shuash11';
  static const String _repo = 'MathCalcu';
  static const String _apiUrl =
      'https://api.github.com/repos/$_owner/$_repo/releases/latest';

  static Future<UpdateInfo?> checkForUpdate(String currentVersion) async {
    try {
      final response = await http
          .get(
            Uri.parse(_apiUrl),
            headers: {'Accept': 'application/vnd.github.v3+json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      final tagName = data['tag_name'] as String? ?? '';
      final latestVersion = tagName.replaceAll(RegExp(r'^v'), '');
      final releaseUrl = data['html_url'] as String? ?? '';
      final releaseNotes = data['body'] as String? ?? 'No release notes available.';
      final currentClean = currentVersion.split('+').first;

      if (tagName.isEmpty || latestVersion.isEmpty) return null;

      final hasUpdate = _compareVersions(latestVersion, currentClean) > 0;

      return UpdateInfo(
        latestVersion: latestVersion,
        currentVersion: currentClean,
        releaseUrl: releaseUrl,
        releaseNotes: releaseNotes,
        hasUpdate: hasUpdate,
      );
    } catch (_) {
      return null;
    }
  }

  /// Compare two semver strings (e.g. "1.2.3" vs "2.0.1").
  /// Handles pre-release suffixes (e.g. "1.0.2-rc1" → major=1, minor=0, patch=2).
  /// Handles variable-length segments (covers all, not just 3).
  static int _compareVersions(String a, String b) {
    final _clean = (String s) => int.tryParse(s.replaceAll(RegExp(r'[^0-9].*$'), '')) ?? 0;
    final aParts = a.split('.').map(_clean).toList();
    final bParts = b.split('.').map(_clean).toList();
    final maxLen = aParts.length > bParts.length ? aParts.length : bParts.length;

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

  /// Validate that downloaded bytes are a real APK (not an HTML error page).
  /// Returns null if valid, or an error message string.
  static String? _validateApkBytes(List<int> bytes, int totalBytes) {
    if (totalBytes < 1000) {
      return 'Downloaded file is too small ($totalBytes bytes). Please try again.';
    }

    // Check first bytes for HTML content (GitHub redirect/error pages)
    final head = String.fromCharCodes(bytes.take(20));
    if (head.contains('<!') || head.contains('<html') || head.contains('Not Found')) {
      return 'Downloaded an error page instead of APK. Please try again.';
    }

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

  /// Download the latest release binary and trigger installation.
  /// Returns null on success, or an error message string on failure.
  static Future<String?> downloadAndInstall(void Function(double progress)? onProgress) async {
    try {
      // Clean up any leftover temp files from previous attempts
      await cleanupTempFiles();

      final isWin = Platform.isWindows;
      final binaryName = isWin ? 'MathCalcu-Setup.exe' : 'MathCalcu.apk';
      final url = 'https://github.com/$_owner/$_repo/releases/latest/download/$binaryName';

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
          return 'Download failed: got HTML instead of APK. Please try again.';
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

              // Validate APK content before writing
              if (Platform.isAndroid) {
                final error = _validateApkBytes(bytes, bytes.length);
                if (error != null) {
                  completer.complete(error);
                  client.close();
                  return;
                }
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
                  await _installerChannel.invokeMethod('installApk', {'apkPath': file.path});
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
