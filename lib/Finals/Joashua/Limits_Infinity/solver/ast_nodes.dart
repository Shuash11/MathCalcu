
// lib/models/ast_nodes.dart

import 'dart:math';

/// Base class for all AST nodes in mathematical expressions
abstract class ASTNode {
  /// Simplify the expression
  ASTNode simplify();
  
  /// Get string representation
  @override
  String toString();
  
  /// Check if node contains a variable
  bool containsVariable([String varName = 'x']);
  
  /// Substitute a variable with another expression
  ASTNode substitute(String varName, ASTNode value);
  
  /// Symbolic differentiation with respect to variable
  ASTNode differentiate([String varName = 'x']);
  
  /// Try to evaluate to a numeric value (returns null if not possible)
  double? tryEvaluate();
  
  /// Get the degree for polynomials (null if not a polynomial)
  int? polynomialDegree([String varName = 'x']);
  
  /// Check if this is zero
  bool isZero();
  
  /// Check if this is one
  bool isOne();
  
  /// Check if this represents infinity
  bool isInfinity();
  
  /// Check if this is negative infinity
  bool isNegativeInfinity();
  
  /// Check if this is a constant (no variables)
  bool isConstant();
  
  /// Deep copy
  ASTNode copy();
  
  /// Get all terms for addition
  List<ASTNode> getTerms();
  
  /// Get all factors for multiplication
  List<ASTNode> getFactors();
}

/// Represents a numeric constant
class NumberNode extends ASTNode {
  final double value;
  
  NumberNode(this.value);
  
  @override
  ASTNode simplify() => this;
  
  @override
  String toString() {
    if (value == value.truncateToDouble() && value.abs() < 1e10) {
      return value.toInt().toString();
    }
    if (value == double.infinity) return '∞';
    if (value == double.negativeInfinity) return '-∞';
    return value.toStringAsFixed(4).replaceAll(RegExp(r'\.?0+$'), '');
  }
  
  @override
  bool containsVariable([String varName = 'x']) => false;
  
  @override
  ASTNode substitute(String varName, ASTNode value) => this;
  
  @override
  ASTNode differentiate([String varName = 'x']) => NumberNode(0);
  
  @override
  double? tryEvaluate() => value;
  
  @override
  int? polynomialDegree([String varName = 'x']) => 0;
  
  @override
  bool isZero() => value == 0;
  
  @override
  bool isOne() => value == 1;
  
  @override
  bool isInfinity() => value == double.infinity;
  
  @override
  bool isNegativeInfinity() => value == double.negativeInfinity;
  
  @override
  bool isConstant() => true;
  
  @override
  ASTNode copy() => NumberNode(value);
  
  @override
  List<ASTNode> getTerms() => [this];
  
  @override
  List<ASTNode> getFactors() => [this];
  
  @override
  bool operator ==(Object other) =>
      other is NumberNode && value == other.value;
  
  @override
  int get hashCode => value.hashCode;
}

/// Represents a variable
class VariableNode extends ASTNode {
  final String name;
  
  VariableNode(this.name);
  
  @override
  ASTNode simplify() => this;
  
  @override
  String toString() => name;
  
  @override
  bool containsVariable([String varName = 'x']) => name == varName;
  
  @override
  ASTNode substitute(String varName, ASTNode value) =>
      name == varName ? value.copy() : this;
  
  @override
  ASTNode differentiate([String varName = 'x']) =>
      name == varName ? NumberNode(1) : NumberNode(0);
  
  @override
  double? tryEvaluate() => null;
  
  @override
  int? polynomialDegree([String varName = 'x']) => name == varName ? 1 : null;
  
  @override
  bool isZero() => false;
  
  @override
  bool isOne() => false;
  
  @override
  bool isInfinity() => false;
  
  @override
  bool isNegativeInfinity() => false;
  
  @override
  bool isConstant() => false;
  
  @override
  ASTNode copy() => VariableNode(name);
  
  @override
  List<ASTNode> getTerms() => [this];
  
  @override
  List<ASTNode> getFactors() => [this];
  
  @override
  bool operator ==(Object other) =>
      other is VariableNode && name == other.name;
  
