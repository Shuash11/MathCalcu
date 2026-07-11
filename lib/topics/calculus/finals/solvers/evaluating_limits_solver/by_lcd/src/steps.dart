// ignore_for_file: duplicate_ignore, prefer_const_declarations

library steps;

import 'dart:math';
import 'lcd_math_engine.dart';

const _d = r'$';

/// Container for a limit solution with formatted steps.
class LimitSolution {
  final String originalEquation;
  final List<String> steps;
  final double? finalAnswer;
  final String? fractionalAnswer;
  final String methodUsed;

  LimitSolution({
    required this.originalEquation,
    required this.steps,
    this.finalAnswer,
    this.fractionalAnswer,
    required this.methodUsed,
  });

  @override
  String toString() {
    final output = StringBuffer();
    output.writeln("LIMIT EVALUATION: $methodUsed");
    for (int i = 0; i < steps.length; i++) {
      output.writeln("${steps[i]}\n");
    }
    return output.toString();
  }
}

/// Generates step-by-step solutions for limits.
class StepGenerator {
  // -------------------------------------------------------------------
  // 1. Direct Substitution
  // -------------------------------------------------------------------
  static LimitSolution directSubstitutionSuccess(
      String eq, String varName, double val, double result, MathNode ast) {
    final valStr = _doubleToStr(val);
    final eqTex = _nodeToTex(ast);
    
    // Try to get exact rational answer first
    final rationalAns = _evaluateToRational(ast, varName, val);
    final String resStr;
    if (rationalAns != null) {
      final num = rationalAns.numerator;
      final den = rationalAns.denominator;
      final gcd = _gcd(num.abs(), den);
      final simplifiedNum = num ~/ gcd;
      final simplifiedDen = den ~/ gcd;
      resStr = _formatExactRational(simplifiedNum, simplifiedDen);
    } else {
      final fractionGuess = _findFractionGuess(result);
      resStr = fractionGuess ?? _formatResultAsConstant(result);
    }

    return LimitSolution(
      originalEquation: eq,
      methodUsed: "Direct Substitution",
      steps: [
        "**Substitute $varName = $valStr:**\n" +
            r"$$" +
            r"\lim_{" +
            varName +
            r" \to " +
            valStr +
            r"} " +
            eqTex +
            r" = " +
            resStr +
            r"$$",
      ],
      finalAnswer: result,
      fractionalAnswer: resStr,
    );
  }

