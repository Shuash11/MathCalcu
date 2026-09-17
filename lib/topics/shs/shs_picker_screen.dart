// ─────────────────────────────────────────────────────────────
// SHS PICKER — Cycle 8 UI entry listing the 10 SHS solver topics.
//
// Pattern: Grade6PickerScreen (search + recent + CurriculumResultCard).
// Source: CurriculumRegistry routes starting with '/shs' (10 thin
// solver screens reuse Grade6SolverConfig — no duplicated layout).
// Topic-first: subject chips AND with the text query. Styling via
// ThemeProvider only. Offline. Route (wired by middle-end): /topics/shs.
// ─────────────────────────────────────────────────────────────

import 'package:calculus_system/core/curriculum_registry.dart';
import 'package:calculus_system/services/history_service.dart';
import 'package:calculus_system/shared/widgets/accessible_back_button.dart';
import 'package:calculus_system/shared/widgets/catalogue_disclosure.dart';
import 'package:calculus_system/shared/widgets/curriculum_result_card.dart';
import 'package:calculus_system/shared/widgets/empty_state.dart';
import 'package:calculus_system/shared/widgets/recent_history.dart';
import 'package:calculus_system/shared/widgets/subject_filter_chips.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// SHS topics = registry entries routed under '/shs'.
List<CurriculumTopic> shsTopics() => CurriculumRegistry.allTopics()
    .where((t) => t.route.startsWith('/shs'))
    .toList();

class ShsPickerScreen extends StatefulWidget {
  const ShsPickerScreen({super.key});

  @override
  State<ShsPickerScreen> createState() => _ShsPickerScreenState();
}

class _ShsPickerScreenState extends State<ShsPickerScreen> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  final _history = const HistoryService();
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
    setState(() => _query = '');
    _searchFocusNode.requestFocus();
  }

  void _pickRecent(String query) {
    _searchController.text = query;
    _searchController.selection = TextSelection.collapsed(
      offset: _searchController.text.length,
    );
    setState(() => _query = query);
  }

  Future<void> _submitSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    await _history.addRecentSearch(trimmed);
    if (mounted) setState(() => _query = query);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final accent = theme.modmatAccent;
    final q = _query.trim();
    final all = shsTopics();
    final subjects = <String>[];
    for (final t in all) {
      if (!subjects.contains(t.subject)) subjects.add(t.subject);
    }

    bool matches(CurriculumTopic t) {
      if (_subject != 'All' && t.subject != _subject) return false;
      if (q.isEmpty) return true;
      final nq = q.toLowerCase();
      return t.label.toLowerCase().contains(nq) ||
          t.subtitle.toLowerCase().contains(nq) ||
          t.subject.toLowerCase().contains(nq) ||
          t.tags.any((tag) => tag.toLowerCase().contains(nq));
    }

    final topics = all.where(matches).toList();
    final solverBacked = all.where((t) => t.solverAvailable).length;

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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const AccessibleBackButton(),
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
                            '${all.length} topics',
                            style: TextStyle(
                              color: accent,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: accent.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Icon(
                            Icons.school_rounded,
                            color: accent,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Senior High',
                            style: TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.w800,
                              color: theme.textPrimary,
                              height: 1.1,
                              letterSpacing: -1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(left: 60),
                      child: Text(
                        '${all.length} topics · GenMath to Basic Calculus',
                        style: TextStyle(
                          fontSize: 15,
                          color: theme.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    CatalogueDisclosure(
                      solverBacked: solverBacked,
                      catalogueOnly: all.length - solverBacked,
                      catalogueName: 'SHS',
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
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
                    onChanged: (query) => setState(() => _query = query),
                    onSubmitted: _submitSearch,
                    style: TextStyle(color: theme.textPrimary),
                    cursorColor: accent,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Search SHS topics, e.g. log, interest, trig',
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
                  subjects: subjects,
                  selected: _subject,
                  onSelected: (s) => setState(() => _subject = s),
                ),
              ),
            ),
            if (topics.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: NoTopicsEmptyState(onClear: _clearSearch),
                ),
              ),
            if (topics.isNotEmpty && q.isEmpty && _subject == 'All')
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  child: FutureBuilder<List<String>>(
                    future: _history.getRecentSearches(),
                    builder: (context, snapshot) {
                      final searches = snapshot.data ?? const <String>[];
                      return RecentSearchesSection(
                        searches: searches,
                        onPick: _pickRecent,
                        onClear: () async {
                          await _history.clearRecentSearches();
                          if (mounted) setState(() {});
                        },
                      );
                    },
                  ),
                ),
              ),
            if (topics.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: CurriculumResultCard(topic: topics[index]),
                    ),
                    childCount: topics.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
