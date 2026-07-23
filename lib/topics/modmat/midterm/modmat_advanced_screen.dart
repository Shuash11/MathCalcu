import 'package:calculus_system/core/module_registry.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../modmat_theme.dart';
import '../modmat_module_registry.dart';

class ModmatAdvancedScreen extends StatefulWidget {
  const ModmatAdvancedScreen({super.key});

  @override
  State<ModmatAdvancedScreen> createState() => _ModmatAdvancedScreenState();
}

class _ModmatAdvancedScreenState extends State<ModmatAdvancedScreen>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;

  final List<ModuleEntry> _modules = ModmatModuleRegistry.advancedModules;

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(
        _modules.length,
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
      Future.delayed(Duration(milliseconds: 120 + i * 80), () {
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
            _buildList(theme),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeProvider theme) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 48, 28, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Semantics(
                  label: 'Back',
                  button: true,
                  onTap: () => context.pop(),
                  excludeSemantics: true,
                  child: GestureDetector(
                    excludeFromSemantics: true,
                    onTap: () => context.pop(),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: theme.card,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: theme.textSecondary.withValues(alpha: 0.2)),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: theme.textPrimary,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ModmatTheme.primary,
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
                    color: ModmatTheme.secondary,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: ModmatTheme.secondary.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.insights_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Advanced',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    color: theme.textPrimary,
                    height: 1.1,
                    letterSpacing: -1.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 60),
              child: Text(
                '${_modules.length} topics available',
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
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: ModmatTheme.secondary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: ModmatTheme.secondary.withValues(alpha: 0.25),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: ModmatTheme.secondary,
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
                        color: ModmatTheme.secondary,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Advanced mathematical topics',
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
                  color: ModmatTheme.secondary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_modules.length}',
                  style: const TextStyle(
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

  Widget _buildList(ThemeProvider theme) {
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
                  child: _AdvancedModuleCard(
                    module: module,
                    onTap: () => context.push(module.route),
                  ),
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

class _AdvancedModuleCard extends StatefulWidget {
  final ModuleEntry module;
  final VoidCallback onTap;

  const _AdvancedModuleCard({required this.module, required this.onTap});

  @override
  State<_AdvancedModuleCard> createState() => _AdvancedModuleCardState();
}

class _AdvancedModuleCardState extends State<_AdvancedModuleCard> {
  bool _pressed = false;
  bool _hovered = false;

  static const double _baseDesignWidth = 400.0;

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final double effectiveWidth = constraints.hasInfiniteWidth
            ? _baseDesignWidth
            : constraints.maxWidth;
        final double s = (effectiveWidth / _baseDesignWidth).clamp(0.7, 1.2);

        return MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: GestureDetector(
            onTapDown: (_) => setState(() => _pressed = true),
            onTapUp: (_) {
              setState(() => _pressed = false);
              widget.onTap();
            },
            onTapCancel: () => setState(() => _pressed = false),
            child: AnimatedScale(
              scale: _pressed ? 0.97 : 1.0,
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOut,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                decoration:
                    ModmatTheme.cardDecoration(context, hovered: _hovered),
                child: Padding(
                  padding: EdgeInsets.all(22 * s),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        width: 56 * s,
                        height: 56 * s,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              ModmatTheme.secondary
                                  .withValues(alpha: _hovered ? 0.22 : 0.13),
                              ModmatTheme.accent
                                  .withValues(alpha: _hovered ? 0.10 : 0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16 * s),
                          border: Border.all(
                            color: _hovered
                                ? ModmatTheme.secondary.withValues(alpha: 0.55)
                                : ModmatTheme.secondary.withValues(alpha: 0.25),
                            width: _hovered ? 1.5 * s : 1 * s,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: ModmatTheme.secondary
                                  .withValues(alpha: _hovered ? 0.28 : 0.12),
                              blurRadius: _hovered ? 14 * s : 6 * s,
                              offset: Offset(0, 3 * s),
                            ),
                          ],
                        ),
                        child: Icon(
                          widget.module.icon,
                          color: _hovered
                              ? ModmatTheme.secondary
                              : ModmatTheme.secondary.withValues(alpha: 0.85),
                          size: 26 * s,
                        ),
                      ),
                      SizedBox(width: 18 * s),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 180),
                              style: TextStyle(
                                fontSize: 18 * s,
                                fontWeight: FontWeight.w700,
                                color: _hovered
                                    ? ModmatTheme.secondary
                                    : theme.textPrimary,
                                letterSpacing: -0.3 * s,
                              ),
                              child: Text(widget.module.label),
                            ),
                            SizedBox(height: 4 * s),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 180),
                              style: TextStyle(
                                fontSize: 13 * s,
                                color: _hovered
                                    ? ModmatTheme.secondary
                                        .withValues(alpha: 0.65)
                                    : theme.textSecondary,
                                height: 1.4,
                              ),
                              child: Text(widget.module.subtitle),
                            ),
                          ],
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        transform: _hovered
                            ? Matrix4.translationValues(3.0 * s, 0.0, 0.0)
                            : Matrix4.identity(),
                        child: Container(
                          width: 34 * s,
                          height: 34 * s,
                          decoration: BoxDecoration(
                            color: _hovered
                                ? ModmatTheme.secondary.withValues(alpha: 0.15)
                                : Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _hovered
                                  ? ModmatTheme.secondary
                                      .withValues(alpha: 0.45)
                                  : ModmatTheme.secondary
                                      .withValues(alpha: 0.2),
                              width: 1.5 * s,
                            ),
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: _hovered
                                ? ModmatTheme.secondary
                                : ModmatTheme.secondary.withValues(alpha: 0.5),
                            size: 15 * s,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