  @override
  int get hashCode => name.hashCode;
}

/// Represents infinity (∞)
class InfinityNode extends ASTNode {
  final bool negative;
  
  InfinityNode([this.negative = false]);
  
  @override
  ASTNode simplify() => this;
  
  @override
  String toString() => negative ? '-∞' : '∞';
  
  @override
  bool containsVariable([String varName = 'x']) => false;
  
  @override
  ASTNode substitute(String varName, ASTNode value) => this;
  
  @override
  ASTNode differentiate([String varName = 'x']) => NumberNode(0);
  
  @override
  double? tryEvaluate() => negative ? double.negativeInfinity : double.infinity;
  
  @override
  int? polynomialDegree([String varName = 'x']) => null;
  
  @override
  bool isZero() => false;
  
  @override
  bool isOne() => false;
  
  @override
  bool isInfinity() => !negative;
  
  @override
  bool isNegativeInfinity() => negative;
  
  @override
  bool isConstant() => true;
  
  @override
  ASTNode copy() => InfinityNode(negative);
  
  @override
  List<ASTNode> getTerms() => [this];
  
  @override
  List<ASTNode> getFactors() => [this];
  
  @override
  bool operator ==(Object other) =>
      other is InfinityNode && negative == other.negative;
  
  @override
  int get hashCode => negative.hashCode;
}

/// Represents a binary operation (+, -, *, /, ^)
class BinaryOpNode extends ASTNode {
  final ASTNode left;
  final String operator;
  final ASTNode right;
  
  BinaryOpNode(this.left, this.operator, this.right);
  
  @override
  ASTNode simplify() {
    var simpLeft = left.simplify();
    var simpRight = right.simplify();
    
    // Handle infinity arithmetic
    if (simpLeft.isInfinity() || simpLeft.isNegativeInfinity() ||
        simpRight.isInfinity() || simpRight.isNegativeInfinity()) {
      return _simplifyInfinity(simpLeft, operator, simpRight);
    }
    
    switch (operator) {
      case '+':
        return _simplifyAddition(simpLeft, simpRight);
      case '-':
        return _simplifySubtraction(simpLeft, simpRight);
      case '*':
        return _simplifyMultiplication(simpLeft, simpRight);
      case '/':
        return _simplifyDivision(simpLeft, simpRight);
      case '^':
        return _simplifyPower(simpLeft, simpRight);
      default:
        return BinaryOpNode(simpLeft, operator, simpRight);
    }
  }
  
  ASTNode _simplifyInfinity(ASTNode left, String op, ASTNode right) {
    bool leftPosInf = left.isInfinity();
    bool leftNegInf = left.isNegativeInfinity();
    bool rightPosInf = right.isInfinity();
    bool rightNegInf = right.isNegativeInfinity();
    
    switch (op) {
      case '+':
        if ((leftPosInf && rightPosInf) || (leftNegInf && rightNegInf)) {
          return left;
        }
        if ((leftPosInf && rightNegInf) || (leftNegInf && rightPosInf)) {
          // Indeterminate form
          return BinaryOpNode(left, op, right);
        }
        if (leftPosInf || leftNegInf) return left;
        return right;
      case '-':
        if ((leftPosInf && rightPosInf) || (leftNegInf && rightNegInf)) {
          return BinaryOpNode(left, op, right); // Indeterminate
        }
        if (leftPosInf) return InfinityNode(false);
        if (leftNegInf) return InfinityNode(true);
        if (rightPosInf) return InfinityNode(true);
        return InfinityNode(false);
      case '*':
        double? rightVal = right.tryEvaluate();
        if (rightVal != null) {
          if (rightVal > 0) return left;
          if (rightVal < 0) return left.isInfinity() ? InfinityNode(true) : InfinityNode(false);
          return BinaryOpNode(left, op, right); // 0 * ∞ indeterminate
        }
        double? leftVal = left.tryEvaluate();
        if (leftVal != null) {
          if (leftVal > 0) return right;
          if (leftVal < 0) return right.isInfinity() ? InfinityNode(true) : InfinityNode(false);
          return BinaryOpNode(left, op, right);
        }
        return BinaryOpNode(left, op, right);
      case '/':
        if (leftPosInf || leftNegInf) {
          double? rightVal = right.tryEvaluate();
          if (rightVal != null && rightVal != 0) {
            if (rightVal > 0) return left;
            return left.isInfinity() ? InfinityNode(true) : InfinityNode(false);
          }
        }
        if (rightPosInf || rightNegInf) return NumberNode(0);
        return BinaryOpNode(left, op, right);
      case '^':
        if (leftPosInf) {
          double? rightVal = right.tryEvaluate();
          if (rightVal != null) {
            if (rightVal > 0) return InfinityNode(false);
            if (rightVal < 0) return NumberNode(0);
            return InfinityNode(false); // ∞^0 is often treated as 1 or indeterminate
          }
        }
        return BinaryOpNode(left, op, right);
      default:
        return BinaryOpNode(left, op, right);
    }
  }
  
