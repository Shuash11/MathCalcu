// ─────────────────────────────────────────────────────────────
// HISTORY SERVICE — offline persistence for Task 7.
//
// Recent searches (max 10) feed the /search + picker "Recent"
// chips. Recent solved (label + route + timestamp, max 20)
// feeds the "Recently opened" section. Backed by
// shared_preferences only — no new packages, offline-first.
//
// Follows the existing prefs pattern from ThemeProvider
// (dark_mode) and main.dart (asked_install_permission).
// ─────────────────────────────────────────────────────────────

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// One recently opened (solver-backed) topic.
class SolvedHistoryEntry {
  final String label;
  final String route;
  final DateTime timestamp;

  const SolvedHistoryEntry({
    required this.label,
    required this.route,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'label': label,
        'route': route,
        'timestamp': timestamp.toIso8601String(),
      };

  static SolvedHistoryEntry? fromJson(Map<String, dynamic> json) {
    final label = json['label'];
    final route = json['route'];
    final timestamp = json['timestamp'];
    if (label is! String || route is! String || timestamp is! String) {
      return null;
    }
    final parsed = DateTime.tryParse(timestamp);
    if (parsed == null) return null;
    return SolvedHistoryEntry(
      label: label,
      route: route,
      timestamp: parsed,
    );
  }
}

/// Offline store for recent searches + recently solved topics.
class HistoryService {
  static const int maxSearches = 10;
  static const int maxSolved = 20;

  static const String searchesKey = 'recent_searches';
  static const String solvedKey = 'recent_solved';

  const HistoryService();

  // ── Recent searches ──────────────────────────────────────────

  Future<List<String>> getRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    return List<String>.from(prefs.getStringList(searchesKey) ?? const []);
  }

  /// Saves a query (trimmed, de-duplicated, most-recent-first).
  /// Blank queries are ignored.
  Future<void> addRecentSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final current = List<String>.from(
      prefs.getStringList(searchesKey) ?? const [],
    );
    current.removeWhere((q) => q.toLowerCase() == trimmed.toLowerCase());
    current.insert(0, trimmed);
    await prefs.setStringList(
      searchesKey,
      current.take(maxSearches).toList(),
    );
  }

  Future<void> clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(searchesKey);
  }

  // ── Recently solved ──────────────────────────────────────────

  Future<List<SolvedHistoryEntry>> getRecentSolved() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(solvedKey) ?? const [];
    final entries = <SolvedHistoryEntry>[];
    for (final item in raw) {
      try {
        final decoded = jsonDecode(item);
        if (decoded is Map<String, dynamic>) {
          final entry = SolvedHistoryEntry.fromJson(decoded);
          if (entry != null) entries.add(entry);
        }
      } catch (_) {
        // Skip corrupt rows, keep the rest.
      }
    }
    return entries;
  }

  /// Records a topic open (most-recent-first, de-duplicated by
  /// route). Blank labels/routes are ignored.
  Future<void> addRecentSolved({
    required String label,
    required String route,
  }) async {
    final cleanLabel = label.trim();
    final cleanRoute = route.trim();
    if (cleanLabel.isEmpty || cleanRoute.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final entries = await getRecentSolved();
    entries.removeWhere((e) => e.route == cleanRoute);
    entries.insert(
      0,
      SolvedHistoryEntry(
        label: cleanLabel,
        route: cleanRoute,
        timestamp: DateTime.now(),
      ),
    );
    await prefs.setStringList(
      solvedKey,
      entries.take(maxSolved).map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  Future<void> clearRecentSolved() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(solvedKey);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(searchesKey);
    await prefs.remove(solvedKey);
  }
}
