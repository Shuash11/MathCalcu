library steps;
/// src/steps.dart

import 'dart:math';
import 'lcd_math_engine.dart';

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
    var output = StringBuffer();
    output.writeln("========================================");
    output.writeln("LIMIT EVALUATION: $methodUsed");
    output.writeln("========================================");
    output.writeln("Equation: $originalEquation\n");

    for (int i = 0; i < steps.length; i++) {
      output.writeln("Step ${i + 1}:");
      output.writeln("  ${steps[i]}\n");
    }

    if (finalAnswer != null) {
      output.writeln("FINAL ANSWER: $finalAnswer");
    } else {
      output.writeln("FINAL ANSWER: Undefined or Requires Advanced Methods");
    }
    output.writeln("========================================");
    return output.toString();
  }
}

class StepGenerator {
  // ══════════════════════════════════════════════════════════════════════════
  // DIRECT SUBSTITUTION
  // ══════════════════════════════════════════════════════════════════════════

  static LimitSolution directSubstitutionSuccess(
      String eq, String varName, double val, double result) {
    return LimitSolution(
      originalEquation: eq,
      methodUsed: "Direct Substitution",
      steps: [
        "We attempt Direct Substitution first by plugging in $varName = $val.",
        "Evaluating the expression yields a real, finite number.",
        "No indeterminate forms (like 0/0) are present."
      ],
      finalAnswer: result,
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CONJUGATE (RATIONALIZATION) METHOD
  // ══════════════════════════════════════════════════════════════════════════

  /// Conjugate Method — handles sqrt in numerator **or** denominator.
  static LimitSolution solveByConjugate(
      String eq, String varName, double val, MathNode ast) {
    // Numerical answer — always accurate regardless of the algebraic path.
    final double ans = _calculateNumericalLimit(ast, varName, val);
    final List<String> steps = [];
    final String valStr =
        val == val.toInt() ? val.toInt().toString() : val.toString();

    if (ast is! BinaryOpNode || ast.op != '/') {
      return unknownForm(eq, varName, val);
    }

    MathNode numNode = ast.left;
    final MathNode denNode = ast.right;

    // Normalize a bare unary-minus numerator: -(expr) → 0 - expr
    if (numNode is UnaryMinusNode) {
      numNode = BinaryOpNode('-', const NumberNode(0), numNode.child);
    }

    final String numTex = _nodeToTex(numNode);
    final String denTex = _nodeToTex(denNode);

    // ── Step 1 : Indeterminate form ────────────────────────────────────────
    steps.add(
      "Direct Substitution: let \$$varName = $valStr\$:\n"
      "\$\$\\lim_{$varName \\to $valStr} "
      "\\frac{$numTex}{$denTex} = \\frac{0}{0}\$\$\n"
      "This is an \\textbf{indeterminate form (0/0)}. "
      "We eliminate the radical using the \\textbf{Conjugate (Rationalization) Method}.",
    );

    // ── CASE A : sqrt appears in the numerator ─────────────────────────────
    if (_containsSqrt(numNode) &&
        numNode is BinaryOpNode &&
        (numNode.op == '+' || numNode.op == '-')) {
      return _conjugateNumeratorSqrt(
          eq, varName, val, valStr, numNode, denNode,
          numTex, denTex, ans, steps);
    }

    // ── CASE B : sqrt appears in the denominator ───────────────────────────
    if (_containsSqrt(denNode) &&
        denNode is BinaryOpNode &&
        (denNode.op == '+' || denNode.op == '-')) {
      return _conjugateDenominatorSqrt(
          eq, varName, val, valStr, numNode, denNode,
          numTex, denTex, ans, steps);
    }

    // ── Fallback : structure not recognised ────────────────────────────────
    steps.add(
      "The expression contains a square root but does not match a standard "
      "conjugate pattern. Returning the numerical limit.",
    );
    final String fracAns = _tryAsFractionTex(ans) ??
        (ans.isFinite ? ans.toStringAsFixed(4) : r"\text{undefined}");
    return LimitSolution(
      originalEquation: eq,
      methodUsed: "Rationalization (Conjugate Method)",
      steps: steps,
      finalAnswer: ans.isFinite ? ans : null,
      fractionalAnswer: fracAns,
    );
  }

  // ── Case A worker ──────────────────────────────────────────────────────────
  static LimitSolution _conjugateNumeratorSqrt(
    String eq,
    String varName,
    double val,
    String valStr,
    BinaryOpNode numNode,
    MathNode denNode,
    String numTex,
    String denTex,
    double ans,
    List<String> steps,
  ) {
    final bool lSqrt = _containsSqrt(numNode.left);
    final MathNode sqrtSide = lSqrt ? numNode.left : numNode.right;
    final MathNode otherSide = lSqrt ? numNode.right : numNode.left;
    final String conjOp = numNode.op == '+' ? '-' : '+';

    final String sqrtTex  = _nodeToTex(sqrtSide);
    final String otherTex = _nodeToTex(otherSide);
    final String conjTex  =
        lSqrt ? "$sqrtTex $conjOp $otherTex" : "$otherTex $conjOp $sqrtTex";

    // Argument inside the sqrt (used for difference-of-squares expansion)
    final MathNode argNode =
        sqrtSide is FunctionNode ? sqrtSide.arg : sqrtSide;
    final String argTex  = _nodeToTex(argNode);
    final String bSqTex  = _squaredTex(otherSide);
    final String diffSqTex = lSqrt ? "$argTex - $bSqTex" : "$bSqTex - $argTex";

    // ── Step 2 : Identify conjugate ─────────────────────────────────────────
    steps.add(
      "The numerator \$$numTex\$ contains a square root. "
      "Form the conjugate by flipping the sign between terms:\n"
      "\$\$\\text{Conjugate} = $conjTex\$\$",
    );

    // ── Step 3 : Multiply by conjugate / conjugate ──────────────────────────
    steps.add(
      "Multiply numerator and denominator by the conjugate "
      "\$$conjTex\$:\n"
      "\$\$\\frac{$numTex}{$denTex}"
      "\\cdot\\frac{$conjTex}{$conjTex}"
      "= \\frac{($numTex)($conjTex)}{($denTex)($conjTex)}\$\$",
    );

    // ── Step 4 : Difference of Squares ─────────────────────────────────────
    steps.add(
      "Apply the Difference of Squares identity "
      r"$(a - b)(a + b) = a^{2} - b^{2}$"
      " to the numerator:\n"
      "\$\$($numTex)($conjTex) = $diffSqTex\$\$\n"
      "The square root is completely eliminated from the numerator.",
    );

    // ── Step 5 : Show the resulting fraction ────────────────────────────────
    steps.add(
      "The expression now becomes:\n"
      "\$\$\\frac{$diffSqTex}{($denTex)($conjTex)}\$\$",
    );

    // ── Step 6 : Cancel the common factor ───────────────────────────────────
    final bool neg = ans < 0;
    final String cancelled =
        neg ? "-\\frac{1}{$conjTex}" : "\\frac{1}{$conjTex}";
    final String cancelNum = neg ? "-($denTex)" : denTex;
    steps.add(
      "\$$diffSqTex\$ simplifies to match the denominator "
      "(${neg ? "with opposite sign" : "exactly"}). "
      "Cancel the common binomial factor:\n"
      "\$\$\\frac{\\cancel{$cancelNum}}"
      "{\\cancel{($denTex)}\\cdot($conjTex)}"
      "= $cancelled,\\quad $varName \\neq $valStr\$\$",
    );

    // ── Step 7 : Substitute and evaluate ───────────────────────────────────
    final double sqrtArgD = _evalNode(argNode, varName, val);
    final double sqrtD    = sqrtArgD >= 0 ? sqrt(sqrtArgD) : double.nan;
    final double otherD   = _evalNode(otherSide, varName, val);

    final String sqrtArgStr = _doubleToStr(sqrtArgD);
    final String sqrtStr    = !sqrtD.isNaN && sqrtD == sqrtD.roundToDouble()
        ? sqrtD.round().toString()
        : sqrtD.toStringAsFixed(4);
    final String otherStr = _doubleToStr(otherD);

    final double conjD = lSqrt
        ? (conjOp == '+' ? sqrtD + otherD : sqrtD - otherD)
        : (conjOp == '+' ? otherD + sqrtD : otherD - sqrtD);
    final String conjDStr = _doubleToStr(conjD);

    final String sub1 = lSqrt
        ? "\\sqrt{$sqrtArgStr} $conjOp $otherStr"
        : "$otherStr $conjOp \\sqrt{$sqrtArgStr}";
    final String sub2 = lSqrt
        ? "$sqrtStr $conjOp $otherStr"
        : "$otherStr $conjOp $sqrtStr";

    final String fracAns = _tryAsFractionTex(ans) ??
        (ans.isFinite ? ans.toStringAsFixed(4) : r"\text{undefined}");

    final String substFull = neg
        ? "-\\frac{1}{$sub1} = -\\frac{1}{$sub2} = -\\frac{1}{$conjDStr}"
        : "\\frac{1}{$sub1} = \\frac{1}{$sub2} = \\frac{1}{$conjDStr}";

    steps.add(
      "Substitute \$$varName = $valStr\$ into \$$cancelled\$:\n"
      "\$\$$cancelled\\bigg|_{$varName=$valStr}"
      " = $substFull = $fracAns\$\$",
    );

    return LimitSolution(
      originalEquation: eq,
      methodUsed: "Rationalization (Conjugate Method)",
      steps: steps,
      finalAnswer: ans.isFinite ? ans : null,
      fractionalAnswer: fracAns,
    );
  }

  // ── Case B worker ──────────────────────────────────────────────────────────
  static LimitSolution _conjugateDenominatorSqrt(
    String eq,
    String varName,
    double val,
    String valStr,
    MathNode numNode,
    BinaryOpNode denNode,
    String numTex,
    String denTex,
    double ans,
    List<String> steps,
  ) {
    final bool lSqrt = _containsSqrt(denNode.left);
    final MathNode sqrtSide = lSqrt ? denNode.left : denNode.right;
    final MathNode otherSide = lSqrt ? denNode.right : denNode.left;
    final String conjOp = denNode.op == '+' ? '-' : '+';

    final String sqrtTex  = _nodeToTex(sqrtSide);
    final String otherTex = _nodeToTex(otherSide);
    final String conjTex  =
        lSqrt ? "$sqrtTex $conjOp $otherTex" : "$otherTex $conjOp $sqrtTex";

    final MathNode argNode =
        sqrtSide is FunctionNode ? sqrtSide.arg : sqrtSide;
    final String argTex  = _nodeToTex(argNode);
    final String bSqTex  = _squaredTex(otherSide);
    final String diffSqTex =
        lSqrt ? "$argTex - $bSqTex" : "$bSqTex - $argTex";

    // ── Step 2 ──────────────────────────────────────────────────────────────
    steps.add(
      "The denominator \$$denTex\$ contains a square root. "
      "Form the conjugate by flipping the sign:\n"
      "\$\$\\text{Conjugate of denominator} = $conjTex\$\$",
    );

    // ── Step 3 ──────────────────────────────────────────────────────────────
    steps.add(
      "Multiply numerator and denominator by the conjugate "
      "\$$conjTex\$:\n"
      "\$\$\\frac{$numTex}{$denTex}"
      "\\cdot\\frac{$conjTex}{$conjTex}"
      "= \\frac{($numTex)($conjTex)}{($denTex)($conjTex)}\$\$",
    );

    // ── Step 4 ──────────────────────────────────────────────────────────────
    steps.add(
      "Apply the Difference of Squares identity to the denominator:\n"
      "\$\$($denTex)($conjTex) = $diffSqTex\$\$\n"
      "The expression becomes:\n"
      "\$\$\\frac{($numTex)($conjTex)}{$diffSqTex}\$\$",
    );

    // ── Step 5 : cancel ─────────────────────────────────────────────────────
    steps.add(
      "The numerator factors and the common factor \$$diffSqTex\$ cancels:\n"
      "\$\$= $conjTex,\\quad $varName \\neq $valStr\$\$",
    );

    // ── Step 6 : substitute ─────────────────────────────────────────────────
    final double sqrtArgD = _evalNode(argNode, varName, val);
    final double sqrtD    = sqrtArgD >= 0 ? sqrt(sqrtArgD) : double.nan;
    final double otherD   = _evalNode(otherSide, varName, val);

    final String sqrtArgStr = _doubleToStr(sqrtArgD);
    final String sqrtStr    = !sqrtD.isNaN && sqrtD == sqrtD.roundToDouble()
        ? sqrtD.round().toString()
        : sqrtD.toStringAsFixed(4);
    final String otherStr = _doubleToStr(otherD);



    final String sub1 = lSqrt
        ? "\\sqrt{$sqrtArgStr} $conjOp $otherStr"
        : "$otherStr $conjOp \\sqrt{$sqrtArgStr}";
    final String sub2 = lSqrt
        ? "$sqrtStr $conjOp $otherStr"
        : "$otherStr $conjOp $sqrtStr";

    final String fracAns = _tryAsFractionTex(ans) ??
        (ans.isFinite ? ans.toStringAsFixed(4) : r"\text{undefined}");

    steps.add(
      "Substitute \$$varName = $valStr\$ into \$$conjTex\$:\n"
      "\$\$$conjTex\\bigg|_{$varName=$valStr}"
      " = $sub1 = $sub2 = $fracAns\$\$",
    );

    return LimitSolution(
      originalEquation: eq,
      methodUsed: "Rationalization (Conjugate Method)",
      steps: steps,
      finalAnswer: ans.isFinite ? ans : null,
      fractionalAnswer: fracAns,
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // LCD METHOD  (Complex Fractions)
  // ══════════════════════════════════════════════════════════════════════════

  static LimitSolution solveByLCD(
      String eq, String varName, double val, MathNode ast) {
    // 1. Structural extraction
    MathNode? numerator;
    MathNode? denominator;

    if (ast is BinaryOpNode && ast.op == '/') {
      numerator   = ast.left;
      denominator = ast.right;
    } else {
      return unknownForm(eq, varName, val);
    }

    String denStr = _nodeToTex(denominator);

    // 2. Identification of fractions in numerator
    MathNode? frac1Node;
    MathNode? frac2Node;
    String op = "+";

    if (numerator is BinaryOpNode &&
        (numerator.op == '+' || numerator.op == '-')) {
      frac1Node = numerator.left;
      frac2Node = numerator.right;
      op        = numerator.op;
    } else {
      return unknownForm(eq, varName, val);
    }

    BinaryOpNode frac1 = _ensureFraction(frac1Node);
    BinaryOpNode frac2 = _ensureFraction(frac2Node);

    String n1 = _nodeToTex(frac1.left);
    String d1 = _nodeToTex(frac1.right);
    String n2 = _nodeToTex(frac2.left);
    String d2 = _nodeToTex(frac2.right);

    // Helpers for formatting
    String formatLcd(String d1, String d2) {
      bool d1IsNum = double.tryParse(d1) != null;
      bool d2IsNum = double.tryParse(d2) != null;
      if (d1IsNum && !d2IsNum) return "$d1$d2";
      if (d2IsNum && !d1IsNum) return "$d2$d1";
      if (d1IsNum && d2IsNum)  return "$d1($d2)";
      return "$d1 \\cdot $d2";
    }

    // 3. Chain of Equality Generation
    List<String> steps = [];
    StringBuffer chain = StringBuffer();

    String formattedLcd   = formatLcd(d1, d2);
    String expandedNumTex = _simplifyNumeratorString(frac1, frac2, op);

    // Original Form
    chain.write(
        "\\frac{ \\frac{$n1}{$d1} $op \\frac{$n2}{$d2} }{ $denStr } = ");

    // LCD Form
    chain.write(
        "\\frac{ \\frac{$expandedNumTex}{$formattedLcd} }{ $denStr } = ");

    // Reciprocated Form
    chain.write("\\frac{ $expandedNumTex }{ $formattedLcd( $denStr ) }");

    // Factoring and Cancellation
    bool isReverse = expandedNumTex.contains('-') &&
        expandedNumTex.startsWith(d2) &&
        denStr.startsWith(varName);
    bool isDirect = expandedNumTex == denStr;

    String cancelledTex;
    if (isDirect) {
      cancelledTex = "\\frac{1}{$formattedLcd}";
    } else if (isReverse) {
      chain.write(
          " = \\frac{ -($denStr) }{ $formattedLcd( $denStr ) }");
      cancelledTex = "-\\frac{1}{$formattedLcd}";
    } else {
      cancelledTex = "\\frac{1}{$formattedLcd}";
    }

    // Cancelled Form with domain restriction
    String valStr =
        val == val.toInt() ? val.toInt().toString() : val.toString();
    chain.write(
        " = $cancelledTex \\text{ for } $varName \\neq $valStr");

    steps.add(
        "Simplify the expression inside the limit:\n\$\$${chain.toString()}\$\$");

    // Step 2: Substitution
    steps.add(
        "Substitute the simplified expression into the limit:\n"
        "\$\$\\lim_{$varName \\to $valStr} $cancelledTex\$\$");

    // Step 3: Evaluation
    double answer = _calculateNumericalLimit(ast, varName, val);

    String d1Subbed =
        _nodeToTex(frac1.right).replaceAll(varName, valStr);
    String d2Subbed =
        _nodeToTex(frac2.right).replaceAll(varName, valStr);

    String formattedLcdSubbed = formatLcd(d1Subbed, d2Subbed);

    String substitutionTex;
    if (isReverse) {
      substitutionTex = "-\\frac{1}{$formattedLcdSubbed}";
    } else {
      substitutionTex = "\\frac{1}{$formattedLcdSubbed}";
    }

    String finalEvalTex = substitutionTex;

    // Try to express as a clean fraction
    if (answer.isFinite && answer != 0) {
      String? fracTex = _tryAsFractionTex(answer);
      if (fracTex != null) finalEvalTex = fracTex;
    }

    String stepLabel = "Evaluate the limit by direct substitution:";
    if (substitutionTex == finalEvalTex) {
      steps.add("$stepLabel\n\$\$$substitutionTex\$\$");
    } else {
      steps.add("$stepLabel\n\$\$$substitutionTex = $finalEvalTex\$\$");
    }

    return LimitSolution(
      originalEquation: eq,
      methodUsed: "Least Common Denominator (LCD)",
      steps: steps,
      finalAnswer: answer.isFinite ? answer : null,
      fractionalAnswer: finalEvalTex,
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // UNKNOWN / FALLBACK
  // ══════════════════════════════════════════════════════════════════════════

  static LimitSolution unknownForm(String eq, String varName, double val) {
    return LimitSolution(
      originalEquation: eq,
      methodUsed: "Analysis Required",
      steps: [
        "Attempt Direct Substitution yielded an undefined or infinite result.",
        "The structure does not strictly match standard Conjugate or LCD heuristics.",
        "Recommendation: Try L'Hôpital's Rule, trigonometric identities, or general polynomial factoring."
      ],
      finalAnswer: null,
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PRIVATE HELPERS — AST ↔ LaTeX
  // ══════════════════════════════════════════════════════════════════════════

  static BinaryOpNode _ensureFraction(MathNode node) {
    if (node is BinaryOpNode && node.op == '/') return node;
    return BinaryOpNode('/', node, const NumberNode(1));
  }

  static String _simplifyNumeratorString(
      BinaryOpNode f1, BinaryOpNode f2, String op) {
    String n1 = _nodeToTex(f1.left);
    String d1 = _nodeToTex(f1.right);
    String n2 = _nodeToTex(f2.left);
    String d2 = _nodeToTex(f2.right);

    if (n1 == "1" && n2 == "1") return "$d2 $op $d1";
    return "$n1($d2) $op $n2($d1)";
  }

  /// Converts an AST node into a LaTeX string.
  static String _nodeToTex(MathNode node) {
    if (node is NumberNode) {
      return node.value == node.value.toInt()
          ? node.value.toInt().toString()
          : node.value.toString();
    }
    if (node is VariableNode) return node.name;
    if (node is UnaryMinusNode) return "-{${_nodeToTex(node.child)}}";

    if (node is FunctionNode) {
      // Proper LaTeX for sqrt: \sqrt{arg}
      if (node.name == 'sqrt') return "\\sqrt{${_nodeToTex(node.arg)}}";
      return "\\${node.name}\\left(${_nodeToTex(node.arg)}\\right)";
    }

    if (node is BinaryOpNode) {
      // Fractions use \frac{}{}
      if (node.op == '/') {
        return "\\frac{${_nodeToTex(node.left)}}{${_nodeToTex(node.right)}}";
      }

      // Powers use ^{}
      if (node.op == '^') {
        String base = _nodeToTex(node.left);
        final String exp = _nodeToTex(node.right);
        if (node.left is BinaryOpNode || node.left is UnaryMinusNode) {
          base = "($base)";
        }
        return "$base^{$exp}";
      }

      String l = _nodeToTex(node.left);
      String r = _nodeToTex(node.right);

      if (node.left is BinaryOpNode &&
          _precedence(node.left as BinaryOpNode) < _precedence(node)) {
        l = "($l)";
      }
      if (node.right is BinaryOpNode &&
          _precedence(node.right as BinaryOpNode) <= _precedence(node)) {
        r = "($r)";
      }

      String op = node.op;
      if (op == '*') op = "\\cdot ";
      return "$l $op $r";
    }
    return "";
  }

  static int _precedence(BinaryOpNode node) {
    if (node.op == '+' || node.op == '-') return 1;
    if (node.op == '*' || node.op == '/') return 2;
    if (node.op == '^') return 3;
    return 0;
  }

  static bool _containsSqrt(MathNode node) {
    if (node is FunctionNode && node.name == 'sqrt') return true;
    if (node is BinaryOpNode) {
      return _containsSqrt(node.left) || _containsSqrt(node.right);
    }
    if (node is UnaryMinusNode) return _containsSqrt(node.child);
    return false;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PRIVATE HELPERS — NUMERIC EVALUATION
  // ══════════════════════════════════════════════════════════════════════════

  static double _evalNode(MathNode node, String varName, double val) {
    if (node is NumberNode) return node.value;
    if (node is VariableNode) return val;
    if (node is UnaryMinusNode) return -_evalNode(node.child, varName, val);
    if (node is FunctionNode) {
      if (node.name == 'sqrt') {
        double argVal = _evalNode(node.arg, varName, val);
        if (argVal < 0) return double.nan;
        return sqrt(argVal);
      }
    }
    if (node is BinaryOpNode) {
      double l = _evalNode(node.left, varName, val);
      double r = _evalNode(node.right, varName, val);
      if (l.isNaN || r.isNaN) return double.nan;
      switch (node.op) {
        case '+': return l + r;
        case '-': return l - r;
        case '*': return l * r;
        case '/': return r == 0 ? double.nan : l / r;
        case '^': return pow(l, r).toDouble();
      }
    }
    return double.nan;
  }

  /// Approaches from both sides to guarantee accuracy at discontinuities.
  static double _calculateNumericalLimit(
      MathNode ast, String varName, double val) {
    const double h = 1e-7;
    final double right = _evalNode(ast, varName, val + h);
    final double left  = _evalNode(ast, varName, val - h);

    if (right.isFinite && left.isFinite && (right - left).abs() < 0.0001) {
      return right;
    }
    return double.nan;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PRIVATE HELPERS — FORMATTING
  // ══════════════════════════════════════════════════════════════════════════

  /// Squares a node's value symbolically when it's a plain number,
  /// or wraps it in TeX (e.g. (x)^{2}) otherwise.
  static String _squaredTex(MathNode node) {
    if (node is NumberNode) {
      final double sq = node.value * node.value;
      return sq == sq.toInt() ? sq.toInt().toString() : sq.toString();
    }
    return "(${_nodeToTex(node)})^{2}";
  }

  /// Tries to express a double as a LaTeX fraction (up to denominator 200).
  /// Returns null if no exact rational representation is found.
  static String? _tryAsFractionTex(double val) {
    if (!val.isFinite) return null;
    if (val == 0) return "0";
    final bool neg  = val < 0;
    final double abs = val.abs();
    for (int d = 1; d <= 200; d++) {
      final double n = abs * d;
      if ((n - n.round()).abs() < 0.00001) {
        final int ni = n.round();
        if (d == 1) return neg ? "-$ni" : "$ni";
        return neg ? "-\\frac{$ni}{$d}" : "\\frac{$ni}{$d}";
      }
    }
    return null;
  }

  /// Formats a double as a compact string (int form when exact).
  static String _doubleToStr(double v) {
    if (v.isNaN) return r"\text{NaN}";
    if (v == v.toInt()) return v.toInt().toString();
    return v.toStringAsFixed(4);
  }
}
