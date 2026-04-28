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
                        child: _buildLatexForExpression(_toLatex(step.expression.toString()), context),
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
    return lines
        .map((line) {
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
                      color: step.type == StepType.identifyRule ? Colors.redAccent : null,
                    ),
                  ),
                  _buildLatexDisplay(mathContent, context),
                ],
              ),
            );
          }

          // Case 2: Pure math or line with math (e.g., "d/dx[...]")
          final hasLatexBraces = trimmedLine.contains('{') && trimmedLine.contains('}');
          final hasExponent = trimmedLine.contains('^') && !trimmedLine.contains(r'\^');
          final hasMathSymbols = trimmedLine.contains('/') || trimmedLine.contains('*') || trimmedLine.contains('[');
          
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
        })
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
            color: FinalsTheme.danger,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

String _toLatex(String expr) {
    if (expr.isEmpty) return '';

    // If it already looks like proper LaTeX, be careful
    if (expr.contains(r'\frac') || expr.contains(r'\cdot')) {
       // Still apply some fixes but don't strip spaces
    }

    String result = expr;
    
    // 0. Handle d/dx notation
    result = result.replaceAllMapped(RegExp(r'd/d([a-zA-Z])'), (m) => '\\frac{d}{d${m[1]}} ');
    
    // 1. Handle f'(x) notation
    result = result.replaceAllMapped(RegExp(r"([a-zA-Z])'\((\w+)\)"), (m) => "${m[1]}'(${m[2]})");

    // 2. Wrap square brackets
    if (result.contains('[') && !result.contains(r'\left[')) {
      result = result.replaceAll('[', '\\left[ ').replaceAll(']', ' \\right]');
    }

    // result = result.replaceAll(' ', ''); // DO NOT REMOVE SPACES GLOBALLY
    
    result = result.replaceAll('*', '##MUL##');
    
    // More comprehensive exponent handling - catch all exponent patterns first
    result = result.replaceAllMapped(RegExp(r'(\w)\^(\s*)(-?\d+)'), (m) => '${m[1]}^{${m[3]}}');
    result = result.replaceAllMapped(RegExp(r'(\w)\)\^(\s*)(-?\d+)'), (m) => '${m[1]}^{${m[3]}}');
    
    // Clean up malformed patterns like ( ^-1 or ^ -1
    result = result.replaceAllMapped(RegExp(r'\(\s*\^\s*(-?\d+)\)'), (m) => '^{${m[1]}}');
    result = result.replaceAll('^ -', '^{-');
    
    // Fix: Remove unnecessary parentheses in exponents (e.g., x^(-1) -> x^{-1})
    result = result.replaceAllMapped(RegExp(r'\^(\()(-?\d+)(\))'), (m) => '^{${m[2]}}');
    
    result = _convertFractions(result);
    result = _convertMultiplication(result);
    
    // result = result.replaceAll('+', ' + '); // Spaces are fine in math mode
    
    // Use negative lookbehind to exclude - after ^
    result = result.replaceAllMapped(RegExp(r'(?<![\^])([a-zA-Z0-9\)])-([a-zA-Z0-9\(])'), (m) => '${m[1]} - ${m[2]}');

    result = result
        .replaceAll('sqrt(', r'\sqrt{')
        .replaceAllMapped(RegExp(r'sqrt([a-zA-Z])'), (m) => '\\sqrt{${m[1]}}')
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
    
    // 1. Digit * Variable -> digitvariable (e.g., 2*x -> 2x)
    result = result.replaceAllMapped(RegExp(r'([0-9])\s*##MUL##\s*([a-zA-Z])'), (m) => '${m[1]}${m[2]}');
    
    // 2. Digit * ( -> digit(
    result = result.replaceAllMapped(RegExp(r'([0-9])\s*##MUL##\s*\('), (m) => '${m[1]}(');
    
    // 3. ) * Digit -> )digit
    result = result.replaceAllMapped(RegExp(r'\)\s*##MUL##\s*([0-9])'), (m) => ')${m[1]}');
    
    // 4. Variable * Variable -> variablevariable
    result = result.replaceAllMapped(RegExp(r'([a-zA-Z])\s*##MUL##\s*([a-zA-Z])'), (m) => '${m[1]}${m[2]}');
    
    // 5. Variable * ( -> variable(
    result = result.replaceAllMapped(RegExp(r'([a-zA-Z])\s*##MUL##\s*\('), (m) => '${m[1]}(');
    
    // 6. ) * Variable -> )variable
    result = result.replaceAllMapped(RegExp(r'\)\s*##MUL##\s*([a-zA-Z])'), (m) => ')${m[1]}');
    
    // 7. ) * ( -> )(
    result = result.replaceAllMapped(RegExp(r'\)\s*##MUL##\s*\('), (m) => ')(');
    
    // 8. All remaining ##MUL## become \cdot
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
              color: FinalsTheme.danger,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    } catch (e) {
      return Text(tex, style: TextStyle(fontSize: 14, color: FinalsTheme.textPrimary(ctx)));
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