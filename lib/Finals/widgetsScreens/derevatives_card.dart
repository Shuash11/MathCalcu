import 'package:flutter/material.dart';
import 'package:calculus_system/Finals/finals_theme.dart';
import 'package:calculus_system/Finals/finals_module_registry.dart';
import 'package:provider/provider.dart';
import 'package:calculus_system/theme/theme_provider.dart';

class FinalsDerivativesCard extends StatefulWidget {
  final FinalsModuleEntry module;
  const FinalsDerivativesCard({super.key, required this.module});

  @override
  State<FinalsDerivativesCard> createState() => _FinalsDerivativesCardState();
}

class _FinalsDerivativesCardState extends State<FinalsDerivativesCard> {
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
                color: FinalsTheme.tertiary.withValues(
                  alpha: _hovered ? 0.6 : 0.25,
                ),
                width: _hovered ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: FinalsTheme.tertiary.withValues(
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // --- RESPONSIVE BREAKPOINTS ---
                  // If width is less than 600px, we consider it mobile/tablet mode
                  final bool isMobile = constraints.maxWidth < 600;
                  
                  // Dynamic Sizes
                  final double horizontalPadding = isMobile ? 16.0 : 20.0;
                  final double verticalPadding = isMobile ? 16.0 : 20.0;
                  final double iconBoxSize = isMobile ? 50.0 : 60.0;
                  final double spacing = isMobile ? 14.0 : 18.0;
                  final double titleFontSize = isMobile ? 16.0 : 18.0;
                  final double subFontSize = isMobile ? 12.0 : 13.0;

                  return Stack(
                    children: [
                      // ✨ Diagonal gradient accent
                      Positioned(
                        top: -40,
                        left: -40,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                FinalsTheme.tertiary.withValues(
                                  alpha: _hovered ? 0.3 : 0.15,
                                ),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),

                      // 🔥 Content
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                          vertical: verticalPadding,
                        ),
                        child: Row(
                          children: [
                            // 🌅 LEFT ICON BOX
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              width: iconBoxSize,
                              height: iconBoxSize,
                              decoration: BoxDecoration(
                                gradient: _hovered
                                    ? const LinearGradient(
                                        colors: [
                                          FinalsTheme.tertiary,
                                          FinalsTheme.primary,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : LinearGradient(
                                        colors: [
                                          FinalsTheme.tertiary.withValues(alpha: 0.2),
                                          FinalsTheme.primary.withValues(alpha: 0.1),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: FinalsTheme.tertiary.withValues(
                                    alpha: _hovered ? 0.8 : 0.35,
                                  ),
                                  width: _hovered ? 2 : 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: FinalsTheme.tertiary.withValues(
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
                                    Icons.trending_up_rounded,
                                    key: ValueKey(_hovered),
                                    color: _hovered
                                        ? Colors.white
                                        : FinalsTheme.tertiary,
                                    size: isMobile ? 24 : 28,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(width: spacing),

                            // Texts & Badges
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Title with d/dx badge
                                  Row(
                                    children: [
                                      Flexible( // Ensures title doesn't overflow
                                        child: AnimatedDefaultTextStyle(
                                          duration: const Duration(milliseconds: 200),
                                          style: TextStyle(
                                            fontSize: titleFontSize,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: -0.4,
                                            color: _hovered
                                                ? FinalsTheme.tertiary
                                                : theme.textPrimary,
                                          ),
                                          child: const Text("Derivatives"),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // d/dx badge
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: FinalsTheme.danger.withValues(
                                            alpha: _hovered ? 0.2 : 0.12,
                                          ),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(
                                            color: FinalsTheme.danger.withValues(
                                              alpha: _hovered ? 0.5 : 0.3,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          "d/dx",
                                          style: TextStyle(
                                            fontSize: isMobile ? 10 : 11,
                                            fontWeight: FontWeight.w900,
                                            color: FinalsTheme.danger.withValues(
                                              alpha: _hovered ? 1.0 : 0.8,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: isMobile ? 4 : 6),

                                  // Subtitle
                                  AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 200),
                                    style: TextStyle(
                                      fontSize: subFontSize,
                                      height: 1.4,
                                      color: _hovered
                                          ? FinalsTheme.tertiary.withValues(alpha: 0.7)
                                          : theme.textSecondary,
                                    ),
                                    child: const Text(
                                      "Power rule, product rule, quotient rule & chain rule",
                                      maxLines: 2, // Prevent overflow
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),

                                  SizedBox(height: isMobile ? 8 : 10),

                                  // Badge row - changed to Wrap for responsiveness
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 6,
                                    children: [
                                      _pillBadge(
                                        "Fundamental",
                                        FinalsTheme.tertiary,
                                        Icons.auto_graph_rounded,
                                        isMobile,
                                      ),
                                      _pillBadge(
                                        "Core",
                                        FinalsTheme.primary,
                                        Icons.star_rounded,
                                        isMobile,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Arrow button
                            if (!isMobile) // Hide arrow on very small screens to save space
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                transform: _hovered
                                    ? (Matrix4.identity()..translate(4.0, 0.0))
                                    : Matrix4.identity(),
                                margin: const EdgeInsets.only(left: 12),
                                child: Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: _hovered
                                        ? FinalsTheme.tertiary.withValues(alpha: 0.15)
                                        : Colors.transparent,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: FinalsTheme.tertiary.withValues(
                                        alpha: _hovered ? 0.5 : 0.25,
                                      ),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 16,
                                    color: _hovered
                                        ? FinalsTheme.tertiary
                                        : FinalsTheme.tertiary.withValues(alpha: 0.5),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _pillBadge(String text, Color color, IconData icon, bool isMobile) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 10, 
        vertical: isMobile ? 4 : 5
      ),
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
            size: isMobile ? 10 : 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: isMobile ? 10 : 11,
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