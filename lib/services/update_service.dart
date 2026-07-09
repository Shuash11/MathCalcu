import 'dart:async';
import 'dart:convert';
import 'dart:io';
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

  /// Download the APK from the latest release and open the system installer.
  /// Returns null on success, or an error message string on failure.
  static Future<String?> downloadAndInstall(void Function(double progress)? onProgress) async {
    try {
      final apkUrl = 'https://github.com/$_owner/$_repo/releases/latest/download/MathCalcu.apk';

      final client = http.Client();
      try {
        final request = http.Request('GET', Uri.parse(apkUrl));
        final response = await client.send(request);

        if (response.statusCode != 200) {
          return 'Server returned ${response.statusCode}';
        }

        final contentLength = response.contentLength ?? 0;
        final bytes = <int>[];
        final completer = Completer<String?>();

        response.stream.listen(
          (chunk) {
            bytes.addAll(chunk);
            if (contentLength > 0 && onProgress != null) {
              onProgress(bytes.length / contentLength);
            }
          },
          onDone: () async {
            try {
              final dir = await getTemporaryDirectory();
              final file = File('${dir.path}/MathCalcu.apk');
              await file.writeAsBytes(bytes);
              if (Platform.isAndroid) {
                try {
                  await _installerChannel.invokeMethod('installApk', {'apkPath': file.path});
                  completer.complete(null);
                } on PlatformException catch (e) {
                  if (e.message == 'NEED_PERMISSION') {
                    completer.complete('NEED_PERMISSION');
                  } else {
                    completer.complete(e.message ?? e.toString());
                  }
                } catch (e) {
                  completer.complete(e.toString());
                }
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
            completer.complete(e.toString());
            client.close();
          },
        );

        return await completer.future;
      } finally {
        client.close();
      }
    } catch (e) {
      return e.toString();
    }
  }
}
