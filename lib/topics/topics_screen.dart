import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:calculus_system/home/widgets/home_card.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:calculus_system/services/history_service.dart';
import 'package:calculus_system/shared/widgets/curriculum_result_card.dart';
import 'package:calculus_system/shared/widgets/recent_history.dart';
import 'package:calculus_system/shared/widgets/empty_state.dart';
import 'package:calculus_system/shared/widgets/responsive_text.dart';
import 'package:calculus_system/core/curriculum_registry.dart';
import 'package:provider/provider.dart';

class TopicsScreen extends StatefulWidget {
  const TopicsScreen({super.key});

  @override
  State<TopicsScreen> createState() => _TopicsScreenState();
}

class _TopicsScreenState extends State<TopicsScreen> {
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
    if (!mounted) return;
    setState(() => _query = query);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final width = MediaQuery.of(context).size.width;

    int crossAxisCount;
    if (width < 600) {
      crossAxisCount = 2;
    } else {
      crossAxisCount = 3;
    }

    final q = _query.trim().toLowerCase();
    final showCalculus =
        q.isEmpty || 'calculus'.contains(q) || 'midterm finals'.contains(q);
    final showModmat = q.isEmpty ||
        'modern math'.contains(q) ||
        'modmat foundations advanced'.contains(q);
    final showGrade6 = q.isEmpty ||
        'grade 6 arithmetic g6 fractions decimals percent ratio gemdas algebra integers geometry volume pie probability'
            .contains(q);
    final curriculumHits = q.isEmpty
        ? const <CurriculumSearchHit>[]
        : CurriculumRegistry.search(q);
    final hasLocalHits = showCalculus || showModmat || showGrade6;

    return Scaffold(
      backgroundColor: theme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: ResponsiveText(
          'Topics',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: theme.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Search all topics',
            onPressed: () => context.push('/search'),
            icon: Icon(Icons.search_rounded, color: theme.textPrimary),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            _buildSearchBar(theme),
            const SizedBox(height: 12),
            Expanded(
              child: q.isNotEmpty && !hasLocalHits && curriculumHits.isEmpty
                  ? ListView(
                      children: [NoTopicsEmptyState(onClear: _clearSearch)],
                    )
                  : ListView(
                      children: [
                        if (q.isEmpty) ...[
                          FutureBuilder<List<String>>(
                            future: _history.getRecentSearches(),
                            builder: (context, snapshot) {
                              final searches =
                                  snapshot.data ?? const <String>[];
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
                          const SizedBox(height: 16),
                          FutureBuilder<List<SolvedHistoryEntry>>(
                            future: _history.getRecentSolved(),
                            builder: (context, snapshot) {
                              final entries =
                                  snapshot.data ?? const <SolvedHistoryEntry>[];
                              return RecentlySolvedSection(
                                entries: entries.take(5).toList(),
                                onClear: () async {
                                  await _history.clearRecentSolved();
                                  if (mounted) setState(() {});
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (hasLocalHits)
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.0,
                            children: [
                              if (showCalculus)
                                HomeCard(
                                  icon: Icons.calculate_rounded,
                                  label: 'Calculus',
                                  accent: theme.accentColor,
                                  onTap: () => context.push('/topics/calculus'),
                                ),
                              if (showModmat)
                                HomeCard(
                                  icon: Icons.auto_awesome_rounded,
                                  label: 'Modern Math',
                                  accent: theme.modmatAccent,
                                  onTap: () => context.push('/topics/modmat'),
                                ),
                              if (showGrade6)
                                HomeCard(
                                  icon: Icons.calculate_rounded,
                                  label: 'Grade 6',
                                  accent: theme.accentColor,
                                  onTap: () => context.push('/grade6'),
                                ),
                            ],
                          ),
                        if (curriculumHits.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          Text(
                            'Curriculum matches',
                            style: TextStyle(
                              color: theme.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          for (final hit in curriculumHits) ...[
                            CurriculumResultCard(topic: hit.topic),
                            const SizedBox(height: 12),
                          ],
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(ThemeProvider theme) {
    final accent = theme.accentColor;
    final isFocused = _searchFocusNode.hasFocus;
    return AnimatedContainer(
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
        onChanged: (query) => setState(() => _query = query),
        style: TextStyle(color: theme.textPrimary),
        cursorColor: accent,
        textInputAction: TextInputAction.search,
        onSubmitted: (value) async {
          await _submitSearch(value);
          if (mounted) context.push('/search');
        },
        decoration: InputDecoration(
          hintText: 'Search topics, e.g. ratio, pie, derivative',
          hintStyle: TextStyle(color: theme.textSecondary),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: isFocused ? accent : theme.textSecondary,
          ),
          suffixIcon: _query.trim().isEmpty
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
    );
  }
}
