// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// DERIVATIVE SOLVER  (generated via SymPy verification)
//
// Self-contained CAS engine:
//   - Expr AST: Num, Var, BinOp, Neg, Func, Sqrt, Abs
//   - Tokenizer + Parser (supports implicit multiplication)
//   - Differentiate (power, product, quotient, chain, trig, exp, log)
//   - Simplify
//   - Step-by-step generation + classroom formatting
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

import 'dart:math' as math;


// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// EXPRESSION AST
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

abstract class Expr {
  const Expr();
  Expr diff(String v);
  Expr simplify();
  bool hasVar(String v);
  bool get isConst;
  double? get constValue;
  @override String toString();
  String format({bool compact = false});
}

class Num extends Expr {
  final double value;
  const Num(this.value);
  @override Expr diff(String v) => const Num(0);
  @override Expr simplify() => this;
  @override bool hasVar(String v) => false;
  @override bool get isConst => true;
  @override double? get constValue => value;
  @override bool operator ==(Object o) => o is Num && value == o.value;
  @override int get hashCode => value.hashCode;
  @override String toString() => value == value.truncateToDouble()
      ? value.toInt().toString() : value.toString();
  @override String format({bool compact = false}) => toString();
}

class Var extends Expr {
  final String name;
  const Var(this.name);
  @override Expr diff(String v) => Num(name == v ? 1.0 : 0.0);
  @override Expr simplify() => this;
  @override bool hasVar(String v) => name == v;
  @override bool get isConst => false;
  @override double? get constValue => null;
  @override bool operator ==(Object o) => o is Var && name == o.name;
  @override int get hashCode => name.hashCode;
  @override String toString() => name;
  @override String format({bool compact = false}) => name;
}

class BinOp extends Expr {
  final String op;
  final Expr left, right;
  const BinOp(this.op, this.left, this.right);

  @override Expr diff(String v) {
    switch (op) {
      case '+': return BinOp('+', left.diff(v), right.diff(v));
      case '-': return BinOp('-', left.diff(v), right.diff(v));
      case '*':
        return BinOp('+',
            BinOp('*', left.diff(v), right),
            BinOp('*', left, right.diff(v)));
      case '/':
        final num = BinOp('-',
            BinOp('*', left.diff(v), right),
            BinOp('*', left, right.diff(v)));
        return BinOp('/', num, BinOp('^', right, const Num(2)));
      case '^':
        if (right.isConst) {
          final n = right.constValue!;
          return BinOp('*',
              BinOp('*', Num(n), BinOp('^', left, Num(n - 1))),
              left.diff(v));
        }
        if (left is Var && (left as Var).name == 'e') {
          return BinOp('*', this, right.diff(v));
        }
        if (left.isConst) {
          return BinOp('*', BinOp('*', this, Func('ln', left)), right.diff(v));
        }
        return BinOp('*', this, BinOp('+',
            BinOp('*', right.diff(v), Func('ln', left)),
            BinOp('*', right, BinOp('/', left.diff(v), left))));
      default: throw ArgumentError('Unknown op: $op');
    }
  }

  @override Expr simplify() {
    Expr l = left.simplify(), r = right.simplify();
    if (l.isConst && r.isConst) {
      final lv = l.constValue!, rv = r.constValue!;
      switch (op) {
        case '+': return Num(lv + rv);
        case '-': return Num(lv - rv);
        case '*': return Num(lv * rv);
        case '/': return rv != 0 ? Num(lv / rv) : this;
        case '^': return Num(math.pow(lv, rv).toDouble());
      }
    }
    switch (op) {
      case '+':
        if (_isZero(l)) return r;
        if (_isZero(r)) return l;
        if (l == r) return BinOp('*', const Num(2), l);
      case '-':
        if (_isZero(l)) return Neg(r);
        if (_isZero(r)) return l;
        if (l == r) return const Num(0);
      case '*':
        if (_isZero(l) || _isZero(r)) return const Num(0);
        if (_isOne(l)) return r;
        if (_isOne(r)) return l;
        if (l is Num && r is BinOp && r.op == '*' && r.left is Num)
          return BinOp('*', Num(l.value * (r.left as Num).value), r.right).simplify();
      case '/':
        if (_isZero(l)) return const Num(0);
        if (_isOne(r)) return l;
        if (l == r) return const Num(1);
        if (l is BinOp && l.op == '*' && l.left is Num && r is Num) {
          final nl = (l.left as Num).value, nr = r.value;
          if (nl == nr) return l.right.simplify();
          if (nr != 0 && (nl / nr).round() == nl / nr)
            return BinOp('*', Num(nl / nr), l.right).simplify();
        }
      case '^':
        if (_isZero(r)) return const Num(1);
        if (_isOne(r)) return l;
        if (_isZero(l) && r.isConst && r.constValue! > 0) return const Num(0);
        if (_isOne(l)) return const Num(1);
    }
    return BinOp(op, l, r);
  }

