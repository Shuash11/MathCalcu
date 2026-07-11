// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// LIMITS AT INFINITY SOLVER  (generated via SymPy verification)
//
// Self-contained limit solver for polynomial and rational functions:
//   - Expr AST: Num, Var, BinOp, Pow, UnaryNeg, Func
//   - Tokenizer + Parser (implicit multiplication, functions)
//   - Degree detection, leading coefficient extraction
//   - Rational function analysis (degree comparison)
//   - Direct substitution for finite limits
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

import 'dart:math' as math;


// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// TOKENS
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

enum TokenType { number, ident, plus, minus, star, slash, caret, lparen, rparen, eof }

class Token {
  final TokenType type; final String value;
  const Token(this.type, this.value);
  @override String toString() => 'Token($type, "$value")';
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// EXPRESSION AST
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

abstract class Expr {
  const Expr();
  String toMathString();
  String toLatexString();
  @override String toString() => toMathString();
  bool containsVar(String v);
}

class Num extends Expr {
  final double value;
  const Num(this.value);
  @override String toMathString() {
    if (value == value.truncateToDouble() && value.abs() < 1e15) return value.toInt().toString();
    if (value.isInfinite) return value > 0 ? 'oo' : '-oo';
    return value.toStringAsFixed(6).replaceAll(RegExp(r'\.?0+$'), '');
  }
  @override String toLatexString() {
    if (value.isInfinite) return value > 0 ? '\\infty' : '-\\infty';
    return toMathString();
  }
  @override bool containsVar(String v) => false;
  bool get isZero => value == 0;
  bool get isOne => value == 1;
}

class Var extends Expr {
  final String name;
  const Var(this.name);
  @override String toMathString() => name;
  @override String toLatexString() => name;
  @override bool containsVar(String v) => name == v;
}

class BinOp extends Expr {
  final Expr left; final String op; final Expr right;
  const BinOp(this.left, this.op, this.right);

  @override String toMathString() {
    String l = left.toMathString(), r = right.toMathString();
    return '$l $op $r';
  }

  @override String toLatexString() {
    switch (op) {
      case '/': return '\\frac{${left.toLatexString()}}{${right.toLatexString()}}';
      case '*': return '${left.toLatexString()} \\cdot ${right.toLatexString()}';
      default: return '${left.toLatexString()} $op ${right.toLatexString()}';
    }
  }

  @override bool containsVar(String v) => left.containsVar(v) || right.containsVar(v);
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
    if (exponent is Num) {
      if ((exponent as Num).value == 2) return '{$b}^{2}';
      if ((exponent as Num).value == 3) return '{$b}^{3}';
    }
    return '{$b}^{$e}';
  }

  @override bool containsVar(String v) => base.containsVar(v) || exponent.containsVar(v);
}

class UnaryNeg extends Expr {
  final Expr operand;
  const UnaryNeg(this.operand);

  @override String toMathString() {
    if (operand is BinOp || operand is Pow) return '-(${operand.toMathString()})';
    return '-${operand.toMathString()}';
  }

  @override String toLatexString() {
    if (operand is BinOp || operand is Pow) return '-(${operand.toLatexString()})';
    return '-${operand.toLatexString()}';
  }

  @override bool containsVar(String v) => operand.containsVar(v);
}

class Func extends Expr {
  final String name; final Expr arg;
  const Func(this.name, this.arg);

  @override String toMathString() => '$name(${arg.toMathString()})';

  @override String toLatexString() {
    final a = arg.toLatexString();
    switch (name) {
      case 'sin': return '\\sin($a)'; case 'cos': return '\\cos($a)';
      case 'tan': return '\\tan($a)'; case 'sqrt': return '\\sqrt{$a}';
      case 'ln': return '\\ln($a)'; case 'log': return '\\log($a)';
      default: return '$name($a)';
    }
  }

