// math_engine.dart
// Three pure-math workers that operate on Expr trees:
//   ExprUtils    — tree inspection and numeric evaluation
//   Simplifier   — algebraic reduction of Expr trees
//   Differentiator — symbolic differentiation rules
// Nothing here parses text or builds SlopeResults.
import 'dart:math' as math;
import 'models.dart';
// ==================== EXPRESSION UTILITIES ====================

class ExprUtils {
  /// Returns true if the expression tree contains the named variable.
  static bool containsVar(Expr e, String varName) {
    if (e is Var) return e.name == varName;
    if (e is Num || e is Const || e is DerivSym) return false;
    if (e is BinOp)
      return containsVar(e.left, varName) || containsVar(e.right, varName);
    if (e is Pow)
      return containsVar(e.base, varName) || containsVar(e.exponent, varName);
    if (e is UnaryNeg) return containsVar(e.operand, varName);
    if (e is Func) return containsVar(e.arg, varName);
    return false;
  }

  /// Returns true if any DerivSym node exists anywhere in the tree.
  static bool containsDerivSym(Expr e) {
    if (e is DerivSym) return true;
    if (e is Num || e is Const || e is Var) return false;
    if (e is BinOp)
      return containsDerivSym(e.left) || containsDerivSym(e.right);
    if (e is Pow)
      return containsDerivSym(e.base) || containsDerivSym(e.exponent);
    if (e is UnaryNeg) return containsDerivSym(e.operand);
    if (e is Func) return containsDerivSym(e.arg);
    return false;
  }

  /// Collects the set of all variable names in the tree.
  static Set<String> collectVars(Expr e) {
    if (e is Var) return {e.name};
    if (e is Num || e is Const || e is DerivSym) return {};
    if (e is BinOp) return collectVars(e.left).union(collectVars(e.right));
    if (e is Pow) return collectVars(e.base).union(collectVars(e.exponent));
    if (e is UnaryNeg) return collectVars(e.operand);
    if (e is Func) return collectVars(e.arg);
    return {};
  }

  /// Substitutes every occurrence of [varName] with a clone of [replacement].
  static Expr substitute(Expr e, String varName, Expr replacement) {
    if (e is Var && e.name == varName) return replacement.clone();
    if (e is Num || e is Const || e is DerivSym) return e.clone();
    if (e is Var) return e.clone();
    if (e is BinOp) {
      return BinOp(
        substitute(e.left, varName, replacement),
        e.op,
        substitute(e.right, varName, replacement),
      );
    }
    if (e is Pow) {
      return Pow(
        substitute(e.base, varName, replacement),
        substitute(e.exponent, varName, replacement),
      );
    }
    if (e is UnaryNeg)
      return UnaryNeg(substitute(e.operand, varName, replacement));
    if (e is Func) return Func(e.name, substitute(e.arg, varName, replacement));
    return e.clone();
  }

  /// Numerically evaluates the expression tree given a map of variable values.
  static double evaluate(Expr e, Map<String, double> values) {
    if (e is Num) return e.value;
    if (e is Const) return e.numericValue;
    if (e is Var) {
      if (values.containsKey(e.name)) return values[e.name]!;
      throw Exception('Undefined variable: ${e.name}');
    }
    if (e is DerivSym) {
      final key = e.toMathString();
      if (values.containsKey(key)) return values[key]!;
      throw Exception('Undefined derivative symbol: $key');
    }
    if (e is BinOp) {
      final l = evaluate(e.left, values);
      final r = evaluate(e.right, values);
      switch (e.op) {
        case '+':
          return l + r;
        case '-':
          return l - r;
        case '*':
          return l * r;
        case '/':
          if (r == 0) throw Exception('Division by zero');
          return l / r;
        default:
          throw Exception('Unknown operator: ${e.op}');
      }
    }
    if (e is Pow) {
      final b = evaluate(e.base, values);
      final exp = evaluate(e.exponent, values);
      return math.pow(b, exp).toDouble();
    }

    double sinh(double x) => (math.exp(x) - math.exp(-x)) / 2;
    double cosh(double x) => (math.exp(x) + math.exp(-x)) / 2;
    double tanh(double x) => sinh(x) / cosh(x);

    if (e is UnaryNeg) return -evaluate(e.operand, values);
    if (e is Func) {
      final a = evaluate(e.arg, values);
      switch (e.name) {
        case 'sin':    return math.sin(a);
        case 'cos':    return math.cos(a);
        case 'tan':    return math.tan(a);
        case 'cot':    return 1 / math.tan(a);
        case 'sec':    return 1 / math.cos(a);
        case 'csc':    return 1 / math.sin(a);
        case 'asin':
        case 'arcsin': return math.asin(a);
        case 'acos':
        case 'arccos': return math.acos(a);
        case 'atan':
        case 'arctan': return math.atan(a);
        case 'sinh':   return sinh(a);
        case 'cosh':   return cosh(a);
        case 'tanh':   return tanh(a);
        case 'ln':
          if (a <= 0) throw Exception('ln of non-positive number');
          return math.log(a);
        case 'log':
          if (a <= 0) throw Exception('log of non-positive number');
          return math.log(a) / math.ln10;
        case 'exp':    return math.exp(a);
        case 'sqrt':
          if (a < 0) throw Exception('sqrt of negative number');
          return math.sqrt(a);
        case 'abs':    return a.abs();
        case 'cbrt':   return _cbrt(a);
        default:
          throw Exception('Unknown function: ${e.name}');
      }
    }
    throw Exception('Cannot evaluate expression: ${e.toMathString()}');
  }

