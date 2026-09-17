import 'package:calculus_system/core/curriculum_registry.dart';
import 'package:calculus_system/core/module_registry.dart';
import 'package:calculus_system/screens/inequality.dart';
import 'package:calculus_system/shared/widgets/accessible_back_button.dart';
import 'package:calculus_system/shared/widgets/curriculum_result_card.dart';
import 'package:calculus_system/shared/widgets/empty_state.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'distancecard.dart';
import 'slopecard.dart';
import 'midpointcard.dart';
import 'pointslopecard.dart';
import 'y_intercept_card.dart';
import 'circlecard.dart';
import 'twopointslopecard.dart';
import 'parallelperpendicularcard.dart';

class CategoryPickerScreen extends StatefulWidget {
  const CategoryPickerScreen({super.key});

  @override
  State<CategoryPickerScreen> createState() => _CategoryPickerScreenState();
}

class _CategoryPickerScreenState extends State<CategoryPickerScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _staggerController;
  late final List<ModuleEntry> _modules;
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _modules = ModuleRegistry.modules;
    _staggerController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300 + _modules.length * 60),
    )..forward();
  }

  @override
  void dispose() {
    _staggerController?.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  List<ModuleEntry> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _modules;
    return _modules
        .where((m) =>
            m.label.toLowerCase().contains(q) ||
            m.subtitle.toLowerCase().contains(q))
        .toList();
  }

  /// Curriculum hits (G6 seed + G7–College stubs) for the same query.
  /// Empty when the search box is blank so the default list shows.
  List<CurriculumSearchHit> get _curriculumHits {
    if (_query.trim().isEmpty) return const [];
    return CurriculumRegistry.search(_query);
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
    _searchFocusNode.requestFocus();
  }

  Animation<double> _fadeFor(int index) {
    final ctrl = _staggerController;
    if (ctrl == null) return const AlwaysStoppedAnimation(1.0);
    final start = (index * 0.06).clamp(0.0, 0.85);
    final end = (start + 0.25).clamp(0.0, 1.0);
    return CurvedAnimation(
      parent: ctrl,
      curve: Interval(start, end, curve: Curves.easeOut),
    );
  }

  Animation<Offset> _slideFor(int index) {
    final ctrl = _staggerController;
    if (ctrl == null) return const AlwaysStoppedAnimation(Offset.zero);
    final start = (index * 0.06).clamp(0.0, 0.85);
    final end = (start + 0.30).clamp(0.0, 1.0);
    return Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: ctrl,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ),
    );
  }

  Widget _buildModuleCard(ModuleEntry module) {
    final label = module.label.toLowerCase();
    if (label == 'inequalities') return InequalityModuleCard(module: module);
    if (label == 'slope') return SlopeModuleCard(module: module);
    if (label == 'distance') return DistanceModuleCard(module: module);
    if (label == 'midpoint') return MidpointModuleCard(module: module);
    if (label == 'point-slope' || label == 'pointslope') {
      return PointSlopeModuleCard(module: module);
    }
    if (label == 'slope-intercept-form') {
      return YInterceptModuleCard(module: module);
    }
    if (label == 'parallel-perpendicular') {
      return ParallelPerpendicularModuleCard(module: module);
    }
    if (label == 'circle') return CircleModuleCard(module: module);
    if (label == 'two-point slope' || label == 'twopointslope') {
      return TwoPointSlopeModuleCard(module: module);
    }
    return _ModuleCard(module: module);
  }

  Widget _buildSearchBar(ThemeProvider theme) {
    final isFocused = _searchFocusNode.hasFocus;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: theme.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: theme.accentColor.withValues(
              alpha: isFocused ? 0.45 : 0.18,
            ),
            width: isFocused ? 1.5 : 1,
          ),
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          onChanged: (query) => setState(() => _query = query),
          style: TextStyle(color: theme.textPrimary),
          cursorColor: theme.accentColor,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Search topics, e.g. slope, midpoint',
            hintStyle: TextStyle(color: theme.textSecondary),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: isFocused ? theme.accentColor : theme.textSecondary,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: theme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fixed header — never participates in scroll layout
            _CategoryHeader(
              moduleCount: _modules.length,
              theme: theme,
            ),
            _buildSearchBar(theme),
            // List takes the remaining bounded space
            Expanded(
              child: _filtered.isEmpty && _curriculumHits.isEmpty
                  ? ListView(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
                      children: [
                        NoTopicsEmptyState(onClear: _clearSearch),
                      ],
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      children: [
                        for (int index = 0; index < _filtered.length; index++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: FadeTransition(
                              opacity: _fadeFor(index),
                              child: SlideTransition(
                                position: _slideFor(index),
                                child: RepaintBoundary(
                                  child: _buildModuleCard(_filtered[index]),
                                ),
                              ),
                            ),
                          ),
                        if (_curriculumHits.isNotEmpty) ...[
                          CurriculumMatchesSection(
                            query: _query,
                            padding: const EdgeInsets.only(top: 4),
                          ),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _CategoryHeader extends StatelessWidget {
  final int moduleCount;
  final ThemeProvider theme;

  const _CategoryHeader({
    required this.moduleCount,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final accent = theme.accentColor;

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 48, 28, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // P1-1: 48dp Material back target with Semantics + tooltip.
              const AccessibleBackButton(),
              // Accent bar
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
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/app_icon.png',
                width: 42,
                height: 42,
              ),
              const SizedBox(width: 10),
              Text(
                'MathCalc',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w700,
                  color: theme.textPrimary,
                  height: 1.1,
                  letterSpacing: -1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 52),
            child: Text(
              '$moduleCount topics available',
              style: TextStyle(
                fontSize: 15,
                color: theme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Default card for unregistered modules ─────────────────────────────────────

class _ModuleCard extends StatefulWidget {
  final ModuleEntry module;
  const _ModuleCard({required this.module});

  @override
  State<_ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<_ModuleCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.read<ThemeProvider>();
    final accent = theme.accentColor;

    // P1-1: keyboard-focusable card with Semantics label + 48dp arrow hit.
    return Semantics(
      label: '${widget.module.label}, ${widget.module.subtitle}',
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => context.push(widget.module.route),
          onHighlightChanged: (h) => setState(() => _pressed = h),
          child: AnimatedScale(
            scale: _pressed ? 0.97 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: Container(
              decoration: BoxDecoration(
                color: theme.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: accent.withValues(alpha: 0.18)),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(widget.module.icon, color: accent),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.module.label,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: theme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.module.subtitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: accent.withValues(alpha: 0.6),
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
