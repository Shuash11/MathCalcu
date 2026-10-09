import 'package:calculus_system/topics/calculus/finals/solvers/derivatives_solver/derivatives_steps.dart';
import 'package:calculus_system/topics/calculus/finals/solvers/derivatives_solver/derivatives_solver.dart';
import 'package:calculus_system/topics/calculus/finals/solvers/derivatives_solver/expr_to_latex.dart';
import 'package:calculus_system/topics/calculus/finals/finals_theme.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class DerivativeStepTile extends StatelessWidget {
  final ClassroomStep step;
  final int index;
  final bool isLast;

  const DerivativeStepTile({
    super.key,
    required this.step,
    required this.index,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Timeline Line
        if (!isLast)
          Positioned(
            left: 14, // Center of the 28px circle (28/2 = 14)
            top: 28,
            bottom: 0,
            child: Container(
              width: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    FinalsTheme.primary.withValues(alpha: 0.5),
                    FinalsTheme.primary.withValues(alpha: 0.05),
                  ],
                ),
              ),
            ),
          ),

        // Step Content Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Number Circle
            SizedBox(
              width: 28,
              height: 28,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: step.type == StepType.finalResult
                      ? FinalsTheme.primaryFor(context)
                      : FinalsTheme.primaryFor(context).withValues(alpha: 0.15),
                  border: Border.all(
                    color: step.type == StepType.finalResult
                        ? FinalsTheme.primaryFor(context)
                        : FinalsTheme.primaryFor(context)
                            .withValues(alpha: 0.5),
                  ),
                ),
                child: Center(
                  child: Text(
                    step.stepNumber.toString(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: step.type == StepType.finalResult
                          ? FinalsTheme.onPrimaryFor(context)
                          : FinalsTheme.primaryFor(context),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title - render as LaTeX if contains math expressions
                    _buildTitleAsLatex(step.title, context),

                    // Inline debug hint
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Type: ${step.type.toString().split('.').last}${step.rule != null ? ' | Rule: ${step.rule!.split(':').first.trim()}' : ''}',
                        style: TextStyle(
                          fontSize: 10,
                          color: FinalsTheme.textSecondary(context),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    if (step.type == StepType.identifyRule &&
                        step.rule != null) ...[
                      _buildRuleFormula(context),
                      const SizedBox(height: 12),
                    ],

                    if (step.type != StepType.simplify)
                      ..._buildExplanationLines(context),

                    const SizedBox(height: 12),

                    if (step.expression.toString().isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: FinalsTheme.cardSecondary(context),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: _buildLatexForExpression(
                            _toLatex(step.expression.toString()), context),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildExplanationLines(BuildContext context) {
    final lines =
        step.explanation.split('\n').where((l) => l.trim().isNotEmpty).toList();
    return lines.map((line) {
      final trimmedLine = line.trim();

      // Case 1: Label with colon (e.g., "Power Rule: \frac{d}{dx}...")
      if (trimmedLine.contains(':')) {
        final parts = trimmedLine.split(':');
        final label = parts[0].trim();
        final mathContent = parts.sublist(1).join(':').trim();

        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                '$label: ',
                style: FinalsTheme.subtitleStyle(context).copyWith(
                  fontWeight: FontWeight.w600,
                  color: step.type == StepType.identifyRule
                      ? Colors.redAccent
                      : null,
                ),
              ),
              _buildLatexDisplay(mathContent, context),
            ],
          ),
        );
      }

      // Case 2: Pure math or line with math (e.g., "d/dx[...]")
      final hasLatexBraces =
          trimmedLine.contains('{') && trimmedLine.contains('}');
      final hasExponent =
          trimmedLine.contains('^') && !trimmedLine.contains(r'\^');
      final hasMathSymbols = trimmedLine.contains('/') ||
          trimmedLine.contains('*') ||
          trimmedLine.contains('[');

      if (hasLatexBraces || hasExponent || hasMathSymbols) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: _buildLatexDisplay(trimmedLine, context),
        );
      }

      // Case 3: Plain text
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(
          trimmedLine,
          style: FinalsTheme.subtitleStyle(context),
        ),
      );
    }).toList();
  }

  Widget _buildRuleFormula(BuildContext context) {
    // Extract formula from rule (format: "Rule Name: LaTeX formula" or just "Rule Name")
    String formula = '';
    if (step.rule != null && step.rule!.contains(':')) {
      final colonIndex = step.rule!.indexOf(':');
      formula = step.rule!.substring(colonIndex + 1).trim();
    }

    if (formula.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: FinalsTheme.primaryFor(context).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: FinalsTheme.primaryFor(context),
            width: 3,
          ),
        ),
      ),
      child: _buildLatexDisplay(formula, context),
    );
  }

  Widget _buildLatexDisplay(String tex, BuildContext ctx) {
    if (tex.isEmpty) return const SizedBox.shrink();

    // Convert to proper LaTeX if needed
    final processedTex = _toLatex(tex);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Math.tex(
        processedTex,
        textStyle: TextStyle(
          fontSize: 14,
          color: FinalsTheme.textPrimary(ctx),
        ),
        mathStyle: MathStyle.text,
        onErrorFallback: (err) => Text(
          tex,
          style: TextStyle(
            fontSize: 14,
            color: FinalsTheme.dangerFor(ctx),
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  /// Shared plain-expression -> LaTeX conversion (see expr_to_latex.dart).
  String _toLatex(String expr) => exprToLatex(expr);

  Widget _buildLatexForExpression(String tex, BuildContext ctx) {
    if (tex.isEmpty) return const SizedBox.shrink();
    try {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Math.tex(
          tex,
          textStyle: TextStyle(
            fontSize: 14,
            color: FinalsTheme.textPrimary(ctx),
          ),
          mathStyle: MathStyle.text,
          onErrorFallback: (err) => Text(
            tex,
            style: TextStyle(
              fontSize: 14,
              color: FinalsTheme.dangerFor(ctx),
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    } catch (e) {
      return Text(tex,
          style: TextStyle(fontSize: 14, color: FinalsTheme.textPrimary(ctx)));
    }
  }

  Widget _buildTitleAsLatex(String title, BuildContext ctx) {
    final hasExponent = title.contains('^') && !title.contains(r'\^');
    final hasLatex = title.contains('{') && title.contains('}');

    if (hasExponent || hasLatex) {
      final latexTitle = _toLatex(title);
      return Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Math.tex(
            latexTitle,
            textStyle: FinalsTheme.titleStyle(ctx).copyWith(fontSize: 15),
            mathStyle: MathStyle.text,
            onErrorFallback: (err) => Text(
              title,
              style: FinalsTheme.titleStyle(ctx).copyWith(fontSize: 15),
            ),
          ),
        ),
      );
    }
    return Text(
      title,
      style: FinalsTheme.titleStyle(ctx).copyWith(fontSize: 15),
    );
  }
}
