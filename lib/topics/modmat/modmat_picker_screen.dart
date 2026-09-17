import 'package:calculus_system/core/curriculum_registry.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:calculus_system/shared/widgets/accessible_back_button.dart';
import 'package:calculus_system/shared/widgets/catalogue_disclosure.dart';
import 'package:calculus_system/shared/widgets/curriculum_result_card.dart';
import 'package:calculus_system/topics/modmat/modmat_module_registry.dart';
import 'package:calculus_system/topics/modmat/modmat_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ModmatPickerScreen extends StatefulWidget {
  const ModmatPickerScreen({super.key});

  @override
  State<ModmatPickerScreen> createState() => _ModmatPickerScreenState();
}

class _ModmatPickerScreenState extends State<ModmatPickerScreen>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;
  String _query = '';

  @override
  void initState() {
    super.initState();

    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
    _searchFocusNode.addListener(() => setState(() {}));

    _controllers = List.generate(
        2,
        (i) => AnimationController(
              vsync: this,
              duration: const Duration(milliseconds: 600),
            ));

    _fadeAnims = _controllers
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeOut))
        .toList();

    _slideAnims = _controllers
        .map(
          (c) => Tween<Offset>(
            begin: const Offset(0, 0.25),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: c, curve: Curves.easeOutCubic)),
        )
        .toList();

    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: 120 + i * 100), () {
        if (mounted) _controllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: theme.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildHeader(theme),
            _buildBanner(theme),
            _buildSearch(theme),
            _buildList(theme),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeProvider theme) {
    final accent = theme.modmatAccent;

    return SliverToBoxAdapter(
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
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(2),
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
                    color: accent,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.grid_on_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Modern Math',
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
                '2 sections available',
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
    );
  }

  Widget _buildBanner(ThemeProvider theme) {
    final accent = theme.modmatAccent;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: accent.withValues(alpha: 0.25),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MODMAT',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: accent,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Foundations and Advanced topics',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '2',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearch(ThemeProvider theme) {
    final accent = theme.modmatAccent;
    final isFocused = _searchFocusNode.hasFocus;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Semantics(
          label: 'Search Modern Math topics',
          textField: true,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: ModmatTheme.inputDecoration(
              context,
              focused: isFocused,
              accentColor: accent,
            ),
            child: TextField(
              key: const Key('modmat-search-field'),
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: (query) => setState(() => _query = query),
              style: TextStyle(color: theme.textPrimary),
              cursorColor: accent,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search Modern Math topics',
                hintStyle: TextStyle(color: theme.textSecondary),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: isFocused ? accent : theme.textSecondary,
                ),
                suffixIcon: _query.trim().isEmpty
                    ? null
                    : Tooltip(
                        message: 'Clear search',
                        child: IconButton(
                          key: const Key('modmat-search-clear'),
                          tooltip: 'Clear search',
                          onPressed: _clearSearch,
                          icon: Icon(
                            Icons.close_rounded,
                            color: theme.textSecondary,
                          ),
                        ),
                      ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
    _searchFocusNode.requestFocus();
  }

  Widget _buildSearchResults(ThemeProvider theme) {
    final hits = ModmatModuleRegistry.search(_query);
    final curriculumHits = CurriculumRegistry.search(_query);
    if (hits.isEmpty && curriculumHits.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Semantics(
            liveRegion: true,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: ModmatTheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.search_off_rounded,
                    color: theme.textSecondary,
                    size: 36,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No topics found',
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Try another title or subtitle.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: theme.textSecondary, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: _clearSearch,
                    icon: const Icon(Icons.close_rounded),
                    label: const Text('Clear search'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverMainAxisGroup(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Search results',
                style: TextStyle(
                  color: theme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final hit = hits[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ModmatSearchResultCard(
                    hit: hit,
                    // Cycle 8: leaf routes are unwired until their
                    // screens land — gate instead of dead-pushing.
                    onTap: () {
                      if (!ModmatModuleRegistry.isRouteAvailable(
                        hit.module.route,
                      )) {
                        showTopicComingSoon(context, hit.module.label);
                        return;
                      }
                      context.push(hit.module.route);
                    },
                  ),
                );
              },
              childCount: hits.length,
            ),
          ),
          if (curriculumHits.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: CurriculumMatchesSection(query: _query),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildList(ThemeProvider theme) {
    if (_query.trim().isNotEmpty) {
      return _buildSearchResults(theme);
    }

    // P0-2 contract: truthful catalogue counts (registry truth).
    final foundationsCount = ModmatModuleRegistry.foundationsModules.length;
    final advancedCount = ModmatModuleRegistry.advancedModules.length;
    final accent = theme.modmatAccent;
    final sections = [
      _Section(
        icon: Icons.auto_awesome_rounded,
        label: 'Foundations',
        subtitle:
            '$foundationsCount topics · Logic, Sets, Proofs, Number Theory',
        color: accent,
      ),
      _Section(
        icon: Icons.architecture_rounded,
        label: 'Advanced',
        subtitle:
            '$advancedCount topics · Algebra, Analysis, Topology, Geometry',
        color: accent,
      ),
    ];

    return SliverMainAxisGroup(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final section = sections[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: FadeTransition(
                    opacity: _fadeAnims[index],
                    child: SlideTransition(
                      position: _slideAnims[index],
                      child: _ModmatSectionCard(
                        section: section,
                        onTap: () {
                          if (section.label == 'Foundations') {
                            context.push('/topics/modmat/foundations');
                          } else {
                            context.push('/topics/modmat/advanced');
                          }
                        },
                      ),
                    ),
                  ),
                );
              },
              childCount: sections.length,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: CatalogueDisclosure(
              solverBacked: 0,
              catalogueOnly: foundationsCount + advancedCount,
              catalogueName: 'Modern Math',
            ),
          ),
        ),
      ],
    );
  }
}

class _Section {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;

  const _Section({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
  });
}

class _ModmatSearchResultCard extends StatefulWidget {
  final ModmatSearchHit hit;
  final VoidCallback onTap;

  const _ModmatSearchResultCard({required this.hit, required this.onTap});

  @override
  State<_ModmatSearchResultCard> createState() =>
      _ModmatSearchResultCardState();
}

class _ModmatSearchResultCardState extends State<_ModmatSearchResultCard> {
  bool _hovered = false;
  bool _focused = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final module = widget.hit.module;
    final accent = module.accent;
    final highlighted = _hovered || _focused;

    return Semantics(
      button: true,
      label: '${module.label}, ${widget.hit.section}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: Key('modmat-search-result-${module.route}'),
          onTap: widget.onTap,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          onHover: (hovered) => setState(() => _hovered = hovered),
          onFocusChange: (focused) => setState(() => _focused = focused),
          borderRadius: BorderRadius.circular(20),
          hoverColor: accent.withValues(alpha: 0.08),
          focusColor: accent.withValues(alpha: 0.12),
          highlightColor: accent.withValues(alpha: 0.14),
          child: AnimatedScale(
            scale: _pressed ? 0.98 : 1,
            duration: const Duration(milliseconds: 120),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: theme.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: accent.withValues(alpha: highlighted ? 0.5 : 0.2),
                  width: highlighted ? 1.5 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: highlighted ? 0.16 : 0.06),
                    blurRadius: highlighted ? 24 : 12,
                    offset: const Offset(0, 6),
                  ),
                ],
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
                    child: Icon(module.icon, color: accent),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          module.label,
                          style: TextStyle(
                            color: theme.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          module.subtitle,
                          style: TextStyle(
                            color: theme.textSecondary,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 10),
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
                            widget.hit.section,
                            style: TextStyle(
                              color: accent,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
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
                      color: accent.withValues(alpha: 0.65),
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModmatSectionCard extends StatefulWidget {
  final _Section section;
  final VoidCallback onTap;

  const _ModmatSectionCard({required this.section, required this.onTap});

  @override
  State<_ModmatSectionCard> createState() => _ModmatSectionCardState();
}

class _ModmatSectionCardState extends State<_ModmatSectionCard> {
  bool _pressed = false;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final accent = widget.section.color;
    final theme = context.watch<ThemeProvider>();

    // P0-2: explicit Open action (48dp) with destination label.
    final openLabel = 'Open ${widget.section.label}';
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Semantics(
        label: '${widget.section.label}, ${widget.section.subtitle}',
        button: true,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: widget.onTap,
            onHighlightChanged: (h) => setState(() => _pressed = h),
            child: AnimatedScale(
              scale: _pressed ? 0.97 : 1.0,
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOut,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  color: theme.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _hovered
                        ? accent.withValues(alpha: 0.45)
                        : accent.withValues(alpha: 0.18),
                    width: _hovered ? 1.5 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _hovered
                          ? accent.withValues(alpha: 0.22)
                          : accent.withValues(alpha: 0.07),
                      blurRadius: _hovered ? 32 : 20,
                      offset: const Offset(0, 8),
                      spreadRadius: _hovered ? 2 : 0,
                    ),
                    BoxShadow(
                      color: theme.shadowColor,
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                      spreadRadius: -4,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  accent.withValues(
                                      alpha: _hovered ? 0.22 : 0.13),
                                  accent.withValues(
                                      alpha: _hovered ? 0.10 : 0.05),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _hovered
                                    ? accent.withValues(alpha: 0.55)
                                    : accent.withValues(alpha: 0.25),
                                width: _hovered ? 1.5 : 1,
                              ),
                            ),
                            child: Icon(
                              widget.section.icon,
                              color: _hovered
                                  ? accent
                                  : accent.withValues(alpha: 0.85),
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.section.label,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color:
                                        _hovered ? accent : theme.textPrimary,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.section.subtitle,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: theme.textSecondary,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Semantics(
                        label: openLabel,
                        button: true,
                        child: Tooltip(
                          message: openLabel,
                          child: SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton.icon(
                              onPressed: widget.onTap,
                              icon: const Icon(
                                Icons.arrow_forward_rounded,
                                size: 18,
                              ),
                              label: Text(openLabel),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: accent,
                                side: BorderSide(
                                  color: accent.withValues(alpha: 0.45),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
