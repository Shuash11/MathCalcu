import 'dart:convert';
import 'package:http/http.dart' as http;

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
}
