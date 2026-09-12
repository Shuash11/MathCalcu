// ─────────────────────────────────────────────────────────────
// GLOBAL SEARCH SCREEN — dedicated /search route (Task 3).
//
// One query fans out to every registry via UnifiedSearch:
// ModuleRegistry (midterm) + FinalsModuleRegistry + ModMat +
// CurriculumRegistry (G6 seed + G7–College stubs).
//
// Offline-first (in-memory filter), Material3, ThemeProvider +
// AppDesign styling. Zero hits reuses NoTopicsEmptyState with a
// Clear-search action. Stub taps show "Coming in Phase 1".
// ─────────────────────────────────────────────────────────────

import 'package:calculus_system/search/unified_search.dart';
import 'package:calculus_system/services/history_service.dart';
import 'package:calculus_system/shared/widgets/curriculum_result_card.dart';
import 'package:calculus_system/shared/widgets/empty_state.dart';
import 'package:calculus_system/shared/widgets/recent_history.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
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
    final isFocused = _searchFocusNode.hasFocus;
    final trimmed = _query.trim();
    final hits = trimmed.isEmpty ? const <UnifiedHit>[] : UnifiedSearch.search(trimmed);

    return Scaffold(
      backgroundColor: theme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 48, 28, 16),
              child: Row(
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
                          color: theme.textSecondary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: theme.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Search',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: theme.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  color: theme.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: accent.withValues(alpha: isFocused ? 0.45 : 0.18),
                    width: isFocused ? 1.5 : 1,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  autofocus: true,
                  onChanged: (query) => setState(() => _query = query),
                  onSubmitted: _submitSearch,
                  style: TextStyle(color: theme.textPrimary),
                  cursorColor: accent,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Search topics, e.g. ratio, pie, derivative',
                    hintStyle: TextStyle(color: theme.textSecondary),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: isFocused ? accent : theme.textSecondary,
                    ),
                    suffixIcon: trimmed.isEmpty
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
            Expanded(
              child: _buildBody(theme, trimmed, hits),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    ThemeProvider theme,
    String trimmed,
    List<UnifiedHit> hits,
  ) {
    if (trimmed.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          Text(
            'Try "ratio", "pie", "derivative", or "G7".',
            style: TextStyle(color: theme.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 20),
          FutureBuilder<List<String>>(
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
          const SizedBox(height: 20),
          FutureBuilder<List<SolvedHistoryEntry>>(
            future: _history.getRecentSolved(),
            builder: (context, snapshot) {
              final entries = snapshot.data ?? const <SolvedHistoryEntry>[];
              return RecentlySolvedSection(
                entries: entries,
                onClear: () async {
                  await _history.clearRecentSolved();
                  if (mounted) setState(() {});
                },
              );
            },
          ),
        ],
      );
    }
    if (hits.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [NoTopicsEmptyState(onClear: _clearSearch)],
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
      itemCount: hits.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: UnifiedResultCard(hit: hits[index]),
      ),
    );
  }
}