  ASTNode _simplifyAddition(ASTNode left, ASTNode right) {
    // 0 + x = x
    if (left.isZero()) return right;
    if (right.isZero()) return left;
    
    // Numeric addition
    var leftVal = left.tryEvaluate();
    var rightVal = right.tryEvaluate();
    if (leftVal != null && rightVal != null) {
      return NumberNode(leftVal + rightVal);
    }
    
    // Combine like terms: ax + bx = (a+b)x
    if (left is VariableNode && right is VariableNode && left.name == right.name) {
      return BinaryOpNode(NumberNode(2), '*', left);
    }
    
    // Combine: n*x + m*x = (n+m)*x
    if (_isCoeffTimesVar(left) && _isCoeffTimesVar(right)) {
      var leftCoeff = _getCoefficient(left);
      var rightCoeff = _getCoefficient(right);
      var varNode = _getVariable(left);
      if (varNode != null && _getVariable(right) != null &&
          varNode.toString() == _getVariable(right).toString()) {
        var newCoeff = (leftCoeff ?? 1) + (rightCoeff ?? 1);
        if (newCoeff == 1) return varNode;
        if (newCoeff == 0) return NumberNode(0);
        return BinaryOpNode(NumberNode(newCoeff), '*', varNode);
      }
    }
    
    // Collect terms and sort
    var terms = <ASTNode>[];
    terms.addAll(left.getTerms());
    terms.addAll(right.getTerms());
    
    if (terms.length == 1) return terms.first;
    return _buildSum(terms);
  }
  
  ASTNode _simplifySubtraction(ASTNode left, ASTNode right) {
    if (left.isZero()) return BinaryOpNode(NumberNode(-1), '*', right).simplify();
    if (right.isZero()) return left;
    
    return BinaryOpNode(left, '+', BinaryOpNode(NumberNode(-1), '*', right)).simplify();
  }
  
  ASTNode _simplifyMultiplication(ASTNode left, ASTNode right) {
    // 0 * x = 0, 1 * x = x
    if (left.isZero() || right.isZero()) return NumberNode(0);
    if (left.isOne()) return right;
    if (right.isOne()) return left;
    if ((left is NumberNode && left.value == -1)) return BinaryOpNode(NumberNode(0), '-', right).simplify();
    if ((right is NumberNode && right.value == -1)) return BinaryOpNode(NumberNode(0), '-', left).simplify();
    
    // Numeric multiplication
    var leftVal = left.tryEvaluate();
    var rightVal = right.tryEvaluate();
    if (leftVal != null && rightVal != null) {
      return NumberNode(leftVal * rightVal);
    }
    
    // Distribute numbers: n * (a + b) = n*a + n*b
    if (leftVal != null && right is BinaryOpNode && right.operator == '+') {
      return BinaryOpNode(
        BinaryOpNode(left, '*', right.left).simplify(),
        '+',
        BinaryOpNode(left, '*', right.right).simplify()
      ).simplify();
    }
    if (rightVal != null && left is BinaryOpNode && left.operator == '+') {
      return BinaryOpNode(
        BinaryOpNode(left.left, '*', right).simplify(),
        '+',
        BinaryOpNode(left.right, '*', right).simplify()
      ).simplify();
    }
    
    // x * x = x^2
    if (left.toString() == right.toString() && left is VariableNode) {
      return BinaryOpNode(left, '^', NumberNode(2));
    }
    
    // Collect factors
    var factors = <ASTNode>[];
    factors.addAll(left.getFactors());
    factors.addAll(right.getFactors());
    
    return _buildProduct(factors);
  }
  
