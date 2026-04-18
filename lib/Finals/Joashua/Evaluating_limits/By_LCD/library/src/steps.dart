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
      String eq, String varName, double val, double result) {
    final valStr = _doubleToStr(val);
    final resStr = _tryAsFractionTex(result) ?? _doubleToStr(result);

    return LimitSolution(
      originalEquation: eq,
      methodUsed: "Direct Substitution",
      steps: [
        "**Substitute $varName = $valStr:**\n" +
            r"$$\lim_{" +
            varName +
            r" \to " +
            valStr +
            r"} " +
            eq +
            r" = " +
            resStr +
            r"$$",
      ],
      finalAnswer: result,
      fractionalAnswer: _tryAsFractionTex(result),
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

    final lcdTex = "$d1Tex \\cdot $d2Tex";
    final combinedNumTex =
        _buildCombinedNumeratorTex(n1Tex, d2Tex, numerator.op, n2Tex, d1Tex);

    // Step 1: Identify the complex fraction
    final step1 = "**Identify the complex fraction:**\n" +
        r"$$\lim_{" +
        varName +
        r" \to " +
        valStr +
        r"} " +
        r"\frac{\frac{" +
        n1Tex +
        r"}{" +
        d1Tex +
        r"} " +
        numerator.op +
        r" \frac{" +
        n2Tex +
        r"}{" +
        d2Tex +
        r"}}{" +
        denTex +
        r"}$$";

    // Step 2: Combine numerator using LCD
    final step2 = "**Combine numerator terms using the LCD \$" +
        lcdTex +
        "\$:**\n" +
        r"$$\frac{\frac{" +
        combinedNumTex +
        r"}{" +
        lcdTex +
        r"}}{" +
        denTex +
        r"} = " +
        r"\frac{" +
        combinedNumTex +
        r"}{(" +
        lcdTex +
        r")(" +
        denTex +
        r")}$$";

    // Check if this is a sqrt case that needs rationalization
    final isSqrtRationalization = _isSqrtRationalizationCase(
        combinedNumTex, denTex, denominator, varName, d1Tex, d2Tex, lcdTex);

    if (isSqrtRationalization != null) {
      return _buildSqrtRationalizationSolution(eq, varName, val, ast, n1Tex,
          n2Tex, denTex, combinedNumTex, lcdTex, valStr, isSqrtRationalization);
    }

    // Step 3: Factor denominator and cancel common factors (dynamic)
    final factorization = _dynamicFactorAndCancel(
        combinedNumTex, denTex, denominator, varName, d1Tex, d2Tex, lcdTex);

    // Step 4: Substitute and compute
    final ans = _calculateNumericalLimit(ast, varName, val);
    final ansTex = _tryAsFractionTex(ans) ?? _doubleToStr(ans);
    final substitutionExpr = factorization.simplifiedExpr.isNotEmpty
        ? factorization.simplifiedExpr
        : "\\frac{$combinedNumTex}{($lcdTex)($denTex)}";
    final substitutionChain =
        _buildSubstitutionChain(substitutionExpr, varName, val, ansTex);
    final step4 = "**Substitute \$" +
        varName +
        " = " +
        valStr +
        "\$:**\n" +
        r"$$" +
        substitutionChain +
        r"$$";

    final steps = [step1, step2];
    if (factorization.factorStep.isNotEmpty) {
      steps.add(factorization.factorStep);
    } else {
      steps.add("**Simplify and cancel common factors:**\n" +
          r"$$\text{Remaining Expression: } " +
          substitutionExpr +
          r"$$");
    }
    steps.add(step4);

    return LimitSolution(
      originalEquation: eq,
      methodUsed: "Least Common Denominator (LCD) / Factoring",
      steps: steps,
      finalAnswer: ans,
      fractionalAnswer: ansTex,
    );
  }

  // Helper to detect sqrt rationalization case
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
        final sqrtTerm = "\\sqrt{$varName}";

        if (combinedNumTex.contains("$aStr - $sqrtTerm") ||
            combinedNumTex.contains("$sqrtTerm - $aStr")) {
          final bool numeratorIsNegative =
              combinedNumTex.contains("$aStr - $sqrtTerm");
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

  // Build full sqrt rationalization solution with explicit steps
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
    final ansTex = _tryAsFractionTex(ans) ?? _doubleToStr(ans);
    final aStr = data.aStr;
    final sqrtTerm = data.sqrtTerm;
    final numeratorIsNegative = data.numeratorIsNegative;

    final conjugate = "$aStr + $sqrtTerm";
    final rationalizedNum =
        numeratorIsNegative ? "${aStr}^2 - $varName" : "$varName - ${aStr}^2";
    final simplified = numeratorIsNegative ? "-" : "";
    final finalExpr = simplified +
        r"\frac{1}{" +
        lcdTex +
        r" \cdot (" +
        sqrtTerm +
        r" + " +
        aStr +
        r")}";

    final step1 = "**Identify the complex fraction:**\n" +
        r"$$\lim_{" +
        varName +
        r" \to " +
        valStr +
        r"} " +
        r"\frac{\frac{" +
        n1Tex +
        r"}{" +
        data.d1Tex +
        r"} - \frac{" +
        n2Tex +
        r"}{" +
        data.d2Tex +
        r"}}{" +
        denTex +
        r"}$$";

    final step2 = "**Find the LCD of the numerator terms:**\n" +
        r"$$\text{LCD} = ${data.d1Tex} \\cdot ${data.d2Tex} = $lcdTex$$\n" +
        r"$$\frac{1}{\sqrt{$varName}} - \frac{1}{$aStr} = " +
        r"\frac{$aStr - \sqrt{$varName}}{$lcdTex}$$";

    const step3 = "**Rewrite the expression:**\n" +
        r"$$\frac{\frac{$aStr - \sqrt{$varName}}{$lcdTex}}{$denTex} = " +
        r"\frac{$aStr - \sqrt{$varName}}{$lcdTex \\cdot ($denTex)}$$";

    final step4 =
        "**Rationalize the numerator by multiplying by the conjugate \$" +
            conjugate +
            "\$:**\n" +
            r"$$\frac{$aStr - \sqrt{$varName}}{$lcdTex \\cdot ($denTex)} \cdot " +
            r"\frac{$conjugate}{$conjugate} = " +
            r"\frac{$rationalizedNum}{$lcdTex \\cdot ($denTex)($conjugate)}$$";

    final step5 = "**Simplify using " +
        (numeratorIsNegative ? "-" : "+") +
        " identity:**\n" +
        r"$$9 - $varName = -($varName - 9) = -($denTex)$$\n" +
        r"$$\frac{-($denTex)}{$lcdTex \\cdot ($denTex)($conjugate)} = " +
        r"\frac{-1}{$lcdTex \\cdot ($conjugate)}$$";

    final step6 = "**Substitute \$" +
        varName +
        " = " +
        valStr +
        "\$:**\n" +
        r"$$" +
        finalExpr.replaceAll(r'\sqrt{' + varName + r'}', aStr) +
        r" = " +
        ansTex +
        r"$$";

    return LimitSolution(
      originalEquation: eq,
      methodUsed: "Least Common Denominator (LCD) with Rationalization",
      steps: [step1, step2, step3, step4, step5, step6],
      finalAnswer: ans,
      fractionalAnswer: ansTex,
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
    final conjTex =
        "${_nodeToTex(target.left)} ${target.op == '+' ? '-' : '+'} ${_nodeToTex(target.right)}";
    final valStr = _doubleToStr(val);
    final ansTex = _tryAsFractionTex(ans) ?? _doubleToStr(ans);

    return LimitSolution(
      originalEquation: eq,
      methodUsed: "Rationalization (Conjugate)",
      steps: [
        "**Identify the conjugate:**\n" +
            r"$$\text{Conjugate: } " +
            conjTex +
            r"$$",
        "**Multiply top and bottom by the conjugate:**\n" +
            r"$$\frac{" +
            _nodeToTex(ast.left) +
            r"}{" +
            _nodeToTex(ast.right) +
            r"} " +
            r"\cdot \frac{" +
            conjTex +
            r"}{" +
            conjTex +
            r"}$$",
        "**Apply the difference of squares identity:**\n" +
            r"$$\text{Simplifying factors...}$$",
        "**Substitute \$" +
            varName +
            " = " +
            valStr +
            "\$ and solve:**\n" +
            r"$$\text{Result: } " +
            ansTex +
            r"$$",
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
        "**Note:** This expression requires L'Hôpital's Rule or advanced factoring."
      ],
    );
  }

  // -------------------------------------------------------------------
  // Utility: Build combined numerator LaTeX
  // -------------------------------------------------------------------
  static String _buildCombinedNumeratorTex(
      String n1, String d2, String op, String n2, String d1) {
    if (n1 == "1" && n2 == "1") {
      return "$d2 $op $d1";
    }
    return "($n1 \\cdot $d2) $op ($n2 \\cdot $d1)";
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
    // 1. Square‑root pattern: denominator = x - a²
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
              ? "${aStr}^2 - $varName"
              : "$varName - ${aStr}^2";
          final simplified = sign +
              r"\frac{1}{" +
              lcdTex +
              r" \cdot (" +
              sqrtTerm +
              r" + " +
              aStr +
              r")}";
          final cancelIdentity = numeratorIsNegative
              ? "$rationalizedNumerator = -($denTex)"
              : "$rationalizedNumerator = ($denTex)";

          final factorStep =
              "**Rationalize the numerator using the conjugate ${_d}" +
                  conjugate +
                  "${_d}:**\n" +
                  r"$$\frac{" +
                  combinedNumTex +
                  r"}{" +
                  lcdTex +
                  r" \cdot (" +
                  denTex +
                  r")} \cdot \frac{" +
                  conjugate +
                  r"}{" +
                  conjugate +
                  r"} = \frac{" +
                  rationalizedNumerator +
                  r"}{" +
                  lcdTex +
                  r" \cdot (" +
                  denTex +
                  r")(" +
                  conjugate +
                  r")}$$" +
                  "\n**Simplify and cancel common factors:**\n" +
                  r"$$" +
                  cancelIdentity +
                  r"\quad\Rightarrow\quad\frac{" +
                  rationalizedNumerator +
                  r"}{" +
                  lcdTex +
                  r" \cdot (" +
                  denTex +
                  r")(" +
                  conjugate +
                  r")} = " +
                  simplified +
                  r"$$";

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
                    "**Factor the denominator using difference of squares:**\n" +
                        r"$$\frac{" +
                        denTex +
                        r"}{1} = (" +
                        factor1 +
                        r")(" +
                        factor2 +
                        r")$$" +
                        "\n**Cancel the common factor (" +
                        factor1 +
                        r"):**\n" +
                        r"$$\frac{" +
                        combinedNumTex +
                        r"}{" +
                        lcdTex +
                        r" \cdot (" +
                        factor1 +
                        r")(" +
                        factor2 +
                        r")} = " +
                        simplified +
                        r"$$";

                return _FactorizationResult(factorStep, simplified);
              }
            }
          }
        }
      }
    }

    // 3. No recognizable pattern → empty result
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
      return "${_nodeToTex(node.left)} ${node.op == '*' ? '\\cdot' : node.op} ${_nodeToTex(node.right)}";
    }
    return "";
  }

  static BinaryOpNode _ensureFraction(MathNode node) {
    if (node is BinaryOpNode && node.op == '/') return node;
    return BinaryOpNode('/', node, const NumberNode(1));
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
    const h = 1e-8;
    final r = _evalNode(ast, varName, val + h);
    final l = _evalNode(ast, varName, val - h);
    if (r.isNaN) return l;
    if (l.isNaN) return r;
    return (r + l) / 2;
  }

  static String _doubleToStr(double v) {
    if (v.isNaN) return "NaN";
    if (v == v.toInt()) return v.toInt().toString();
    return v
        .toStringAsFixed(4)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  static String? _tryAsFractionTex(double val) {
    if (!val.isFinite || val == 0) return null;
    final absVal = val.abs();
    for (int d = 1; d <= 800; d++) {
      final n = absVal * d;
      if ((n - n.round()).abs() < 1e-6) {
        final num = n.round();
        if (d == 1) return val < 0 ? "-$num" : "$num";
        return "${val < 0 ? '-' : ''}\\frac{$num}{$d}";
      }
    }
    return null;
  }

  static String _buildSubstitutionChain(
      String substitutionExpr, String varName, double val, String ansTex) {
    final valStr = _doubleToStr(val);
    final substituted = substitutionExpr.replaceAll(
      RegExp('(?<![A-Za-z])${RegExp.escape(varName)}(?![A-Za-z])'),
      valStr,
    );

    final parts = <String>[substituted];

    final sqrtEvaluated = substituted.replaceAllMapped(
      RegExp(r'\\sqrt\{(-?\d+(?:\.\d+)?)\}'),
      (match) {
        final raw = match.group(1);
        final parsed = raw == null ? null : double.tryParse(raw);
        if (parsed == null || parsed < 0) return match.group(0)!;
        return _doubleToStr(sqrt(parsed));
      },
    );

    if (sqrtEvaluated != parts.last) {
      parts.add(sqrtEvaluated);
    }

    if (parts.last != ansTex) {
      parts.add(ansTex);
    }

    return parts.join(' = ');
  }

  static bool _containsSqrt(MathNode node) {
    if (node is FunctionNode && node.name == 'sqrt') return true;
    if (node is BinaryOpNode) {
      return _containsSqrt(node.left) || _containsSqrt(node.right);
    }
    if (node is UnaryMinusNode) return _containsSqrt(node.child);
    return false;
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