  static double _cbrt(double x) {
    return x < 0
        ? -math.pow(-x, 1 / 3).toDouble()
        : math.pow(x, 1 / 3).toDouble();
  }
}

// ==================== SIMPLIFIER ====================

class Simplifier {
  /// Repeatedly applies one-pass simplification until the tree stabilises.
  static Expr simplify(Expr e) {
    Expr prev;
    Expr curr = e;
    int iterations = 0;
    do {
      prev = curr;
      curr = _simplifyOnce(curr);
      iterations++;
    } while (curr.toMathString() != prev.toMathString() && iterations < 20);
    return curr;
  }

  static Expr _simplifyOnce(Expr e) {
    if (e is Num || e is Const || e is Var || e is DerivSym) return e;

    if (e is UnaryNeg) {
      final inner = _simplifyOnce(e.operand);
      if (inner is UnaryNeg) return inner.operand;
      if (inner is Num) return Num(-inner.value);
      if (inner is BinOp && inner.op == '-')
        return BinOp(inner.right, '-', inner.left);
      if (inner is BinOp && inner.op == '*' && inner.left is Num) {
        return BinOp(Num(-(inner.left as Num).value), '*', inner.right);
      }
      return UnaryNeg(inner);
    }

    if (e is Func) return Func(e.name, _simplifyOnce(e.arg));

    if (e is Pow) {
      final b = _simplifyOnce(e.base);
      final exp = _simplifyOnce(e.exponent);
      if (exp is Num && exp.isZero) return const Num(1);
      if (exp is Num && exp.isOne) return b;
      if (b is Num && b.isZero && exp is Num && exp.value > 0)
        return const Num(0);
      if (b is Num && b.isOne) return const Num(1);
      if (b is Num && exp is Num) {
        final result = math.pow(b.value, exp.value);
        if (result.isFinite) return Num(result.toDouble());
      }
      if (b is Pow && exp is Num) {
        return _simplifyOnce(Pow(b.base, BinOp(b.exponent, '*', exp)));
      }
      return Pow(b, exp);
    }

    if (e is BinOp) {
      final left = _simplifyOnce(e.left);
      final right = _simplifyOnce(e.right);
      return _simplifyBinOp(left, e.op, right);
    }

    return e;
  }

