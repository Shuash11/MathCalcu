import 'package:calculus_system/Finals/finals_theme.dart';
import 'package:calculus_system/Finals/finals_module_registry.dart';
import 'package:calculus_system/Finals/widgetsScreens/derevatives_card.dart';
import 'package:calculus_system/Finals/widgetsScreens/evaluationg_limits.dart';
import 'package:calculus_system/Finals/widgetsScreens/finals_about_sheets.dart'
    as finals_about_sheets;
import 'package:calculus_system/Finals/widgetsScreens/finding_slope_derevatives_card.dart';
import 'package:calculus_system/Finals/widgetsScreens/limits_and_infinity_card.dart';
import 'package:calculus_system/screens/category_picker_screen.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ─────────────────────────────────────────────────────────────
// FINALS PICKER SCREEN
//
// Sister screen to CategoryPickerScreen.
// Reads from FinalsModuleRegistry — add entries there, not here.
// Theme lives in FinalsTheme — change colours there, not here.
//
// To wire a new card:
//   1. Create  screens/finals/cards/your_card.dart
//   2. Add entry to FinalsModuleRegistry.modules
//
// ─────────────────────────────────────────────────────────────

class FinalsPickerScreen extends StatefulWidget {
  const FinalsPickerScreen({super.key});

  @override
  State<FinalsPickerScreen> createState() => _FinalsPickerScreenState();
}

