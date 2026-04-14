import 'dart:math';

import 'ast_nodes.dart';

/// Provides algebraic simplification of expressions
class Simplifier {
  /// Simplify an expression repeatedly until stable
  ASTNode fullySimplify(ASTNode node, {int maxIterations = 10}) {
    var current = node;
    for (var i = 0; i < maxIterations; i++) {
      var simplified = current.simplify();
      if (simplified.toString() == current.toString()) break;
      current = simplified;
    }
    return current;
  }
  
  /// Expand a product: (a+b)(c+d) = ac + ad + bc + bd
  ASTNode expand(ASTNode node) {
    if (node is BinaryOpNode && node.operator == '*') {
      var leftTerms = node.left.getTerms();
      var rightTerms = node.right.getTerms();
      
      if (leftTerms.length > 1 || rightTerms.length > 1) {
        var resultTerms = <ASTNode>[];
        for (var left in leftTerms) {
          for (var right in rightTerms) {
            resultTerms.add(BinaryOpNode(left, '*', right).simplify());
          }
        }
        return _buildSum(resultTerms);
      }
    }
    
    // Handle (a+b)^n expansion for small n
    if (node is BinaryOpNode && node.operator == '^') {
      var expVal = node.right.tryEvaluate()?.toInt();
      if (expVal != null && expVal >= 0 && expVal <= 4) {
        return _expandPower(node.left, expVal);
      }
    }
    
    return node;
  }
  
  ASTNode _expandPower(ASTNode base, int exponent) {
    if (exponent == 0) return NumberNode(1);
    if (exponent == 1) return base;
    
    var result = base;
    for (var i = 1; i < exponent; i++) {
      result = expand(BinaryOpNode(result, '*', base));
    }
    return result;
  }
  
  ASTNode _buildSum(List<ASTNode> terms) {
    if (terms.isEmpty) return NumberNode(0);
    var result = terms.first;
    for (var i = 1; i < terms.length; i++) {
      result = BinaryOpNode(result, '+', terms[i]);
    }
    return result;
  }
  
  /// Try to factor a simple polynomial
  /// Returns null if factoring not possible or too complex
  ASTNode? tryFactor(ASTNode node, [String varName = 'x']) {
    // Handle a² - b² = (a-b)(a+b)
    var diffOfSquares = _tryFactorDifferenceOfSquares(node, varName);
    if (diffOfSquares != null) return diffOfSquares;
    
    // Handle polynomial like ax² + bx + c
    var quadratic = _tryFactorQuadratic(node, varName);
    if (quadratic != null) return quadratic;
    
    // Handle common factor extraction
    var commonFactor = _tryExtractCommonFactor(node, varName);
    if (commonFactor != null) return commonFactor;
    
    return null;
  }
  
  ASTNode? _tryFactorDifferenceOfSquares(ASTNode node, String varName) {
    if (node is! BinaryOpNode || node.operator != '-') return null;
    
    // Check if both sides are perfect squares
    var leftSquare = _tryIdentifySquare(node.left);
    var rightSquare = _tryIdentifySquare(node.right);
    
    if (leftSquare != null && rightSquare != null) {
      return BinaryOpNode(
        BinaryOpNode(leftSquare, '-', rightSquare),
        '*',
        BinaryOpNode(leftSquare, '+', rightSquare)
      );
    }
    
    return null;
  }
  
  ASTNode? _tryIdentifySquare(ASTNode node) {
    // x²
    if (node is BinaryOpNode && node.operator == '^' && 
        node.right.isOne() && node.left is VariableNode) {
      return node.left;
    }
    // n²
    if (node is BinaryOpNode && node.operator == '^') {
      var exp = node.right.tryEvaluate();
      if (exp == 2) return node.left;
    }
    // (√x)²
    if (node is FunctionNode && node.name == 'sqrt') {
      return node.argument;
    }
    return null;
  }
  
  ASTNode? _tryFactorQuadratic(ASTNode node, String varName) {
    // Get coefficients: ax² + bx + c
    var coeffs = _getQuadraticCoefficients(node, varName);
    if (coeffs == null) return null;
    
    var a = coeffs[0], b = coeffs[1], c = coeffs[2];
    
    // Skip if too complex
    if (a == 0) return null;
    
    // Try factoring: find p, q such that pq = ac and p + q = b
    var ac = a * c;
    if (ac == 0) return null;
    
    // Find factors of ac that sum to b
    var factors = _findFactorPairs(ac);
    for (var (p, q) in factors) {
      if (p + q == b) {
        // Return (ax + p)(x + q/a) or similar
        // This is simplified - full implementation would need more work
        return BinaryOpNode(
          BinaryOpNode(
            NumberNode(a),
            '*',
            VariableNode(varName)
          ),
          '+',
          NumberNode(p)
        );
      }
    }
    
    return null;
  }
  