  ASTNode _simplifyDivision(ASTNode left, ASTNode right) {
    // 0/x = 0
    if (left.isZero() && !right.isZero()) return NumberNode(0);
    // x/1 = x
    if (right.isOne()) return left;
    // x/x = 1
    if (left.toString() == right.toString()) return NumberNode(1);
    
    // Numeric division
    var leftVal = left.tryEvaluate();
    var rightVal = right.tryEvaluate();
    if (leftVal != null && rightVal != null) {
      if (rightVal == 0) return BinaryOpNode(left, '/', right); // Undefined
      return NumberNode(leftVal / rightVal);
    }
    
    // (a*x^n)/(b*x^m) = (a/b)*x^(n-m)
    if (_isPowerOfVar(left) && _isPowerOfVar(right)) {
      var leftCoeff = _getCoefficient(left) ?? 1;
      var rightCoeff = _getCoefficient(right) ?? 1;
      var leftExp = _getExponent(left) ?? 1;
      var rightExp = _getExponent(right) ?? 1;
      var leftVar = _getBaseVariable(left);
      var rightVar = _getBaseVariable(right);
      
      if (leftVar != null && rightVar != null && leftVar == rightVar) {
        var newCoeff = leftCoeff / rightCoeff;
        var newExp = leftExp - rightExp;
        
        ASTNode result;
        if (newExp == 0) {
          result = NumberNode(newCoeff);
        } else if (newExp == 1) {
          result = BinaryOpNode(NumberNode(newCoeff), '*', VariableNode(leftVar));
        } else {
          result = BinaryOpNode(
            NumberNode(newCoeff),
            '*',
            BinaryOpNode(VariableNode(leftVar), '^', NumberNode(newExp))
          );
        }
        return result.simplify();
      }
    }
    
    return BinaryOpNode(left, '/', right);
  }
  
  ASTNode _simplifyPower(ASTNode left, ASTNode right) {
    // x^0 = 1, x^1 = x, 0^x = 0 (for x > 0), 1^x = 1
    if (right.isZero()) return NumberNode(1);
    if (right.isOne()) return left;
    if (left.isZero()) return NumberNode(0);
    if (left.isOne()) return NumberNode(1);
    
    // Numeric power
    var leftVal = left.tryEvaluate();
    var rightVal = right.tryEvaluate();
    if (leftVal != null && rightVal != null) {
      return NumberNode(pow(leftVal, rightVal).toDouble());
    }
    
    // (x^n)^m = x^(n*m)
    if (left is BinaryOpNode && left.operator == '^') {
      var expVal = right.tryEvaluate();
      var leftExpVal = left.right.tryEvaluate();
      if (expVal != null && leftExpVal != null) {
        return BinaryOpNode(left.left, '^', NumberNode(expVal * leftExpVal));
      }
    }
    
    return BinaryOpNode(left, '^', right);
  }
  
  bool _isCoeffTimesVar(ASTNode node) {
    if (node is VariableNode) return true;
    if (node is BinaryOpNode && node.operator == '*') {
      return node.left.tryEvaluate() != null && node.right.containsVariable();
    }
    return false;
  }
  
  double? _getCoefficient(ASTNode node) {
    if (node is VariableNode) return 1;
    if (node is BinaryOpNode && node.operator == '*') {
      return node.left.tryEvaluate();
    }
    return null;
  }
  
  VariableNode? _getVariable(ASTNode node) {
    if (node is VariableNode) return node;
    if (node is BinaryOpNode && node.operator == '*') {
      if (node.right is VariableNode) return node.right as VariableNode;
      if (node.right is BinaryOpNode && (node.right as BinaryOpNode).operator == '^') {
        return (node.right as BinaryOpNode).left as VariableNode?;
      }
    }
    return null;
  }
  