  // -------------------------------------------------------------------
  // 2. LCD / Factoring Method (handles any nested fraction)
  // -------------------------------------------------------------------
  static LimitSolution solveByLCD(
      String eq, String varName, double val, MathNode ast) {
    if (ast is! BinaryOpNode || ast.op != '/') {
      return unknownForm(eq, varName, val);
    }

    final numerator = ast.left;
    final denominator = ast.right;
    if (numerator is! BinaryOpNode) return unknownForm(eq, varName, val);

    final frac1 = _ensureFraction(numerator.left);
    final frac2 = _ensureFraction(numerator.right);

    final n1Tex = _nodeToTex(frac1.left);
    final d1Tex = _nodeToTex(frac1.right);
    final n2Tex = _nodeToTex(frac2.left);
    final d2Tex = _nodeToTex(frac2.right);
    final denTex = _nodeToTex(denominator);
    final valStr = _doubleToStr(val);

    const dot = r'\cdot';
    final lcdTex = "($d1Tex) $dot $d2Tex";
    final combinedNumTex =
        _buildCombinedNumeratorTex(n1Tex, d2Tex, numerator.op, n2Tex, d1Tex);

    // Step 1: Write the given limit
    final step1 = "Write the given limit.\n" +
        r"$$" + r"\lim_{" + varName + r" \to " + valStr + r"} \frac{\frac{" + n1Tex + r"}{" + d1Tex + r"} - \frac{" + n2Tex + r"}{" + d2Tex + r"}}{" + denTex + r"}$$";

    // Step 2: Find the LCD of the fractions in the numerator
    final step2 = "Find the LCD of the fractions in the numerator.\n" +
        r"$$" + r"\text{LCD} = " + lcdTex + r"$$";

    // Step 3: Rewrite the numerator as a single fraction
    final step3 = "Rewrite the numerator as a single fraction.\n" +
        r"$$" + r"\frac{" + n1Tex + r"}{" + d1Tex + r"} - \frac{" + n2Tex + r"}{" + d2Tex + r"} = \frac{" + combinedNumTex + r"}{" + lcdTex + r"}$$";

    // Step 4: Rewrite the entire complex fraction
    final step4 = "Rewrite the entire complex fraction.\n" +
        r"$$" + r"\frac{\frac{" + combinedNumTex + r"}{" + lcdTex + r"}}{" + denTex + r"} = \frac{" + combinedNumTex + r"}{(" + lcdTex + ")(" + denTex + r")}$$";

    // Check if this is a sqrt case that needs rationalization
    final isSqrtRationalization = _isSqrtRationalizationCase(
        combinedNumTex, denTex, denominator, varName, d1Tex, d2Tex, lcdTex);

    if (isSqrtRationalization != null) {
      return _buildSqrtRationalizationSolution(eq, varName, val, ast, n1Tex,
          n2Tex, denTex, combinedNumTex, lcdTex, valStr, isSqrtRationalization);
    }

    // Step 3: Factor denominator and cancel common factors
    final factorization = _dynamicFactorAndCancel(
        combinedNumTex, denTex, denominator, varName, d1Tex, d2Tex, lcdTex);

    // Step 4: Try exact rational evaluation first, fallback to numerical
    final rationalAns = _evaluateToRational(ast, varName, val);
    final bool hasSqrt = _containsSqrt(ast);
    final String ansTex;
    if (rationalAns != null) {
      final num = rationalAns.numerator;
      final den = rationalAns.denominator;
      final gcd = _gcd(num.abs(), den);
      final simplifiedNum = num ~/ gcd;
      final simplifiedDen = den ~/ gcd;
      ansTex = _formatExactRational(simplifiedNum, simplifiedDen);
    } else {
      final ans = _calculateNumericalLimit(ast, varName, val);
      if (hasSqrt) {
        final formatted = _formatResult(ans);
        assert(() {
          // ignore: avoid_print
          print('LCD_DEBUG: hasSqrt=$hasSqrt, ans=$ans, formatted=$formatted');
          return true;
        }());
        final fractionGuess = _findFractionGuess(ans);
        assert(() {
          // ignore: avoid_print
          print('LCD_DEBUG: fractionGuess=$fractionGuess');
          return true;
        }());
        if (fractionGuess != null) {
          ansTex = "$fractionGuess \\approx $formatted";
        } else {
          ansTex = "\\approx $formatted";
        }
      } else {
        // For non-sqrt cases without rational answer, try to find a fraction
        final fractionGuess = _findFractionGuess(ans);
        ansTex = fractionGuess ?? _formatResultAsConstant(ans);
      }
    }
    final substitutionExpr = factorization.simplifiedExpr.isNotEmpty
        ? factorization.simplifiedExpr
        : r"\frac{" + combinedNumTex + r"}{(" + lcdTex + r")(" + denTex + r")}";

    // Step 5: Simplify and cancel common factors
    final step5 = "Simplify and cancel common factors.\n" +
        r"$$" + substitutionExpr + r"$$";

    // Step 6: Substitute the approach value
    final step6 = "Substitute $varName = $valStr.\n";

    // Determine the answer parts
    // ignore: unused_local_variable
    String exactAnswerTex;
    String approxAnswerTex;
    final numLimitAns = rationalAns != null 
        ? rationalAns.numerator / rationalAns.denominator 
        : _calculateNumericalLimit(ast, varName, val);

    if (rationalAns != null && !hasSqrt) {
      // Use exact rational answer
      exactAnswerTex = ansTex;
      approxAnswerTex = "";
    } else if (hasSqrt) {
      final formatted = _formatResult(numLimitAns);
      final fractionGuess = _findFractionGuess(numLimitAns);
      exactAnswerTex = fractionGuess ?? "=$formatted";
      approxAnswerTex = "≠ˆ $formatted";
    } else {
      exactAnswerTex = ansTex;
      approxAnswerTex = "";
    }

    // Step 7: State the exact answer
    final step7 = "State the exact answer.\n" +
        r"$$" + r"\text{Exact answer: }" + exactAnswerTex + r"$$";

    // Step 8: State the approximation (only for irrational)
    final String step8;
    if (hasSqrt && approxAnswerTex.isNotEmpty) {
      step8 = "State the approximation.\n" +
          r"$$" + r"\text{Approximation: }" + approxAnswerTex + r"$$";
    } else {
      step8 = "";
    }

    final ans = numLimitAns;

    final List<String> steps;
    String step6Full;
    if (hasSqrt) {
      final substitutedExpr = substitutionExpr.replaceAll(
        RegExp('(?<![A-Za-z])${RegExp.escape(varName)}(?![A-Za-z])'),
        valStr,
      );
      step6Full = step6 + r"$$" + substitutedExpr + r"$$";
      steps = [step1, step2, step3, step4, step5, step6Full, step7, step8];
    } else {
      final substitutedExpr = substitutionExpr.replaceAll(
        RegExp('(?<![A-Za-z])${RegExp.escape(varName)}(?![A-Za-z])'),
        valStr,
      );
      step6Full = step6 + r"$$" + substitutedExpr + r" = " + ansTex + r"$$";
      steps = step8.isNotEmpty 
          ? [step1, step2, step3, step4, step5, step6Full, step7, step8]
          : [step1, step2, step3, step4, step5, step6Full, step7];
    }

    // Always use ansTex for the fractional answer - it's already computed correctly above
    final displayAnswer = ansTex;

    return LimitSolution(
      originalEquation: eq,
      methodUsed: "Least Common Denominator (LCD) / Factoring",
      steps: steps,
      finalAnswer: ans,
      fractionalAnswer: displayAnswer,
    );
  }

