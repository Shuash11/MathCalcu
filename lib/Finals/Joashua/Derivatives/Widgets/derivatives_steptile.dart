import 'package:calculus_system/Finals/Joashua/Derivatives/solvers/derivatives_steps.dart';
import 'package:calculus_system/Finals/Joashua/Derivatives/solvers/deriviatives_solver.dart';
import 'package:calculus_system/Finals/finals_theme.dart';
import 'package:flutter/material.dart';
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
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Line & Number
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: step.type == StepType.finalResult
                        ? FinalsTheme.primary
                        : FinalsTheme.primary.withValues(alpha: 0.15),
                    border: Border.all(
                      color: step.type == StepType.finalResult
                          ? FinalsTheme.primary
                          : FinalsTheme.primary.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      step.stepNumber.toString(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: step.type == StepType.finalResult
                            ? Colors.white
                            : FinalsTheme.primary,
                      ),
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            FinalsTheme.primary.withValues(alpha: 0.5),
                            FinalsTheme.primary.withValues(alpha: 0.05),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Step Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.title,
                      style:
                          FinalsTheme.titleStyle(context).copyWith(fontSize: 15),
                    ),
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

                    if (step.type == StepType.identifyRule && step.rule != null) ...[
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
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: _buildLatexForExpression(_toLatex(step.expression.toString()), context),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildExplanationLines(BuildContext context) {
    final lines =
        step.explanation.split('\n').where((l) => l.trim().isNotEmpty).toList();
    return lines
        .map((line) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                line.trim(),
                style: FinalsTheme.subtitleStyle(context),
              ),
            ))
        .toList();
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
        color: FinalsTheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: const Border(
          left: BorderSide(
            color: FinalsTheme.primary,
            width: 3,
          ),
        ),
),
      child: _buildLatexDisplay(formula, context),
    );
  }

  Widget _buildLatexDisplay(String tex, BuildContext ctx) {
    if (tex.isEmpty) return const SizedBox.shrink();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SelectableMath.tex(
        tex,
        textStyle: TextStyle(
          fontSize: 14,
          color: FinalsTheme.textPrimary(ctx),
        ),
      ),
    );
  }

String _toLatex(String expr) {
    if (expr.isEmpty) return '';

    String result = expr;
    result = result.replaceAll(' ', '');
    result = result.replaceAll('*', '##MUL##');
    
    // More comprehensive exponent handling - catch all exponent patterns first
    // Handle patterns like: x^-1, (x)^-1, x^-2, etc.
    // Use { } braces for proper LaTeX superscript
    result = result.replaceAllMapped(RegExp(r'(\w)\^(-?\d+)'), (m) => '${m[1]}^{${m[2]}}');
    result = result.replaceAllMapped(RegExp(r'(\w)\)\^(-?\d+)'), (m) => '${m[1]}^{${m[2]}}');
    // Clean up malformed patterns like ( ^-1 or ^ -1
    result = result.replaceAllMapped(RegExp(r'\(\s*\^\s*(-?\d+)\)'), (m) => '^{${m[1]}}');
    result = result.replaceAll('^ -', '^{-');
    // Fix: Remove unnecessary parentheses in exponents (e.g., x^(-1) -> x^{-1})
    result = result.replaceAllMapped(RegExp(r'\^(\()(-?\d+)(\))'), (m) => '^{${m[2]}}');
    
    result = _convertFractions(result);
    result = _convertMultiplication(result);
    result = result.replaceAll('+', ' + ');
    // Use negative lookbehind to exclude - after ^
    result = result.replaceAllMapped(RegExp(r'(?<![\^])([a-zA-Z0-9\)])-([a-zA-Z0-9\(])'), (m) => '${m[1]} - ${m[2]}');

    result = result
        // Handle sqrt followed by parenthesis: sqrt(x) -> \sqrt{x}
        .replaceAll('sqrt(', r'\sqrt{')
        // Handle sqrt followed by variable: sqrtx -> \sqrt{x}
        .replaceAllMapped(RegExp(r'sqrt([a-zA-Z])'), (m) => '\\sqrt{${m[1]}}')
        // Handle sqrt followed by number: sqrt2 -> \sqrt{2}
        .replaceAllMapped(RegExp(r'sqrt(\d+)'), (m) => '\\sqrt{${m[1]}}')
        .replaceAll('sin(', r'\sin{')
        .replaceAll('cos(', r'\cos{')
        .replaceAll('tan(', r'\tan{')
        .replaceAll('ln(', r'\ln{')
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

  Widget _buildLatexForExpression(String tex, BuildContext ctx) {
    if (tex.isEmpty) return const SizedBox.shrink();
    try {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SelectableMath.tex(
          tex,
          textStyle: TextStyle(
            fontSize: 14,
            color: FinalsTheme.textPrimary(ctx),
          ),
        ),
      );
    } catch (e) {
      return Text(tex, style: TextStyle(fontSize: 14, color: FinalsTheme.textPrimary(ctx)));
    }
  }
}