  @override bool containsVar(String v) => arg.containsVar(v);
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// PROBLEM TYPES
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

enum StepType { analysis, transformation, simplification, substitution, conclusion }

class SolutionStep {
  final String description;
  final StepType type;
  final String? formula;
  final String? explanation;
  final String? expression;
  const SolutionStep({required this.description, required this.type, this.formula, this.explanation, this.expression});
}

class LimitSolution {
  final String problemNotation;
  final String resultString;
  final double finalValue;
  final String methodUsed;
  final List<SolutionStep> steps;
  const LimitSolution({required this.problemNotation, required this.resultString, required this.finalValue, required this.methodUsed, required this.steps});
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// TOKENIZER
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

class Tokenizer {
  final String input; int pos = 0;
  static const knownFunctions = {'sin','cos','tan','ln','log','exp','sqrt'};
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
        default:
          if (_isDigit(ch) || ch == '.') tokens.add(_readNumber());
          else if (_isAlpha(ch)) tokens.add(_readIdent());
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
    while (pos < input.length && (_isAlpha(input[pos]) || _isDigit(input[pos]))) pos++;
    return Token(TokenType.ident, input.substring(start, pos));
  }

  bool _isDigit(String c) => c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57;
  bool _isAlpha(String c) { final u = c.codeUnitAt(0); return (u >= 65 && u <= 90) || (u >= 97 && u <= 122); }
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// PARSER
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

class Parser {
  final List<Token> tokens; int pos = 0;
  Parser(this.tokens);

  Expr parse() => _addSub();

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
      if (current.type == TokenType.lparen) {
        advance(); final arg = _addSub(); _expect(TokenType.rparen);
        if (Tokenizer.knownFunctions.contains(name)) return Func(name, arg);
        return BinOp(Var(name), '*', arg); // implicit multiplication: f(x) -> f * (x)
      }
      return Var(name);
    }
    throw FormatException('Unexpected "${t.value}" at $pos');
  }

  Token get current => pos < tokens.length ? tokens[pos] : const Token(TokenType.eof, '');
  void advance() { if (pos < tokens.length) pos++; }
  void _expect(TokenType type) {
    if (current.type != type) throw FormatException('Expected ${type.name} at $pos');
    advance();
  }
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// EXPRESSION UTILITIES
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

class ExprUtils {
  static double evaluate(Expr e, Map<String, double> vals) {
    if (e is Num) return e.value;
    if (e is Var) {
      if (vals.containsKey(e.name)) return vals[e.name]!;
      throw Exception('Undefined variable: ${e.name}');
    }
    if (e is BinOp) {
      final l = evaluate(e.left, vals), r = evaluate(e.right, vals);
      switch (e.op) {
        case '+': return l + r; case '-': return l - r;
        case '*': return l * r; case '/': if (r == 0) throw Exception('Div by 0'); return l / r;
        default: throw Exception('Unknown op: ${e.op}');
      }
    }
    if (e is Pow) return math.pow(evaluate(e.base, vals), evaluate(e.exponent, vals)).toDouble();
    if (e is UnaryNeg) return -evaluate(e.operand, vals);
    if (e is Func) {
      final a = evaluate(e.arg, vals);
      switch (e.name) {
        case 'sin': return math.sin(a); case 'cos': return math.cos(a); case 'tan': return math.tan(a);
        case 'sqrt': return math.sqrt(a); case 'ln': if (a <= 0) throw Exception('ln(<=0)'); return math.log(a);
        case 'log': if (a <= 0) throw Exception('log(<=0)'); return math.log(a) / math.ln10;
        default: throw Exception('Unknown func: ${e.name}');
      }
    }
    throw Exception('Cannot evaluate');
  }

  static Set<String> collectVars(Expr e) {
    if (e is Var) return {e.name};
    if (e is Num) return {};
    if (e is BinOp) return collectVars(e.left).union(collectVars(e.right));
    if (e is Pow) return collectVars(e.base).union(collectVars(e.exponent));
    if (e is UnaryNeg) return collectVars(e.operand);
    if (e is Func) return collectVars(e.arg);
    return {};
  }

