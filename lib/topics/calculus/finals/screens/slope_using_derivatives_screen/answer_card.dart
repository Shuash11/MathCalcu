import 'package:calculus_system/topics/calculus/finals/solvers/slope_using_derivatives_solver/steps.dart';
import 'package:flutter/material.dart';
import 'package:calculus_system/shared/widgets/responsive_text.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:provider/provider.dart';
import 'package:calculus_system/topics/calculus/finals/finals_theme.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:calculus_system/shared/widgets/solution_steps_modal.dart';
import 'package:calculus_system/theme/app_design.dart';
import 'package:calculus_system/shared/widgets/solution_step_card.dart';

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
          showSolutionStepsModal(
            context: context,
            title: widget.solution.problemTitle,
            design: AppDesign.calculus,
            child: _SlopeDerivativesSteps(solution: widget.solution),
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
          Flexible(
            child: Text(
              text, 
              style: TextStyle(
                fontSize: 12, 
                fontWeight: FontWeight.w700, 
                color: color, 
                letterSpacing: 0.3,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _SlopeDerivativesSteps extends StatelessWidget {
  final ClassroomSolution solution;
  const _SlopeDerivativesSteps({required this.solution});

  bool _isMathExpression(String line) {
    if (line.trim().isEmpty) return false;
    if (line.contains('{') && line.contains('}')) return true;
    if (line.contains('\\') && RegExp(r'[\\{}]').hasMatch(line)) return true;
    if (line.contains('dy/dx') || line.contains('d/dx')) return true;
    final mathPattern = RegExp(r'[0-9]+[a-zA-Z\^]|[a-zA-Z][0-9]|\^|\+|\-|\/|\*|=');
    final hasVariables = RegExp(r'[x-yt]').hasMatch(line);
    final hasNumbers = RegExp(r'[0-9]').hasMatch(line);
    if (hasVariables && (mathPattern.hasMatch(line) || line.startsWith('?'))) return true;
    if (hasNumbers && mathPattern.hasMatch(line) && line.contains('=')) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
          child: Row(
            children: [
              Container(
                width: 3, height: 20,
                decoration: BoxDecoration(
                  color: FinalsTheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              ResponsiveText(
          '',
                style: FinalsTheme.labelStyle(context),
              ),
            ],
          ),
        ),
        ...solution.steps.asMap().entries.map((entry) {
          final i = entry.key;
          final step = entry.value;
          return SolutionStepCard(
            stepNumber: i + 1,
            title: step.label,
            description: step.hint,
            design: AppDesign.calculus,
            mathContent: _buildMathContent(step, context),
          );
        }),
      ],
    );
  }

  Widget _buildMathContent(ClassroomStep step, BuildContext context) {
    final textLines = <Widget>[];
    for (final line in step.lines) {
      if (line.trim().isEmpty) {
        textLines.add(const SizedBox(height: 6));
      } else if (_isMathExpression(line)) {
        textLines.add(Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Math.tex(
              line,
              textStyle: TextStyle(
                color: FinalsTheme.textPrimary(context),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              mathStyle: MathStyle.text,
              onErrorFallback: (err) => Text(
                line,
                style: TextStyle(
                  color: FinalsTheme.danger,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
        ));
      } else {
        textLines.add(Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            line,
            style: FinalsTheme.subtitleStyle(context).copyWith(
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ));
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: textLines,
    );
  }
}