  bool _isPowerOfVar(ASTNode node) {
    if (node is VariableNode) return true;
    if (node is BinaryOpNode && node.operator == '*') {
      return node.left.tryEvaluate() != null && _isPowerOfVar(node.right);
    }
    if (node is BinaryOpNode && node.operator == '^') {
      return node.left is VariableNode && node.right.tryEvaluate() != null;
    }
    return false;
  }
  
  String? _getBaseVariable(ASTNode node) {
    if (node is VariableNode) return node.name;
    if (node is BinaryOpNode && node.operator == '*') {
      return _getBaseVariable(node.right);
    }
    if (node is BinaryOpNode && node.operator == '^' && node.left is VariableNode) {
      return (node.left as VariableNode).name;
    }
    return null;
  }
  
  double? _getExponent(ASTNode node) {
    if (node is VariableNode) return 1;
    if (node is BinaryOpNode && node.operator == '*') {
      return _getExponent(node.right);
    }
    if (node is BinaryOpNode && node.operator == '^') {
      return node.right.tryEvaluate();
    }
    return null;
  }
  
  ASTNode _buildSum(List<ASTNode> terms) {
    if (terms.isEmpty) return NumberNode(0);
    if (terms.length == 1) return terms.first;
    var result = terms.first;
    for (var i = 1; i < terms.length; i++) {
      result = BinaryOpNode(result, '+', terms[i]);
    }
    return result;
  }
  
  ASTNode _buildProduct(List<ASTNode> factors) {
    if (factors.isEmpty) return NumberNode(1);
    if (factors.length == 1) return factors.first;
    var result = factors.first;
    for (var i = 1; i < factors.length; i++) {
      result = BinaryOpNode(result, '*', factors[i]);
    }
    return result;
  }
  
  @override
  String toString() {
    String leftStr = _wrapInParens(left);
    String rightStr = _wrapInParens(right);
    return '$leftStr $operator $rightStr';
  }
  
  String _wrapInParens(ASTNode node) {
    if (node is BinaryOpNode) {
      int nodePrec = _precedence(node.operator);
      int myPrec = _precedence(operator);
      if (nodePrec < myPrec) {
        return '(${node.toString()})';
      }
      if (nodePrec == myPrec && operator == '-' && node.operator != '+') {
        return '(${node.toString()})';
      }
    }
    return node.toString();
  }
  
  int _precedence(String op) {
    switch (op) {
      case '+': case '-': return 1;
      case '*': case '/': return 2;
      case '^': return 3;
      default: return 0;
    }
  }
  
  @override
  bool containsVariable([String varName = 'x']) =>
      left.containsVariable(varName) || right.containsVariable(varName);
  
  @override
  ASTNode substitute(String varName, ASTNode value) =>
      BinaryOpNode(
        left.substitute(varName, value),
        operator,
        right.substitute(varName, value)
      );
  
  @override
  ASTNode differentiate([String varName = 'x']) {
    switch (operator) {
      case '+':
        return BinaryOpNode(
          left.differentiate(varName),
          '+',
          right.differentiate(varName)
        );
      case '-':
        return BinaryOpNode(
          left.differentiate(varName),
          '-',
          right.differentiate(varName)
        );
      case '*': // Product rule: (fg)' = f'g + fg'
        return BinaryOpNode(
          BinaryOpNode(
            left.differentiate(varName),
            '*',
            right
          ),
          '+',
          BinaryOpNode(
            left,
            '*',
            right.differentiate(varName)
          )
        );
      case '/': // Quotient rule: (f/g)' = (f'g - fg') / g²
        return BinaryOpNode(
          BinaryOpNode(
            BinaryOpNode(left.differentiate(varName), '*', right),
            '-',
            BinaryOpNode(left, '*', right.differentiate(varName))
          ),
          '/',
          BinaryOpNode(right, '^', NumberNode(2))
        );
      case '^':
        // Power rule with chain rule
        if (!right.containsVariable(varName)) {
          // x^n -> n*x^(n-1)*x'
          return BinaryOpNode(
            BinaryOpNode(
              right,
              '*',
              BinaryOpNode(left, '^', BinaryOpNode(right, '-', NumberNode(1)))
            ),
            '*',
            left.differentiate(varName)
          );
        } else if (!left.containsVariable(varName)) {
          // a^x -> a^x * ln(a) * x'
          return BinaryOpNode(
            BinaryOpNode(
              BinaryOpNode(left, '^', right),
              '*',
              FunctionNode('ln', left)
            ),
            '*',
            right.differentiate(varName)
          );
        } else {
          // f^g -> f^g * (g'*ln(f) + g*f'/f)
          return BinaryOpNode(
            BinaryOpNode(left, '^', right),
            '*',
            BinaryOpNode(
              BinaryOpNode(
                right.differentiate(varName),
                '*',
                FunctionNode('ln', left)
              ),
              '+',
              BinaryOpNode(
                right,
                '*',
                BinaryOpNode(left.differentiate(varName), '/', left)
              )
            )
          );
        }
      default:
        return NumberNode(0);
    }
  }
  
