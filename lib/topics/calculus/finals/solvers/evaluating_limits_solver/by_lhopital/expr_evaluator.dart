import 'dart:math' as math;

import 'package:calculus_system/topics/calculus/finals/solvers/derivatives_solver/derivatives_solver.dart';

/// Numeric evaluator for the shared derivatives-solver [Expr] AST.
///
/// The derivatives solver differentiates expressions but does not evaluate
/// them, so L'Hopital's rule owns this small walker instead of growing the
/// shared file. Mirrors the sibling evaluating-limits evaluators: never
/// throws — anything it cannot evaluate (bad domain, unknown node) becomes
/// NaN and the engine falls back to its error path.
class ExprEvaluator {
  double evaluate(Expr e, double x, String variable) {
    if (e is Num) return e.value;
    if (e is Var) return e.name == variable ? x : 0;
    if (e is Neg) return -evaluate(e.expr, x, variable);
    if (e is Sqrt) {
      final a = evaluate(e.arg, x, variable);
      return a < 0 ? double.nan : math.sqrt(a);
    }
    if (e is Abs) return evaluate(e.arg, x, variable).abs();
    if (e is BinOp) {
      final l = evaluate(e.left, x, variable);
      final r = evaluate(e.right, x, variable);
      switch (e.op) {
        case '+':
          return l + r;
        case '-':
          return l - r;
        case '*':
          return l * r;
        case '/':
          return l / r;
        case '^':
          return math.pow(l, r).toDouble();
      }
      return double.nan;
    }
    if (e is Func) {
      final a = evaluate(e.arg, x, variable);
      switch (e.name) {
        case 'sin':
          return math.sin(a);
        case 'cos':
          return math.cos(a);
        case 'tan':
          return math.sin(a) / math.cos(a);
        case 'sec':
          return 1 / math.cos(a);
        case 'csc':
          return 1 / math.sin(a);
        case 'cot':
          return math.cos(a) / math.sin(a);
        case 'exp':
          return math.exp(a);
        case 'ln':
          return a > 0 ? math.log(a) : double.nan;
        case 'log':
          return a > 0 ? math.log(a) / math.ln10 : double.nan;
        case 'sqrt':
          return a >= 0 ? math.sqrt(a) : double.nan;
        case 'abs':
          return a.abs();
        case 'asin':
        case 'arcsin':
          return (a >= -1 && a <= 1) ? math.asin(a) : double.nan;
        case 'acos':
        case 'arccos':
          return (a >= -1 && a <= 1) ? math.acos(a) : double.nan;
        case 'atan':
        case 'arctan':
          return math.atan(a);
      }
      return double.nan;
    }
    return double.nan;
  }
}
