import 'package:flutter/material.dart';
import 'package:calculus_system/Finals/finals_theme.dart';
import 'package:calculus_system/Finals/finals_module_registry.dart';
import 'package:provider/provider.dart';
import 'package:calculus_system/theme/theme_provider.dart';

class FinalsLimitsCard extends StatefulWidget {
  final FinalsModuleEntry module;
  const FinalsLimitsCard({super.key, required this.module});

  @override
  State<FinalsLimitsCard> createState() => _FinalsLimitsCardState();
}

class _FinalsLimitsCardState extends State<FinalsLimitsCard> {
  bool _hovered = false;
  bool _pressed = false;

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
          // context.push(widget.module.route);
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.96 : 1,
          duration: const Duration(milliseconds: 120),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: theme.card,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: FinalsTheme.primary.withValues(
                  alpha: _hovered ? 0.5 : 0.2,
                ),
                width: _hovered ? 1.6 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: FinalsTheme.primary.withValues(
                    alpha: _hovered ? 0.25 : 0.08,
                  ),
                  blurRadius: _hovered ? 30 : 18,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: theme.shadowColor,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                  spreadRadius: -4,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Stack(
                children: [
                  // ✨ Gradient glow overlay
                  Positioned.fill(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: _hovered ? 1 : 0.6,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          gradient: FinalsTheme.cardGlow(
                            hovered: _hovered,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 🔥 Content
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        // 🌅 LEFT ICON BOX - matching infinity card style
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: _hovered
                                ? FinalsTheme.headerGradient
                                : LinearGradient(
                                    colors: [
                                      FinalsTheme.primary.withValues(alpha: 0.2),
                                      FinalsTheme.secondary.withValues(alpha: 0.1),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: FinalsTheme.primary.withValues(
                                alpha: _hovered ? 0.8 : 0.35,
                              ),
                              width: _hovered ? 2 : 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: FinalsTheme.primary.withValues(
                                  alpha: _hovered ? 0.4 : 0.2,
                                ),
                                blurRadius: _hovered ? 16 : 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: Icon(
                                Icons.functions_rounded,
                                key: ValueKey(_hovered),
                                color: _hovered
                                    ? Colors.white
                                    : FinalsTheme.primary,
                                size: 28,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 18),

                        // Texts
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.4,
                                  color: _hovered
                                      ? FinalsTheme.primary
                                      : theme.textPrimary,
                                ),
                                child: const Text("Evaluating Limits"),
                              ),

                              const SizedBox(height: 6),

                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.4,
                                  color: _hovered
                                      ? FinalsTheme.primary.withValues(alpha: 0.7)
                                      : theme.textSecondary,
                                ),
                                child: const Text(
                                  "Direct substitution, factoring, rationalization & special limits",
                                ),
                              ),

                              const SizedBox(height: 10),

                              // Tag / badge row
                              Row(
                                children: [
                                  _badge("Core", FinalsTheme.primary),
                                  const SizedBox(width: 6),
                                  _badge("Important", FinalsTheme.secondary),
                                ],
                              )
                            ],
                          ),
                        ),

                        // Arrow button
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          transform: _hovered
                              ? (Matrix4.identity()..translate(4.0, 0.0))
                              : Matrix4.identity(),
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: _hovered
                                  ? FinalsTheme.primary.withValues(alpha: 0.15)
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: FinalsTheme.primary.withValues(
                                  alpha: _hovered ? 0.5 : 0.25,
                                ),
                                width: 1.5,
                              ),
                            ),
                            child: Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                              color: _hovered
                                  ? FinalsTheme.primary
                                  : FinalsTheme.primary.withValues(alpha: 0.5),
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

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.35),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}