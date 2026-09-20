// Cycle 10 Item 2: regression tests for DerivativeSolver.
// Written BEFORE any solver fix to prove the bugs:
//  - tokenizer funcs set omitted asin/acos/atan/arcsin/arccos/arctan
//    (asin(x) parsed as Var('asin')*x and differentiated back to the
//    original expression instead of 1/sqrt(1-x^2)),
//  - _determineRule hardcoded variable 'x' (sin(t) w.r.t. t labeled
//    'Sine Derivative' while sin(x) w.r.t. x is labeled 'Chain Rule'),
//  - _preprocess had no function shorthand (sin x parsed as Var('sinx')
//    -> silent 0),
//  - _preprocess did not map '**' to '^' (x**2 threw).
import 'dart:math' as math;

import 'package:calculus_system/topics/calculus/finals/solvers/derivatives_solver/derivatives_solver.dart';
import 'package:flutter_test/flutter_test.dart';

double evalAt(Expr e, String v, double x) {
  if (e is Num) return e.value;
  if (e is Var) return e.name == v ? x : 0;
  if (e is Neg) return -evalAt(e.expr, v, x);
  if (e is Sqrt) {
    final a = evalAt(e.arg, v, x);
    return a < 0 ? double.nan : math.sqrt(a);
  }
  if (e is Abs) return evalAt(e.arg, v, x).abs();
  if (e is BinOp) {
    final l = evalAt(e.left, v, x);
    final r = evalAt(e.right, v, x);
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
    throw ArgumentError('Unknown op: ${e.op}');
  }
  if (e is Func) {
    final a = evalAt(e.arg, v, x);
    switch (e.name) {
      case 'sin':
        return math.sin(a);
      case 'cos':
        return math.cos(a);
      case 'tan':
        return math.tan(a);
      case 'sec':
        return 1 / math.cos(a);
      case 'csc':
        return 1 / math.sin(a);
      case 'cot':
        return 1 / math.tan(a);
      case 'exp':
        return math.exp(a);
      case 'ln':
        return math.log(a);
      case 'log':
        return math.log(a) / math.ln10;
      case 'sqrt':
        return math.sqrt(a);
      case 'abs':
        return a.abs();
      case 'asin':
      case 'arcsin':
        return math.asin(a);
      case 'acos':
      case 'arccos':
        return math.acos(a);
      case 'atan':
      case 'arctan':
        return math.atan(a);
    }
    throw ArgumentError('Unknown function: ${e.name}');
  }
  throw ArgumentError('Cannot evaluate: $e');
}

String ruleOf(String expr, String v) {
  final steps = DerivativeSolver.getSteps(expr, v);
  return steps.steps.firstWhere((s) => s.type == StepType.identifyRule).rule!;
}

void main() {
  group('DerivativeSolver inverse trig derivatives (Cycle 10 Item 2)', () {
    test('d/dx asin(x) is 1/sqrt(1-x^2)', () {
      final d = DerivativeSolver.solve('asin(x)', 'x');
      expect(evalAt(d, 'x', 0.5), closeTo(1 / math.sqrt(1 - 0.25), 1e-6));
    });

    test('d/dx acos(x) is -1/sqrt(1-x^2)', () {
      final d = DerivativeSolver.solve('acos(x)', 'x');
      expect(evalAt(d, 'x', 0.5), closeTo(-1 / math.sqrt(1 - 0.25), 1e-6));
    });

    test('d/dx atan(x) is 1/(1+x^2)', () {
      final d = DerivativeSolver.solve('atan(x)', 'x');
      expect(evalAt(d, 'x', 1), closeTo(0.5, 1e-6));
      expect(evalAt(d, 'x', 0.5), closeTo(0.8, 1e-6));
    });

    test('arcsin/arccos/arctan aliases match asin/acos/atan', () {
      const x = 0.5;
      expect(
        evalAt(DerivativeSolver.solve('arcsin(x)', 'x'), 'x', x),
        closeTo(evalAt(DerivativeSolver.solve('asin(x)', 'x'), 'x', x), 1e-9),
      );
      expect(
        evalAt(DerivativeSolver.solve('arccos(x)', 'x'), 'x', x),
        closeTo(evalAt(DerivativeSolver.solve('acos(x)', 'x'), 'x', x), 1e-9),
      );
      expect(
        evalAt(DerivativeSolver.solve('arctan(x)', 'x'), 'x', x),
        closeTo(evalAt(DerivativeSolver.solve('atan(x)', 'x'), 'x', x), 1e-9),
      );
    });

    test('chain: d/dx asin(x^2) is 2x/sqrt(1-x^4)', () {
      final d = DerivativeSolver.solve('asin(x^2)', 'x');
      expect(
        evalAt(d, 'x', 0.5),
        closeTo(1 / math.sqrt(1 - 0.5 * 0.5 * 0.5 * 0.5), 1e-6),
      );
    });
  });

  group('DerivativeSolver rule label follows variable (Cycle 10 Item 2)', () {
    test('sin(t) w.r.t. t is labeled like sin(x) w.r.t. x', () {
      expect(ruleOf('sin(t)', 't'), ruleOf('sin(x)', 'x'));
    });

    test('atan(t) w.r.t. t is labeled like atan(x) w.r.t. x', () {
      expect(ruleOf('atan(t)', 't'), ruleOf('atan(x)', 'x'));
    });

    test('sin(2t) w.r.t. t is labeled like sin(2x) w.r.t. x', () {
      expect(ruleOf('sin(2t)', 't'), ruleOf('sin(2x)', 'x'));
    });
  });

  group('DerivativeSolver student notation (Cycle 10 Item 2)', () {
    test('d/dx sin x is cos(x)', () {
      final d = DerivativeSolver.solve('sin x', 'x');
      expect(evalAt(d, 'x', 0), closeTo(1, 1e-9));
    });

    test('d/dx cos x is -sin(x)', () {
      final d = DerivativeSolver.solve('cos x', 'x');
      expect(evalAt(d, 'x', 0.5235987755982988), closeTo(-0.5, 1e-6));
    });

    test('d/dx tan x is sec^2(x)', () {
      final d = DerivativeSolver.solve('tan x', 'x');
      expect(
        evalAt(d, 'x', 0.5),
        closeTo(1 / (math.cos(0.5) * math.cos(0.5)), 1e-6),
      );
    });

    test('d/dx ln x is 1/x', () {
      final d = DerivativeSolver.solve('ln x', 'x');
      expect(evalAt(d, 'x', 2), closeTo(0.5, 1e-9));
    });

    test('d/dx x**2 is 2x', () {
      final d = DerivativeSolver.solve('x**2', 'x');
      expect(evalAt(d, 'x', 3), closeTo(6, 1e-9));
    });

    test('d/dx (x+1)**2 is 2(x+1)', () {
      final d = DerivativeSolver.solve('(x+1)**2', 'x');
      expect(evalAt(d, 'x', 2), closeTo(6, 1e-9));
    });

    test('d/dx 2**x is 2^x ln(2)', () {
      final d = DerivativeSolver.solve('2**x', 'x');
      expect(evalAt(d, 'x', 1), closeTo(2 * math.log(2), 1e-6));
    });
  });
}
