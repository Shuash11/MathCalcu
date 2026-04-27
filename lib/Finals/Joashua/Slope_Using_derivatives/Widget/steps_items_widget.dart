import 'package:calculus_system/Finals/Joashua/Slope_Using_derivatives/Solver/steps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:calculus_system/Finals/finals_theme.dart';

class StepItemWidget extends StatelessWidget {
  final ClassroomStep step;
  const StepItemWidget({super.key, required this.step});

  bool _isMathExpression(String line) {
    if (line.trim().isEmpty) return false;
    if (line.contains('\\') && RegExp(r'[\\{}]').hasMatch(line)) return true;
    if (line.contains('dy/dx') || line.contains('d/dx')) return true;
    
    final mathPattern = RegExp(r'[0-9]+[a-zA-Z\^]|[a-zA-Z][0-9]|\^|\+|\-|\/|\*|=');
    final hasVariables = RegExp(r'[x-yt]').hasMatch(line);
    final hasNumbers = RegExp(r'[0-9]').hasMatch(line);
    
    if (hasVariables && (mathPattern.hasMatch(line) || line.startsWith('→'))) return true;
    if (hasNumbers && mathPattern.hasMatch(line) && line.contains('=')) return true;

    return false;
  }

  /// Safely renders LaTeX on mobile. 
  /// Wraps in a horizontal scroll view to prevent overflow errors on long equations.
  Widget _buildMathLine(String line, TextStyle style) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal, // Allows swiping left/right on long equations
        physics: const BouncingScrollPhysics(), // Native iOS/Android feel
        child: Math.tex(
          line,
          textStyle: style,
          mathStyle: MathStyle.text,
          onErrorFallback: (err) => Text(
            line,
            style: TextStyle(
              color: FinalsTheme.danger,
              fontSize: style.fontSize! - 2,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (step.kind) {
      case StepKind.sectionHeader:
        return _buildSectionHeader(context);
      case StepKind.result:
        return _buildResultBox(context);
      case StepKind.note:
        return _buildNote(context);
      default:
        return _buildStandardStep(context);
    }
  }

  Widget _buildStandardStep(BuildContext context) {
    Color accentColor;
    IconData icon;

    switch (step.kind) {
      case StepKind.ruleStatement:
        accentColor = FinalsTheme.tertiary;
        icon = Icons.lightbulb_outline_rounded;
        break;
      case StepKind.algebra:
        accentColor = FinalsTheme.danger;
        icon = Icons.calculate_rounded;
        break;
      case StepKind.substitution:
        accentColor = FinalsTheme.primary;
        icon = Icons.subscript_rounded;
        break;
      case StepKind.tangentNormal:
        accentColor = FinalsTheme.secondary;
        icon = Icons.show_chart_rounded;
        break;
      default:
        accentColor = FinalsTheme.primary;
        icon = Icons.circle;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: FinalsTheme.card(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentColor.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: FinalsTheme.shadowColor(context).withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 14, color: accentColor),
                const SizedBox(width: 8),
                Text(
                  step.label, 
                  style: TextStyle(
                    color: accentColor, 
                    fontWeight: FontWeight.w800, 
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: step.lines.map((line) {
                if (line.trim().isEmpty) return const SizedBox(height: 6);
                               
                if (_isMathExpression(line)) {
                  return _buildMathLine(
                    line, 
                    TextStyle(
                      color: FinalsTheme.textPrimary(context), 
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      line, 
                      style: FinalsTheme.subtitleStyle(context).copyWith(
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  );
                }
              }).toList(),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildNote(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 2, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded, 
            size: 14, 
            color: FinalsTheme.textSecondary(context).withValues(alpha: 0.5),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              step.lines.join(' '), 
              style: TextStyle(
                color: FinalsTheme.textSecondary(context), 
                fontStyle: FontStyle.italic, 
                fontSize: 12, // Compact notes
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32, height: 3, 
            decoration: BoxDecoration(
              color: FinalsTheme.primary, 
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            step.label.toUpperCase(), 
            style: TextStyle(
              color: FinalsTheme.primary, 
              fontWeight: FontWeight.w900, 
              fontSize: 16, 
              letterSpacing: 1.2,
            ),
          ),
          if (step.lines.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              step.lines.join(' '), 
              style: TextStyle(
                color: FinalsTheme.textPrimary(context).withValues(alpha: 0.8), 
                fontSize: 13, 
                height: 1.4, 
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultBox(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            FinalsTheme.primary.withValues(alpha: 0.12), 
            FinalsTheme.danger.withValues(alpha: 0.12)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FinalsTheme.primary.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: FinalsTheme.primary.withValues(alpha: 0.15), 
            blurRadius: 16, 
            offset: const Offset(0, 6)
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.check_circle, color: FinalsTheme.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                'FINAL FORM', 
                style: TextStyle(
                  color: FinalsTheme.primary, 
                  fontWeight: FontWeight.w900, 
                  letterSpacing: 1.2, 
                  fontSize: 11,
                ),
              ),
            ]),
            const SizedBox(height: 12),
            ...step.lines.map((line) => _buildMathLine(
              line, 
              TextStyle(
                color: FinalsTheme.textPrimary(context), 
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            )),
          ],
        ),
      ),
    );
  }
}