  // -------------------------------------------------------------------
  // 3. Conjugate Method
  // -------------------------------------------------------------------
  static LimitSolution solveByConjugate(
      String eq, String varName, double val, MathNode ast) {
    if (ast is! BinaryOpNode || ast.op != '/') {
      return unknownForm(eq, varName, val);
    }

    final ans = _calculateNumericalLimit(ast, varName, val);
    final radInNum = _containsSqrt(ast.left);
    final target = (radInNum ? ast.left : ast.right) as BinaryOpNode;
    // ignore: unused_local_variable
    final conjTex =
        "${_nodeToTex(target.left)} ${target.op == '+' ? '-' : '+'} ${_nodeToTex(target.right)}";
    final valStr = _doubleToStr(val);
    
    // Try to get exact rational answer first
    final rationalAns = _evaluateToRational(ast, varName, val);
    final String ansTex;
    if (rationalAns != null) {
      final num = rationalAns.numerator;
      final den = rationalAns.denominator;
      final gcd = _gcd(num.abs(), den);
      final simplifiedNum = num ~/ gcd;
      final simplifiedDen = den ~/ gcd;
      ansTex = _formatExactRational(simplifiedNum, simplifiedDen);
    } else {
      final fractionGuess = _findFractionGuess(ans);
      ansTex = fractionGuess ?? _formatResultAsConstant(ans);
    }

    return LimitSolution(
      originalEquation: eq,
      methodUsed: "Rationalization (Conjugate)",
      steps: [
        "**Identify the conjugate:**\n"
            r"$$\text{Conjugate: } $conjTex$$",
        "**Multiply top and bottom by the conjugate:**\n"
            r"$$\frac{${_nodeToTex(ast.left)}}{${_nodeToTex(ast.right)}} \cdot \frac{$conjTex}{$conjTex}$$",
        "**Apply the difference of squares identity:**\n"
            r"$$\text{Simplifying factors...}$$",
        "**Substitute $varName = $valStr and solve:**\n"
            r"$$\text{Result: } $ansTex$$",
      ],
      finalAnswer: ans,
      fractionalAnswer: ansTex,
    );
  }