class _FinalsPickerScreenState extends State<FinalsPickerScreen>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;

  final List<FinalsModuleEntry> _modules = FinalsModuleRegistry.modules;

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(
      // Always animate at least 1 slot so the empty state also fades in
      _modules.isEmpty ? 1 : _modules.length,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      ),
    );

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
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  Widget _buildModuleCard(FinalsModuleEntry module) {
    final label = module.label.toLowerCase();

    if (label.contains('slope') && label.contains('derivative')) {
      return FinalsSlopeDerivativeCard(module: module);
    }
    // Check MORE SPECIFIC match first (infinity)
    if (label.contains('infinity')) {
      return FinalsInfinityLimitsCard(module: module);
    }
    if (label.contains('derivative')) {
      return FinalsDerivativesCard(module: module);
    }
    // Then check GENERAL match (limit)
    if (label.contains('limit')) {
      return FinalsLimitsCard(module: module);
    }

    return _FinalsDefaultCard(module: module);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FinalsTheme.surface(context),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildHeader(),
            _buildBanner(),
            _buildList(),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────

  Widget _buildHeader() {
    final theme = context.watch<ThemeProvider>();

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 48, 28, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Accent bar — gold gradient
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: FinalsTheme.headerGradient,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Right controls
                Row(
                  children: [
                    // Back to Mid Term pill
                    GestureDetector(
                      onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const CategoryPickerScreen())),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            color: FinalsTheme.primary.withValues(alpha: 0.45),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 13,
                              color:
                                  FinalsTheme.primary.withValues(alpha: 0.85),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Mid Term',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color:
                                    FinalsTheme.primary.withValues(alpha: 0.85),
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // 👤 HUMAN ICON BUTTON (About button)
                    GestureDetector(
                      onTap: () =>
                          finals_about_sheets.showFinalsAboutSheet(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.card,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          size: 20,
                          color: FinalsTheme.primary,
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Theme toggle
                    GestureDetector(
                      onTap: () => context.read<ThemeProvider>().toggle(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.card,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          theme.isLight
                              ? Icons.dark_mode_rounded
                              : Icons.light_mode_rounded,
                          size: 20,
                          color: theme.isLight
                              ? FinalsTheme.primary
                              : Colors.amber,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Title row
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Gold flame icon container
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: FinalsTheme.headerGradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: FinalsTheme.primary.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.local_fire_department_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                ShaderMask(
                  shaderCallback: (bounds) =>
                      FinalsTheme.headerGradient.createShader(bounds),
                  child: const Text(
                    'Finals',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                      color: Colors.white, // masked by shader
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
                '${_modules.length} topic${_modules.length == 1 ? '' : 's'} available',
                style: FinalsTheme.subtitleStyle(context),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ── Semester badge banner ─────────────────────────────────

  Widget _buildBanner() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: FinalsTheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: FinalsTheme.primary.withValues(alpha: 0.25),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  gradient: FinalsTheme.headerGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
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
                      'FINALS PERIOD',
                      style: FinalsTheme.labelStyle(context),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Advanced topics for the final term',
                      style: FinalsTheme.subtitleStyle(context)
                          .copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: FinalsTheme.headerGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Finals',
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

  // ── Module list ───────────────────────────────────────────

  Widget _buildList() {
    if (_modules.isEmpty) {
      return SliverToBoxAdapter(
        child: FadeTransition(
          opacity: _fadeAnims[0],
          child: SlideTransition(
            position: _slideAnims[0],
            child: _EmptyState(),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final module = _modules[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: FadeTransition(
                opacity: _fadeAnims[index],
                child: SlideTransition(
                  position: _slideAnims[index],
                  child: _buildModuleCard(module),
                ),
              ),
            );
          },
          childCount: _modules.length,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// EMPTY STATE
// Shown when FinalsModuleRegistry.modules is empty
// ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        decoration: BoxDecoration(
          color: FinalsTheme.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: FinalsTheme.primary.withValues(alpha: 0.18),
          ),
        ),
        child: Column(
          children: [
            ShaderMask(
              shaderCallback: (bounds) =>
                  FinalsTheme.headerGradient.createShader(bounds),
              child: const Icon(
                Icons.hourglass_empty_rounded,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Topics coming soon',
              style: FinalsTheme.titleStyle(context).copyWith(fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              'Finals modules will appear here once added\nto FinalsModuleRegistry.',
              textAlign: TextAlign.center,
              style: FinalsTheme.subtitleStyle(context).copyWith(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// DEFAULT CARD
// Used for any module that doesn't have a custom card yet.
// Replace with a custom card by adding a branch in

// ─────────────────────────────────────────────────────────────

class _FinalsDefaultCard extends StatefulWidget {
  final FinalsModuleEntry module;
  const _FinalsDefaultCard({required this.module});

  @override
  State<_FinalsDefaultCard> createState() => _FinalsDefaultCardState();
}

class _FinalsDefaultCardState extends State<_FinalsDefaultCard> {
  bool _pressed = false;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final accent = widget.module.accent;
    final theme = context.watch<ThemeProvider>();

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          // context.push(widget.module.route);
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: theme.card,
              borderRadius: BorderRadius.circular(20),
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // ── Background glow orb (top right)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 380),
                    curve: Curves.easeOut,
                    top: _hovered ? -35 : -25,
                    right: _hovered ? -35 : -25,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 280),
                      width: _hovered ? 150 : 110,
                      height: _hovered ? 150 : 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent.withValues(
                          alpha: _hovered ? 0.13 : 0.07,
                        ),
                      ),
                    ),
                  ),

                  // ── Background glow orb (bottom left)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 380),
                    curve: Curves.easeOut,
                    bottom: _hovered ? -25 : -18,
                    left: _hovered ? -25 : -18,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 280),
                      width: _hovered ? 120 : 90,
                      height: _hovered ? 120 : 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: FinalsTheme.secondary.withValues(
                          alpha: _hovered ? 0.10 : 0.04,
                        ),
                      ),
                    ),
                  ),

                  // ── Content
                  Padding(
                    padding: const EdgeInsets.all(22),
                    child: Row(
                      children: [
                        // ── ICON BOX (UPDATED with human badge)
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
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _hovered
                                  ? accent.withValues(alpha: 0.55)
                                  : accent.withValues(alpha: 0.25),
                              width: _hovered ? 1.5 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: accent.withValues(
                                    alpha: _hovered ? 0.28 : 0.12),
                                blurRadius: _hovered ? 14 : 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Icon(
                                  widget.module.icon,
                                  color: _hovered
                                      ? accent
                                      : accent.withValues(alpha: 0.85),
                                  size: 26,
                                ),
                              ),

                              // 👤 HUMAN BADGE
                              Positioned(
                                right: 5,
                                top: 5,
                                child: Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: accent.withValues(alpha: 0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.person_rounded,
                                    size: 12,
                                    color: accent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 18),

                        // ── TEXT
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 180),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: _hovered ? accent : theme.textPrimary,
                                  letterSpacing: -0.3,
                                ),
                                child: Text(widget.module.label),
                              ),
                              const SizedBox(height: 4),
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 180),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _hovered
                                      ? accent.withValues(alpha: 0.65)
                                      : theme.textSecondary,
                                  height: 1.4,
                                ),
                                child: Text(widget.module.subtitle),
                              ),
                            ],
                          ),
                        ),

                        // ── ARROW
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          transform: _hovered
                              ? (Matrix4.identity()..translate(3.0, 0.0))
                              : Matrix4.identity(),
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: _hovered
                                  ? accent.withValues(alpha: 0.15)
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _hovered
                                    ? accent.withValues(alpha: 0.45)
                                    : accent.withValues(alpha: 0.2),
                                width: 1.5,
                              ),
                            ),
                            child: Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: _hovered
                                  ? accent
                                  : accent.withValues(alpha: 0.5),
                              size: 15,
                            ),
                          ),
                        ),
                      ],
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