  @override
  double? tryEvaluate() {
    var leftVal = left.tryEvaluate();
    var rightVal = right.tryEvaluate();
    if (leftVal == null || rightVal == null) return null;
    
    switch (operator) {
      case '+': return leftVal + rightVal;
      case '-': return leftVal - rightVal;
      case '*': return leftVal * rightVal;
      case '/':
        if (rightVal == 0) return null;
        return leftVal / rightVal;
      case '^': return pow(leftVal, rightVal).toDouble();
      default: return null;
    }
  }
  
  @override
  int? polynomialDegree([String varName = 'x']) {
    if (!containsVariable(varName)) return 0;
    
    switch (operator) {
      case '+': case '-':
        var leftDeg = left.polynomialDegree(varName);
        var rightDeg = right.polynomialDegree(varName);
        if (leftDeg == null || rightDeg == null) return null;
        return leftDeg > rightDeg ? leftDeg : rightDeg;
      case '*':
        var leftDeg = left.polynomialDegree(varName);
        var rightDeg = right.polynomialDegree(varName);
        if (leftDeg == null || rightDeg == null) return null;
        return leftDeg + rightDeg;
      case '/':
        var leftDeg = left.polynomialDegree(varName);
        var rightDeg = right.polynomialDegree(varName);
        if (leftDeg == null || rightDeg == null) return null;
        return leftDeg - rightDeg;
      case '^':
        final l = left;
        if (l is VariableNode && l.name == varName) {
          return right.tryEvaluate()?.toInt();
        }
        return null;
      default:
        return null;
    }
  }
  
  @override
  bool isZero() => false;
  
  @override
  bool isOne() => false;
  
  @override
  bool isInfinity() => false;
  
  @override
  bool isNegativeInfinity() => false;
  
  @override
  bool isConstant() => left.isConstant() && right.isConstant();
  
  @override
  ASTNode copy() => BinaryOpNode(left.copy(), operator, right.copy());
  
  @override
  List<ASTNode> getTerms() {
    if (operator == '+') {
      return [...left.getTerms(), ...right.getTerms()];
    }
    return [this];
  }
  
  @override
  List<ASTNode> getFactors() {
    if (operator == '*') {
      return [...left.getFactors(), ...right.getFactors()];
    }
    return [this];
  }
  
  @override
  bool operator ==(Object other) =>
      other is BinaryOpNode &&
      left == other.left &&
      operator == other.operator &&
      right == other.right;
  
  @override
  int get hashCode => Object.hash(left, operator, right);
}

/// Represents a mathematical function (sin, cos, ln, etc.)
class FunctionNode extends ASTNode {
  final String name;
  final ASTNode argument;
  