  static Expr _simplifyBinOp(Expr left, String op, Expr right) {
    if (left is Num && right is Num) {
      switch (op) {
        case '+': return Num(left.value + right.value);
        case '-': return Num(left.value - right.value);
        case '*': return Num(left.value * right.value);
        case '/':
          if (right.value != 0) return Num(left.value / right.value);
          break;
      }
    }

    switch (op) {
      case '+':
        if (left is Num && left.isZero) return right;
        if (right is Num && right.isZero) return left;
        if (right is UnaryNeg) return _simplifyBinOp(left, '-', right.operand);
        if (left is UnaryNeg) return _simplifyBinOp(right, '-', left.operand);
        break;

      case '-':
        if (left is Num && left.isZero) return UnaryNeg(right);
        if (right is Num && right.isZero) return left;
        if (left.toMathString() == right.toMathString()) return const Num(0);
        if (right is UnaryNeg) return _simplifyBinOp(left, '+', right.operand);
        break;

      case '*':
        if (left is Num && left.isZero) return const Num(0);
        if (right is Num && right.isZero) return const Num(0);
        if (left is Num && left.isOne) return right;
        if (right is Num && right.isOne) return left;
        if (left is Num && left.isMinusOne) return UnaryNeg(right);
        if (right is Num && right.isMinusOne) return UnaryNeg(left);
        if (left is Num &&
            right is BinOp &&
            right.op == '*' &&
            right.left is Num) {
          return _simplifyBinOp(
              Num(left.value * (right.left as Num).value), '*', right.right);
        }
        if (right is Num &&
            left is BinOp &&
            left.op == '*' &&
            left.left is Num) {
          return _simplifyBinOp(
              Num((left.left as Num).value * right.value), '*', left.right);
        }
        if (right is BinOp && right.op == '/') {
          return _simplifyBinOp(BinOp(left, '*', right.left), '/', right.right);
        }
        if (left is BinOp && left.op == '/') {
          return _simplifyBinOp(BinOp(left.left, '*', right), '/', left.right);
        }
        if (left is UnaryNeg)
          return UnaryNeg(_simplifyBinOp(left.operand, '*', right));
        if (right is UnaryNeg)
          return UnaryNeg(_simplifyBinOp(left, '*', right.operand));
        break;

      case '/':
        if (left is Num && left.isZero) return const Num(0);
        if (right is Num && right.isOne) return left;
        if (left.toMathString() == right.toMathString()) return const Num(1);
        if (left is BinOp &&
            left.op == '*' &&
            left.right.toMathString() == right.toMathString()) return left.left;
        if (left is BinOp &&
            left.op == '*' &&
            right is BinOp &&
            right.op == '*') {
          if (left.right.toMathString() == right.right.toMathString()) {
            return _simplifyBinOp(left.left, '/', right.left);
          }
        }
        if (left is UnaryNeg && right is! UnaryNeg) {
          return UnaryNeg(_simplifyBinOp(left.operand, '/', right));
        }
        if (right is UnaryNeg && left is! UnaryNeg) {
          return UnaryNeg(_simplifyBinOp(left, '/', right.operand));
        }
        if (left is UnaryNeg && right is UnaryNeg) {
          return _simplifyBinOp(left.operand, '/', right.operand);
        }
        if (left is BinOp && left.op == '/') {
          return _simplifyBinOp(left.left, '/', BinOp(left.right, '*', right));
        }
        if (right is BinOp && right.op == '/') {
          return _simplifyBinOp(BinOp(left, '*', right.right), '/', right.left);
        }
        break;
    }

    return BinOp(left, op, right);
  }

  /// Splits [e] into (coeffOfDeriv, remainder) such that:
  ///   e  =  coeffOfDeriv * dy/dx  +  remainder
  /// Used by the implicit solver to isolate and solve for dy/dx.
  static (Expr, Expr) extractDerivCoeff(Expr e, String derivVar) {
    if (e is DerivSym && e.varName == derivVar)
      return (const Num(1), const Num(0));
    if (!ExprUtils.containsDerivSym(e)) return (const Num(0), e);

    if (e is UnaryNeg) {
      final (c, r) = extractDerivCoeff(e.operand, derivVar);
      return (simplify(UnaryNeg(c)), simplify(UnaryNeg(r)));
    }
    if (e is BinOp) {
      if (e.op == '+') {
        final (lc, lr) = extractDerivCoeff(e.left, derivVar);
        final (rc, rr) = extractDerivCoeff(e.right, derivVar);
        return (simplify(BinOp(lc, '+', rc)), simplify(BinOp(lr, '+', rr)));
      }
      if (e.op == '-') {
        final (lc, lr) = extractDerivCoeff(e.left, derivVar);
        final (rc, rr) = extractDerivCoeff(e.right, derivVar);
        return (simplify(BinOp(lc, '-', rc)), simplify(BinOp(lr, '-', rr)));
      }
      if (e.op == '*') {
        final leftHas = ExprUtils.containsDerivSym(e.left);
        final rightHas = ExprUtils.containsDerivSym(e.right);
        if (!leftHas && rightHas) {
          final (rc, rr) = extractDerivCoeff(e.right, derivVar);
          return (
            simplify(BinOp(e.left, '*', rc)),
            simplify(BinOp(e.left, '*', rr))
          );
        }
        if (leftHas && !rightHas) {
          final (lc, lr) = extractDerivCoeff(e.left, derivVar);
          return (
            simplify(BinOp(lc, '*', e.right)),
            simplify(BinOp(lr, '*', e.right))
          );
        }
        if (leftHas) {
          final (lc, lr) = extractDerivCoeff(e.left, derivVar);
          return (
            simplify(BinOp(lc, '*', e.right)),
            simplify(BinOp(lr, '*', e.right))
          );
        }
      }
      if (e.op == '/') {
        final numHas = ExprUtils.containsDerivSym(e.left);
        final denHas = ExprUtils.containsDerivSym(e.right);
        if (!denHas && numHas) {
          final (nc, nr) = extractDerivCoeff(e.left, derivVar);
          return (
            simplify(BinOp(nc, '/', e.right)),
            simplify(BinOp(nr, '/', e.right))
          );
        }
      }
    }
    if (ExprUtils.containsDerivSym(e)) return (e, const Num(0));
    return (const Num(0), e);
  }
}