  bool _isZero(Expr e) => e.isConst && e.constValue == 0;
  bool _isOne(Expr e) => e.isConst && e.constValue == 1;

  @override bool hasVar(String v) => left.hasVar(v) || right.hasVar(v);
  @override bool get isConst => left.isConst && right.isConst;
  @override double? get constValue {
    if (!isConst) return null;
    final l = left.constValue!, r = right.constValue!;
    switch (op) {
      case '+': return l + r;
      case '-': return l - r;
      case '*': return l * r;
      case '/': return r != 0 ? l / r : null;
      case '^': return math.pow(l, r).toDouble();
      default: return null;
    }
  }
  @override bool operator ==(Object o) => o is BinOp && op == o.op && left == o.left && right == o.right;
  @override int get hashCode => Object.hash(op, left, right);

  @override String toString() {
    final l = _wrap(left, _prec(op)), r = _wrap(right, _prec(op), true);
    return '$l $op $r';
  }
  @override String format({bool compact = false}) => toString();

  String _wrap(Expr e, int p, [bool rightSide = false]) {
    if (e is BinOp) {
      final ep = _prec(e.op);
      if (ep < p || (ep == p && rightSide && (op == '-' || op == '/' || op == '^'))) return '($e)';
    }
    if (e is Neg) return '($e)';
    return e.toString();
  }
  static int _prec(String op) {
    switch (op) { case '+': case '-': return 1; case '*': case '/': return 2; case '^': return 3; default: return 0; }
  }
}

class Neg extends Expr {
  final Expr expr;
  const Neg(this.expr);
  @override Expr diff(String v) => Neg(expr.diff(v));
  @override Expr simplify() {
    final s = expr.simplify();
    if (s is Num) return Num(-s.value);
    if (s is Neg) return s.expr;
    return Neg(s);
  }
  @override bool hasVar(String v) => expr.hasVar(v);
  @override bool get isConst => expr.isConst;
  @override double? get constValue { final v = expr.constValue; return v != null ? -v : null; }
  @override bool operator ==(Object o) => o is Neg && expr == o.expr;
  @override int get hashCode => expr.hashCode;
  @override String toString() => '-$expr';
  @override String format({bool compact = false}) => '-${expr.format(compact: compact)}';
}

class Func extends Expr {
  final String name;
  final Expr arg;
  const Func(this.name, this.arg);

  @override Expr diff(String v) {
    final inner = arg.diff(v);
    Expr outer;
    switch (name) {
      case 'sin': outer = Func('cos', arg); break;
      case 'cos': outer = Neg(Func('sin', arg)); break;
      case 'tan': outer = BinOp('^', Func('sec', arg), const Num(2)); break;
      case 'sec': outer = BinOp('*', Func('sec', arg), Func('tan', arg)); break;
      case 'csc': outer = Neg(BinOp('*', Func('csc', arg), Func('cot', arg))); break;
      case 'cot': outer = Neg(BinOp('^', Func('csc', arg), const Num(2))); break;
      case 'exp': outer = this; break;
      case 'ln': outer = BinOp('/', const Num(1), arg); break;
      case 'log': outer = BinOp('/', const Num(1), BinOp('*', arg, Func('ln', const Num(10)))); break;
      case 'sqrt': outer = BinOp('/', const Num(1), BinOp('*', const Num(2), Sqrt(arg))); break;
      case 'abs': outer = BinOp('/', arg, Func('abs', arg)); break;
      default: throw ArgumentError('Unknown function: $name');
    }
    return BinOp('*', outer, inner);
  }

  @override Expr simplify() {
    final s = arg.simplify();
    if (s.isConst) {
      final v = s.constValue!;
      try {
        switch (name) {
          case 'exp': return Num(math.exp(v));
          case 'sqrt': return v >= 0 ? Num(math.sqrt(v)) : this;
          case 'abs': return Num(v.abs());
          case 'sin': return Num(math.sin(v));
          case 'cos': return Num(math.cos(v));
          case 'tan': return Num(math.tan(v));
          case 'ln': return v > 0 ? Num(math.log(v)) : this;
        }
      } catch (_) { return this; }
    }
    if (name == 'sqrt' && s is BinOp && s.op == '^' && s.right == const Num(2)) return Abs(s.left);
    return Func(name, s);
  }