  // -------------------------------------------------------------------
  // 4. Fallback
  // -------------------------------------------------------------------
  static LimitSolution unknownForm(String eq, String varName, double val) {
    return LimitSolution(
      originalEquation: eq,
      methodUsed: "Analytical Approach",
      steps: [
        "**Note:** This expression requires L'H÷´pital's Rule or advanced factoring."
      ],
    );
  }

  // -------------------------------------------------------------------
  // Utility: Build combined numerator LaTeX
  // -------------------------------------------------------------------
  static String _buildCombinedNumeratorTex(
      String n1, String d2, String op, String n2, String d1) {
    return "($n1 \\cdot $d2) $op ($n2 \\cdot ($d1))";
  }

  // -------------------------------------------------------------------
  // Dynamic factoring: handles √x and polynomial differences
  // -------------------------------------------------------------------
  static _FactorizationResult _dynamicFactorAndCancel(
      String combinedNumTex,
      String denTex,
      MathNode denNode,
      String varName,
      String d1Tex,
      String d2Tex,
      String lcdTex) {
    // 1. Squareâ€‘root pattern: denominator = x - a²
    if (denNode is BinaryOpNode &&
        denNode.op == '-' &&
        denNode.left is VariableNode &&
        denNode.right is NumberNode) {
      final aSquared = (denNode.right as NumberNode).value;
      final a = sqrt(aSquared);
      if ((a - a.round()).abs() < 1e-10) {
        final aInt = a.round();
        final aStr = aInt.toString();
        final sqrtTerm = "\\sqrt{$varName}";

        if (combinedNumTex.contains("$aStr - $sqrtTerm") ||
            combinedNumTex.contains("$sqrtTerm - $aStr")) {
          final bool numeratorIsNegative =
              combinedNumTex.contains("$aStr - $sqrtTerm");
          final sign = numeratorIsNegative ? "-" : "";
          final conjugate = "$aStr + $sqrtTerm";
          final rationalizedNumerator = numeratorIsNegative
              ? "$aStr^2 - $varName"
              : "$varName - $aStr^2";
          final simplified = sign +
              r"\frac{1}{" +
              lcdTex +
              r" \cdot (" +
              sqrtTerm +
              r" + " +
              aStr +
              r")}";
          // ignore: unused_local_variable
          final cancelIdentity = numeratorIsNegative
              ? "$rationalizedNumerator = -($denTex)"
              : "$rationalizedNumerator = ($denTex)";

          final factorStep =
              "**Rationalize the numerator using the conjugate $_d$conjugate$_d:**\n"
              r"$$\frac{$combinedNumTex}{$lcdTex \cdot ($denTex)} \cdot \frac{$conjugate}{$conjugate} = \frac{$rationalizedNumerator}{$lcdTex \cdot ($denTex)($conjugate)}$$"
              "\n**Simplify and cancel common factors:**\n"
              r"$$$cancelIdentity\quad\Rightarrow\quad\frac{$rationalizedNumerator}{$lcdTex \cdot ($denTex)($conjugate)} = $simplified$$";

          return _FactorizationResult(factorStep, simplified);
        }
      }
    }

    // 2. Polynomial difference of squares: denominator = x² - a²
    if (denNode is BinaryOpNode && denNode.op == '-') {
      final left = denNode.left;
      final right = denNode.right;

      if (left is BinaryOpNode &&
          left.op == '^' &&
          left.left is VariableNode &&
          left.right is NumberNode) {
        final baseVar = (left.left as VariableNode).name;
        final exp = (left.right as NumberNode).value;
        if (exp == 2.0 && baseVar == varName) {
          if (right is NumberNode) {
            final aSquared = right.value;
            final a = sqrt(aSquared);
            if ((a - a.round()).abs() < 1e-10) {
              final aInt = a.round();
              final aStr = aInt.toString();

              final pattern1 = "$aStr - $varName";
              final pattern2 = "$varName - $aStr";

              if (combinedNumTex.contains(pattern1) ||
                  combinedNumTex.contains(pattern2)) {
                final bool numeratorIsNegative =
                    combinedNumTex.contains(pattern1);
                final sign = numeratorIsNegative ? "-" : "";
                final factor1 = "$varName - $aStr";
                final factor2 = "$varName + $aStr";
                final simplified = sign +
                    r"\frac{1}{" +
                    lcdTex +
                    r" \cdot (" +
                    factor2 +
                    r")}";

                final factorStep =
                    "**Factor the denominator using difference of squares:**\n"
                    r"$$\frac{$denTex}{1} = ($factor1)($factor2)$$"
                    "\n**Cancel the common factor ($factor1):**\n"
                    r"$$\frac{$combinedNumTex}{$lcdTex \cdot ($factor1)($factor2)} = $simplified$$";

                return _FactorizationResult(factorStep, simplified);
              }
            }
          }
        }
      }
    }

    // 3. Simple x-cancellation: denominator is x and numerator contains x
    if (denNode is VariableNode && denNode.name == varName) {
      if (combinedNumTex.contains(varName)) {
        bool isNegative = combinedNumTex.contains(' - ');
        final sign = isNegative ? "-" : "";
        final simplified = "$sign" + r"\frac{1}{" + lcdTex + r"}";

        final cancelMsg = isNegative
            ? r'**Factor -1: $-x = -($varName)**' '\n' r'**Cancel the common factor ($varName):**'
            : r'**Cancel the common factor ($varName):**';

        final factorStep = "$cancelMsg\n"
            r"$$\frac{$combinedNumTex}{$lcdTex \cdot $varName} = $simplified$$";

        return _FactorizationResult(factorStep, simplified);
      }
    }

    // 4. No recognizable pattern → empty result
    return _FactorizationResult.empty();
  }