// ==================== DIFFERENTIATOR ====================

class Differentiator {
  /// Symbolically differentiates [e] with respect to [varName].
  /// Variables listed in [dependentVars] are treated as functions of [varName],
  /// so their derivatives produce DerivSym nodes (e.g. dy/dx).
  static Expr differentiate(
    Expr e,
    String varName, {
    Set<String> dependentVars = const {},
  }) {
    if (e is Num) return const Num(0);
    if (e is Const) return const Num(0);

    if (e is Var) {
      if (e.name == varName) return const Num(1);
      if (dependentVars.contains(e.name)) return DerivSym(e.name);
      return const Num(0);
    }

    if (e is DerivSym) return const Num(0);

    if (e is UnaryNeg) {
      return Simplifier.simplify(
        UnaryNeg(
            differentiate(e.operand, varName, dependentVars: dependentVars)),
      );
    }

    if (e is BinOp && (e.op == '+' || e.op == '-')) {
      return Simplifier.simplify(BinOp(
        differentiate(e.left, varName, dependentVars: dependentVars),
        e.op,
        differentiate(e.right, varName, dependentVars: dependentVars),
      ));
    }

    if (e is BinOp && e.op == '*') {
      // Product rule: (fg)' = f'g + fg'
      final df = differentiate(e.left, varName, dependentVars: dependentVars);
      final dg = differentiate(e.right, varName, dependentVars: dependentVars);
      return Simplifier.simplify(BinOp(
        BinOp(df, '*', e.right.clone()),
        '+',
        BinOp(e.left.clone(), '*', dg),
      ));
    }

    if (e is BinOp && e.op == '/') {
      // Quotient rule: (f/g)' = (f'g - fg') / g²
      final df = differentiate(e.left, varName, dependentVars: dependentVars);
      final dg = differentiate(e.right, varName, dependentVars: dependentVars);
      return Simplifier.simplify(BinOp(
        BinOp(
          BinOp(df, '*', e.right.clone()),
          '-',
          BinOp(e.left.clone(), '*', dg),
        ),
        '/',
        Pow(e.right.clone(), const Num(2)),
      ));
    }

    if (e is Pow) return _differentiatePow(e, varName, dependentVars);
    if (e is Func) return _differentiateFunc(e, varName, dependentVars);

    throw Exception('Cannot differentiate: ${e.toMathString()}');
  }

