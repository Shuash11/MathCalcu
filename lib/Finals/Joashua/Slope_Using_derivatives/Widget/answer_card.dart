import 'package:calculus_system/Finals/Joashua/Slope_Using_derivatives/Solver/steps.dart';
import 'package:calculus_system/Finals/Joashua/Slope_Using_derivatives/Widget/steps_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calculus_system/Finals/finals_theme.dart';
import 'package:calculus_system/theme/theme_provider.dart';

class AnswerCard extends StatefulWidget {
  final ClassroomSolution solution;
  const AnswerCard({super.key, required this.solution});

  @override
  State<AnswerCard> createState() => _AnswerCardState();
}

class _AnswerCardState extends State<AnswerCard> {
  bool _hovered = false;

  /// Helper to format the double nicely (e.g., 10.0 -> "10", 2.5 -> "2.5")
  String _formatSlope(double? value) {
    if (value == null) return "N/A";
    if (value == value.truncateToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(3).replaceAll(RegExp(r'\.?0+$'), '');
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final r = widget.solution.result;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => StepsScreen(solution: widget.solution),
            ),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: FinalsTheme.card(context),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: FinalsTheme.danger.withValues(alpha: _hovered ? 0.6 : 0.25),
              width: _hovered ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: FinalsTheme.danger.withValues(alpha: _hovered ? 0.3 : 0.1),
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
                // Background glow effect
                Positioned(
                  bottom: -30, right: -30,
                  child: Container(
                    width: 140, height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          FinalsTheme.secondary.withValues(alpha: _hovered ? 0.25 : 0.12),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Main Content Column
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // TOP ROW: Label & Navigation Arrow
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle_outline, 
                                color: FinalsTheme.danger.withValues(alpha: _hovered ? 1.0 : 0.8), 
                                size: 20
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Slope (m)", 
                                style: TextStyle(
                                  fontSize: 14, 
                                  fontWeight: FontWeight.w700, 
                                  color: FinalsTheme.textPrimary(context).withValues(alpha: 0.6),
                                  letterSpacing: 0.5,
                                )
                              ),
                            ],
                          ),
                          Container(
                            width: 34, height: 34,
                            decoration: BoxDecoration(
                              color: _hovered ? FinalsTheme.danger.withValues(alpha: 0.15) : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(color: FinalsTheme.danger.withValues(alpha: _hovered ? 0.5 : 0.25), width: 1.5),
                            ),
                            child: Icon(
                              Icons.arrow_forward_ios_rounded, 
                              size: 14, 
                              color: FinalsTheme.danger.withValues(alpha: _hovered ? 1.0 : 0.5)
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // HERO ELEMENT: The Answer Itself
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.w900,
                          color: _hovered ? FinalsTheme.danger : FinalsTheme.textPrimary(context),
                          letterSpacing: -2,
                          height: 1.1,
                        ),
                        child: Text(_formatSlope(r.slopeValue)),
                      ),

                      const SizedBox(height: 24),

                      // BOTTOM ROW: Action Badges
                      Wrap(
                        alignment: WrapAlignment.start,
                        spacing: 8,
                        children: [
                          _pillBadge("View Steps", FinalsTheme.danger, Icons.double_arrow_rounded),
                          if (r.tangentLineEquation != null) 
                            _pillBadge("Tangent", FinalsTheme.secondary, Icons.linear_scale_rounded),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _pillBadge(String text, Color color, IconData icon) {
    final bool isHovered = _hovered;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isHovered ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: isHovered ? 0.6 : 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text, 
            style: TextStyle(
              fontSize: 12, 
              fontWeight: FontWeight.w700, 
              color: color, 
              letterSpacing: 0.3
            ),
          ),
        ],
      ),
    );
  }
}