  // -------------------------------------------------------------------
  // AST → LaTeX conversion
  // -------------------------------------------------------------------
  static String _nodeToTex(MathNode node) {
    if (node is NumberNode) return _doubleToStr(node.value);
    if (node is VariableNode) return node.name;
    if (node is UnaryMinusNode) return "-{${_nodeToTex(node.child)}}";
    if (node is FunctionNode) {
      if (node.name == 'sqrt') {
        return "\\sqrt{${_nodeToTex(node.arg)}}";
      }
      return "\\text{${node.name}}(${_nodeToTex(node.arg)})";
    }
    if (node is BinaryOpNode) {
      if (node.op == '/') {
        return "\\frac{${_nodeToTex(node.left)}}{${_nodeToTex(node.right)}}";
      }
      if (node.op == '^') {
        return "{${_nodeToTex(node.left)}}^{${_nodeToTex(node.right)}}";
      }
      return "${_nodeToTex(node.left)} ${node.op == '*' ? r'\cdot' : node.op} ${_nodeToTex(node.right)}";
    }
    return "";
  }

  static BinaryOpNode _ensureFraction(MathNode node) {
    if (node is BinaryOpNode && node.op == '/') return node;
    return BinaryOpNode('/', node, const NumberNode(1));
  }

  static _RationalResult? _evaluateToRational(MathNode node, String varName, double val) {
    try {
      return _evalNodeToRational(node, varName, val);
    } catch (_) {
      return null;
    }
  }

  static _RationalResult? _evalNodeToRational(MathNode node, String varName, double val) {
    if (node is NumberNode) {
      return _RationalResult(node.value.toInt(), 1);
    }
    if (node is VariableNode) {
      return _RationalResult(val.toInt(), 1);
    }
    if (node is UnaryMinusNode) {
      final child = _evalNodeToRational(node.child, varName, val);
      if (child == null) return null;
      return _RationalResult(-child.numerator, child.denominator);
    }
    if (node is FunctionNode && node.name == 'sqrt') {
      return null;
    }
    if (node is BinaryOpNode) {
      final left = _evalNodeToRational(node.left, varName, val);
      final right = _evalNodeToRational(node.right, varName, val);
      if (left == null || right == null) return null;
      int num, den;
      switch (node.op) {
        case '+':
          num = left.numerator * right.denominator + right.numerator * left.denominator;
          den = left.denominator * right.denominator;
          break;
        case '-':
          num = left.numerator * right.denominator - right.numerator * left.denominator;
          den = left.denominator * right.denominator;
          break;
        case '*':
          num = left.numerator * right.numerator;
          den = left.denominator * right.denominator;
          break;
        case '/':
          if (right.numerator == 0) return null;
          num = left.numerator * right.denominator;
          den = left.denominator * right.numerator;
          break;
        default:
          return null;
      }
      if (den == 0) return null;
      if (den < 0) {
        num = -num;
        den = -den;
      }
      return _RationalResult(num, den);
    }
    return null;
  }

