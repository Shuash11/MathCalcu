// ─────────────────────────────────────────────────────────────
// TOPIC HUB — Cycle 8 topic-first entry (E-2 contract amendment).
//
// CONTRACT AMENDMENT (recorded): the prior "no-filter freeze" on
// pickers is overridden by the new Cycle 8 directive — topic-first
// browsing (filter-by-subject, not grade labels) is now REQUIRED.
// This hub groups the full CurriculumRegistry catalogue by subject
// with section pills; solver-backed rows push, stubs show the
// "Coming in Phase 1" SnackBar (never a dead link). Route to be
// wired by middle-end (suggested: /topics/hub).
// ─────────────────────────────────────────────────────────────

import 'package:calculus_system/core/curriculum_registry.dart';
import 'package:calculus_system/shared/widgets/accessible_back_button.dart';
import 'package:calculus_system/shared/widgets/catalogue_disclosure.dart';
import 'package:calculus_system/shared/widgets/curriculum_result_card.dart';
import 'package:calculus_system/shared/widgets/empty_state.dart';
import 'package:calculus_system/shared/widgets/subject_filter_chips.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TopicHubScreen extends StatefulWidget {
  const TopicHubScreen({super.key});

  @override
  State<TopicHubScreen> createState() => _TopicHubScreenState();
}

class _TopicHubScreenState extends State<TopicHubScreen> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  String _query = '';
  String _subject = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _query = '';
      _subject = 'All';
    });
    _searchFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final accent = theme.accentColor;
    final q = _query.trim().toLowerCase();
    final all = CurriculumRegistry.allTopics();
    final solverBacked = all.where((t) => t.solverAvailable).length;

    final filtered = all.where((t) {
      if (_subject != 'All' && t.subject != _subject) return false;
      if (q.isEmpty) return true;
      return t.label.toLowerCase().contains(q) ||
          t.subtitle.toLowerCase().contains(q) ||
          t.subject.toLowerCase().contains(q) ||
          t.gradeLevel.toLowerCase().contains(q) ||
          t.tags.any((tag) => tag.toLowerCase().contains(q));
    }).toList();

    // Group by subject for topic-first sections.
    final groups = <String, List<CurriculumTopic>>{};
    for (final t in filtered) {
      groups.putIfAbsent(t.subject, () => []).add(t);
    }
    final orderedSubjects = groups.keys.toList()..sort();

    return Scaffold(
      backgroundColor: theme.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 48, 28, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AccessibleBackButton(),
                    const SizedBox(height: 24),
                    Text(
                      'Browse by topic',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        color: theme.textPrimary,
                        height: 1.1,
                        letterSpacing: -1.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${all.length} topics · ${CurriculumRegistry.subjects.length} subjects',
                      style: TextStyle(
                        fontSize: 15,
                        color: theme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    CatalogueDisclosure(
                      solverBacked: solverBacked,
                      catalogueOnly: all.length - solverBacked,
                      catalogueName: 'curriculum',
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: accent.withValues(
                        alpha: _searchFocusNode.hasFocus ? 0.45 : 0.18,
                      ),
                      width: _searchFocusNode.hasFocus ? 1.5 : 1,
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    onChanged: (v) => setState(() => _query = v),
                    style: TextStyle(color: theme.textPrimary),
                    cursorColor: accent,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Search all topics, e.g. fraction, trig, limit',
                      hintStyle: TextStyle(color: theme.textSecondary),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: _searchFocusNode.hasFocus
                            ? accent
                            : theme.textSecondary,
                      ),
                      suffixIcon: q.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Clear search',
                              onPressed: _clearSearch,
                              icon: Icon(
                                Icons.close_rounded,
                                color: theme.textSecondary,
                              ),
                            ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: SubjectFilterChips(
                  subjects: CurriculumRegistry.subjects,
                  selected: _subject,
                  onSelected: (s) => setState(() => _subject = s),
                ),
              ),
            ),
            if (filtered.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: NoTopicsEmptyState(onClear: _clearSearch),
                ),
              ),
            for (final subject in orderedSubjects) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                  child: Row(
                    children: [
                      Text(
                        subject,
                        style: TextStyle(
                          color: theme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SectionPill(
                        label: '${groups[subject]!.length}',
                        accent: accent,
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: CurriculumResultCard(
                        topic: groups[subject]![index],
                        sectionLabel: groups[subject]![index].gradeLevel,
                      ),
                    ),
                    childCount: groups[subject]!.length,
                  ),
                ),
              ),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }
}
