// models.dart
// All data structures: token types, AST expression nodes,
// ProblemType enum, and the SlopeResult data class.
// Nothing here computes — it only describes.

// ==================== TOKENS ====================

enum TokenType {
  number,
  ident,
  plus,
  minus,
  star,
  slash,
  caret,
  lparen,
  rparen,
  equals,
  comma,
  eof,
}

class Token {
  final TokenType type;
  final String value;
  const Token(this.type, this.value);

  @override
  String toString() => 'Token($type, "$value")';
}

// ==================== AST NODES ====================

abstract class Expr {
  const Expr();
  String toMathString();
  Expr clone();

  @override
  String toString() => toMathString();
}

/// Numeric constant: 3, -2.5, 0, 100
class Num extends Expr {
  final double value;
  const Num(this.value);

  @override
  String toMathString() {
    if (value == value.truncateToDouble() && value.abs() < 1e15) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(6).replaceAll(RegExp(r'\.?0+$'), '');
  }

  @override
  Expr clone() => Num(value);

  bool get isZero => value == 0;
  bool get isOne => value == 1;
  bool get isMinusOne => value == -1;
  bool get isInteger => value == value.truncateToDouble();
}

/// Variable: x, y, t, theta, etc.
class Var extends Expr {
  final String name;
  const Var(this.name);

  @override
  String toMathString() => name;

  @override
  Expr clone() => Var(name);
}

/// Named constant: e, pi
class Const extends Expr {
  final String name;
  final double numericValue;
  const Const(this.name, this.numericValue);

  @override
  String toMathString() => name;

  @override
  Expr clone() => Const(name, numericValue);
}

/// Binary operation: +, -, *, /
class BinOp extends Expr {
  final Expr left;
  final String op;
  final Expr right;
  const BinOp(this.left, this.op, this.right);

  @override
  String toMathString() {
    String l = left.toMathString();
    String r = right.toMathString();
    if (left is BinOp && _prec((left as BinOp).op) < _prec(op)) {
      l = '($l)';
    }
    if (left is UnaryNeg && _prec('*') <= _prec(op)) {
      l = '($l)';
    }
    if (right is BinOp) {
      final rp = _prec((right as BinOp).op);
      if (rp < _prec(op) || (rp == _prec(op) && (op == '-' || op == '/'))) {
        r = '($r)';
      }
    }
    if (right is UnaryNeg && (op == '+' || op == '-')) {
      r = '($r)';
    }
    return '$l $op $r';
  }

  static int prec(String op) => const {'+': 1, '-': 1, '*': 2, '/': 2}[op] ?? 0;
  int _prec(String op) => prec(op);

  @override
  Expr clone() => BinOp(left.clone(), op, right.clone());
}

/// Power: base^exponent
class Pow extends Expr {
  final Expr base;
  final Expr exponent;
  const Pow(this.base, this.exponent);

  @override
  String toMathString() {
    String b = base.toMathString();
    String e = exponent.toMathString();
    if (base is BinOp || base is UnaryNeg) b = '($b)';
    if (exponent is BinOp || exponent is UnaryNeg) e = '($e)';
    return '$b^$e';
  }

  @override
  Expr clone() => Pow(base.clone(), exponent.clone());
}

/// Unary negation: -expr
class UnaryNeg extends Expr {
  final Expr operand;
  const UnaryNeg(this.operand);

  @override
  String toMathString() {
    if (operand is BinOp || operand is Pow)
      return '-(${operand.toMathString()})';
    return '-${operand.toMathString()}';
  }

  @override
  Expr clone() => UnaryNeg(operand.clone());
}

/// Function call: sin(x), ln(x), sqrt(x), etc.
class Func extends Expr {
  final String name;
  final Expr arg;
  const Func(this.name, this.arg);

  @override
  String toMathString() => '$name(${arg.toMathString()})';

  @override
  Expr clone() => Func(name, arg.clone());
}

/// Derivative symbol used during implicit differentiation: dy/dx
class DerivSym extends Expr {
  final String varName;
  const DerivSym(this.varName);

  @override
  String toMathString() => varName == 'y' ? 'dy/dx' : 'd$varName/dx';

  @override
  Expr clone() => DerivSym(varName);
}

// ==================== PROBLEM TYPE ====================

enum ProblemType { explicit, implicit, parametric }

// ==================== SLOPE RESULT ====================

/// Immutable data bag returned by SlopeSolver.solve().
/// Contains everything needed for display and further computation —
/// the solver writes it, the display layer reads it.
class SlopeResult {
  final ProblemType type;
  final String originalInput;
  final Expr functionExpr;
  final Expr derivative;
  final Expr simplifiedDerivative;
  final double? slopeValue;
  final Map<String, double> point;
  final String independentVar;
  final String? dependentVar;

  // Implicit-only fields
  final Expr? leftSide;
  final Expr? rightSide;
  final Expr? leftDerivative;
  final Expr? rightDerivative;
  final Expr? implicitSlopeExpr;

  // Parametric-only fields
  final Expr? paramXExpr;
  final Expr? paramYExpr;
  final Expr? dxDt;
  final Expr? dyDt;
  final Expr? secondDerivative; // d²y/dx²

  // Tangent line
  final double? tangentSlope;
  final double? tangentYIntercept;
  final String? tangentLineEquation;

  // Normal line
  final double? normalSlope;
  final String? normalLineEquation;

  const SlopeResult({
    required this.type,
    required this.originalInput,
    required this.functionExpr,
    required this.derivative,
    required this.simplifiedDerivative,
    this.slopeValue,
    required this.point,
    required this.independentVar,
    this.dependentVar,
    this.leftSide,
    this.rightSide,
    this.leftDerivative,
    this.rightDerivative,
    this.implicitSlopeExpr,
    this.paramXExpr,
    this.paramYExpr,
    this.dxDt,
    this.dyDt,
    this.secondDerivative,
    this.tangentSlope,
    this.tangentYIntercept,
    this.normalSlope,
    this.tangentLineEquation,
    this.normalLineEquation,
  });
}
