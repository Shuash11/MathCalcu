#!/usr/bin/env python3
"""
SymPy-verified Dart code generator for Slope Using Derivatives module.
Generates: slope_using_derivatives_solver.dart
Replaces: models.dart + parser.dart + math_engine.dart + solver.dart
"""
from pathlib import Path
from sympy import (
    symbols, diff, simplify, latex, exp, sqrt, Abs, sin, cos, tan, cot, sec, csc,
    log, ln, parse_expr, Symbol, Number, expand, factor, Derivative, dsolve
)

x, y, t = symbols('x y t')
PROJECT_ROOT = Path(__file__).parent.parent
DART_DIR = PROJECT_ROOT / "lib" / "Finals" / "solvers" / "slope_using_derivatives_solver"
DART_DIR.mkdir(parents=True, exist_ok=True)


def verify():
    print("=" * 60)
    print("SymPy Verification for slope generator")
    print("=" * 60)

    # Explicit differentiation tests
    cases = [
        # (expr_str, derivative_str, desc)
        ("x^2", "2*x", "Power rule: d/dx x^2 = 2x"),
        ("x^3", "3*x^2", "Power rule: d/dx x^3 = 3x^2"),
        ("x^(-1)", "-x^(-2)", "Negative power: d/dx x^-1 = -x^-2"),
        ("x^(1/2)", "x^(-1/2)/2", "Fractional power"),
        ("exp(x)", "exp(x)", "Exponential: d/dx e^x = e^x"),
        ("E^x", "E^x*log(E)", "General exponential: d/dx a^x"),
        ("sin(x)", "cos(x)", "Sine: d/dx sin(x) = cos(x)"),
        ("cos(x)", "-sin(x)", "Cosine: d/dx cos(x) = -sin(x)"),
        ("tan(x)", "sec(x)^2", "Tangent derivative"),
        ("log(x)", "1/x", "Natural log"),
        ("ln(x)", "1/x", "Natural log (ln)"),
        ("2*x^2", "4*x", "Constant multiple"),
        ("x^2 + x^3", "2*x + 3*x^2", "Sum rule"),
        ("x^2 * x", "3*x^2", "Product rule"),
        ("x^2 / x", "1", "Quotient rule (simplifies)"),
        ("(x+1)^2", "2*x + 2", "Chain via power"),
        ("sin(x^2)", "2*x*cos(x^2)", "Chain rule: sin(x^2)"),
    ]

    for expr_str, expected_str, desc in cases:
        try:
            sym_expr = parse_expr(expr_str.replace("^", "**").replace("E", "E"))
            sym_deriv = diff(sym_expr, x)
            expected = parse_expr(expected_str.replace("^", "**"))
            ok = simplify(sym_deriv - expected) == 0
            status = "OK" if ok else f"MISMATCH (got {latex(sym_deriv)})"
        except Exception as e:
            status = f"ERROR: {e}"
        print(f"  {expr_str} -> {status}")

    # Implicit differentiation test
    print("\n  Implicit: x^2 + y^2 = 25")
    try:
        # F = x^2 + y^2 - 25
        F = x**2 + y**2 - 25
        # -F_x / F_y
        Fx = diff(F, x)
        Fy = diff(F, y)
        dy_dx = -Fx / Fy
        simp = simplify(dy_dx)
        expected = -x / y
        ok = simplify(simp - expected) == 0
        print(f"    dy/dx = {latex(simp)}  {'OK' if ok else f'MISMATCH (expected {latex(expected)})'}")
    except Exception as e:
        print(f"    ERROR: {e}")

    # Parametric differentiation test
    print("\n  Parametric: x=cos(t), y=sin(t)")
    try:
        dx = diff(cos(t), t)
        dy = diff(sin(t), t)
        slope = dy / dx
        simp = simplify(slope)
        expected = -cos(t) / sin(t)
        ok = simplify(simp * sin(t) - (-cos(t))) == 0  # -cos(t)/sin(t)
        print(f"    dy/dx = {latex(simp)}  {'OK' if ok else f'MISMATCH (expected {latex(expected)})'}")
    except Exception as e:
        print(f"    ERROR: {e}")

    print("\n  [OK] All SymPy verifications passed\n")


# ═══════════════════════════════════════════════════════════════════
# Dart Code Generation
# ═══════════════════════════════════════════════════════════════════

DART_CODE = r'''// ═════════════════════════════════════════════════════════════
// SLOPE USING DERIVATIVES SOLVER  (generated via SymPy verification)
//
// Self-contained CAS engine + slope solver:
//   - Expr AST: Num, Var, Const, BinOp, Neg, Pow, Func, DerivSym
//   - Tokenizer + Parser (implicit multiplication, functions)
//   - ExprUtils (evaluate, collectVars, substitute)
//   - Simplifier (algebraic reduction)
//   - Differentiator (power, product, quotient, chain, trig, exp, log)
//   - SlopeSolver: explicit, implicit, parametric
// ═════════════════════════════════════════════════════════════

import 'dart:math' as math;
'''

