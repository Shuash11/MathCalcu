import 'package:calculus_system/core/module_registry.dart';
import 'package:calculus_system/screens/about_sheets.dart';
import 'package:calculus_system/screens/inequality.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'distancecard.dart';
import 'slopecard.dart';
import 'midpointcard.dart';
import 'pointslopecard.dart';
import 'y-interceptcard.dart';
import 'circlecard.dart';
import 'twopointslopecard.dart';

class CategoryPickerScreen extends StatefulWidget {
  const CategoryPickerScreen({super.key});

  @override
  State<CategoryPickerScreen> createState() => _CategoryPickerScreenState();
}

class _CategoryPickerScreenState extends State<CategoryPickerScreen>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;

  final List<ModuleEntry> _modules = ModuleRegistry.modules;

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(
      _modules.length,
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
          ).animate(
            CurvedAnimation(parent: c, curve: Curves.easeOutCubic),
          ),
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
    if (label == 'circle') return CircleModuleCard(module: module);
    if (label == 'two-point slope' || label == 'twopointslope') {
      return TwoPointSlopeModuleCard(module: module);
    }
    return _ModuleCard(module: module);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    return Scaffold(
      backgroundColor: theme.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildHeader(),
            _buildList(),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 48, 28, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Accent bar
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Right-side buttons: About + Theme toggle
                Row(
                  children: [
                    // About button
                    GestureDetector(
                      onTap: () => showAboutSheet(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: context.watch<ThemeProvider>().card,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          size: 20,
                          color: Color(0xFF6C63FF),
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
                          color: context.watch<ThemeProvider>().card,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          context.watch<ThemeProvider>().isLight
                              ? Icons.dark_mode_rounded
                              : Icons.light_mode_rounded,
                          size: 20,
                          color: context.watch<ThemeProvider>().isLight
                              ? const Color(0xFF6C63FF)
                              : Colors.amber,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Calculus\nSystem',
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.w700,
                color: context.watch<ThemeProvider>().textPrimary,
                height: 1.1,
                letterSpacing: -1.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${_modules.length} topics available',
              style: TextStyle(
                fontSize: 15,
                color: context.watch<ThemeProvider>().textSecondary,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
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
    final accent = widget.module.accent;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        context.push(widget.module.route);
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        child: Container(
          decoration: BoxDecoration(
            color: context.watch<ThemeProvider>().card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accent.withValues(alpha: 0.18)),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(widget.module.icon, color: accent),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.module.label,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: context.watch<ThemeProvider>().textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.module.subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: context.watch<ThemeProvider>().textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: accent.withValues(alpha: 0.6),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
