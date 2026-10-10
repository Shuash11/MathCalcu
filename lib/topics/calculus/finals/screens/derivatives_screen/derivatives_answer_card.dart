import 'package:material_ui/material_ui.dart';
import 'package:calculus_system/shared/widgets/responsive_text.dart';
import 'package:flutter/services.dart';
import 'package:flutter_math_fork/flutter_math.dart';

import 'package:calculus_system/topics/calculus/finals/finals_theme.dart';
import 'package:calculus_system/topics/calculus/finals/solvers/derivatives_solver/expr_to_latex.dart';

class DerivativeAnswerCard extends StatelessWidget {
  final String originalExpr;
  final String answerExpr;
  final bool hasError;
  final String? errorMessage;
  final VoidCallback onTap;

  const DerivativeAnswerCard({
    super.key,
    required this.originalExpr,
    required this.answerExpr,
    this.hasError = false,
    this.errorMessage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'View derivative solution steps',
      button: true,
      child: GestureDetector(
        onTap: hasError ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            gradient: hasError
                ? LinearGradient(
                    colors: [
                      FinalsTheme.danger.withValues(alpha: 0.1),
                      FinalsTheme.danger.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : FinalsTheme.cardGlow(hovered: true),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: hasError
                  ? FinalsTheme.danger.withValues(alpha: 0.3)
                  : FinalsTheme.primary.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: hasError
                    ? FinalsTheme.danger.withValues(alpha: 0.1)
                    : FinalsTheme.primary.withValues(alpha: 0.15),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      hasError ? 'Parsing Error' : 'Derivative Result',
                      style: FinalsTheme.labelStyle(context).copyWith(
                        color: hasError ? FinalsTheme.dangerFor(context) : null,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (!hasError)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Copy answer',
                          icon: const Icon(Icons.copy_rounded, size: 18),
                          color: FinalsTheme.primaryFor(context),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: answerExpr));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Answer copied to clipboard'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: FinalsTheme.primaryFor(context)
                                .withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: FinalsTheme.primaryFor(context),
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (hasError)
                Text(
                  errorMessage ?? 'Invalid expression syntax.',
                  style: FinalsTheme.subtitleStyle(context)
                      .copyWith(color: FinalsTheme.dangerFor(context)),
                )
              else ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ResponsiveText(
                      '',
                      style: FinalsTheme.subtitleStyle(context),
                    ),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: _buildLatex(_toLatex(originalExpr), context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: FinalsTheme.surface(context).withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          "f'(x) = ",
                          style: FinalsTheme.titleStyle(context).copyWith(
                            fontSize: 20,
                            color: FinalsTheme.primaryFor(context),
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: _buildLatex(_toLatex(answerExpr), context),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: ResponsiveText(
                    '',
                    style: FinalsTheme.labelStyle(context)
                        .copyWith(fontSize: 9, letterSpacing: 0.5),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Shared plain-expression -> LaTeX conversion (see expr_to_latex.dart).
  String _toLatex(String expr) => exprToLatex(expr);

  Widget _buildLatex(String tex, BuildContext ctx) {
    if (tex.isEmpty) return const SizedBox.shrink();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SelectableMath.tex(
        tex,
        textStyle: TextStyle(
          fontSize: 18,
          color: FinalsTheme.primaryFor(ctx),
          fontWeight: FontWeight.w800,
        ),
        // flutter_math_fork catches parse errors internally and routes them
        // through `onErrorFallback`, so an explicit fallback is the only way
        // to show readable text instead of the default red error box (a
        // try/catch around SelectableMath.tex can never fire).
        onErrorFallback: (err) => Text(
          tex,
          style: TextStyle(
            fontSize: 18,
            color: FinalsTheme.primaryFor(ctx),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