  @override bool hasVar(String v) => arg.hasVar(v);
  @override bool get isConst => arg.isConst;
  @override double? get constValue => null;
  @override bool operator ==(Object o) => o is Func && name == o.name && arg == o.arg;
  @override int get hashCode => Object.hash(name, arg);
  @override String toString() => '$name($arg)';
  @override String format({bool compact = false}) => '$name(${arg.format(compact: compact)})';
}

class Sqrt extends Expr {
  final Expr arg;
  const Sqrt(this.arg);
  @override Expr diff(String v) => BinOp('/', arg.diff(v), BinOp('*', const Num(2), Sqrt(arg)));
  @override Expr simplify() {
    final s = arg.simplify();
    if (s.isConst) { final v = s.constValue!; if (v >= 0) return Num(math.sqrt(v)); }
    if (s is BinOp && s.op == '^' && s.right == const Num(2)) return Abs(s.left);
    return Sqrt(s);
  }
  @override bool hasVar(String v) => arg.hasVar(v);
  @override bool get isConst => arg.isConst;
  @override double? get constValue => null;
  @override bool operator ==(Object o) => o is Sqrt && arg == o.arg;
  @override int get hashCode => arg.hashCode;
  @override String toString() => '√($arg)';
  @override String format({bool compact = false}) => '√(${arg.format(compact: compact)})';
}

class Abs extends Expr {
  final Expr arg;
  const Abs(this.arg);
  @override Expr diff(String v) => BinOp('*', arg.diff(v), BinOp('/', arg, Abs(arg)));
  @override Expr simplify() { final s = arg.simplify(); if (s.isConst) return Num(s.constValue!.abs()); return Abs(s); }
  @override bool hasVar(String v) => arg.hasVar(v);
  @override bool get isConst => arg.isConst;
  @override double? get constValue => null;
  @override bool operator ==(Object o) => o is Abs && arg == o.arg;
  @override int get hashCode => arg.hashCode;
  @override String toString() => '|$arg|';
  @override String format({bool compact = false}) => '|${arg.format(compact: compact)}|';
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// TOKENIZER & PARSER
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

enum TokenType { number, variable, operator, lParen, rParen, function, eof }

class Token {
  final TokenType type; final String value; final int pos;
  const Token(this.type, this.value, this.pos);
  @override String toString() => 'Token($type, "$value")';
}

class ParseException implements Exception {
  final String message; final int pos;
  ParseException(this.message, this.pos);
  @override String toString() => 'ParseException: $message at $pos';
}

class Tokenizer {
  final String input;
  int _pos = 0;
  Tokenizer(this.input);

  List<Token> tokenize() {
    final tokens = <Token>[];
    while (_pos < input.length) {
      _skipWs();
      if (_pos >= input.length) break;
      final char = input[_pos], start = _pos;
      if (_isDigit(char) || (char == '.' && _pos + 1 < input.length && _isDigit(input[_pos + 1]))) {
        tokens.add(_readNumber(start));
      } else if (_isLetter(char) || char == '√') {
        tokens.add(_readIdent(start));
      } else if ('+-*/^'.contains(char)) {
        tokens.add(Token(TokenType.operator, char, start)); _pos++;
      } else if (char == '(') { tokens.add(Token(TokenType.lParen, '(', start)); _pos++; }
      else if (char == ')') { tokens.add(Token(TokenType.rParen, ')', start)); _pos++; }
      else { throw ParseException('Unexpected "$char" at $start', start); }
    }
    tokens.add(Token(TokenType.eof, '', _pos));
    return tokens;
  }

  void _skipWs() { while (_pos < input.length && input[_pos] == ' ') _pos++; }
  bool _isDigit(String c) => c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57;
  bool _isLetter(String c) { final code = c.toLowerCase().codeUnitAt(0); return code >= 97 && code <= 122; }

  Token _readNumber(int start) {
    final b = StringBuffer(); bool dot = false;
    while (_pos < input.length) {
      final c = input[_pos];
      if (_isDigit(c)) { b.write(c); _pos++; }
      else if (c == '.' && !dot) { b.write(c); dot = true; _pos++; }
      else break;
    }
    return Token(TokenType.number, b.toString(), start);
  }

