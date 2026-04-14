import 'package:flutter/material.dart';
import 'package:calculus_system/Finals/finals_theme.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class SubstitutionCard extends StatefulWidget {
  const SubstitutionCard({super.key});

  @override
  State<SubstitutionCard> createState() => _SubstitutionCardState();
}

class _SubstitutionCardState extends State<SubstitutionCard> {
  bool _hovered = false;
  bool _pressed = false;

  final String title = 'By Substitution';
  final String subtitle = 'The quickest way: Plug the value directly into the function.';
  final IconData icon = Icons.input_rounded;
  final String route = '/second-sem/limits/substitution';
  final Color accent = FinalsTheme.primary;

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          context.push(route);
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
                  // ── Dynamic background glow
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

                  // ── Content
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    child: Row(
                      children: [
                        // ── Icon Box
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                accent.withValues(alpha: _hovered ? 0.22 : 0.13),
                                accent.withValues(alpha: _hovered ? 0.10 : 0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
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
                          child: Center(
                            child: Icon(
                              icon,
                              color: _hovered ? accent : accent.withValues(alpha: 0.85),
                              size: 24,
                            ),
                          ),
                        ),

                        const SizedBox(width: 18),

                        // ── Text
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 180),
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: _hovered ? accent : theme.textPrimary,
                                  letterSpacing: -0.3,
                                ),
                                child: Text(title),
                              ),
                              const SizedBox(height: 2),
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 180),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _hovered
                                      ? accent.withValues(alpha: 0.65)
                                      : theme.textSecondary,
                                  height: 1.3,
                                ),
                                child: Text(subtitle),
                              ),
                            ],
                          ),
                        ),

                        // ── Arrow
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          transform: _hovered
                              ? (Matrix4.identity()..translate(3.0, 0.0))
                              : Matrix4.identity(),
                          child: Container(
                            width: 32,
                            height: 32,
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
                              color: _hovered ? accent : accent.withValues(alpha: 0.5),
                              size: 14,
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
