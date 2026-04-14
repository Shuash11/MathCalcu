// lib/engine/differentiator.dart

import 'ast_nodes.dart';

/// Handles symbolic differentiation
class Differentiator {
  /// Differentiate an expression with respect to a variable
  ASTNode differentiate(ASTNode node, [String varName = 'x']) {
    return _simplifyDerivative(node.differentiate(varName));
  }
  
  /// Apply simplifications specific to derivatives
  ASTNode _simplifyDerivative(ASTNode node) {
    var simplified = node.simplify();
    
    // Additional simplifications for derivatives
    if (simplified is BinaryOpNode) {
      // 0 * anything = 0
      if (simplified.left.isZero() || simplified.right.isZero()) {
        return NumberNode(0);
      }
      // 1 * x = x
      if (simplified.left.isOne()) return simplified.right;
      if (simplified.right.isOne()) return simplified.left;
    }
    
    return simplified;
  }
  
  /// Get nth derivative
  ASTNode nthDerivative(ASTNode node, int n, [String varName = 'x']) {
    var result = node;
    for (var i = 0; i < n; i++) {
      result = differentiate(result, varName);
    }
    return result;
  }
}