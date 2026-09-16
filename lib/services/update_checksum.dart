import 'package:crypto/crypto.dart' as crypto;

/// Integrity helpers for the in-app updater (Cycle 1 Batch C Item 4).
///
/// Single responsibility: derive and compare the SHA-256 checksums published
/// alongside GitHub release binaries, so [UpdateService] never installs a
/// payload it cannot authenticate. Pure functions only — no I/O here.
class UpdateChecksum {
  const UpdateChecksum._();

  /// Canonical binary names served from the GitHub releases page.
  static const String androidBinary = 'MathCalcu.apk';
  static const String windowsBinary = 'MathCalcu-Setup.exe';

  static final RegExp _hex64 = RegExp(r'[0-9a-fA-F]{64}');
  static final RegExp _gnuLine =
      RegExp(r'^([0-9a-fA-F]{64})\s+\*?(.+?)\s*$');
  static final RegExp _bsdLine = RegExp(
    r'SHA-?256\s*\(\s*(.+?)\s*\)\s*=\s*([0-9a-fA-F]{64})',
    caseSensitive: false,
  );

  /// Hex SHA-256 digest of [bytes].
  static String sha256Hex(List<int> bytes) =>
      crypto.sha256.convert(bytes).toString();

  /// True when [value] is a 64-char hex digest (case-insensitive).
  static bool isSha256Hex(String? value) =>
      value != null && RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(value.trim());

  /// Case-insensitive digest comparison with early length check.
  static bool hashesEqual(String actual, String expected) {
    final a = actual.trim().toLowerCase();
    final e = expected.trim().toLowerCase();
    if (a.length != e.length || a.length != 64) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ e.codeUnitAt(i);
    }
    return diff == 0;
  }

  /// Parse a checksum manifest (`checksums.txt`-style) and return the digest
  /// for [fileName], or null when the file is not listed.
  ///
  /// Understands GNU (`<hash>[ *]<file>`) and BSD (`SHA256 (<file>) = <hash>`)
  /// line formats; anything else is ignored line by line.
  static String? parseChecksumFile(String content, String fileName) {
    final want = fileName.trim().toLowerCase();
    for (final rawLine in content.split('\n')) {
      final line = rawLine.trim().replaceAll('\r', '');
      if (line.isEmpty || line.startsWith('#')) continue;

      final gnu = _gnuLine.firstMatch(line);
      if (gnu != null) {
        final listed = _baseName(gnu.group(2)!).toLowerCase();
        if (listed == want) return gnu.group(1)!.toLowerCase();
        continue;
      }

      final bsd = _bsdLine.firstMatch(line);
      if (bsd != null) {
        final listed = _baseName(bsd.group(1)!).toLowerCase();
        if (listed == want) return bsd.group(2)!.toLowerCase();
      }
    }
    return null;
  }

  /// Extract an inline checksum from release notes: prefers a 64-hex digest
  /// on a line that mentions [fileName]; falls back to the body-wide digest
  /// when exactly one is present; otherwise null (ambiguous or absent).
  static String? extractFromReleaseBody(String body, String fileName) {
    final want = fileName.trim().toLowerCase();
    String? soleCandidate;
    var candidateCount = 0;

    for (final rawLine in body.split('\n')) {
      final line = rawLine.trim();
      final matches = _hex64.allMatches(line).toList();
      if (matches.isEmpty) continue;
      if (line.toLowerCase().contains(want)) {
        return matches.first.group(0)!.toLowerCase();
      }
      for (final match in matches) {
        candidateCount++;
        soleCandidate ??= match.group(0)!.toLowerCase();
      }
    }
    return candidateCount == 1 ? soleCandidate : null;
  }

  /// Resolve the expected checksum from a decoded GitHub release payload
  /// without extra I/O. Priority: per-asset `digest` → inline release-notes
  /// hash → `checksums.txt`-style manifest URL (caller fetches it).
  static ResolvedChecksum resolveFromReleaseJson(
    Map<String, dynamic> json,
    String fileName,
  ) {
    String? manifestUrl;
    final assets = json['assets'];
    if (assets is List) {
      for (final entry in assets) {
        if (entry is! Map<String, dynamic>) continue;
        final name = (entry['name'] as String? ?? '').trim();
        if (name.isEmpty) continue;
        final url = entry['browser_download_url'] as String?;
        final digest = entry['digest'] as String?;

        if (_baseName(name).toLowerCase() == fileName.trim().toLowerCase()) {
          final hex = _digestHex(digest);
          if (hex != null) {
            return ResolvedChecksum(sha256Hex: hex);
          }
        }
        if (url != null && _looksLikeManifest(name)) {
          manifestUrl ??= url;
        }
      }
    }

    final body = json['body'];
    if (body is String && body.isNotEmpty) {
      final inline = extractFromReleaseBody(body, fileName);
      if (inline != null) {
        return ResolvedChecksum(sha256Hex: inline);
      }
    }
    return ResolvedChecksum(checksumFileUrl: manifestUrl);
  }

  /// `sha256:<hex>` → `<hex>`, else null.
  static String? _digestHex(String? digest) {
    if (digest == null) return null;
    final parts = digest.trim().split(':');
    if (parts.length != 2 || parts[0].trim().toLowerCase() != 'sha256') {
      return null;
    }
    final hex = parts[1].trim().toLowerCase();
    return isSha256Hex(hex) ? hex : null;
  }

  static bool _looksLikeManifest(String name) {
    final lower = name.toLowerCase();
    final isChecksumName = lower.contains('checksum') ||
        lower.contains('sha256') ||
        lower.contains('sha256sums');
    return isChecksumName &&
        (lower.endsWith('.txt') ||
            lower.endsWith('.sha256') ||
            lower.endsWith('.sums'));
  }

  static String _baseName(String path) {
    final normalized = path.trim().replaceAll('\\', '/');
    final slash = normalized.lastIndexOf('/');
    return slash < 0 ? normalized : normalized.substring(slash + 1);
  }
}

/// Checksum expectation derived from release metadata: either a directly
/// usable digest, or the URL of a manifest the caller must fetch and parse.
class ResolvedChecksum {
  final String? sha256Hex;
  final String? checksumFileUrl;

  const ResolvedChecksum({this.sha256Hex, this.checksumFileUrl});

  bool get hasDirectHash =>
      sha256Hex != null && UpdateChecksum.isSha256Hex(sha256Hex);
  bool get hasLookup => hasDirectHash ||
      (checksumFileUrl != null && checksumFileUrl!.isNotEmpty);
}
