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

  // The baseline width the original design was created for
  static const double _baseDesignWidth = 400.0;

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate a scale factor (Clamped so it doesn't get too tiny or too big)
        final double s = (constraints.maxWidth / _baseDesignWidth).clamp(0.7, 1.2);

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
                  borderRadius: BorderRadius.circular(22 * s),
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
                      blurRadius: _hovered ? 28 * s : 16 * s,
                      offset: Offset(0, 8 * s),
                    ),
                    BoxShadow(
                      color: theme.shadowColor,
                      blurRadius: 12 * s,
                      offset: Offset(0, 4 * s),
                      spreadRadius: -4 * s,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22 * s),
                  child: Stack(
                    children: [
                      // ✨ Bottom-right glow accent
                      Positioned(
                        bottom: -30 * s,
                        right: -30 * s,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          width: 120 * s,
                          height: 120 * s,
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
                        padding: EdgeInsets.all(20 * s),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start, // Align top to allow text expansion
                          children: [
                            // 🌅 LEFT ICON BOX
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              width: 60 * s,
                              height: 60 * s,
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
                                borderRadius: BorderRadius.circular(16 * s),
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
                                    blurRadius: _hovered ? 16 * s : 8 * s,
                                    offset: Offset(0, 4 * s),
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
                                    size: 28 * s,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(width: 18 * s),

                            // Texts
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Title with m badge
                                  // CHANGED: Row -> Wrap to allow text to move to next line
                                  Wrap(
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    spacing: 8 * s,
                                    runSpacing: 4 * s,
                                    children: [
                                      // Title
                                      AnimatedDefaultTextStyle(
                                        duration: const Duration(milliseconds: 200),
                                        style: TextStyle(
                                          fontSize: 18 * s,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.4 * s,
                                          color: _hovered
                                              ? FinalsTheme.danger
                                              : theme.textPrimary,
                                          // No maxLines constraint here anymore
                                        ),
                                        child: const Text("Slope Using Derivatives"),
                                      ),
                                      
                                      // m = slope badge
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8 * s,
                                          vertical: 3 * s,
                                        ),
                                        decoration: BoxDecoration(
                                          color: FinalsTheme.primary.withValues(
                                            alpha: _hovered ? 0.2 : 0.12,
                                          ),
                                          borderRadius: BorderRadius.circular(6 * s),
                                          border: Border.all(
                                            color: FinalsTheme.primary.withValues(
                                              alpha: _hovered ? 0.5 : 0.3,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          "m = f'(x)",
                                          style: TextStyle(
                                            fontSize: 11 * s,
                                            fontWeight: FontWeight.w900,
                                            color: FinalsTheme.primary.withValues(
                                              alpha: _hovered ? 1.0 : 0.8,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 6 * s),

                                  // Subtitle
                                  // CHANGED: Removed maxLines and overflow to allow full text
                                  AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 200),
                                    style: TextStyle(
                                      fontSize: 13 * s,
                                      height: 1.4,
                                      color: _hovered
                                          ? FinalsTheme.danger.withValues(alpha: 0.7)
                                          : theme.textSecondary,
                                    ),
                                    child: const Text(
                                      "Tangent line slope · Evaluate at point · Instantaneous rate",
                                    ),
                                  ),

                                  SizedBox(height: 10 * s),

                                  // Badge row
                                  Wrap( // Also using Wrap here for extra safety
                                    spacing: 8 * s,
                                    runSpacing: 6 * s,
                                    children: [
                                      _pillBadge(
                                        "Application",
                                        FinalsTheme.danger,
                                        Icons.touch_app_rounded,
                                        s,
                                      ),
                                      _pillBadge(
                                        "Tangent",
                                        FinalsTheme.secondary,
                                        Icons.linear_scale_rounded,
                                        s,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Arrow button
                            // Hidden on very small scales to prevent overlap with expanding text
                            if (s > 0.85) 
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                transform: _hovered
                                    ? (Matrix4.identity()..translate(4.0 * s, 0.0))
                                    : Matrix4.identity(),
                                child: Container(
                                  width: 34 * s,
                                  height: 34 * s,
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
                                    size: 16 * s,
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
      },
    );
  }

  Widget _pillBadge(String text, Color color, IconData icon, double s) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 5 * s),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20 * s),
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
            size: 12 * s,
            color: color,
          ),
          SizedBox(width: 4 * s),
          Text(
            text,
            style: TextStyle(
              fontSize: 11 * s,
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