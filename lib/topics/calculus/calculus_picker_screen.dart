import 'package:calculus_system/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class CalculusPickerScreen extends StatefulWidget {
  const CalculusPickerScreen({super.key});

  @override
  State<CalculusPickerScreen> createState() => _CalculusPickerScreenState();
}

class _CalculusPickerScreenState extends State<CalculusPickerScreen>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(2, (i) => AnimationController(
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
    const accent = Color(0xFF6C63FF);

    return SliverToBoxAdapter(
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
                      border: Border.all(color: theme.textSecondary.withValues(alpha: 0.2)),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 16,
                      color: theme.textPrimary,
                    ),
                  ),
                ),
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
                    Icons.calculate_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Calculus',
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
    const accent = Color(0xFF6C63FF);

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
                      'CALCULUS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: accent,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Midterm and Finals topics',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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

  Widget _buildList(ThemeProvider theme) {
    final sections = [
      _Section(
        icon: Icons.school_rounded,
        label: 'Midterm',
        subtitle: 'Algebra, geometry, and coordinate topics',
        color: theme.textPrimary,
      ),
      _Section(
        icon: Icons.local_fire_department_rounded,
        label: 'Finals',
        subtitle: 'Limits, derivatives, and advanced topics',
        color: const Color(0xFFFFB020),
      ),
    ];

    return SliverPadding(
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
                  child: _CalculusSectionCard(
                    section: section,
                    onTap: () {
                      if (section.label == 'Midterm') {
                        context.push('/topics/calculus/midterm');
                      } else {
                        context.push('/topics/calculus/finals');
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

class _CalculusSectionCard extends StatefulWidget {
  final _Section section;
  final VoidCallback onTap;

  const _CalculusSectionCard({required this.section, required this.onTap});

  @override
  State<_CalculusSectionCard> createState() => _CalculusSectionCardState();
}

class _CalculusSectionCardState extends State<_CalculusSectionCard> {
  bool _pressed = false;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final accent = widget.section.color;
    final theme = context.watch<ThemeProvider>();

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
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          accent.withValues(alpha: _hovered ? 0.22 : 0.13),
                          accent.withValues(alpha: _hovered ? 0.10 : 0.05),
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
                          color: accent.withValues(alpha: _hovered ? 0.28 : 0.12),
                          blurRadius: _hovered ? 14 : 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.section.icon,
                      color: _hovered ? accent : accent.withValues(alpha: 0.85),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 18),
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
                          child: Text(widget.section.label),
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
                          child: Text(widget.section.subtitle),
                        ),
                      ],
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    transform: _hovered
                        ? Matrix4.translationValues(3.0, 0.0, 0.0)
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
          ),
        ),
      ),
    );
  }
}