  Token _readIdent(int start) {
    final b = StringBuffer();
    while (_pos < input.length && (_isLetter(input[_pos]) || _isDigit(input[_pos]) || input[_pos] == '√')) {
      b.write(input[_pos]); _pos++;
    }
    var v = b.toString().toLowerCase();
    if (v.contains('√')) v = v.replaceAll('√', 'sqrt');
    const funcs = {'exp','sqrt','abs','sin','cos','tan','sec','csc','cot','ln','log'};
    return Token(funcs.contains(v) ? TokenType.function : TokenType.variable, v, start);
  }
}

class Parser {
  final List<Token> tokens;
  int _i = 0;
  Parser(this.tokens);

  Expr parse() {
    final e = _expr();
    if (_i < tokens.length && tokens[_i].type != TokenType.eof)
      throw ParseException('Unexpected: ${tokens[_i]}', tokens[_i].pos);
    return e;
  }

  Expr _expr() => _addSub();
  Expr _addSub() {
    var l = _mulDiv();
    while (_match('+') || _match('-')) { final op = _prev().value; final r = _mulDiv(); l = BinOp(op, l, r); }
    return l;
  }

  Expr _mulDiv() {
    var l = _unary();
    while (true) {
      if (_match('*') || _match('/')) { final op = _prev().value; final r = _unary(); l = BinOp(op, l, r); }
      else if (_isImplicitMul()) { final r = _unary(); l = BinOp('*', l, r); }
      else break;
    }
    return l;
  }

  bool _isImplicitMul() {
    if (_i >= tokens.length) return false;
    final n = tokens[_i], p = tokens[_i - 1];
    if (p.type == TokenType.rParen) return n.type == TokenType.lParen || n.type == TokenType.number || n.type == TokenType.variable || n.type == TokenType.function;
    if (p.type == TokenType.number) return n.type == TokenType.variable || n.type == TokenType.function || n.type == TokenType.lParen;
    if (p.type == TokenType.variable) return n.type == TokenType.variable || n.type == TokenType.function || n.type == TokenType.lParen;
    return false;
  }

  Expr _unary() {
    if (_match('-')) return Neg(_unary());
    if (_match('+')) return _unary();
    return _power();
  }

  Expr _power() {
    var b = _primary();
    if (_match('^')) { final e = _unary(); b = BinOp('^', b, e); }
    return b;
  }

  Expr _primary() {
    final t = _peek();
    switch (t.type) {
      case TokenType.number: _advance(); return Num(double.parse(t.value));
      case TokenType.variable: _advance(); return Var(t.value);
      case TokenType.function: return _parseFunc();
      case TokenType.lParen: _advance(); final e = _expr(); _expect(TokenType.rParen); return e;
      case TokenType.eof: throw ParseException('Unexpected end', t.pos);
      default: throw ParseException('Unexpected: $t', t.pos);
    }
  }

  Expr _parseFunc() {
    final name = _advance().value;
    _expect(TokenType.lParen);
    final arg = _expr();
    _expect(TokenType.rParen);
    if (name == 'sqrt') return Sqrt(arg);
    if (name == 'abs') return Abs(arg);
    return Func(name, arg);
  }

  Token _peek() => tokens[_i];
  Token _advance() => tokens[_i++];
  Token _prev() => tokens[_i - 1];
  bool _match(String op) { if (_peek().type == TokenType.operator && _peek().value == op) { _advance(); return true; } return false; }
  void _expect(TokenType type) { if (_peek().type != type) throw ParseException('Expected $type, got ${_peek().type}', _peek().pos); _advance(); }
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// STEP DATA
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

enum StepType { original, identifyRule, applyRule, simplify, finalResult }

class DerivativeStep {
  final StepType type; final String description; final Expr expression; final String? rule;
  const DerivativeStep({required this.type, required this.description, required this.expression, this.rule});
  @override String toString() => '[$type] $description: $expression';
}

class DerivativeSteps {
  final Expr original; final String variable; final Expr derivative; final List<DerivativeStep> steps;
  const DerivativeSteps({required this.original, required this.variable, required this.derivative, required this.steps});
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// SOLVER
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

class DerivativeSolver {
  static Expr parse(String expr) {
    final p = _preprocess(expr);
    final tokens = Tokenizer(p).tokenize();
    return Parser(tokens).parse();
  }