  FunctionNode(this.name, this.argument);
  
  
  @override
  ASTNode simplify() {
    var simpArg = argument.simplify();
    
    // Try numeric evaluation
    var argVal = simpArg.tryEvaluate();
    if (argVal != null) {
      var result = _evaluateFunction(name, argVal);
      if (result != null && result.isFinite) {
        return NumberNode(result);
      }
    }
    
    // sqrt(x^2) = |x|
    if (name == 'sqrt' && simpArg is BinaryOpNode && 
        simpArg.operator == '^' && simpArg.right.isOne()) {
      return simpArg.left;
    }
    
    // ln(e^x) = x
    if (name == 'ln' && simpArg is FunctionNode && simpArg.name == 'exp') {
      return simpArg.argument;
    }
    
    // exp(ln(x)) = x
    if (name == 'exp' && simpArg is FunctionNode && simpArg.name == 'ln') {
      return simpArg.argument;
    }
    
    return FunctionNode(name, simpArg);
  }
  
  double? _evaluateFunction(String name, double arg) {
    try {
      switch (name) {
        case 'sin': return sin(arg);
        case 'cos': return cos(arg);
        case 'tan': return tan(arg);
        case 'cot': return 1 / tan(arg);
        case 'sec': return 1 / cos(arg);
        case 'csc': return 1 / sin(arg);
        case 'arcsin': return asin(arg);
        case 'arccos': return acos(arg);
        case 'arctan': return atan(arg);
        case 'sinh': return (exp(arg) - exp(-arg)) / 2;
        case 'cosh': return (exp(arg) + exp(-arg)) / 2;
        case 'tanh': 
          var e2x = exp(2 * arg);
          return (e2x - 1) / (e2x + 1);
        case 'ln': case 'log': return log(arg);
        case 'log10': return log(arg) / ln10;
        case 'log2': return log(arg) / ln2;
        case 'sqrt': return sqrt(arg);
        case 'cbrt': 
          if (arg == 0) return 0;
          return arg.sign * pow(arg.abs(), 1 / 3).toDouble();
        case 'abs': return arg.abs();
        case 'exp': return exp(arg);
        case 'ceil': return arg.ceilToDouble();
        case 'floor': return arg.floorToDouble();
        default: return null;
      }
    } catch (e) {
      return null;
    }
  }
  
  @override
  String toString() {
    if (name == 'sqrt') return '√(${argument})';
    if (name == 'abs') return '|${argument}|';
    return '$name(${argument})';
  }
  
  @override
  bool containsVariable([String varName = 'x']) =>
      argument.containsVariable(varName);
  
  @override
  ASTNode substitute(String varName, ASTNode value) =>
      FunctionNode(name, argument.substitute(varName, value));
  
  @override
  ASTNode differentiate([String varName = 'x']) {
    var inner = argument;
    var innerDeriv = inner.differentiate(varName);
    
    // f(g(x))' = f'(g(x)) * g'(x)
    ASTNode outerDeriv;
    
    switch (name) {
      case 'sin':
        outerDeriv = FunctionNode('cos', inner);
        break;
      case 'cos':
        outerDeriv = BinaryOpNode(
          NumberNode(0),
          '-',
          FunctionNode('sin', inner)
        );
        break;
      case 'tan':
        outerDeriv = BinaryOpNode(
          NumberNode(1),
          '/',
          BinaryOpNode(
            FunctionNode('cos', inner),
            '^',
            NumberNode(2)
          )
        );
        break;
      case 'ln': case 'log':
        outerDeriv = BinaryOpNode(NumberNode(1), '/', inner);
        break;
      case 'log10':
        outerDeriv = BinaryOpNode(
          NumberNode(1),
          '/',
          BinaryOpNode(
            inner,
            '*',
            FunctionNode('ln', NumberNode(10))
          )
        );
        break;
      case 'log2':
        outerDeriv = BinaryOpNode(
          NumberNode(1),
          '/',
          BinaryOpNode(
            inner,
            '*',
            FunctionNode('ln', NumberNode(2))
          )
        );
        break;
      case 'sqrt':
        outerDeriv = BinaryOpNode(
          NumberNode(1),
          '/',
          BinaryOpNode(
            NumberNode(2),
            '*',
            FunctionNode('sqrt', inner)
          )
        );
        break;
      case 'exp':
        outerDeriv = FunctionNode('exp', inner);
        break;
      case 'arcsin':
        outerDeriv = BinaryOpNode(
          NumberNode(1),
          '/',
          FunctionNode('sqrt', 
            BinaryOpNode(NumberNode(1), '-', BinaryOpNode(inner, '^', NumberNode(2)))
          )
        );
        break;
      case 'arccos':
        outerDeriv = BinaryOpNode(
          NumberNode(-1),
          '/',
          FunctionNode('sqrt', 
            BinaryOpNode(NumberNode(1), '-', BinaryOpNode(inner, '^', NumberNode(2)))
          )
        );
        break;
      case 'arctan':
        outerDeriv = BinaryOpNode(
          NumberNode(1),
          '/',
          BinaryOpNode(NumberNode(1), '+', BinaryOpNode(inner, '^', NumberNode(2)))
        );
        break;
      case 'sinh':
        outerDeriv = FunctionNode('cosh', inner);
        break;
      case 'cosh':
        outerDeriv = FunctionNode('sinh', inner);
        break;
      case 'tanh':
        outerDeriv = BinaryOpNode(
          NumberNode(1),
          '/',
          BinaryOpNode(
            FunctionNode('cosh', inner),
            '^',
            NumberNode(2)
          )
        );
        break;
      default:
        return BinaryOpNode(NumberNode(0), '-', NumberNode(0)); // Unknown
    }
    
    return BinaryOpNode(outerDeriv, '*', innerDeriv).simplify();
  }
  
