import 'package:flutter/material.dart';
import 'package:calculus_system/Finals/finals_theme.dart';
import 'package:calculus_system/Finals/finals_module_registry.dart';
import 'package:provider/provider.dart';
import 'package:calculus_system/theme/theme_provider.dart';

class FinalsSlopeDerivativeCard extends StatefulWidget {
  final FinalsModuleEntry module;
  const FinalsSlopeDerivativeCard({super.key, required this.module});

  @override
  State<FinalsSlopeDerivativeCard> createState() => _FinalsSlopeDerivativeCardState();
}

class _FinalsSlopeDerivativeCardState extends State<FinalsSlopeDerivativeCard> {
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
                color: FinalsTheme.danger.withValues(
                  alpha: _hovered ? 0.6 : 0.25,
                ),
                width: _hovered ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: FinalsTheme.danger.withValues(
                    alpha: _hovered ? 0.3 : 0.1,
                  ),
                  blurRadius: _hovered ? 28 : 16,
                  offset: const Offset(0, 8),
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
              borderRadius: BorderRadius.circular(22),
              child: Stack(
                children: [
                  // ✨ Bottom-right glow accent
                  Positioned(
                    bottom: -30,
                    right: -30,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            FinalsTheme.secondary.withValues(
                              alpha: _hovered ? 0.25 : 0.12,
                            ),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 🔥 Content
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        // 🌅 LEFT ICON BOX - Rose/Danger theme
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: _hovered
                                ? const LinearGradient(
                                    colors: [
                                      FinalsTheme.danger,
                                      FinalsTheme.secondary,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : LinearGradient(
                                    colors: [
                                      FinalsTheme.danger.withValues(alpha: 0.2),
                                      FinalsTheme.secondary.withValues(alpha: 0.1),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: FinalsTheme.danger.withValues(
                                alpha: _hovered ? 0.8 : 0.35,
                              ),
                              width: _hovered ? 2 : 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: FinalsTheme.danger.withValues(
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
                                Icons.show_chart_rounded,
                                key: ValueKey(_hovered),
                                color: _hovered
                                    ? Colors.white
                                    : FinalsTheme.danger,
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
                              // Title with m badge (slope notation)
                              Row(
                                children: [
                                  AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 200),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.4,
                                      color: _hovered
                                          ? FinalsTheme.danger
                                          : theme.textPrimary,
                                    ),
                                    child: const Text("Slope Using Derivatives"),
                                  ),
                                  const SizedBox(width: 8),
                                  // m = slope badge
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: FinalsTheme.primary.withValues(
                                        alpha: _hovered ? 0.2 : 0.12,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: FinalsTheme.primary.withValues(
                                          alpha: _hovered ? 0.5 : 0.3,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      "m = f'(x)",
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                        color: FinalsTheme.primary.withValues(
                                          alpha: _hovered ? 1.0 : 0.8,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 6),

                              // Subtitle
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.4,
                                  color: _hovered
                                      ? FinalsTheme.danger.withValues(alpha: 0.7)
                                      : theme.textSecondary,
                                ),
                                child: const Text(
                                  "Tangent line slope · Evaluate at point · Instantaneous rate",
                                ),
                              ),

                              const SizedBox(height: 10),

                              // Badge row
                              Row(
                                children: [
                                  _pillBadge(
                                    "Application",
                                    FinalsTheme.danger,
                                    Icons.touch_app_rounded,
                                  ),
                                  const SizedBox(width: 8),
                                  _pillBadge(
                                    "Tangent",
                                    FinalsTheme.secondary,
                                    Icons.linear_scale_rounded,
                                  ),
                                ],
                              ),
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
                                  ? FinalsTheme.danger.withValues(alpha: 0.15)
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: FinalsTheme.danger.withValues(
                                  alpha: _hovered ? 0.5 : 0.25,
                                ),
                                width: 1.5,
                              ),
                            ),
                            child: Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                              color: _hovered
                                  ? FinalsTheme.danger
                                  : FinalsTheme.danger.withValues(alpha: 0.5),
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

  Widget _pillBadge(String text, Color color, IconData icon) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}