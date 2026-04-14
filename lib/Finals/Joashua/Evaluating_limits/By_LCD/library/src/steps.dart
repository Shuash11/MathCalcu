/// src/steps.dart

import 'dart:math';
import 'lcd_math_engine.dart';

class LimitSolution {
  final String originalEquation;
  final List<String> steps;
  final double? finalAnswer;
  final String methodUsed;

  LimitSolution({
    required this.originalEquation,
    required this.steps,
    this.finalAnswer,
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
  /// Direct Substitution
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

  /// Conjugate Method (Square Roots)
  static LimitSolution solveByConjugate(
      String eq, String varName, double val, MathNode ast) {
    // 1. Extract actual strings from the AST so steps reflect exactly what the user typed
    String numStr = "";
    String denStr = "";
    String conjStr = "";
    String diffOfSquaresStr = "";

    if (ast is BinaryOpNode && ast.op == '/') {
      MathNode numerator = ast.left;
      denStr = _nodeToString(ast.right);

      // Handle unary minus in numerator (e.g., - (sqrt(x) - 2) )
      if (numerator is UnaryMinusNode) {
        numerator = BinaryOpNode('-', NumberNode(0), numerator.child);
      }

      if (numerator is BinaryOpNode &&
          (numerator.op == '+' || numerator.op == '-')) {
        numStr = _nodeToString(numerator);

        // Identify which side has the sqrt
        bool leftIsSqrt = _containsSqrt(numerator.left);
        MathNode sqrtSide = leftIsSqrt ? numerator.left : numerator.right;
        MathNode constSide = leftIsSqrt ? numerator.right : numerator.left;

        // Create conjugate string (flip the sign)
        String newOp = numerator.op == '+' ? '-' : '+';
        conjStr =
            "(${_nodeToString(sqrtSide)} $newOp ${_nodeToString(constSide)})";

        // Create difference of squares string representation
        String aSquared =
            _nodeToString((sqrtSide is FunctionNode) ? sqrtSide.arg : sqrtSide);
        String bSquared = _nodeToString(constSide);
        diffOfSquaresStr = "($aSquared - ($bSquared)^2)";
      }
    }

    // 2. Calculate the actual mathematical answer using numerical limits
    double answer = _calculateNumericalLimit(ast, varName, val);

    // 3. Return formatted classroom steps
    return LimitSolution(
      originalEquation: eq,
      methodUsed: "Rationalization (Conjugate Method)",
      steps: [
        "Attempt Direct Substitution: Plugging in $varName = $val results in 0/0 (Indeterminate Form).",
        "Because the numerator contains a square root [$numStr], we must rationalize it.",
        "Identify the conjugate of the numerator: $conjStr",
        "Multiply both the numerator and the denominator by this conjugate.",
        "For the numerator, apply the Difference of Squares formula: (a-b)(a+b) = a^2 - b^2",
        "Numerator simplifies to: $diffOfSquaresStr",
        "Expand the squares and simplify the numerator to remove the radical.",
        "Simplify the denominator: ($denStr) * $conjStr",
        "Cancel out the common binomial factor between the new numerator and denominator (this removes the 0/0).",
        "Perform Direct Substitution on the newly simplified expression with $varName = $val."
      ],
      finalAnswer: answer.isFinite ? answer : null,
    );
  }

  /// LCD Method (Complex Fractions)
  static LimitSolution solveByLCD(
      String eq, String varName, double val, MathNode ast) {
    // 1. Extract structural info from AST
    String denStr = "";
    String lcdStr = "";
    String combinedNumStr = "";

    if (ast is BinaryOpNode && ast.op == '/') {
      MathNode numerator = ast.left;
      denStr = _nodeToString(ast.right);

      if (numerator is BinaryOpNode &&
          (numerator.op == '+' || numerator.op == '-')) {
        if (numerator.left is BinaryOpNode && numerator.right is BinaryOpNode) {
          BinaryOpNode frac1 = numerator.left as BinaryOpNode;
          BinaryOpNode frac2 = numerator.right as BinaryOpNode;

          if (frac1.op == '/' && frac2.op == '/') {
            String den1 = _nodeToString(frac1.right);
            String den2 = _nodeToString(frac2.right);

            // Generate LCD string
            lcdStr = "($den1) * ($den2)";

            // Generate distributed numerator string
            String term1 = "(${_nodeToString(frac1.left)}) * ($den2)";
            String term2 = "(${_nodeToString(frac2.left)}) * ($den1)";
            combinedNumStr = "$term1 ${numerator.op} $term2";
          }
        }
      }
    }

    // 2. Calculate the actual mathematical answer
    double answer = _calculateNumericalLimit(ast, varName, val);

    // 3. Return formatted classroom steps
    return LimitSolution(
      originalEquation: eq,
      methodUsed: "Least Common Denominator (LCD)",
      steps: [
        "Attempt Direct Substitution: Plugging in $varName = $val results in 0/0 (Indeterminate Form).",
        "We observe that the numerator consists of separate fractions being added or subtracted.",
        "To combine them, we must find the Least Common Denominator (LCD) of the numerator's fractions.",
        "The LCD is the product of the denominators: $lcdStr",
        "Multiply every term in the numerator by the LCD to eliminate the small fractions.",
        "The newly expanded numerator becomes: $combinedNumStr",
        "Distribute and simplify the expanded numerator.",
        "The new overall denominator is the LCD multiplied by the original denominator: ($lcdStr) * ($denStr)",
        "Factor the new numerator. You will notice it contains the original denominator ($denStr) as a factor.",
        "Cancel the common factor ($denStr) from the numerator and overall denominator.",
        "With the expression simplified, perform Direct Substitution using $varName = $val."
      ],
      finalAnswer: answer.isFinite ? answer : null,
    );
  }

  static LimitSolution unknownForm(String eq, String varName, double val) {
    return LimitSolution(
      originalEquation: eq,
      methodUsed: "Analysis Required",
      steps: [
        "Attempt Direct Substitution yielded an undefined or infinite result.",
        "The structure does not strictly match standard Conjugate or LCD heuristics.",
        "Recommendation: Try L'Hopital's Rule, trigonometric identities, or general polynomial factoring."
      ],
      finalAnswer: null,
    );
  }

  // ==========================================
  // PRIVATE AST HELPERS & MATH ENGINE
  // ==========================================

  /// Safely converts an AST node back into a readable math string for the steps
  static String _nodeToString(MathNode node) {
    if (node is NumberNode) {
      return node.value == node.value.toInt()
          ? node.value.toInt().toString()
          : node.value.toString();
    }
    if (node is VariableNode) return node.name;
    if (node is UnaryMinusNode) return "-${_nodeToString(node.child)}";
    if (node is FunctionNode) return "${node.name}(${_nodeToString(node.arg)})";
    if (node is BinaryOpNode) {
      String l = _nodeToString(node.left);
      String r = _nodeToString(node.right);
      // Add parentheses to preserve order of operations in text
      if (node.left is BinaryOpNode &&
          _precedence(node.left as BinaryOpNode) < _precedence(node))
        l = "($l)";
      if (node.right is BinaryOpNode &&
          _precedence(node.right as BinaryOpNode) <= _precedence(node))
        r = "($r)";
      return "$l ${node.op} $r";
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
    if (node is BinaryOpNode)
      return _containsSqrt(node.left) || _containsSqrt(node.right);
    if (node is UnaryMinusNode) return _containsSqrt(node.child);
    return false;
  }

  /// Evaluates the AST dynamically. Used to find the exact real-number answer.
  static double _evalNode(MathNode node, String varName, double val) {
    if (node is NumberNode) return node.value;
    if (node is VariableNode) return val;
    if (node is UnaryMinusNode) return -_evalNode(node.child, varName, val);
    if (node is FunctionNode) {
      if (node.name == 'sqrt') {
        double argVal = _evalNode(node.arg, varName, val);
        if (argVal < 0) return double.nan; // Prevent sqrt of negative error
        return sqrt(argVal);
      }
    }
    if (node is BinaryOpNode) {
      double l = _evalNode(node.left, varName, val);
      double r = _evalNode(node.right, varName, val);
      if (l.isNaN || r.isNaN) return double.nan;

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
    return double.nan;
  }

  /// Approaches the limit from both the left and right to guarantee accuracy
  static double _calculateNumericalLimit(
      MathNode ast, String varName, double val) {
    double h = 0.0000001; // Very small delta
    double rightLimit = _evalNode(ast, varName, val + h);
    double leftLimit = _evalNode(ast, varName, val - h);

    // If limits from both sides agree, we found the hole in the graph!
    if (rightLimit.isFinite &&
        leftLimit.isFinite &&
        (rightLimit - leftLimit).abs() < 0.0001) {
      return rightLimit;
    }

    return double.nan; // True asymptote or divergence
  }
}