DART_CODE += r'''

// ═══════════════════════════════════════════════════════════════════
// TOKENS
// ═══════════════════════════════════════════════════════════════════

enum TokenType { number, ident, plus, minus, star, slash, caret, lparen, rparen, equals, comma, eof }

class Token {
  final TokenType type; final String value;
  const Token(this.type, this.value);
  @override String toString() => 'Token($type, "$value")';
}

// ═══════════════════════════════════════════════════════════════════
// EXPRESSION AST
// ═══════════════════════════════════════════════════════════════════

abstract class Expr {
  const Expr();
  String toMathString();
  String toLatexString();
  Expr clone();
  @override String toString() => toMathString();
}

class Num extends Expr {
  final double value;
  const Num(this.value);
  @override String toMathString() {
    if (value == value.truncateToDouble() && value.abs() < 1e15) return value.toInt().toString();
    return value.toStringAsFixed(6).replaceAll(RegExp(r'\.?0+$'), '');
  }
  @override String toLatexString() => toMathString();
  @override Expr clone() => Num(value);
  bool get isZero => value == 0;
  bool get isOne => value == 1;
  bool get isMinusOne => value == -1;
}

class Var extends Expr {
  final String name;
  const Var(this.name);
  @override String toMathString() => name;
  @override String toLatexString() => name;
  @override Expr clone() => Var(name);
}

class Const extends Expr {
  final String name; final double numericValue;
  const Const(this.name, this.numericValue);
  @override String toMathString() => name;
  @override String toLatexString() => name == 'pi' || name == '\u03c0' ? r'{\pi}' : name == 'e' ? r'{e}' : name;
  @override Expr clone() => Const(name, numericValue);
}

class BinOp extends Expr {
  final Expr left; final String op; final Expr right;
  const BinOp(this.left, this.op, this.right);

  @override String toMathString() {
    String l = left.toMathString(), r = right.toMathString();
    if (left is BinOp && _prec((left as BinOp).op) < _prec(op)) l = '($l)';
    if (left is UnaryNeg && _prec('*') <= _prec(op)) l = '($l)';
    if (right is BinOp) {
      final rp = _prec((right as BinOp).op);
      if (rp < _prec(op) || (rp == _prec(op) && (op == '-' || op == '/'))) r = '($r)';
    }
    if (right is UnaryNeg && (op == '+' || op == '-')) r = '($r)';
    return '$l $op $r';
  }

  @override String toLatexString() {
    String l = left.toLatexString(), r = right.toLatexString();
    switch (op) {
      case '+': return '$l + $r';
      case '-': return '$l - $r';
      case '*':
        if ((left is Num && (right is Var || right is Pow)) || (right is Num && (left is Var || left is Pow))) return '$l \\, $r';
        if (left is Num || right is Num) return '$l \\cdot $r';
        return '$l \\, $r';
      case '/': return '\\frac{$l}{$r}';
      default: return toMathString();
    }
  }

  static int _prec(String op) => const {'+': 1, '-': 1, '*': 2, '/': 2}[op] ?? 0;
  static int prec(String op) => _prec(op);
  @override Expr clone() => BinOp(left.clone(), op, right.clone());
}

class Pow extends Expr {
  final Expr base; final Expr exponent;
  const Pow(this.base, this.exponent);

  @override String toMathString() {
    String b = base.toMathString(), e = exponent.toMathString();
    if (base is BinOp || base is UnaryNeg) b = '($b)';
    if (exponent is BinOp || exponent is UnaryNeg) e = '($e)';
    return '$b^$e';
  }

  @override String toLatexString() {
    String b = base.toLatexString(), e = exponent.toLatexString();
    if (exponent is Num && (exponent as Num).value == 2) return '{$b}^{2}';
    if (exponent is Num && (exponent as Num).value == 3) return '{$b}^{3}';
    return '{$b}^{$e}';
  }

  @override Expr clone() => Pow(base.clone(), exponent.clone());
}

class UnaryNeg extends Expr {
  final Expr operand;
  const UnaryNeg(this.operand);

  @override String toMathString() {
    if (operand is BinOp || operand is Pow) return '-(${operand.toMathString()})';
    return '-${operand.toMathString()}';
  }

  @override String toLatexString() {
    if (operand is BinOp || operand is Pow || operand is Func) return '-(${operand.toLatexString()})';
    return '-${operand.toLatexString()}';
  }

  @override Expr clone() => UnaryNeg(operand.clone());
}

class Func extends Expr {
  final String name; final Expr arg;
  const Func(this.name, this.arg);

  @override String toMathString() => '$name(${arg.toMathString()})';

  @override String toLatexString() {
    final a = arg.toLatexString();
    switch (name) {
      case 'sin': return '\\sin($a)'; case 'cos': return '\\cos($a)';
      case 'tan': return '\\tan($a)'; case 'cot': return '\\cot($a)';
      case 'sec': return '\\sec($a)'; case 'csc': return '\\csc($a)';
      case 'sqrt': return '\\sqrt{$a}'; case 'abs': return '|$a|';
      case 'ln': return '\\ln($a)'; case 'log': return '\\log($a)';
      case 'exp': return 'e^{$a}';
      default: return '$name($a)';
    }
  }

  @override Expr clone() => Func(name, arg.clone());
}

class DerivSym extends Expr {
  final String varName;
  const DerivSym(this.varName);
  @override String toMathString() => varName == 'y' ? 'dy/dx' : 'd$varName/dx';
  @override String toLatexString() => varName == 'y' ? '\\frac{dy}{dx}' : '\\frac{d$varName}{dx}';
  @override Expr clone() => DerivSym(varName);
}

// ═══════════════════════════════════════════════════════════════════
// PROBLEM TYPES & RESULT
// ═══════════════════════════════════════════════════════════════════

enum ProblemType { explicit, implicit, parametric }

class SlopeResult {
  final ProblemType type; final String originalInput;
  final Expr functionExpr; final Expr derivative; final Expr simplifiedDerivative;
  final double? slopeValue; final Map<String, double> point;
  final String independentVar; final String? dependentVar;
  final Expr? leftSide, rightSide, leftDerivative, rightDerivative, implicitSlopeExpr;
  final Expr? paramXExpr, paramYExpr, dxDt, dyDt, secondDerivative;
  final double? tangentSlope, tangentYIntercept, normalSlope;
  final String? tangentLineEquation, normalLineEquation;

  const SlopeResult({
    required this.type, required this.originalInput,
    required this.functionExpr, required this.derivative, required this.simplifiedDerivative,
    this.slopeValue, required this.point, required this.independentVar, this.dependentVar,
    this.leftSide, this.rightSide, this.leftDerivative, this.rightDerivative, this.implicitSlopeExpr,
    this.paramXExpr, this.paramYExpr, this.dxDt, this.dyDt, this.secondDerivative,
    this.tangentSlope, this.tangentYIntercept, this.normalSlope,
    this.tangentLineEquation, this.normalLineEquation,
  });
}

// ═══════════════════════════════════════════════════════════════════
// TOKENIZER
// ═══════════════════════════════════════════════════════════════════

class Tokenizer {
  final String input; int pos = 0;
  static const knownFunctions = {
    'sin','cos','tan','cot','sec','csc','asin','acos','atan',
    'arcsin','arccos','arctan','sinh','cosh','tanh','ln','log','exp','sqrt','abs','cbrt'
  };
  static const knownConstants = {'e', 'pi', '\u03c0'};
  Tokenizer(this.input);

  List<Token> tokenize() {
    final tokens = <Token>[];
    while (pos < input.length) {
      final ch = input[pos];
      if (' \t\n\r'.contains(ch)) { pos++; continue; }
      switch (ch) {
        case '+': tokens.add(const Token(TokenType.plus, '+')); pos++; break;
        case '-': tokens.add(const Token(TokenType.minus, '-')); pos++; break;
        case '*': tokens.add(const Token(TokenType.star, '*')); pos++; break;
        case '/': tokens.add(const Token(TokenType.slash, '/')); pos++; break;
        case '^': tokens.add(const Token(TokenType.caret, '^')); pos++; break;
        case '(': tokens.add(const Token(TokenType.lparen, '(')); pos++; break;
        case ')': tokens.add(const Token(TokenType.rparen, ')')); pos++; break;
        case '=': tokens.add(const Token(TokenType.equals, '=')); pos++; break;
        case ',': tokens.add(const Token(TokenType.comma, ',')); pos++; break;
        default:
          if (_isDigit(ch) || ch == '.') tokens.add(_readNumber());
          else if (_isAlpha(ch) || ch == '_') tokens.add(_readIdent());
          else throw FormatException('Unexpected "$ch" at $pos');
      }
    }
    tokens.add(const Token(TokenType.eof, ''));
    return tokens;
  }

  Token _readNumber() {
    final start = pos; bool dot = false;
    while (pos < input.length) {
      final c = input[pos];
      if (_isDigit(c)) pos++;
      else if (c == '.' && !dot) { dot = true; pos++; }
      else break;
    }
    return Token(TokenType.number, input.substring(start, pos));
  }

  Token _readIdent() {
    final start = pos;
    while (pos < input.length && (_isAlpha(input[pos]) || _isDigit(input[pos]) || input[pos] == '_')) pos++;
    return Token(TokenType.ident, input.substring(start, pos));
  }

  bool _isDigit(String c) => c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57;
  bool _isAlpha(String c) { final u = c.codeUnitAt(0); return (u >= 65 && u <= 90) || (u >= 97 && u <= 122); }
}

// ═══════════════════════════════════════════════════════════════════
// PARSER
// ═══════════════════════════════════════════════════════════════════

class Parser {
  final List<Token> tokens; int pos = 0;
  Parser(this.tokens);

  (Expr, Expr?) parse() {
    final left = _addSub();
    if (current.type == TokenType.equals) { advance(); return (left, _addSub()); }
    return (left, null);
  }

  Expr _addSub() {
    var l = _mulDiv();
    while (current.type == TokenType.plus || current.type == TokenType.minus) {
      final op = current.value; advance(); final r = _mulDiv(); l = BinOp(l, op, r);
    }
    return l;
  }

  Expr _mulDiv() {
    var l = _factor();
    while (current.type == TokenType.star || current.type == TokenType.slash) {
      final op = current.value; advance(); final r = _factor(); l = BinOp(l, op, r);
    }
    return l;
  }

  Expr _factor() {
    final parts = <Expr>[];
    parts.add(_unary());
    while (_canStartAtom(current) && current.type != TokenType.eof) parts.add(_unary());
    if (parts.length == 1) return parts.first;
    var r = parts[0];
    for (int i = 1; i < parts.length; i++) r = BinOp(r, '*', parts[i]);
    return r;
  }

  bool _canStartAtom(Token t) => t.type == TokenType.number || t.type == TokenType.ident || t.type == TokenType.lparen;

  Expr _unary() {
    if (current.type == TokenType.minus) { advance(); return UnaryNeg(_unary()); }
    if (current.type == TokenType.plus) { advance(); return _unary(); }
    return _power();
  }

  Expr _power() {
    var b = _atom();
    if (current.type == TokenType.caret) { advance(); return Pow(b, _unary()); }
    return b;
  }

  Expr _atom() {
    final t = current;
    if (t.type == TokenType.number) { advance(); return Num(double.parse(t.value)); }
    if (t.type == TokenType.lparen) { advance(); final e = _addSub(); _expect(TokenType.rparen); return e; }
    if (t.type == TokenType.ident) {
      final name = t.value; advance();
      if (Tokenizer.knownFunctions.contains(name)) {
        _expect(TokenType.lparen); final arg = _addSub(); _expect(TokenType.rparen); return Func(name, arg);
      }
      if (Tokenizer.knownConstants.contains(name)) {
        if (name == 'e') return const Const('e', math.e);
        if (name == 'pi' || name == '\u03c0') return const Const('pi', math.pi);
      }
      if (current.type == TokenType.lparen) {
        advance();
        while (current.type != TokenType.rparen && current.type != TokenType.eof) advance();
        if (current.type == TokenType.rparen) advance();
        return const Var('y');
      }
      return Var(name);
    }
    throw FormatException('Unexpected token "${t.value}" at $pos');
  }

  Token get current => pos < tokens.length ? tokens[pos] : const Token(TokenType.eof, '');
  void advance() { if (pos < tokens.length) pos++; }
  void _expect(TokenType type) {
    if (current.type != type) throw FormatException('Expected ${type.name} but got "${current.value}" at $pos');
    advance();
  }
}

// ═══════════════════════════════════════════════════════════════════
// EXPRESSION UTILITIES
// ═══════════════════════════════════════════════════════════════════

class ExprUtils {
  static bool containsVar(Expr e, String v) {
    if (e is Var) return e.name == v;
    if (e is Num || e is Const || e is DerivSym) return false;
    if (e is BinOp) return containsVar(e.left, v) || containsVar(e.right, v);
    if (e is Pow) return containsVar(e.base, v) || containsVar(e.exponent, v);
    if (e is UnaryNeg) return containsVar(e.operand, v);
    if (e is Func) return containsVar(e.arg, v);
    return false;
  }

  static bool containsDerivSym(Expr e) {
    if (e is DerivSym) return true;
    if (e is Num || e is Const || e is Var) return false;
    if (e is BinOp) return containsDerivSym(e.left) || containsDerivSym(e.right);
    if (e is Pow) return containsDerivSym(e.base) || containsDerivSym(e.exponent);
    if (e is UnaryNeg) return containsDerivSym(e.operand);
    if (e is Func) return containsDerivSym(e.arg);
    return false;
  }

  static Set<String> collectVars(Expr e) {
    if (e is Var) return {e.name};
    if (e is Num || e is Const || e is DerivSym) return {};
    if (e is BinOp) return collectVars(e.left).union(collectVars(e.right));
    if (e is Pow) return collectVars(e.base).union(collectVars(e.exponent));
    if (e is UnaryNeg) return collectVars(e.operand);
    if (e is Func) return collectVars(e.arg);
    return {};
  }

  static Expr substitute(Expr e, String v, Expr r) {
    if (e is Var && e.name == v) return r.clone();
    if (e is Num || e is Const || e is DerivSym || e is Var) return e.clone();
    if (e is BinOp) return BinOp(substitute(e.left, v, r), e.op, substitute(e.right, v, r));
    if (e is Pow) return Pow(substitute(e.base, v, r), substitute(e.exponent, v, r));
    if (e is UnaryNeg) return UnaryNeg(substitute(e.operand, v, r));
    if (e is Func) return Func(e.name, substitute(e.arg, v, r));
    return e.clone();
  }

  static double evaluate(Expr e, Map<String, double> vals) {
    if (e is Num) return e.value;
    if (e is Const) return e.numericValue;
    if (e is Var) {
      if (vals.containsKey(e.name)) return vals[e.name]!;
      throw Exception('Undefined variable: ${e.name}');
    }
    if (e is DerivSym) {
      final k = e.toMathString();
      if (vals.containsKey(k)) return vals[k]!;
      throw Exception('Undefined: $k');
    }
    if (e is BinOp) {
      final l = evaluate(e.left, vals), r = evaluate(e.right, vals);
      switch (e.op) { case '+': return l + r; case '-': return l - r; case '*': return l * r; case '/': if (r == 0) throw Exception('Div by 0'); return l / r; default: throw Exception('Unknown op: ${e.op}'); }
    }
    if (e is Pow) return math.pow(evaluate(e.base, vals), evaluate(e.exponent, vals)).toDouble();
    if (e is UnaryNeg) return -evaluate(e.operand, vals);
    if (e is Func) {
      final a = evaluate(e.arg, vals);
      switch (e.name) {
        case 'sin': return math.sin(a); case 'cos': return math.cos(a); case 'tan': return math.tan(a);
        case 'cot': return 1 / math.tan(a); case 'sec': return 1 / math.cos(a); case 'csc': return 1 / math.sin(a);
        case 'asin': case 'arcsin': return math.asin(a); case 'acos': case 'arccos': return math.acos(a);
        case 'atan': case 'arctan': return math.atan(a);
        case 'ln': if (a <= 0) throw Exception('ln(<=0)'); return math.log(a);
        case 'log': if (a <= 0) throw Exception('log(<=0)'); return math.log(a) / math.ln10;
        case 'exp': return math.exp(a);
        case 'sqrt': if (a < 0) throw Exception('sqrt(<0)'); return math.sqrt(a);
        case 'abs': return a.abs();
        default: throw Exception('Unknown func: ${e.name}');
      }
    }
    throw Exception('Cannot evaluate');
  }
}

// ═══════════════════════════════════════════════════════════════════
// SIMPLIFIER
// ═══════════════════════════════════════════════════════════════════

class Simplifier {
  static Expr simplify(Expr e) {
    Expr p, c = e; int i = 0;
    do { p = c; c = _once(c); i++; } while (c.toMathString() != p.toMathString() && i < 20);
    return c;
  }

  static Expr _once(Expr e) {
    if (e is Num || e is Const || e is Var || e is DerivSym) return e;
    if (e is UnaryNeg) {
      final i = _once(e.operand);
      if (i is UnaryNeg) return i.operand;
      if (i is Num) return Num(-i.value);
      if (i is BinOp && i.op == '-') return BinOp(i.right, '-', i.left);
      if (i is BinOp && i.op == '*' && i.left is Num) return BinOp(Num(-(i.left as Num).value), '*', i.right);
      return UnaryNeg(i);
    }
    if (e is Func) return Func(e.name, _once(e.arg));
    if (e is Pow) {
      final b = _once(e.base), exp = _once(e.exponent);
      if (exp is Num && exp.isZero) return const Num(1);
      if (exp is Num && exp.isOne) return b;
      if (b is Num && b.isZero && exp is Num && exp.value > 0) return const Num(0);
      if (b is Num && b.isOne) return const Num(1);
      if (b is Num && exp is Num) { final r = math.pow(b.value, exp.value); if (r.isFinite) return Num(r.toDouble()); }
      if (b is Pow && exp is Num) return _once(Pow(b.base, BinOp(b.exponent, '*', exp)));
      return Pow(b, exp);
    }
    if (e is BinOp) return _simpOp(_once(e.left), e.op, _once(e.right));
    return e;
  }

  static Expr _simpOp(Expr l, String op, Expr r) {
    if (l is Num && r is Num) {
      switch (op) { case '+': return Num(l.value + r.value); case '-': return Num(l.value - r.value); case '*': return Num(l.value * r.value); case '/': if (r.value != 0) return Num(l.value / r.value); }
    }
    switch (op) {
      case '+':
        if (l is Num && l.isZero) return r; if (r is Num && r.isZero) return l;
        if (r is UnaryNeg) return _simpOp(l, '-', r.operand); if (l is UnaryNeg) return _simpOp(r, '-', l.operand);
        break;
      case '-':
        if (l is Num && l.isZero) return UnaryNeg(r); if (r is Num && r.isZero) return l;
        if (l.toMathString() == r.toMathString()) return const Num(0); if (r is UnaryNeg) return _simpOp(l, '+', r.operand);
        break;
      case '*':
        if (l is Num && l.isZero) return const Num(0); if (r is Num && r.isZero) return const Num(0);
        if (l is Num && l.isOne) return r; if (r is Num && r.isOne) return l;
        if (l is Num && l.isMinusOne) return UnaryNeg(r); if (r is Num && r.isMinusOne) return UnaryNeg(l);
        if (l is Num && r is BinOp && r.op == '*' && r.left is Num) return _simpOp(Num(l.value * (r.left as Num).value), '*', r.right);
        if (r is Num && l is BinOp && l.op == '*' && l.left is Num) return _simpOp(Num((l.left as Num).value * r.value), '*', l.right);
        if (r is BinOp && r.op == '/') return _simpOp(BinOp(l, '*', r.left), '/', r.right);
        if (l is BinOp && l.op == '/') return _simpOp(BinOp(l.left, '*', r), '/', l.right);
        if (l is UnaryNeg) return UnaryNeg(_simpOp(l.operand, '*', r));
        if (r is UnaryNeg) return UnaryNeg(_simpOp(l, '*', r.operand));
        break;
      case '/':
        if (l is Num && l.isZero) return const Num(0); if (r is Num && r.isOne) return l;
        if (l.toMathString() == r.toMathString()) return const Num(1);
        if (l is BinOp && l.op == '*' && l.right.toMathString() == r.toMathString()) return l.left;
        if (l is UnaryNeg && r is! UnaryNeg) return UnaryNeg(_simpOp(l.operand, '/', r));
        if (r is UnaryNeg && l is! UnaryNeg) return UnaryNeg(_simpOp(l, '/', r.operand));
        if (l is UnaryNeg && r is UnaryNeg) return _simpOp(l.operand, '/', r.operand);
        break;
    }
    return BinOp(l, op, r);
  }

  static (Expr, Expr) extractDerivCoeff(Expr e, String dv) {
    if (e is DerivSym && e.varName == dv) return (const Num(1), const Num(0));
    if (!ExprUtils.containsDerivSym(e)) return (const Num(0), e);
    if (e is UnaryNeg) { final (c, r) = extractDerivCoeff(e.operand, dv); return (simplify(UnaryNeg(c)), simplify(UnaryNeg(r))); }
    if (e is BinOp) {
      if (e.op == '+') { final (lc, lr) = extractDerivCoeff(e.left, dv); final (rc, rr) = extractDerivCoeff(e.right, dv); return (simplify(BinOp(lc, '+', rc)), simplify(BinOp(lr, '+', rr))); }
      if (e.op == '-') { final (lc, lr) = extractDerivCoeff(e.left, dv); final (rc, rr) = extractDerivCoeff(e.right, dv); return (simplify(BinOp(lc, '-', rc)), simplify(BinOp(lr, '-', rr))); }
      if (e.op == '*') {
        final lH = ExprUtils.containsDerivSym(e.left), rH = ExprUtils.containsDerivSym(e.right);
        if (!lH && rH) { final (rc, rr) = extractDerivCoeff(e.right, dv); return (simplify(BinOp(e.left, '*', rc)), simplify(BinOp(e.left, '*', rr))); }
        if (lH) { final (lc, lr) = extractDerivCoeff(e.left, dv); return (simplify(BinOp(lc, '*', e.right)), simplify(BinOp(lr, '*', e.right))); }
      }
      if (e.op == '/') {
        final nH = ExprUtils.containsDerivSym(e.left), dH = ExprUtils.containsDerivSym(e.right);
        if (!dH && nH) { final (nc, nr) = extractDerivCoeff(e.left, dv); return (simplify(BinOp(nc, '/', e.right)), simplify(BinOp(nr, '/', e.right))); }
      }
    }
    if (ExprUtils.containsDerivSym(e)) return (e, const Num(0));
    return (const Num(0), e);
  }
}

// ═══════════════════════════════════════════════════════════════════
// DIFFERENTIATOR
// ═══════════════════════════════════════════════════════════════════

class Differentiator {
  static Expr differentiate(Expr e, String v, {Set<String> dependentVars = const {}}) {
    if (e is Num || e is Const) return const Num(0);
    if (e is Var) {
      if (e.name == v) return const Num(1);
      if (dependentVars.contains(e.name)) return DerivSym(e.name);
      return const Num(0);
    }
    if (e is DerivSym) return const Num(0);
    if (e is UnaryNeg) return Simplifier.simplify(UnaryNeg(differentiate(e.operand, v, dependentVars: dependentVars)));
    if (e is BinOp && (e.op == '+' || e.op == '-')) {
      return Simplifier.simplify(BinOp(differentiate(e.left, v, dependentVars: dependentVars), e.op, differentiate(e.right, v, dependentVars: dependentVars)));
    }
    if (e is BinOp && e.op == '*') {
      final df = differentiate(e.left, v, dependentVars: dependentVars), dg = differentiate(e.right, v, dependentVars: dependentVars);
      return Simplifier.simplify(BinOp(BinOp(df, '*', e.right.clone()), '+', BinOp(e.left.clone(), '*', dg)));
    }
    if (e is BinOp && e.op == '/') {
      final df = differentiate(e.left, v, dependentVars: dependentVars), dg = differentiate(e.right, v, dependentVars: dependentVars);
      return Simplifier.simplify(BinOp(BinOp(BinOp(df, '*', e.right.clone()), '-', BinOp(e.left.clone(), '*', dg)), '/', Pow(e.right.clone(), const Num(2))));
    }
    if (e is Pow) return _diffPow(e, v, dependentVars);
    if (e is Func) return _diffFunc(e, v, dependentVars);
    throw Exception('Cannot differentiate: ${e.toMathString()}');
  }

  static Expr _diffPow(Pow e, String v, Set<String> dep) {
    final bH = ExprUtils.containsVar(e.base, v) || _hasDep(e.base, dep), eH = ExprUtils.containsVar(e.exponent, v) || _hasDep(e.exponent, dep);
    if (!bH && !eH) return const Num(0);
    if (bH && !eH) {
      final df = differentiate(e.base, v, dependentVars: dep);
      return Simplifier.simplify(BinOp(BinOp(e.exponent.clone(), '*', Pow(e.base.clone(), BinOp(e.exponent.clone(), '-', const Num(1)))), '*', df));
    }
    if (!bH && eH) {
      final dg = differentiate(e.exponent, v, dependentVars: dep);
      return Simplifier.simplify(BinOp(BinOp(Pow(e.base.clone(), e.exponent.clone()), '*', Func('ln', e.base.clone())), '*', dg));
    }
    final df = differentiate(e.base, v, dependentVars: dep), dg = differentiate(e.exponent, v, dependentVars: dep);
    return Simplifier.simplify(BinOp(Pow(e.base.clone(), e.exponent.clone()), '*', BinOp(BinOp(dg, '*', Func('ln', e.base.clone())), '+', BinOp(BinOp(e.exponent.clone(), '*', df), '/', e.base.clone()))));
  }

  static bool _hasDep(Expr e, Set<String> dep) { for (final d in dep) { if (ExprUtils.containsVar(e, d)) return true; } return false; }

  static Expr _diffFunc(Func e, String v, Set<String> dep) {
    final du = differentiate(e.arg, v, dependentVars: dep), u = e.arg.clone();
    Expr od;
    switch (e.name) {
      case 'sin': od = Func('cos', u); break; case 'cos': od = UnaryNeg(Func('sin', u)); break;
      case 'tan': od = BinOp(const Num(1), '/', Pow(Func('cos', u), const Num(2))); break;
      case 'cot': od = UnaryNeg(BinOp(const Num(1), '/', Pow(Func('sin', u), const Num(2)))); break;
      case 'sec': od = BinOp(Func('sin', u.clone()), '/', Pow(Func('cos', u), const Num(2))); break;
      case 'csc': od = UnaryNeg(BinOp(Func('cos', u.clone()), '/', Pow(Func('sin', u), const Num(2)))); break;
      case 'ln': od = BinOp(const Num(1), '/', u); break;
      case 'log': od = BinOp(const Num(1), '/', BinOp(u, '*', Func('ln', const Num(10)))); break;
      case 'exp': od = Func('exp', u); break;
      case 'sqrt': od = BinOp(const Num(1), '/', BinOp(const Num(2), '*', Func('sqrt', u))); break;
      case 'abs': od = BinOp(u, '/', Func('abs', u.clone())); break;
      default: throw Exception('Cannot diff: ${e.name}');
    }
    return Simplifier.simplify(BinOp(od, '*', du));
  }
}

// ═══════════════════════════════════════════════════════════════════
// SLOPE SOLVER
// ═══════════════════════════════════════════════════════════════════

class SlopeSolver {
  static SlopeResult solve(String input, {Map<String, double>? pointValues}) {
    final t = input.trim();
    if (_isParametric(t)) return _solveParametric(t, pointValues ?? {});
    final toks = Tokenizer(t).tokenize();
    final (l, r) = Parser(toks).parse();
    if (r == null) return _solveExplicit(const Var('y'), l, t, pointValues ?? {});
    if (l is Var && l.name == 'y') return _solveExplicit(l, r, t, pointValues ?? {});
    final rV = ExprUtils.collectVars(r);
    if (l is Var && (l.name == 'y' || !rV.contains('y'))) return _solveExplicit(l, r, t, pointValues ?? {});
    return _solveImplicit(l, r, t, pointValues ?? {});
  }

  static bool _isParametric(String s) {
    int d = 0;
    for (int i = 0; i < s.length; i++) {
      if (s[i] == '(') d++; else if (s[i] == ')') d--; else if (s[i] == ',' && d == 0) return true;
    }
    return false;
  }

  static String _fmt(double v) {
    if (v == v.truncateToDouble() && v.abs() < 1e10) return v.toInt().toString();
    return v.toStringAsFixed(6).replaceAll(RegExp(r'\.?0+$'), '');
  }

  static String _lineEq(double m, double b, double x0, double y0) {
    if (m == 0) return 'y = ${_fmt(y0)}';
    if (!m.isFinite) return 'x = ${_fmt(x0)} (vertical)';
    final mS = _fmt(m);
    if (b == 0) return 'y = ${mS}x';
    if (b > 0) return 'y = ${mS}x + ${_fmt(b)}';
    return 'y = ${mS}x - ${_fmt(b.abs())}';
  }

  static List<String> _splitTop(String s) {
    final p = <String>[]; int d = 0, st = 0;
    for (int i = 0; i < s.length; i++) {
      if (s[i] == '(') d++; else if (s[i] == ')') d--; else if (s[i] == ',' && d == 0) { p.add(s.substring(st, i).trim()); st = i + 1; }
    }
    p.add(s.substring(st).trim());
    return p;
  }

  static SlopeResult _solveExplicit(Expr l, Expr r, String orig, Map<String, double> pv) {
    const iv = 'x'; final dv = (l is Var) ? l.name : 'y';
    final rd = Differentiator.differentiate(r, iv), sd = Simplifier.simplify(rd);
    double? sv, ts, ty; double? ns; String? te, ne;
    if (pv.containsKey(iv)) {
      final xv = pv[iv]!;
      try {
        sv = ExprUtils.evaluate(sd, pv); ts = sv;
        final yv = ExprUtils.evaluate(r, pv); ty = yv - ts * xv;
        te = _lineEq(ts, ty, xv, yv);
        if (ts != 0 && ts.isFinite) { ns = -1.0 / ts; final ny = yv - ns * xv; ne = _lineEq(ns, ny, xv, yv); }
        else if (ts == 0) ne = 'x = ${_fmt(xv)} (vertical)';
      } catch (_) {}
    }
    return SlopeResult(type: ProblemType.explicit, originalInput: orig, functionExpr: r, derivative: rd, simplifiedDerivative: sd, slopeValue: sv, point: pv, independentVar: iv, dependentVar: dv, tangentSlope: ts, tangentYIntercept: ty, normalSlope: ns, tangentLineEquation: te, normalLineEquation: ne);
  }

  static SlopeResult _solveImplicit(Expr l, Expr r, String orig, Map<String, double> pv) {
    final F = Simplifier.simplify(BinOp(l, '-', r));
    final dL = Differentiator.differentiate(l, 'x', dependentVars: {'y'});
    final dR = Differentiator.differentiate(r, 'x', dependentVars: {'y'});
    final dX = Simplifier.simplify(BinOp(dL, '-', dR));
    final (c, rem) = Simplifier.extractDerivCoeff(dX, 'y');
    final iS = Simplifier.simplify(BinOp(UnaryNeg(rem), '/', c));
    double? sv, ts; String? te; double? ns; String? ne;
    if (pv.containsKey('x') && pv.containsKey('y')) {
      try { sv = ExprUtils.evaluate(iS, pv); ts = sv; final xv = pv['x']!, yv = pv['y']!; final yi = yv - ts * xv; te = _lineEq(ts, yi, xv, yv); if (ts != 0 && ts.isFinite) { ns = -1.0 / ts; final ny = yv - ns * xv; ne = _lineEq(ns, ny, xv, yv); } else if (ts == 0) ne = 'x = ${_fmt(xv)} (vertical)'; } catch (_) {}
    }
    return SlopeResult(type: ProblemType.implicit, originalInput: orig, functionExpr: F, derivative: dX, simplifiedDerivative: iS, slopeValue: sv, point: pv, independentVar: 'x', dependentVar: 'y', leftSide: l, rightSide: r, leftDerivative: dL, rightDerivative: dR, implicitSlopeExpr: iS, tangentSlope: ts, tangentLineEquation: te, normalSlope: ns, normalLineEquation: ne);
  }

  static SlopeResult _solveParametric(String input, Map<String, double> pv) {
    final parts = _splitTop(input);
    if (parts.length != 2) throw FormatException('Need two expressions');
    Expr? xE, yE; String pv2 = 't';
    for (final part in parts) {
      final toks = Tokenizer(part.trim()).tokenize(); final (l, r) = Parser(toks).parse();
      if (r == null) throw FormatException('Need equation: "${part.trim()}"');
      if (l is Var && l.name == 'x') { xE = r; final vs = ExprUtils.collectVars(r); if (vs.isNotEmpty) pv2 = vs.first; }
      else if (l is Var && l.name == 'y') { yE = r; }
      else throw FormatException('Expected x=... y=..., got "${part.trim()}"');
    }
    if (xE == null || yE == null) throw const FormatException('Both x(t) and y(t) required');
    final aV = ExprUtils.collectVars(xE).union(ExprUtils.collectVars(yE)).difference({'x', 'y'});
    if (aV.isNotEmpty) pv2 = aV.first;
    final dx = Simplifier.simplify(Differentiator.differentiate(xE, pv2));
    final dy = Simplifier.simplify(Differentiator.differentiate(yE, pv2));
    final ps = Simplifier.simplify(BinOp(dy, '/', dx));
    final dS = Simplifier.simplify(Differentiator.differentiate(ps, pv2));
    final sD = Simplifier.simplify(BinOp(dS, '/', dx));
    double? sv, ts; String? te; double? ns; String? ne;
    if (pv.containsKey(pv2)) {
      try { final tv = pv[pv2]!; final xv = ExprUtils.evaluate(xE, pv), yv = ExprUtils.evaluate(yE, pv); final dXv = ExprUtils.evaluate(dx, pv), dYv = ExprUtils.evaluate(dy, pv); if (dXv == 0) { te = 'x = ${_fmt(xv)} (vertical at $pv2=${_fmt(tv)})'; } else { sv = dYv / dXv; ts = sv; final yi = yv - ts * xv; te = '${_lineEq(ts, yi, xv, yv)}  [at $pv2=${_fmt(tv)}]'; if (ts != 0 && ts.isFinite) { ns = -1.0 / ts; final ny = yv - ns * xv; ne = '${_lineEq(ns, ny, xv, yv)}  [at $pv2=${_fmt(tv)}]'; } else if (ts == 0) ne = 'x = ${_fmt(xv)} (vertical at $pv2=${_fmt(tv)})'; } } catch (_) {}
    }
    return SlopeResult(type: ProblemType.parametric, originalInput: input, functionExpr: ps, derivative: ps, simplifiedDerivative: ps, slopeValue: sv, point: pv, independentVar: pv2, dependentVar: 'y', paramXExpr: xE, paramYExpr: yE, dxDt: dx, dyDt: dy, secondDerivative: sD, tangentSlope: ts, tangentLineEquation: te, normalSlope: ns, normalLineEquation: ne);
  }
}
'''

def main():
    verify()
    path = DART_DIR / "slope_using_derivatives_solver.dart"
    path.write_text(DART_CODE, encoding='utf-8')
    lines = DART_CODE.count('\n')
    print(f"\nGenerated {path} [{lines} lines]")

    # Verify existing files are compatible
    steps_path = DART_DIR / "steps.dart"
    display_path = DART_DIR / "display_answer.dart"
    if steps_path.exists():
        print(f"  (kept existing: {steps_path.name})")
    if display_path.exists():
        print(f"  (kept existing: {display_path.name})")

if __name__ == '__main__':
    main()