  static Expr _differentiatePow(
      Pow e, String varName, Set<String> dependentVars) {
    final baseHasVar = ExprUtils.containsVar(e.base, varName) ||
        _hasDependentVar(e.base, varName, dependentVars);
    final expHasVar = ExprUtils.containsVar(e.exponent, varName) ||
        _hasDependentVar(e.exponent, varName, dependentVars);

    if (!baseHasVar && !expHasVar) return const Num(0);

    // Power rule: d/dx[f^n] = n * f^(n-1) * f'
    if (baseHasVar && !expHasVar) {
      final df = differentiate(e.base, varName, dependentVars: dependentVars);
      return Simplifier.simplify(BinOp(
        BinOp(
          e.exponent.clone(),
          '*',
          Pow(e.base.clone(), BinOp(e.exponent.clone(), '-', const Num(1))),
        ),
        '*',
        df,
      ));
    }

    // Exponential rule: d/dx[a^g] = a^g * ln(a) * g'
    if (!baseHasVar && expHasVar) {
      final dg =
          differentiate(e.exponent, varName, dependentVars: dependentVars);
      return Simplifier.simplify(BinOp(
        BinOp(
          Pow(e.base.clone(), e.exponent.clone()),
          '*',
          Func('ln', e.base.clone()),
        ),
        '*',
        dg,
      ));
    }

    // General rule: d/dx[f^g] = f^g * (g'*ln(f) + g*f'/f)
    final df = differentiate(e.base, varName, dependentVars: dependentVars);
    final dg = differentiate(e.exponent, varName, dependentVars: dependentVars);
    return Simplifier.simplify(BinOp(
      Pow(e.base.clone(), e.exponent.clone()),
      '*',
      BinOp(
        BinOp(dg, '*', Func('ln', e.base.clone())),
        '+',
        BinOp(BinOp(e.exponent.clone(), '*', df), '/', e.base.clone()),
      ),
    ));
  }

  static bool _hasDependentVar(
      Expr e, String varName, Set<String> dependentVars) {
    for (final dv in dependentVars) {
      if (ExprUtils.containsVar(e, dv)) return true;
    }
    return false;
  }

  static Expr _differentiateFunc(
      Func e, String varName, Set<String> dependentVars) {
    final du = differentiate(e.arg, varName, dependentVars: dependentVars);
    final u = e.arg.clone();

    Expr outerDeriv;
    switch (e.name) {
      case 'sin':
        outerDeriv = Func('cos', u);
        break;
      case 'cos':
        outerDeriv = UnaryNeg(Func('sin', u));
        break;
      case 'tan':
        outerDeriv =
            BinOp(const Num(1), '/', Pow(Func('cos', u), const Num(2)));
        break;
      case 'cot':
        outerDeriv = UnaryNeg(
          BinOp(const Num(1), '/', Pow(Func('sin', u), const Num(2))),
        );
        break;
      case 'sec':
        outerDeriv = BinOp(
          Func('sin', u.clone()),
          '/',
          Pow(Func('cos', u), const Num(2)),
        );
        break;
      case 'csc':
        outerDeriv = UnaryNeg(BinOp(
          Func('cos', u.clone()),
          '/',
          Pow(Func('sin', u), const Num(2)),
        ));
        break;
      case 'asin':
      case 'arcsin':
        outerDeriv = BinOp(
          const Num(1),
          '/',
          Func('sqrt', BinOp(const Num(1), '-', Pow(u, const Num(2)))),
        );
        break;
      case 'acos':
      case 'arccos':
        outerDeriv = UnaryNeg(BinOp(
          const Num(1),
          '/',
          Func('sqrt', BinOp(const Num(1), '-', Pow(u, const Num(2)))),
        ));
        break;
      case 'atan':
      case 'arctan':
        outerDeriv = BinOp(
          const Num(1),
          '/',
          BinOp(const Num(1), '+', Pow(u, const Num(2))),
        );
        break;
      case 'sinh':
        outerDeriv = Func('cosh', u);
        break;
      case 'cosh':
        outerDeriv = Func('sinh', u);
        break;
      case 'tanh':
        outerDeriv =
            BinOp(const Num(1), '/', Pow(Func('cosh', u), const Num(2)));
        break;
      case 'ln':
        outerDeriv = BinOp(const Num(1), '/', u);
        break;
      case 'log':
        outerDeriv = BinOp(
          const Num(1),
          '/',
          BinOp(u, '*', Func('ln', const Num(10))),
        );
        break;
      case 'exp':
        outerDeriv = Func('exp', u);
        break;
      case 'sqrt':
        outerDeriv = BinOp(
          const Num(1),
          '/',
          BinOp(const Num(2), '*', Func('sqrt', u)),
        );
        break;
      case 'abs':
        outerDeriv = BinOp(u, '/', Func('abs', u.clone()));
        break;
      case 'cbrt':
        outerDeriv = BinOp(
          const Num(1),
          '/',
          BinOp(
            const Num(3),
            '*',
            Pow(u, BinOp(const Num(2), '/', const Num(3))),
          ),
        );
        break;
      default:
        throw Exception('Cannot differentiate unknown function: ${e.name}');
    }

    return Simplifier.simplify(BinOp(outerDeriv, '*', du));
  }
}