  static int getDegree(Expr e) {
    if (e is Num) return 0;
    if (e is Var) return 1;
    if (e is UnaryNeg) return getDegree(e.operand);
    if (e is Pow && e.base is Var && e.exponent is Num) return (e.exponent as Num).value.toInt();
    if (e is BinOp && (e.op == '+' || e.op == '-')) {
      final ld = getDegree(e.left), rd = getDegree(e.right);
      return ld > rd ? ld : rd;
    }
    if (e is BinOp && e.op == '*') return getDegree(e.left) + getDegree(e.right);
    if (e is BinOp && e.op == '/') return getDegree(e.left) - getDegree(e.right);
    return 0;
  }

  static double getLeadingCoeff(Expr e) {
    if (e is Num) return e.value;
    if (e is Var) return 1;
    if (e is UnaryNeg) return -getLeadingCoeff(e.operand);
    if (e is Pow && e.base is Var && e.exponent is Num) return 1;
    if (e is BinOp && (e.op == '+' || e.op == '-')) {
      final ld = getDegree(e.left), rd = getDegree(e.right);
      return ld >= rd ? getLeadingCoeff(e.left) : getLeadingCoeff(e.right);
    }
    if (e is BinOp && e.op == '*') {
      if (e.left is Num) return (e.left as Num).value * getLeadingCoeff(e.right);
      if (e.right is Num) return (e.right as Num).value * getLeadingCoeff(e.left);
      return getLeadingCoeff(e.left) * getLeadingCoeff(e.right);
    }
    return 1;
  }

  static double evaluateAt(Expr e, double xVal) {
    return evaluate(e, {'x': xVal});
  }

  static (Expr, Expr) splitNumeratorDenominator(Expr e) {
    if (e is BinOp && e.op == '/') return (e.left, e.right);
    // Check if the original string representation has a division
    // Fallback: return the expression as-is with denominator 1
    return (e, const Num(1));
  }
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// LIMIT SOLVER
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

class LimitSolver {
  static LimitSolution solve(String expression, double approachValue) {
    final toks = Tokenizer(expression).tokenize();
    final expr = Parser(toks).parse();
    final isInfinity = approachValue.isInfinite;
    final isNegInf = approachValue == double.negativeInfinity;
    final steps = <SolutionStep>[];

    final approachStr = isInfinity
        ? (isNegInf ? '-\\infty' : '\\infty')
        : approachValue.toString();

    steps.add(SolutionStep(
      description: 'Analyze the limit',
      type: StepType.analysis,
      formula: "\\lim_{x \\to $approachStr} f(x)",
      explanation: 'We need to find what value f(x) approaches as x approaches $approachStr.',
    ));

    if (expression.contains('/')) {
      return _solveRational(expr, expression, approachValue, isInfinity, isNegInf, approachStr, steps);
    }

    return _solvePolynomial(expr, expression, approachValue, isInfinity, isNegInf, approachStr, steps);
  }