  List<double>? _getQuadraticCoefficients(ASTNode node, String varName) {
    var terms = node.getTerms();
    var coeffs = [0.0, 0.0, 0.0]; // a, b, c for ax² + bx + c
    
    for (var term in terms) {
      var degree = term.polynomialDegree(varName);
      var coeff = _getTermCoefficient(term, varName);
      
      if (degree == null || coeff == null) return null;
      
      if (degree == 2) coeffs[0] += coeff;
      else if (degree == 1) coeffs[1] += coeff;
      else if (degree == 0) coeffs[2] += coeff;
      else return null;
    }
    
    return coeffs;
  }
  
  double? _getTermCoefficient(ASTNode term, String varName) {
    if (term is NumberNode) return term.value;
    if (term is VariableNode && term.name == varName) return 1;
    if (term is UnaryMinusNode) {
      var inner = _getTermCoefficient(term.operand, varName);
      return inner != null ? -inner : null;
    }
    if (term is BinaryOpNode && term.operator == '*') {
      var numPart = term.left.tryEvaluate();
      if (numPart != null) {
        var varCoeff = _getTermCoefficient(term.right, varName);
        return varCoeff != null ? numPart * varCoeff : null;
      }
    }
    if (term is BinaryOpNode && term.operator == '^') {
      if (term.left is VariableNode && (term.left as VariableNode).name == varName) {
        return 1;
      }
    }
    return null;
  }
  
  List<(double, double)> _findFactorPairs(double product) {
    var pairs = <(double, double)>[];
    var limit = sqrt(product.abs()).ceil();
    
    for (var i = 1; i <= limit; i++) {
      if (product % i == 0) {
        pairs.add((i.toDouble(), product / i));
        pairs.add((-i.toDouble(), -product / i));
      }
    }
    
    return pairs;
  }
  
  ASTNode? _tryExtractCommonFactor(ASTNode node, String varName) {
    var terms = node.getTerms();
    if (terms.length < 2) return null;
    
    // Find common numeric factor
    var coeffs = terms.map((t) => _getTermCoefficient(t, varName)).toList();
    if (coeffs.any((c) => c == null)) return null;
    
    var gcdVal = coeffs.cast<double>().reduce(_gcd);
    if (gcdVal <= 1) return null;
    
    // Extract the GCD
    var insideTerms = terms.map((t) {
      var coeff = _getTermCoefficient(t, varName)!;
      if (coeff == gcdVal) {
        // Remove the coefficient
        return _removeCoefficient(t, varName);
      }
      return BinaryOpNode(NumberNode(coeff / gcdVal), '*', _removeCoefficient(t, varName)).simplify();
    }).toList();
    
    var inside = _buildSum(insideTerms);
    return BinaryOpNode(NumberNode(gcdVal), '*', inside);
  }
  
  ASTNode _removeCoefficient(ASTNode term, String varName) {
    if (term is VariableNode) return term;
    if (term is BinaryOpNode && term.operator == '*' && term.left.tryEvaluate() != null) {
      return term.right;
    }
    if (term is BinaryOpNode && term.operator == '^') {
      return term;
    }
    return term;
  }
  
  double _gcd(double a, double b) {
    a = a.abs();
    b = b.abs();
    while (b > 0.0001) {
      var t = b;
      b = a % b;
      a = t;
    }
    return a;
  }
  
  /// Rationalize by multiplying by conjugate
  /// Returns null if not applicable
  ASTNode? rationalize(ASTNode node, [String varName = 'x']) {
    // Look for √(a) - √(b) or √(a) + √(b) pattern
    if (node is! BinaryOpNode || node.operator != '/') return null;
    
    // Check denominator for sum/difference of square roots
    var denom = node.right;
    if (denom is BinaryOpNode && 
        (denom.operator == '+' || denom.operator == '-')) {
      var leftIsSqrt = denom.left is FunctionNode && (denom.left as FunctionNode).name == 'sqrt';
      var rightIsSqrt = denom.right is FunctionNode && (denom.right as FunctionNode).name == 'sqrt';
      
      if (leftIsSqrt || rightIsSqrt) {
        // Create conjugate
        var conjugateOp = denom.operator == '+' ? '-' : '+';
        var conjugate = BinaryOpNode(denom.left, conjugateOp, denom.right);
        
        // Multiply numerator and denominator by conjugate
        var newNumerator = BinaryOpNode(node.left, '*', conjugate);
        var newDenominator = BinaryOpNode(denom, '*', conjugate);
        
        // Simplify denominator (should become a - b or b - a)
        return BinaryOpNode(newNumerator, '/', newDenominator);
      }
    }
    
    return null;
  }
}