  static String _preprocess(String input) {
    var r = input;
    // Unicode superscripts → caret
    final sup = {'â°': '^0','Â¹': '^1','²': '^2','Â³': '^3','â´': '^4','âµ': '^5','â¶': '^6','â·': '^7','â¸': '^8','â¹': '^9'};
    sup.forEach((k, v) { r = r.replaceAll(k, v); });
    r = r.replaceAll('âˆ’', '-').replaceAll('÷—', '*').replaceAll('×', '/');
    // Implicit multiplication parens
    r = r.replaceAllMapped(RegExp(r'(\))\s*(\()'), (m) => '${m[1]}*${m[2]}');
    r = r.replaceAllMapped(RegExp(r'(\d)\('), (m) => '${m[1]}*(');
    r = r.replaceAllMapped(RegExp(r'\)(\d)'), (m) => ')*${m[1]}');
    r = r.replaceAllMapped(RegExp(r'(?<![a-zA-Z])([a-zA-Z])\('), (m) => '${m[1]}*(');
    // sqrt shorthand
    r = r.replaceAllMapped(RegExp(r'sqrt([a-zA-Z])'), (m) => 'sqrt(${m[1]})');
    r = r.replaceAllMapped(RegExp(r'sqrt(\d)'), (m) => 'sqrt(${m[1]})');
    r = r.replaceAllMapped(RegExp(r'√([a-zA-Z])'), (m) => 'sqrt(${m[1]})');
    r = r.replaceAllMapped(RegExp(r'√(\d)'), (m) => 'sqrt(${m[1]})');
    r = r.replaceAll('√(', 'sqrt(');
    return r.replaceAll(RegExp(r'\s+'), '');
  }

  static Expr differentiate(Expr e, String v) => e.diff(v);

  static Expr simplify(Expr e) {
    for (int i = 0; i < 10; i++) { final n = e.simplify(); if (n == e) break; e = n; }
    return e;
  }

  static Expr solve(String expr, String v) {
    final p = parse(expr);
    return simplify(differentiate(p, v));
  }

  static DerivativeSteps getSteps(String expr, String v) {
    final parsed = parse(expr);
    final steps = <DerivativeStep>[];

    steps.add(DerivativeStep(
      type: StepType.original,
      description: 'Find derivative of f($v) = $parsed',
      expression: parsed,
    ));

    final rule = _determineRule(parsed);
    steps.add(DerivativeStep(
      type: StepType.identifyRule,
      description: 'Apply: $rule',
      expression: parsed,
      rule: rule,
    ));

    final raw = differentiate(parsed, v);
    steps.add(DerivativeStep(
      type: StepType.applyRule,
      description: 'Compute derivative',
      expression: raw,
    ));

    final simp = simplify(raw);
    if (simp != raw) {
      steps.add(DerivativeStep(
        type: StepType.simplify,
        description: 'Simplify the result',
        expression: simp,
      ));
    }

    steps.add(DerivativeStep(
      type: StepType.finalResult,
      description: "Derivative: f'($v) = $simp",
      expression: simp,
    ));

    return DerivativeSteps(original: parsed, variable: v, derivative: simp, steps: steps);
  }

  static String _determineRule(Expr e) {
    if (e is BinOp && e.op == '^' && e.right.isConst) return 'Power Rule';
    if (e is BinOp && e.op == '^' && e.left.isConst && !e.right.isConst) return 'Exponential Rule';
    if (e is BinOp) {
      switch (e.op) {
        case '/': return 'Quotient Rule';
        case '*':
          if (e.left.isConst || e.right.isConst) return 'Constant Multiple';
          return 'Product Rule';
        case '+': case '-': return 'Sum/Difference Rule';
      }
    }
    if (e is Func) {
      if (e.arg.hasVar('x')) return 'Chain Rule';
      switch (e.name) {
        case 'sin': return 'Sine Derivative';
        case 'cos': return 'Cosine Derivative';
        case 'tan': return 'Tangent Derivative';
        case 'sec': return 'Secant Derivative';
        case 'csc': return 'Cosecant Derivative';
        case 'cot': return 'Cotangent Derivative';
        case 'exp': return 'Exponential Derivative';
        case 'ln': return 'Natural Log Derivative';
        case 'sqrt': return 'Square Root Derivative';
        case 'abs': return 'Absolute Value Derivative';
        default: return 'Function Derivative';
      }
    }
    return 'Basic Derivative';
  }
}