  static double _evalNode(MathNode node, String varName, double val) {
    try {
      if (node is NumberNode) return node.value;
      if (node is VariableNode) return val;
      if (node is UnaryMinusNode) return -_evalNode(node.child, varName, val);
      if (node is FunctionNode && node.name == 'sqrt') {
        return sqrt(_evalNode(node.arg, varName, val));
      }
      if (node is BinaryOpNode) {
        final l = _evalNode(node.left, varName, val);
        final r = _evalNode(node.right, varName, val);
        switch (node.op) {
          case '+':
            return l + r;
          case '-':
            return l - r;
          case '*':
            return l * r;
          case '/':
            return r == 0 ? double.nan : l / r;
          case '^':
            return pow(l, r).toDouble();
        }
      }
    } catch (_) {}
    return double.nan;
  }

  static double _calculateNumericalLimit(
      MathNode ast, String varName, double val) {
    final hValues = [0.1, 0.01, 0.001, 0.0001, 0.00001];
    final validResults = <double>[];

    for (final h in hValues) {
      final r = _evalNode(ast, varName, val + h);
      final l = _evalNode(ast, varName, val - h);

      if (r.isFinite && !r.isNaN && l.isFinite && !l.isNaN) {
        final avg = (r + l) / 2;
        if (avg.isFinite && !avg.isNaN) {
          validResults.add(avg);
        }
      }
    }

    if (validResults.isEmpty) {
      return double.nan;
    }

    if (validResults.length == 1) {
      return validResults.first;
    }

    final avg = validResults.reduce((a, b) => a + b) / validResults.length;
    return avg;
  }

