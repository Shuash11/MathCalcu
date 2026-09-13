// ─────────────────────────────────────────────────────────────
// GRADE 6 PICKER — Phase-1 UI entry listing the 11 G6 topics.
//
// Source: Grade6ModuleRegistry (11 solver-backed entries).
// Search reuses the registry filter; zero hits show
// NoTopicsEmptyState with a Clear action. Rows reuse
// CurriculumResultCard (grade badge included). Taps push the
// topic route via handleCurriculumTap (solverAvailable=true).
//
// Styling via ThemeProvider only. Offline.
// ─────────────────────────────────────────────────────────────

import 'package:calculus_system/core/curriculum_registry.dart';
import 'package:calculus_system/services/history_service.dart';
import 'package:calculus_system/shared/widgets/curriculum_result_card.dart';
import 'package:calculus_system/shared/widgets/empty_state.dart';
import 'package:calculus_system/shared/widgets/recent_history.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class Grade6PickerScreen extends StatefulWidget {
  const Grade6PickerScreen({super.key});

  @override
  State<Grade6PickerScreen> createState() => _Grade6PickerScreenState();
}

class _Grade6PickerScreenState extends State<Grade6PickerScreen> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  final _history = const HistoryService();
  String _query = '';

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
    final accent = theme.accentColor;
    final q = _query.trim();

    final List<CurriculumTopic> topics = q.isEmpty
        ? Grade6ModuleRegistry.modules
        : Grade6ModuleRegistry.search(q).map((h) => h.topic).toList();

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
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: theme.card,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color:
                                    theme.textSecondary.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 16,
                              color: theme.textPrimary,
                            ),
                          ),
                        ),
                        const GradeBadge(gradeLevel: 'G6'),
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
                            Icons.calculate_rounded,
                            color: accent,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Grade 6',
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
                        '${Grade6ModuleRegistry.modules.length} topics · DepEd-aligned',
                        style: TextStyle(
                          fontSize: 15,
                          color: theme.textSecondary,
                        ),
                      ),
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
                      hintText:
                          'Search Grade 6 topics, e.g. ratio, pie, fraction',
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
            if (topics.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: NoTopicsEmptyState(onClear: _clearSearch),
                ),
              ),
            if (topics.isNotEmpty && q.isEmpty)
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
            if (topics.isNotEmpty && q.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                  child: FutureBuilder<List<SolvedHistoryEntry>>(
                    future: _history.getRecentSolved(),
                    builder: (context, snapshot) {
                      final entries =
                          snapshot.data ?? const <SolvedHistoryEntry>[];
                      final g6 = entries
                          .where((e) => e.route.startsWith('/grade6'))
                          .toList();
                      return RecentlySolvedSection(
                        entries: g6,
                        onClear: () async {
                          await _history.clearRecentSolved();
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