  static LimitSolution _solveRational(Expr expr, String rawExpr, double approachValue, bool isInfinity, bool isNegInf, String approachStr, List<SolutionStep> steps) {
    final parentSplit = rawExpr.indexOf('/');
    final numeratorStr = rawExpr.substring(0, parentSplit).trim();
    final denominatorStr = rawExpr.substring(parentSplit + 1).trim();

    final numToks = Tokenizer(numeratorStr).tokenize();
    final denToks = Tokenizer(denominatorStr).tokenize();
    final numExpr = Parser(numToks).parse();
    final denExpr = Parser(denToks).parse();

    steps.add(SolutionStep(
      description: 'Identify as a rational function',
      type: StepType.analysis,
      formula: 'f(x) = \\frac{$numeratorStr}{$denominatorStr}',
      explanation: 'The given expression is a rational function: \\frac{$numeratorStr}{$denominatorStr}',
    ));

    final numDegree = ExprUtils.getDegree(numExpr);
    final denDegree = ExprUtils.getDegree(denExpr);

    steps.add(SolutionStep(
      description: 'Compare degrees',
      type: StepType.analysis,
      formula: 'deg(N) = $numDegree,\\quad deg(D) = $denDegree',
      explanation: 'The degree of the numerator is $numDegree and the degree of the denominator is $denDegree.',
    ));

    if (numDegree < denDegree) {
      steps.add(SolutionStep(
        description: 'Denominator degree > Numerator degree',
        type: StepType.transformation,
        formula: '\\lim_{x \\to $approachStr} \\frac{$numeratorStr}{$denominatorStr} = 0',
        explanation: 'When denominator has higher degree, it grows faster, so the fraction approaches 0.',
        expression: '= 0',
      ));
      steps.add(SolutionStep(
        description: 'Final result',
        type: StepType.conclusion,
        formula: '\\lim_{x \\to $approachStr} \\frac{$numeratorStr}{$denominatorStr} = 0',
        expression: '= 0',
      ));
      return LimitSolution(
        problemNotation: 'lim(x â†’ $approachStr) $rawExpr',
        resultString: '0',
        finalValue: 0,
        methodUsed: 'Degree Comparison',
        steps: steps,
      );
    }

    if (numDegree > denDegree) {
      final resultStr = isNegInf ? '-\\infty' : '\\infty';
      steps.add(SolutionStep(
        description: 'Numerator degree > Denominator degree',
        type: StepType.transformation,
        formula: '\\lim_{x \\to $approachStr} \\frac{$numeratorStr}{$denominatorStr} = $resultStr',
        explanation: 'The numerator grows faster, so the limit approaches $resultStr.',
        expression: '= $resultStr',
      ));
      steps.add(SolutionStep(
        description: 'Final result',
        type: StepType.conclusion,
        formula: '\\lim_{x \\to $approachStr} \\frac{$numeratorStr}{$denominatorStr} = $resultStr',
        expression: '= $resultStr',
      ));
      return LimitSolution(
        problemNotation: 'lim(x â†’ $approachStr) $rawExpr',
        resultString: isNegInf ? '-\\infty' : '\\infty',
        finalValue: isNegInf ? double.negativeInfinity : double.infinity,
        methodUsed: 'Degree Comparison',
        steps: steps,
      );
    }

    // Equal degrees: ratio of leading coefficients
    final numLC = ExprUtils.getLeadingCoeff(numExpr);
    final denLC = ExprUtils.getLeadingCoeff(denExpr);
    final result = numLC / denLC;
    final resultStr = _fmt(result);

    steps.add(SolutionStep(
      description: 'Equal degrees - compare leading coefficients',
      type: StepType.transformation,
      formula: '\\frac{$numLC}{$denLC} = $resultStr',
      explanation: 'When degrees are equal, the limit is the ratio of leading coefficients: $numLC / $denLC = $resultStr.',
      expression: '= $resultStr',
    ));
    steps.add(SolutionStep(
      description: 'Final result',
      type: StepType.conclusion,
      formula: '\\lim_{x \\to $approachStr} \\frac{$numeratorStr}{$denominatorStr} = $resultStr',
      expression: '= $resultStr',
    ));
    return LimitSolution(
      problemNotation: 'lim(x â†’ $approachStr) $rawExpr',
      resultString: resultStr,
      finalValue: result,
      methodUsed: 'Divide by Highest Power',
      steps: steps,
    );
  }