  static String _doubleToStr(double v) {
    if (v.isNaN) return "NaN";
    if (v == v.toInt()) return v.toInt().toString();
    return v
        .toStringAsFixed(4)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  static String _formatExactRational(int numerator, int denominator) {
    if (denominator == 1) {
      return numerator.toString();
    }
    final neg = numerator < 0 ? "-" : "";
    return "$neg\\frac{${numerator.abs()}}{$denominator}";
  }

  static String? _findFractionGuess(double val) {
    if (!val.isFinite || val == 0) return null;
    final roundedVal = double.parse(val.toStringAsFixed(3));
    final absRounded = roundedVal.abs();
    for (int d = 1; d <= 100; d++) {
      final n = absRounded * d;
      if ((n - n.round()).abs() < 0.01) {
        final num = n.round();
        int numerator = num;
        int denominator = d;
        int gcd = _gcd(numerator, denominator);
        numerator = numerator ~/ gcd;
        denominator = denominator ~/ gcd;
        if (denominator == 1) {
          return val < 0 ? "-$numerator" : "$numerator";
        }
        return "${val < 0 ? '-' : ''}\\frac{$numerator}{$denominator}";
      }
    }
    return null;
  }

  static String _formatResult(double val) {
    if (!val.isFinite) return "NaN";
    if (val == 0) return "0";
    final absVal = val.abs();
    for (int d = 1; d <= 1000; d++) {
      final n = absVal * d;
      if ((n - n.round()).abs() < 1e-4) {
        final num = n.round();
        int numerator = num;
        int denominator = d;
        int gcd = _gcd(numerator, denominator);
        numerator = numerator ~/ gcd;
        denominator = denominator ~/ gcd;
        final result = denominator == 1
            ? (val < 0 ? "-$numerator" : "$numerator")
            : "${val < 0 ? '-' : ''}\\frac{$numerator}{$denominator}";
        return result;
      }
    }
    return _doubleToStr(val);
  }

  static String _formatResultAsConstant(double val) {
    if (!val.isFinite) return "NaN";
    if (val == 0) return "0";
    final absVal = val.abs();
    for (int d = 1; d <= 1000; d++) {
      final n = absVal * d;
      if ((n - n.round()).abs() < 1e-4) {
        final num = n.round();
        int numerator = num;
        int denominator = d;
        int gcd = _gcd(numerator, denominator);
        numerator = numerator ~/ gcd;
        denominator = denominator ~/ gcd;
        final result = denominator == 1
            ? (val < 0 ? "-$numerator" : "$numerator")
            : "${val < 0 ? '-' : ''}\\frac{$numerator}{$denominator}";
        return result;
      }
    }
    // If we can't find a good fraction, return as integer if possible
    if (val == val.toInt()) {
      return val.toInt().toString();
    }
    // For values that don't simplify to nice fractions, try with higher denominator tolerance
    // but still return as fraction, not decimal
    for (int d = 1001; d <= 10000; d += 100) {
      final n = absVal * d;
      if ((n - n.round()).abs() < 1.0) {
        final num = n.round();
        int numerator = num;
        int denominator = d;
        int gcd = _gcd(numerator, denominator);
        numerator = numerator ~/ gcd;
        denominator = denominator ~/ gcd;
        if (denominator <= 1000) { // Only return if denominator is reasonable
          final result = denominator == 1
              ? (val < 0 ? "-$numerator" : "$numerator")
              : "${val < 0 ? '-' : ''}\\frac{$numerator}{$denominator}";
          return result;
        }
      }
    }
    // Last resort: return as a simple fraction representation avoiding decimals
    return val.toString().replaceAll(RegExp(r'\.0+$'), '');
  }

static int _gcd(int a, int b) {
    while (b != 0) {
      final t = b;
      b = a % b;
      a = t;
    }
    return a;
  }

  static _SqrtRationalizationData? _isSqrtRationalizationCase(
      String combinedNumTex,
      String denTex,
      MathNode denNode,
      String varName,
      String d1Tex,
      String d2Tex,
      String lcdTex) {
    if (denNode is BinaryOpNode &&
        denNode.op == '-' &&
        denNode.left is VariableNode &&
        denNode.right is NumberNode) {
      final aSquared = (denNode.right as NumberNode).value;
      final a = sqrt(aSquared);
      if ((a - a.round()).abs() < 1e-10) {
        final aInt = a.round();
        final aStr = aInt.toString();
        final sqrtTerm = r"\sqrt{" + varName + r"}";

        if (combinedNumTex.contains(aStr + r" - " + sqrtTerm) ||
            combinedNumTex.contains(sqrtTerm + r" - " + aStr)) {
          final bool numeratorIsNegative =
              combinedNumTex.contains(aStr + r" - " + sqrtTerm);
          return _SqrtRationalizationData(
            aInt: aInt,
            aStr: aStr,
            sqrtTerm: sqrtTerm,
            numeratorIsNegative: numeratorIsNegative,
            d1Tex: d1Tex,
            d2Tex: d2Tex,
            lcdTex: lcdTex,
          );
        }
      }
    }
    return null;
  }

  static bool _containsSqrt(MathNode node) {
    if (node is FunctionNode && node.name == 'sqrt') return true;
    if (node is BinaryOpNode) {
      return _containsSqrt(node.left) || _containsSqrt(node.right);
    }
    if (node is UnaryMinusNode) return _containsSqrt(node.child);
    return false;
  }

  static LimitSolution _buildSqrtRationalizationSolution(
      String eq,
      String varName,
      double val,
      MathNode ast,
      String n1Tex,
      String n2Tex,
      String denTex,
      String combinedNumTex,
      String lcdTex,
      String valStr,
      _SqrtRationalizationData data) {
    final ans = _calculateNumericalLimit(ast, varName, val);
    
    // Try to get exact rational answer first
    final rationalAns = _evaluateToRational(ast, varName, val);
    final String ansTex;
    if (rationalAns != null) {
      final num = rationalAns.numerator;
      final den = rationalAns.denominator;
      final gcd = _gcd(num.abs(), den);
      final simplifiedNum = num ~/ gcd;
      final simplifiedDen = den ~/ gcd;
      ansTex = _formatExactRational(simplifiedNum, simplifiedDen);
    } else {
      ansTex = _formatResult(ans);
    }
    final aStr = data.aStr;
    final sqrtTerm = data.sqrtTerm;
    final numeratorIsNegative = data.numeratorIsNegative;

    final conjugate = aStr + r" + " + sqrtTerm;
    // ignore: unused_local_variable
    final rationalizedNum = numeratorIsNegative ? aStr + r"^2 - " + varName : varName + r" - " + aStr + r"^2";
    final simplified = numeratorIsNegative ? r"-" : r"";
    final finalExpr = simplified + r"\frac{1}{" + lcdTex + r" \cdot (" + sqrtTerm + r" + " + aStr + r")}";

    // ignore: prefer_const_declarations
    final step1 = "Identify the complex fraction.\n" +
        r"$$" + r"\lim_{" + varName + r" \to " + valStr + r"} \frac{\frac{" + n1Tex + r"}{" + data.d1Tex + r"} - \frac{" + n2Tex + r"}{" + data.d2Tex + r"}}{" + denTex + r"}$$";

    // ignore: prefer_const_declarations
    final step2 = "Find the LCD of the numerator terms.\n" +
        r"$$" + r"\text{LCD} = " + data.d1Tex + r" \cdot " + data.d2Tex + r" = " + lcdTex + r"$$";

    final step3 = "Rewrite with common denominator.\n" +
        r"$$" + r"\frac{" + aStr + r" - " + sqrtTerm + r"}{" + lcdTex + r"} \cdot \frac{1}{" + denTex + r"} = \frac{" + aStr + r" - " + sqrtTerm + r"}{" + lcdTex + r" \cdot (" + denTex + r")}$$";

    final step4 = "Rationalize by multiplying by the conjugate.\n" +
        r"$$" + r"\frac{" + aStr + r" - " + sqrtTerm + r"}{" + lcdTex + r" \cdot (" + denTex + r")} \cdot \frac{" + conjugate + r"}{" + conjugate + r"} = \frac{" + rationalizedNum + r"}{" + lcdTex + r" \cdot (" + denTex + r")(" + conjugate + r")}$$";

    final step5 = "Apply difference of squares: $denTex \\cdot $conjugate = ${numeratorIsNegative ? "-" : ""}($denTex)\$\$\nThen simplify the numerator.";

    final step6 = "Substitute $varName = $valStr and simplify.\n" +
        "${finalExpr.replaceAll(r'\sqrt{' + varName + r'}', aStr)} = $ansTex";

    return LimitSolution(
      originalEquation: eq,
      methodUsed: "LCD with Rationalization",
      steps: [step1, step2, step3, step4, step5, step6],
      finalAnswer: ans,
      fractionalAnswer: ansTex,
    );
  }
}

/// Helper class for factorization result
class _FactorizationResult {
  final String factorStep;
  final String simplifiedExpr;
  _FactorizationResult(this.factorStep, this.simplifiedExpr);
  static _FactorizationResult empty() => _FactorizationResult("", "");
}

class _SqrtRationalizationData {
  final int aInt;
  final String aStr;
  final String sqrtTerm;
  final bool numeratorIsNegative;
  final String d1Tex;
  final String d2Tex;
  final String lcdTex;
  _SqrtRationalizationData({
    required this.aInt,
    required this.aStr,
    required this.sqrtTerm,
    required this.numeratorIsNegative,
    required this.d1Tex,
    required this.d2Tex,
    required this.lcdTex,
  });
}

class _RationalResult {
  final int numerator;
  final int denominator;
  _RationalResult(this.numerator, this.denominator);
}
