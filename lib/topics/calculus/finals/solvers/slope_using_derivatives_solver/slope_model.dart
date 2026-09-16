// slope_model.dart
// Pure data model for the slope-using-derivatives solver:
// expression AST (Expr + subclasses) with math/LaTeX rendering,
// plus ProblemType and the SlopeResult value object.
// No parsing, differentiation, or solving logic lives here.

// EXPRESSION AST
// ═══════════════════════════════════════════════════════════════════

abstract class Expr {
  const Expr();
  String toMathString();
  String toLatexString();
  Expr clone();
  @override
  String toString() => toMathString();
}

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
  String toLatexString() => toMathString();
  @override
  Expr clone() => Num(value);
  bool get isZero => value == 0;
  bool get isOne => value == 1;
  bool get isMinusOne => value == -1;
}

class Var extends Expr {
  final String name;
  const Var(this.name);
  @override
  String toMathString() => name;
  @override
  String toLatexString() => name;
  @override
  Expr clone() => Var(name);
}

class Const extends Expr {
  final String name;
  final double numericValue;
  const Const(this.name, this.numericValue);
  @override
  String toMathString() => name;
  @override
  String toLatexString() => name == 'pi' || name == '\u03c0'
      ? r'{\pi}'
      : name == 'e'
          ? r'{e}'
          : name;
  @override
  Expr clone() => Const(name, numericValue);
}

class BinOp extends Expr {
  final Expr left;
  final String op;
  final Expr right;
  const BinOp(this.left, this.op, this.right);

  @override
  String toMathString() {
    String l = left.toMathString(), r = right.toMathString();
    if (left is BinOp && _prec((left as BinOp).op) < _prec(op)) l = '($l)';
    if (left is UnaryNeg && _prec('*') <= _prec(op)) l = '($l)';
    if (right is BinOp) {
      final rp = _prec((right as BinOp).op);
      if (rp < _prec(op) || (rp == _prec(op) && (op == '-' || op == '/'))) {
        r = '($r)';
      }
    }
    if (right is UnaryNeg && (op == '+' || op == '-')) r = '($r)';
    return '$l $op $r';
  }

  @override
  String toLatexString() {
    String l = left.toLatexString(), r = right.toLatexString();
    switch (op) {
      case '+':
        return '$l + $r';
      case '-':
        return '$l - $r';
      case '*':
        if ((left is Num && (right is Var || right is Pow)) ||
            (right is Num && (left is Var || left is Pow))) {
          return '$l \\, $r';
        }
        if (left is Num || right is Num) return '$l \\cdot $r';
        return '$l \\, $r';
      case '/':
        return '\\frac{$l}{$r}';
      default:
        return toMathString();
    }
  }

  static int _prec(String op) =>
      const {'+': 1, '-': 1, '*': 2, '/': 2}[op] ?? 0;
  static int prec(String op) => _prec(op);
  @override
  Expr clone() => BinOp(left.clone(), op, right.clone());
}

class Pow extends Expr {
  final Expr base;
  final Expr exponent;
  const Pow(this.base, this.exponent);

  @override
  String toMathString() {
    String b = base.toMathString(), e = exponent.toMathString();
    if (base is BinOp || base is UnaryNeg) b = '($b)';
    if (exponent is BinOp || exponent is UnaryNeg) e = '($e)';
    return '$b^$e';
  }

  @override
  String toLatexString() {
    String b = base.toLatexString(), e = exponent.toLatexString();
    if (exponent is Num && (exponent as Num).value == 2) return '{$b}^{2}';
    if (exponent is Num && (exponent as Num).value == 3) return '{$b}^{3}';
    return '{$b}^{$e}';
  }

  @override
  Expr clone() => Pow(base.clone(), exponent.clone());
}

class UnaryNeg extends Expr {
  final Expr operand;
  const UnaryNeg(this.operand);

  @override
  String toMathString() {
    if (operand is BinOp || operand is Pow) {
      return '-(${operand.toMathString()})';
    }
    return '-${operand.toMathString()}';
  }

  @override
  String toLatexString() {
    if (operand is BinOp || operand is Pow || operand is Func) {
      return '-(${operand.toLatexString()})';
    }
    return '-${operand.toLatexString()}';
  }

  @override
  Expr clone() => UnaryNeg(operand.clone());
}

class Func extends Expr {
  final String name;
  final Expr arg;
  const Func(this.name, this.arg);

  @override
  String toMathString() => '$name(${arg.toMathString()})';

  @override
  String toLatexString() {
    final a = arg.toLatexString();
    switch (name) {
      case 'sin':
        return '\\sin($a)';
      case 'cos':
        return '\\cos($a)';
      case 'tan':
        return '\\tan($a)';
      case 'cot':
        return '\\cot($a)';
      case 'sec':
        return '\\sec($a)';
      case 'csc':
        return '\\csc($a)';
      case 'sqrt':
        return '\\sqrt{$a}';
      case 'abs':
        return '|$a|';
      case 'ln':
        return '\\ln($a)';
      case 'log':
        return '\\log($a)';
      case 'exp':
        return 'e^{$a}';
      default:
        return '$name($a)';
    }
  }

  @override
  Expr clone() => Func(name, arg.clone());
}

class DerivSym extends Expr {
  final String varName;
  const DerivSym(this.varName);
  @override
  String toMathString() => varName == 'y' ? 'dy/dx' : 'd$varName/dx';
  @override
  String toLatexString() =>
      varName == 'y' ? '\\frac{dy}{dx}' : '\\frac{d$varName}{dx}';
  @override
  Expr clone() => DerivSym(varName);
}

// ═══════════════════════════════════════════════════════════════════
// PROBLEM TYPES & RESULT
// ═══════════════════════════════════════════════════════════════════

enum ProblemType { explicit, implicit, parametric }

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
  final Expr? leftSide,
      rightSide,
      leftDerivative,
      rightDerivative,
      implicitSlopeExpr;
  final Expr? paramXExpr, paramYExpr, dxDt, dyDt, secondDerivative;
  final double? tangentSlope, tangentYIntercept, normalSlope;
  final String? tangentLineEquation, normalLineEquation;

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