  @override
  double? tryEvaluate() {
    var argVal = argument.tryEvaluate();
    if (argVal == null) return null;
    return _evaluateFunction(name, argVal);
  }
  
  @override
  int? polynomialDegree([String varName = 'x']) => null;
  
  @override
  bool isZero() => false;
  @override
  bool isOne() => false;
  @override
  bool isInfinity() => false;
  @override
  bool isNegativeInfinity() => false;
  @override
  bool isConstant() => argument.isConstant();
  
  @override
  ASTNode copy() => FunctionNode(name, argument.copy());
  
  @override
  List<ASTNode> getTerms() => [this];
  
  @override
  List<ASTNode> getFactors() => [this];
  
  @override
  bool operator ==(Object other) =>
      other is FunctionNode && name == other.name && argument == other.argument;
  
  @override
  int get hashCode => Object.hash(name, argument);
}

/// Represents a unary negation
class UnaryMinusNode extends ASTNode {
  final ASTNode operand;
  
  UnaryMinusNode(this.operand);
  
  @override
  ASTNode simplify() {
    var simpOperand = operand.simplify();
    if (simpOperand is NumberNode) {
      return NumberNode(-simpOperand.value);
    }
    if (simpOperand is UnaryMinusNode) {
      return simpOperand.operand;
    }
    if (simpOperand is InfinityNode) {
      return InfinityNode(!simpOperand.negative);
    }
    return UnaryMinusNode(simpOperand);
  }
  
  @override
  String toString() {
    if (operand is BinaryOpNode) return '-(${operand})';
    return '-$operand';
  }
  
  @override
  bool containsVariable([String varName = 'x']) =>
      operand.containsVariable(varName);
  
  @override
  ASTNode substitute(String varName, ASTNode value) =>
      UnaryMinusNode(operand.substitute(varName, value));
  
  @override
  ASTNode differentiate([String varName = 'x']) =>
      UnaryMinusNode(operand.differentiate(varName));
  
  @override
  double? tryEvaluate() {
    var val = operand.tryEvaluate();
    return val != null ? -val : null;
  }
  
  @override
  int? polynomialDegree([String varName = 'x']) =>
      operand.polynomialDegree(varName);
  
  @override
  bool isZero() => operand.isZero();
  @override
  bool isOne() => false;
  @override
  bool isInfinity() => operand.isNegativeInfinity();
  @override
  bool isNegativeInfinity() => operand.isInfinity();
  @override
  bool isConstant() => operand.isConstant();
  
  @override
  ASTNode copy() => UnaryMinusNode(operand.copy());
  
  @override
  List<ASTNode> getTerms() => [this];
  
  @override
  List<ASTNode> getFactors() => [this];
  
  @override
  bool operator ==(Object other) =>
      other is UnaryMinusNode && operand == other.operand;
  
  @override
  int get hashCode => operand.hashCode;
}