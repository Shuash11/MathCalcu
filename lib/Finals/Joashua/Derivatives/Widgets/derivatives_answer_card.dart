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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'f(x) = ',
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
    if (expr.isEmpty) return '';

    String result = expr;
    result = result.replaceAll(' ', '');
    result = result.replaceAll('*', '##MUL##');
    
    result = result.replaceAllMapped(RegExp(r'(\w)\^(-?\d+)'), (m) => '${m[1]}^{${m[2]}}');
    result = result.replaceAllMapped(RegExp(r'(\w)\)\^(-?\d+)'), (m) => '${m[1]}^{${m[2]}}');
    result = result.replaceAllMapped(RegExp(r'\(\s*\^\s*(-?\d+)\)'), (m) => '^{${m[1]}}');
    result = result.replaceAll('^ -', '^{-');
    result = result.replaceAllMapped(RegExp(r'\^(\()(-?\d+)(\))'), (m) => '^{${m[2]}}');
    
    result = _convertFractions(result);
    result = _convertMultiplication(result);
    result = result.replaceAll('+', ' + ');
    result = result.replaceAllMapped(RegExp(r'(?<![\^])([a-zA-Z0-9\)])-([a-zA-Z0-9\(])'), (m) => '${m[1]} - ${m[2]}');

    result = result
        .replaceAll('sqrt(', r'\sqrt{')
        .replaceAllMapped(RegExp(r'sqrt([a-zA-Z])'), (m) => '\\sqrt{${m[1]}}')
        .replaceAllMapped(RegExp(r'sqrt(\d+)'), (m) => '\\sqrt{${m[1]}}')
        .replaceAll('sin(', r'\sin{')
        .replaceAll('cos(', r'\cos{')
        .replaceAll('tan(', r'\tan{')
        .replaceAll('exp(', r'\exp{');

    return result;
  }

String _convertMultiplication(String expr) {
    String result = expr;
    
    // 1. Digit * Variable -> digitvariable (e.g., 2*x -> 2x) - ONLY this gets merged
    result = result.replaceAllMapped(RegExp(r'([0-9])##MUL##([a-zA-Z])'), (m) => '${m[1]}${m[2]}');
    
    // 2. Digit * ( -> digit( (e.g., 2*( -> 2()
    result = result.replaceAllMapped(RegExp(r'([0-9])##MUL##\('), (m) => '${m[1]}(');
    
    // 3. ) * Digit -> )digit (e.g., )*2 -> )2
    result = result.replaceAllMapped(RegExp(r'\)##MUL##([0-9])'), (m) => ')${m[1]}');
    
    // 4. Variable * Variable -> variablevariable (e.g., x*y -> xy)
    result = result.replaceAllMapped(RegExp(r'([a-zA-Z])##MUL##([a-zA-Z])'), (m) => '${m[1]}${m[2]}');
    
    // 5. Variable * ( -> variable( (e.g., x*( -> x()
    result = result.replaceAllMapped(RegExp(r'([a-zA-Z])##MUL##\('), (m) => '${m[1]}(');
    
    // 6. ) * Variable -> )variable (e.g., )*x -> )x
    result = result.replaceAllMapped(RegExp(r'\)##MUL##([a-zA-Z])'), (m) => ')${m[1]}');
    
    // 7. ) * ( -> )(
    result = result.replaceAllMapped(RegExp(r'\)##MUL##\('), (m) => ')(');
    
    // 8. All remaining ##MUL## become \cdot (including x*2, 2*3, etc.)
    result = result.replaceAll('##MUL##', r'\cdot ');
    
    return result;
  }

  String _convertFractions(String expr) {
    final buffer = StringBuffer();
    int i = 0;
    int lastWritePos = 0;

    while (i < expr.length) {
      if (expr[i] == '/') {
        int numStart = _findNumeratorStart(expr, i);
        int denEnd = _findDenominatorEnd(expr, i);

        String num = expr.substring(numStart, i).trim();
        String den = expr.substring(i + 1, denEnd).trim();

        if (num.isEmpty || den.isEmpty) {
          buffer.write(expr[i]);
          i++;
          continue;
        }

        num = _stripOuterParens(num);
        den = _stripOuterParens(den);

        String frac = '\\frac{$num}{$den}';
        
        buffer.write(expr.substring(lastWritePos, numStart));
        buffer.write(frac);
        lastWritePos = denEnd;
        i = denEnd;
      } else {
        i++;
      }
    }

    buffer.write(expr.substring(lastWritePos));
    return buffer.toString();
  }

  String _stripOuterParens(String s) {
    if (s.isEmpty) return s;
    if (s.startsWith('(') && s.endsWith(')')) {
      final inner = s.substring(1, s.length - 1);
      if (_isBalancedParens(s) || _isBalancedParens(inner)) {
        return inner.trim();
      }
    }
    return s;
  }

  bool _isBalancedParens(String s) {
    int depth = 0;
    for (int i = 0; i < s.length; i++) {
      if (s[i] == '(') depth++;
      if (s[i] == ')') {
        depth--;
        if (depth < 0) return false;
      }
    }
    return depth == 0;
  }

  int _findNumeratorStart(String s, int slashPos) {
    int depth = 0;
    int i = slashPos - 1;
    while (i >= 0) {
      if (s[i] == ' ') { i--; continue; }
      if (s[i] == ')') {
        int match = _findMatchingOpen(s, i);
        if (match == -1) { i--; continue; }
        depth++;
        i = match - 1;
      } else if (s[i] == '(') {
        if (depth == 0) return i;
        depth--;
        i--;
      } else {
        if (depth == 0) {
          if (s[i] == '+' || s[i] == '-' || s[i] == '*' || s[i] == '#') {
            return i + 1;
          }
          if (i == 0) {
            return 0;
          }
        }
        i--;
      }
    }
    return 0;
  }

  int _findDenominatorEnd(String s, int slashPos) {
    int depth = 0;
    int i = slashPos + 1;
    while (i < s.length) {
      if (s[i] == ' ') { i++; continue; }
      if (s[i] == '(') {
        int match = _findMatchingClose(s, i);
        if (match == -1) { i++; continue; }
        depth++;
        i = match + 1;
      } else if (s[i] == ')') {
        if (depth == 0) return i;
        depth--;
        i++;
      } else {
        if (depth == 0 && (s[i] == '+' || s[i] == '-' || s[i] == '*' || s[i] == '#' || s[i] == '^' || s[i] == ')')) {
          return i;
        }
        i++;
      }
    }
    return s.length;
  }

  int _findMatchingOpen(String s, int closePos) {
    int depth = 1;
    for (int i = closePos - 1; i >= 0; i--) {
      if (s[i] == ')') depth++;
      if (s[i] == '(') { depth--; if (depth == 0) return i; }
    }
    return -1;
  }

  int _findMatchingClose(String s, int openPos) {
    int depth = 1;
    for (int i = openPos + 1; i < s.length; i++) {
      if (s[i] == '(') depth++;
      if (s[i] == ')') { depth--; if (depth == 0) return i; }
    }
    return -1;
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
