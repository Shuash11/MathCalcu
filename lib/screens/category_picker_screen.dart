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
    super.dispose();
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
            // List takes the remaining bounded space
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                itemCount: _modules.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: FadeTransition(
                      opacity: _fadeFor(index),
                      child: SlideTransition(
                        position: _slideFor(index),
                        child: RepaintBoundary(
                          child: _buildModuleCard(_modules[index]),
                        ),
                      ),
                    ),
                  );
                },
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
    const accent = Color(0xFF6C63FF);

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 48, 28, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Accent bar
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Right-side buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Finals pill
                  GestureDetector(
                    onTap: () => context.push('/second-sem'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: accent.withValues(alpha: 0.45),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.school_rounded,
                            size: 15,
                            color: accent.withValues(alpha: 0.85),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Finals',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: accent.withValues(alpha: 0.85),
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // About
                  GestureDetector(
                    onTap: () => showAboutSheet(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.card,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        size: 20,
                        color: accent,
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
                        color: theme.isLight ? accent : Colors.amber,
                      ),
                    ),
                  ),
                ],
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
    final accent = widget.module.accent;
    final theme = context.read<ThemeProvider>();

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        context.push(widget.module.route);
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          decoration: BoxDecoration(
            color: theme.card,
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
          padding: const EdgeInsets.all(24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
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
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: accent.withValues(alpha: 0.6),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}