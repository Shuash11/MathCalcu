// ─────────────────────────────────────────────────────────────
// CURRICULUM SEARCH UI — shared result card + matches section.
//
// Reused by every picker (Topics / Category / Calculus / Finals /
// ModMat) and the global /search screen so Task 3 search looks and
// behaves the same everywhere. Styling via ThemeProvider only.
//
// Stub rule: tapping a topic whose solver is not available yet
// (solverAvailable == false, e.g. G7–G10 placeholders) shows
// a "Coming in Phase 1" SnackBar instead of navigating — never a
// dead-end, never a GoRouter error. Solver-backed topics (11 G6 +
// 10 SHS entries, all with GoRouter destinations) push their
// registry route.
// ─────────────────────────────────────────────────────────────

import 'package:calculus_system/core/curriculum_registry.dart';
import 'package:calculus_system/search/unified_search.dart';
import 'package:calculus_system/services/history_service.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:calculus_system/topics/modmat/modmat_module_registry.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// Shows the generic coming-soon SnackBar for a topic whose screen
/// has not landed yet. Never a dead-end, never a GoRouter error.
void showTopicComingSoon(BuildContext context, String label) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          'Coming in Phase 1 — "$label" solver isn\'t built yet.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
}

/// Shows the "Coming in Phase 1" SnackBar for stub topics.
void showComingInPhase1(BuildContext context, CurriculumTopic topic) {
  showTopicComingSoon(context, topic.label);
}

/// Cycle 8 never-dead-end guard: true only when [route] resolves
/// to a registered GoRouter destination. Curriculum routes defer
/// to their topic's solverAvailable flag (the registry invariant);
/// ModMat leaf routes are unwired until their screens land; every
/// other legacy route is wired.
bool isRouteAvailable(String route) {
  final topic = CurriculumRegistry.getByRoute(route);
  if (topic != null) return topic.solverAvailable;
  return ModmatModuleRegistry.isRouteAvailable(route);
}

/// Tap handler shared by every curriculum result card.
///
/// Topics with a wired solver (solverAvailable == true — 11 G6 +
/// 10 SHS entries, each with a GoRouter destination) push their
/// registry route. Stubs without a solver yet show the "Coming in
/// Phase 1" SnackBar — never a dead-end, never a GoRouter error.
///
/// Cycle 8: SHS topics are wired (engines + screens + /shs/*
/// GoRoutes all landed); remaining G7–College stubs stay gated.
void handleCurriculumTap(BuildContext context, CurriculumTopic topic) {
  if (!topic.solverAvailable) {
    showComingInPhase1(context, topic);
    return;
  }
  // Task 7: record recently opened (fire-and-forget, offline prefs).
  const HistoryService()
      .addRecentSolved(label: topic.label, route: topic.route);
  context.push(topic.route);
}

/// Push a "Recently opened" history entry, guarding unwired routes.
///
/// History may hold routes stored before their screens landed (or
/// from a registry whose flag flipped back to gated). Gated routes
/// show the coming-soon SnackBar instead of pushing a dead link.
void pushHistoryRoute(BuildContext context, SolvedHistoryEntry entry) {
  if (!isRouteAvailable(entry.route)) {
    showTopicComingSoon(context, entry.label);
    return;
  }
  // Task 7: record recently opened (fire-and-forget, offline prefs).
  const HistoryService().addRecentSolved(
    label: entry.label,
    route: entry.route,
  );
  context.push(entry.route);
}

/// Small grade pill, e.g. "G6". Uses the theme accent.
class GradeBadge extends StatelessWidget {
  final String gradeLevel;

  const GradeBadge({super.key, required this.gradeLevel});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final accent = theme.accentColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        gradeLevel,
        style: TextStyle(
          color: accent,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

/// One curriculum search result row with subject pill + grade metadata.
///
/// E-1: topic-first labelling — the accent [SubjectPill] carries the
/// subject (11 G6 subjects + SHS subjects); the grade level renders
/// as muted metadata, never as the primary badge.
class CurriculumResultCard extends StatelessWidget {
  final CurriculumTopic topic;
  final String? sectionLabel;

  const CurriculumResultCard(
      {super.key, required this.topic, this.sectionLabel});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final accent = theme.accentColor;
    return Semantics(
      label: '${topic.label}, ${topic.subject}',
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => handleCurriculumTap(context, topic),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accent.withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(topic.icon, color: accent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topic.label,
                        style: TextStyle(
                          color: theme.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        topic.subtitle,
                        style: TextStyle(
                          color: theme.textSecondary,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              topic.subject,
                              style: TextStyle(
                                color: accent,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                          if (sectionLabel != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: theme.cardSecondary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                sectionLabel!,
                                style: TextStyle(
                                  color: theme.textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          if (!topic.solverAvailable)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: accent.withValues(alpha: 0.25),
                                ),
                              ),
                              child: Text(
                                'Phase 1 soon',
                                style: TextStyle(
                                  color: accent,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          Text(
                            topic.gradeLevel,
                            style: TextStyle(
                              color: theme.textSecondary.withValues(alpha: 0.7),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 48,
                  height: 48,
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: accent.withValues(alpha: 0.85),
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Unified-hit row for the global /search screen (solver hits push,
/// curriculum stubs show the Phase-1 SnackBar).
///
/// Cycle 8: non-curriculum hits on unwired routes (ModMat leaves,
/// future /grade* /college* /shs* paths) are gated the same way —
/// no push can land on a missing GoRouter destination.
class UnifiedResultCard extends StatelessWidget {
  final UnifiedHit hit;

  const UnifiedResultCard({super.key, required this.hit});

  @override
  Widget build(BuildContext context) {
    final topic = hit.curriculumTopic;
    if (topic != null) return CurriculumResultCard(topic: topic);

    final theme = context.watch<ThemeProvider>();
    final accent = theme.accentColor;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (hit.isStub) {
            showTopicComingSoon(context, hit.label);
            return;
          }
          // Task 7: record recently opened (fire-and-forget).
          const HistoryService().addRecentSolved(
            label: hit.label,
            route: hit.route,
          );
          context.push(hit.route);
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: theme.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accent.withValues(alpha: 0.2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(hit.icon, color: accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hit.label,
                      style: TextStyle(
                        color: theme.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hit.subtitle,
                      style: TextStyle(
                        color: theme.textSecondary,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 10),
                    GradeBadge(gradeLevel: hit.source),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: accent.withValues(alpha: 0.85),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Curriculum matches" section dropped under a picker's own local
/// results whenever the query is non-empty. Returns an empty box
/// for a blank query so pickers show their default sections.
class CurriculumMatchesSection extends StatelessWidget {
  final String query;
  final EdgeInsetsGeometry padding;

  const CurriculumMatchesSection({
    super.key,
    required this.query,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    if (query.trim().isEmpty) return const SizedBox.shrink();
    final theme = context.watch<ThemeProvider>();
    final hits = CurriculumRegistry.search(query);
    if (hits.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Curriculum matches',
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          for (final hit in hits) ...[
            CurriculumResultCard(topic: hit.topic),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}
