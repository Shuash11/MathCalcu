// ─────────────────────────────────────────────────────────────
// UNIFIED SEARCH — offline in-memory index over all registries.
//
// Merges the existing hardcoded registries (ModuleRegistry,
// FinalsModuleRegistry, ModmatModuleRegistry) with the new
// CurriculumRegistry (G6 seed + G7–College stubs) into one hit
// list for the global /search screen (Task 3).
//
// No network, no DB. Pure Dart filtering, same lowercase
// contains pattern as ModMat search().
// ─────────────────────────────────────────────────────────────

import 'package:calculus_system/core/curriculum_registry.dart';
import 'package:calculus_system/core/module_registry.dart';
import 'package:calculus_system/topics/calculus/finals/finals_module_registry.dart';
import 'package:calculus_system/topics/modmat/modmat_module_registry.dart';
import 'package:flutter/material.dart';

/// One tappable row in the global search list.
class UnifiedHit {
  /// Picker card title.
  final String label;

  /// Picker card subtitle / example hint.
  final String subtitle;

  /// GoRouter path for solver-backed hits. Future curriculum
  /// routes (e.g. '/grade6/ratio') are kept for display but must
  /// NOT be pushed until Phase 1 wires the solvers.
  final String route;

  /// Leading icon.
  final IconData icon;

  /// Group chip shown on the card, e.g. 'Midterm', 'Finals',
  /// 'Modern Math', 'G6', 'G7', 'College'.
  final String source;

  /// Non-null for curriculum hits (carries grade badge, subject,
  /// solverAvailable stub flag).
  final CurriculumTopic? curriculumTopic;

  const UnifiedHit({
    required this.label,
    required this.subtitle,
    required this.route,
    required this.icon,
    required this.source,
    this.curriculumTopic,
  });

  /// True when tapping must show the "Coming in Phase 1" SnackBar
  /// instead of navigating (stub topic without a wired solver).
  ///
  /// Task 5 wired all 11 /grade6/* routes (app_router.dart): a
  /// curriculum hit is a stub iff its topic reports
  /// solverAvailable == false. Non-curriculum hits fall back to
  /// the route guard for unwired future paths.
  ///
  /// Cycle 9: ModMat leaf routes with landed screens (see
  /// ModmatModuleRegistry.wiredLeafRoutes) are solver-backed; only
  /// unwired leaves — as is any /shs/* hit without a curriculum
  /// topic — are stubs too.
  bool get isStub {
    final topic = curriculumTopic;
    if (topic != null) return !topic.solverAvailable;
    // Non-curriculum hit: guard unwired future paths only.
    if (route.startsWith('/grade') ||
        route.startsWith('/college') ||
        route.startsWith('/shs')) {
      return true;
    }
    if (ModmatModuleRegistry.isLeafRoute(route)) {
      return !ModmatModuleRegistry.isRouteAvailable(route);
    }
    return false;
  }
}

/// Offline aggregator. One responsibility: fan out one query to
/// every registry and return a single ordered list.
class UnifiedSearch {
  const UnifiedSearch._();

  /// Search everything. Empty/blank query returns [] (callers show
  /// their default sections instead).
  static List<UnifiedHit> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];

    final hits = <UnifiedHit>[
      ..._searchModules(q),
      ..._searchFinals(q),
      ..._searchModmat(q),
      ..._searchCurriculum(q),
    ];
    return hits;
  }

  static List<UnifiedHit> _searchModules(String q) => [
        for (final m in ModuleRegistry.modules)
          if (m.label.toLowerCase().contains(q) ||
              m.subtitle.toLowerCase().contains(q))
            UnifiedHit(
              label: m.label,
              subtitle: m.subtitle,
              route: m.route,
              icon: m.icon,
              source: 'Midterm',
            ),
      ];

  static List<UnifiedHit> _searchFinals(String q) => [
        for (final m in FinalsModuleRegistry.modules)
          if (m.label.toLowerCase().contains(q) ||
              m.subtitle.toLowerCase().contains(q))
            UnifiedHit(
              label: m.label,
              subtitle: m.subtitle,
              route: m.route,
              icon: m.icon,
              source: 'Finals',
            ),
      ];

  static List<UnifiedHit> _searchModmat(String q) => [
        for (final hit in ModmatModuleRegistry.search(q))
          UnifiedHit(
            label: hit.module.label,
            subtitle: hit.module.subtitle,
            route: hit.module.route,
            icon: hit.module.icon,
            source: 'Modern Math',
          ),
      ];

  static List<UnifiedHit> _searchCurriculum(String q) => [
        for (final hit in CurriculumRegistry.search(q))
          UnifiedHit(
            label: hit.topic.label,
            subtitle: hit.topic.subtitle,
            route: hit.topic.route,
            icon: hit.topic.icon,
            source: hit.gradeLevel,
            curriculumTopic: hit.topic,
          ),
      ];
}
