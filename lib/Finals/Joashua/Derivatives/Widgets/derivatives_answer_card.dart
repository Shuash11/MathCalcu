import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_math_fork/flutter_math.dart';

import 'package:calculus_system/Finals/finals_theme.dart';

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
    return GestureDetector(
      onTap: hasError ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          gradient: hasError
              ? LinearGradient(
                  colors: [
                    FinalsTheme.danger.withValues(alpha: 0.1),
                    FinalsTheme.danger.withValues(alpha: 0.05)
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
                Text(
                  hasError ? 'Parsing Error' : 'Derivative Result',
                  style: FinalsTheme.labelStyle(context).copyWith(
                    color: hasError ? FinalsTheme.danger : null,
                    fontSize: 11,
                  ),
                ),
                if (!hasError)
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.copy_rounded, size: 18),
                        color: FinalsTheme.primary,
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
                          color: FinalsTheme.primary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: FinalsTheme.primary,
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
                    .copyWith(color: FinalsTheme.danger),
              )
            else ...[
              Row(
                children: [
                  Text(
                    'f(x) = ',
                    style: FinalsTheme.subtitleStyle(context),
                  ),
                  Expanded(
                    child: _buildLatex(_toLatex(originalExpr), context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                decoration: BoxDecoration(
                  color: FinalsTheme.surface(context).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Text(
                      "f'(x) = ",
                      style: FinalsTheme.titleStyle(context).copyWith(
                        fontSize: 20,
                        color: FinalsTheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Expanded(
                      child: _buildLatex(_toLatex(answerExpr), context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Tap to view step-by-step solution',
                  style: FinalsTheme.labelStyle(context).copyWith(
                    fontSize: 9,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  String _toLatex(String expr) {
    return expr
        .replaceAll('/', r' \frac{}{')
        .replaceAllMapped(RegExp(r'(\w+)\^(\d+)'), (m) => '^{${m[2]}}')
        .replaceAll('sqrt(', r'\sqrt{')
        .replaceAll('sin(', r'\sin{')
        .replaceAll('cos(', r'\cos{')
        .replaceAll('tan(', r'\tan{')
        .replaceAll('ln(', r'\ln{')
        .replaceAll('exp(', r'\exp{')
        .replaceAllMapped(RegExp(r'(\w)\)'), (m) => '${m[1]}}');
  }

  Widget _buildLatex(String tex, BuildContext ctx) {
    if (tex.isEmpty) return const SizedBox.shrink();
    try {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SelectableMath.tex(
          tex,
          textStyle: TextStyle(
            fontSize: 18,
            color: FinalsTheme.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    } catch (e) {
      return Text(tex, style: TextStyle(fontSize: 18, color: FinalsTheme.primary, fontWeight: FontWeight.w800));
    }
  }
}