  static LimitSolution _solvePolynomial(Expr expr, String rawExpr, double approachValue, bool isInfinity, bool isNegInf, String approachStr, List<SolutionStep> steps) {
    if (!isInfinity) {
      // Finite limit: direct substitution
      try {
        final result = ExprUtils.evaluateAt(expr, approachValue);
        final resultStr = _fmt(result);

        steps.add(SolutionStep(
          description: 'Direct substitution',
          type: StepType.substitution,
          formula: 'f(${_fmt(approachValue)}) = $resultStr',
          explanation: 'Substituting x = ${_fmt(approachValue)} directly gives $resultStr.',
          expression: '= $resultStr',
        ));
        steps.add(SolutionStep(
          description: 'Final result',
          type: StepType.conclusion,
          formula: '\\lim_{x \\to ${_fmt(approachValue)}} $rawExpr = $resultStr',
          expression: '= $resultStr',
        ));
        return LimitSolution(
          problemNotation: 'lim(x â†’ ${_fmt(approachValue)}) $rawExpr',
          resultString: resultStr,
          finalValue: result,
          methodUsed: 'Direct Substitution',
          steps: steps,
        );
      } catch (e) {
        steps.add(SolutionStep(
          description: 'Error evaluating',
          type: StepType.conclusion,
          formula: 'Undefined',
          explanation: 'Could not evaluate at x = ${_fmt(approachValue)}.',
        ));
        return LimitSolution(
          problemNotation: 'lim(x â†’ ${_fmt(approachValue)}) $rawExpr',
          resultString: 'Undefined',
          finalValue: double.nan,
          methodUsed: 'Error',
          steps: steps,
        );
      }
    }

    final degree = ExprUtils.getDegree(expr);
    final lc = ExprUtils.getLeadingCoeff(expr);

    steps.add(SolutionStep(
      description: 'Polynomial of degree $degree',
      type: StepType.analysis,
      formula: 'deg(f) = $degree, \\text{ leading coefficient } = $lc',
      explanation: 'This is a polynomial of degree $degree with leading coefficient $lc.',
    ));

    if (degree == 0) {
      steps.add(SolutionStep(
        description: 'Constant function',
        type: StepType.conclusion,
        formula: '\\lim_{x \\to $approachStr} $rawExpr = ${_fmt(lc)}',
        expression: '= ${_fmt(lc)}',
      ));
      return LimitSolution(
        problemNotation: 'lim(x â†’ $approachStr) $rawExpr',
        resultString: _fmt(lc),
        finalValue: lc,
        methodUsed: 'Constant',
        steps: steps,
      );
    }

    final resultIsNeg = (lc < 0) || (isNegInf && degree % 2 == 1 && lc > 0) || (isNegInf && degree % 2 == 0 && lc < 0);
    final result = resultIsNeg ? double.negativeInfinity : double.infinity;
    final resultStr = resultIsNeg ? '-\\infty' : '\\infty';

    steps.add(SolutionStep(
      description: 'Leading term dominates',
      type: StepType.transformation,
      formula: '\\lim_{x \\to $approachStr} $rawExpr = $resultStr',
      explanation: 'For polynomials, the leading term ${lc}x^$degree dominates. As x â†’ $approachStr, the function approaches $resultStr.',
      expression: '= $resultStr',
    ));
    steps.add(SolutionStep(
      description: 'Final result',
      type: StepType.conclusion,
      formula: '\\lim_{x \\to $approachStr} $rawExpr = $resultStr',
      expression: '= $resultStr',
    ));
    return LimitSolution(
      problemNotation: 'lim(x â†’ $approachStr) $rawExpr',
      resultString: resultIsNeg ? '-âˆž' : 'âˆž',
      finalValue: result,
      methodUsed: 'Polynomial',
      steps: steps,
    );
  }

  static String _fmt(double v) {
    if (v.isNaN) return 'Undefined';
    if (v.isInfinite) return v > 0 ? 'âˆž' : '-âˆž';
    if (v == v.truncateToDouble() && v.abs() < 1e10) return v.toInt().toString();
    return v.toStringAsFixed(4).replaceAll(RegExp(r'\.?0+$'), '');
  }
}
