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

  // Baseline width the design was created for
  static const double _baseDesignWidth = 400.0;

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate dynamic scale factor based on actual given width
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
                      blurRadius: _hovered ? 30 * s : 18 * s,
                      offset: Offset(0, 10 * s),
                    ),
                    BoxShadow(
                      color: theme.shadowColor,
                      blurRadius: 10 * s,
                      offset: Offset(0, 4 * s),
                      spreadRadius: -4 * s,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22 * s),
                  child: Stack(
                    children: [
                      // ✨ Gradient glow overlay
                      Positioned.fill(
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: _hovered ? 1 : 0.6,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22 * s),
                              gradient: FinalsTheme.cardGlow(
                                hovered: _hovered,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // 🔥 Content
                      Padding(
                        padding: EdgeInsets.all(20 * s),
                        child: Row(
                          children: [
                            // 🌅 LEFT ICON BOX
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              width: 60 * s,
                              height: 60 * s,
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
                                borderRadius: BorderRadius.circular(16 * s),
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
                                    blurRadius: _hovered ? 16 * s : 8 * s,
                                    offset: Offset(0, 4 * s),
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
                                  AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 200),
                                    style: TextStyle(
                                      fontSize: 18 * s,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.4 * s,
                                      color: _hovered
                                          ? FinalsTheme.primary
                                          : theme.textPrimary,
                                    ),
                                    child: const Text(
                                      "Evaluating Limits",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),

                                  SizedBox(height: 6 * s),

                                  AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 200),
                                    style: TextStyle(
                                      fontSize: 13 * s,
                                      height: 1.4,
                                      color: _hovered
                                          ? FinalsTheme.primary.withValues(alpha: 0.7)
                                          : theme.textSecondary,
                                    ),
                                    child: const Text(
                                      "Direct substitution, factoring, rationalization & special limits",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),

                                  SizedBox(height: 10 * s),

                                  // Tag / badge row
                                  Row(
                                    children: [
                                      _badge("Core", FinalsTheme.primary, s),
                                      SizedBox(width: 6 * s),
                                      _badge("Important", FinalsTheme.secondary, s),
                                    ],
                                  )
                                ],
                              ),
                            ),

                            // Arrow button
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
                                  size: 16 * s,
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
      },
    );
  }

  // Updated badge widget to accept scale factor
  Widget _badge(String text, Color color, double s) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 3 * s),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8 * s),
        border: Border.all(
          color: color.withValues(alpha: 0.35),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10 * s,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}