import 'dart:math' as math;

import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/core/step_model.dart';

class RadicalSolver {
  static const _eps = 1e-8;

  static SolveResult solve(String input) {
    try {
      final problem = _RadicalProblem.parse(input);
      if (problem == null) {
        return SolveResult.error(
          'Could not parse radical inequality. Use an operator such as <, <=, >, or >= and at least one square root.',
        );
      }

      final result = _IntervalSolver(problem).solve();
      return SolveResult(
        answer: result.answer,
        points: result.points,
        intervalNotation: result.plainNotation,
        latex: result.latexAnswer,
        customData: result.spans,
      );
    } catch (e) {
      return SolveResult.error('Error solving radical inequality: $e');
    }
  }

  static List<StepModel> getSteps(String input) {
    final problem = _RadicalProblem.parse(input);
    if (problem == null) {
      return const [
        StepModel(
          stepNumber: 1,
          title: 'Unable To Parse',
          explanation: 'Check the square root, inequality symbol, and algebraic expression.',
          latex: r'\text{Invalid radical inequality}',
        ),
      ];
    }

    final result = _IntervalSolver(problem).solve();
    return [
      StepModel(
        stepNumber: 1,
        title: 'Problem',
        explanation: 'Start with the radical inequality.',
        latex: problem.toLatex(),
      ),
      StepModel(
        stepNumber: 2,
        title: 'Domain',
        explanation: 'Every expression inside a square root must be non-negative, and denominators cannot be zero.',
        latex: result.domainLatex,
      ),
      StepModel(
        stepNumber: 3,
        title: 'Critical Points',
        explanation: 'Use domain boundaries, denominator zeros, and equality points to split the number line.',
        latex: result.points.isEmpty
            ? r'\text{No finite critical points}'
            : 'x = ${result.points.map(_fmtLatex).join(r',\ ')}',
      ),
      StepModel(
        stepNumber: 4,
        title: 'Test Intervals',
        explanation: 'Pick one easy value from each interval. If it makes the original inequality true, keep that interval.',
        latex: r'\text{Test the intervals from the number line}',
        subLatex: result.testRowsLatex,
      ),
      StepModel(
        stepNumber: 5,
        title: 'Final Answer',
        explanation: 'Write the valid regions as an inequality, then show the interval notation.',
        latex: result.latexAnswer,
        subLatex: [result.latexNotation],
      ),
    ];
  }

  static String _fmtPlain(double n) {
    if (n.isNaN) return 'undefined';
    if (!n.isFinite) return n.isNegative ? '-\u221e' : '\u221e';
    // ignore: dead_code
    if (!n.isFinite) return n.isNegative ? '-∞' : '∞';
    if (n.abs() < _eps) return '0';
    if ((n - n.round()).abs() < 1e-9) return n.round().toString();
    final fraction = _fractionFor(n);
    if (fraction != null) return fraction.plain;
    return n.toStringAsPrecision(8);
  }

  static String _fmtLatex(double n) {
    if (n.isNaN) return r'\text{undefined}';
    if (!n.isFinite) return n.isNegative ? r'-\infty' : r'\infty';
    if (n.abs() < _eps) return '0';
    if ((n - n.round()).abs() < 1e-9) return n.round().toString();
    final fraction = _fractionFor(n);
    if (fraction != null) return fraction.latex;
    return n.toStringAsPrecision(8);
  }

  static String _fmtTestLatex(double n) {
    if (n.isNaN) return r'\text{undefined}';
    if (!n.isFinite) return n.isNegative ? r'-\infty' : r'\infty';
    if (n.abs() < _eps) return '0';
    if ((n - n.round()).abs() < 1e-9) return n.round().toString();
    final fraction = _fractionFor(n);
    if (fraction != null) return fraction.latex;
    return n.toStringAsFixed(2);
  }

  static _FractionLabel? _fractionFor(double n) {
    const maxDenominator = 120;
    const tolerance = 1e-8;
    var bestNumerator = 0;
    var bestDenominator = 1;
    var bestError = double.infinity;

    for (var denominator = 2; denominator <= maxDenominator; denominator++) {
      final numerator = (n * denominator).round();
      final value = numerator / denominator;
      final error = (value - n).abs();
      if (error < bestError) {
        bestError = error;
        bestNumerator = numerator;
        bestDenominator = denominator;
        if (error < tolerance) break;
      }
    }

    if (bestError > tolerance) return null;
    final g = _gcd(bestNumerator.abs(), bestDenominator);
    final numerator = bestNumerator ~/ g;
    final denominator = bestDenominator ~/ g;
    if (denominator == 1) {
      return _FractionLabel(numerator.toString(), numerator.toString());
    }
    final sign = numerator.isNegative ? '-' : '';
    final absNumerator = numerator.abs();
    return _FractionLabel(
      '$numerator/$denominator',
      '$sign\\frac{$absNumerator}{$denominator}',
    );
  }

  static int _gcd(int a, int b) => b == 0 ? a : _gcd(b, a % b);

  static String _opLatex(String op) {
    return switch (op) {
      '>=' => r'\geq',
      '<=' => r'\leq',
      _ => op,
    };
  }
}

class _FractionLabel {
  final String plain;
  final String latex;

  const _FractionLabel(this.plain, this.latex);
}

class _IntervalSolver {
  final _RadicalProblem problem;

  _IntervalSolver(this.problem);

  _SolveData solve() {
    final roots = <double>[];
    final maxConstant = math.max(
      problem.left.maxConstant(),
      problem.right.maxConstant(),
    );
    final scanLimit = math.min(
      1000000.0,
      math.max(1000.0, maxConstant * maxConstant * 4 + maxConstant * 20 + 100),
    );

    roots.addAll(_rootsOf((x) => problem.left.eval(x) - problem.right.eval(x), scanLimit));
    for (final radicand in [...problem.left.radicands(), ...problem.right.radicands()]) {
      roots.addAll(_rootsOf(radicand.eval, scanLimit));
    }
    for (final den in [...problem.left.denominators(), ...problem.right.denominators()]) {
      roots.addAll(_rootsOf(den.eval, scanLimit));
    }

    final points = _dedupe(roots.where((x) => x.isFinite).toList())..sort();
    final spans = <_Span>[];
    final tests = <_TestRow>[];

    if (points.isEmpty) {
      final accepted = _test(0);
      tests.add(_testRow(r'(-\infty, \infty)', 0, accepted));
      if (accepted) {
        spans.add(const _Span(double.negativeInfinity, double.infinity, false, false));
      }
    } else {
      final firstTest = _outerTestPoint(points.first, points, left: true);
      var accepted = _test(firstTest);
      tests.add(_testRow(
        _Span(double.negativeInfinity, points.first, false, false).latexNotation(),
        firstTest,
        accepted,
      ));
      if (accepted) {
        spans.add(_Span(
          double.negativeInfinity,
          points.first,
          false,
          _included(points.first),
        ));
      }

      for (var i = 0; i < points.length; i++) {
        final x = points[i];
        if (_included(x)) {
          spans.add(_Span(x, x, true, true));
        }
        if (i < points.length - 1) {
          final mid = (x + points[i + 1]) / 2;
          accepted = _test(mid);
          tests.add(_testRow(
            _Span(x, points[i + 1], false, false).latexNotation(),
            mid,
            accepted,
          ));
          if (accepted) {
            spans.add(_Span(
              x,
              points[i + 1],
              _included(x),
              _included(points[i + 1]),
            ));
          }
        }
      }

      final lastTest = _outerTestPoint(points.last, points, left: false);
      accepted = _test(lastTest);
      tests.add(_testRow(
        _Span(points.last, double.infinity, false, false).latexNotation(),
        lastTest,
        accepted,
      ));
      if (accepted) {
        spans.add(_Span(
          points.last,
          double.infinity,
          _included(points.last),
          false,
        ));
      }
    }

    final merged = _merge(spans);
    // ignore: unused_local_variable
    final plainNotation = merged.isEmpty
        ? '∅'
        : merged.map((s) => s.plainNotation()).join(' ∪ ');
    final latexNotation = merged.isEmpty
        ? r'\emptyset'
        : merged.map((s) => s.latexNotation()).join(r' \cup ');
    final answer = merged.isEmpty
        ? 'No solution'
        : merged.map((s) => s.answer()).join(' or ');
    final latexAnswer = merged.isEmpty
        ? r'\text{No solution}'
        : merged.map((s) => s.latexAnswer()).join(r'\quad\text{or}\quad');
    final cardPlainNotation = merged.isEmpty
        ? '\u2205'
        : merged.map((s) => s.plainNotation()).join(' \u222a ');
    final cardAnswer = merged.isEmpty
        ? 'No real x satisfies the inequality'
        : answer;
    final cardLatexAnswer = merged.isEmpty
        ? r'\text{No real }x\text{ satisfies the inequality}'
        : latexAnswer;

    final graphPoints = points
        .where((x) => x.isFinite && x.abs() < 1000000)
        .toList();

    return _SolveData(
      answer: cardAnswer,
      plainNotation: cardPlainNotation,
      latexNotation: latexNotation,
      latexAnswer: cardLatexAnswer,
      points: graphPoints,
      spans: merged,
      domainLatex: _domainLatex(),
      testRowsLatex: _testRowsLatex(tests),
    );
  }

  bool _test(double x) {
    final left = problem.left.eval(x);
    final right = problem.right.eval(x);
    if (!left.isFinite || !right.isFinite) return false;

    switch (problem.op) {
      case '>':
        return left > right + 1e-7;
      case '<':
        return left < right - 1e-7;
      case '>=':
        return left > right - 1e-7;
      case '<=':
        return left < right + 1e-7;
    }
    return false;
  }

  bool _included(double x) {
    final left = problem.left.eval(x);
    final right = problem.right.eval(x);
    if (!left.isFinite || !right.isFinite) return false;
    if (problem.op == '>' || problem.op == '<') return _test(x);
    return _test(x) || (left - right).abs() < 1e-6;
  }

  _TestRow _testRow(String intervalLatex, double sample, bool accepted) {
    final left = problem.left.eval(sample);
    final right = problem.right.eval(sample);
    final isDefined = left.isFinite && right.isFinite;
    return _TestRow(
      intervalLatex,
      RadicalSolver._fmtTestLatex(sample),
      RadicalSolver._fmtTestLatex(left),
      RadicalSolver._opLatex(problem.op),
      RadicalSolver._fmtTestLatex(right),
      accepted,
      isDefined,
    );
  }

  String _domainLatex() {
    final pieces = <String>[];
    for (final radicand in [...problem.left.radicands(), ...problem.right.radicands()]) {
      pieces.add('${radicand.toLatex()} \\geq 0');
    }
    for (final denominator in [...problem.left.denominators(), ...problem.right.denominators()]) {
      pieces.add('${denominator.toLatex()} \\ne 0');
    }
    return pieces.isEmpty ? r'\text{All real numbers}' : pieces.join(r',\ ');
  }

  static List<String> _testRowsLatex(List<_TestRow> tests) {
    if (tests.isEmpty) return const [r'\text{No test intervals}'];
    return tests
        .map((test) {
          final resultLatex = test.isDefined
              ? '${test.leftLatex} ${test.operatorLatex} ${test.rightLatex}'
              : r'\text{outside the domain}';
          final decisionLatex = test.accepted
              ? r'\checkmark\ \text{keep}'
              : r'\times\ \text{reject}';
          return '${test.intervalLatex}:\\quad '
              'x = ${test.sampleLatex}:\\quad '
              '$resultLatex\\quad '
              '$decisionLatex';
        })
        .toList();
  }

  static double _outerTestPoint(double edge, List<double> points, {required bool left}) {
    final gap = points.length > 1 ? (points[1] - points[0]).abs() : 1.0;
    final step = math.max(1.0, math.min(1000.0, gap));
    return left ? edge - step : edge + step;
  }

  static List<double> _rootsOf(double Function(double) f, double limit) {
    final roots = <double>[];
    const steps = 6000;
    final dx = (2 * limit) / steps;
    var prevX = -limit;
    var prevY = f(prevX);

    for (var i = 1; i <= steps; i++) {
      final x = -limit + i * dx;
      final y = f(x);

      if (y.isFinite && y.abs() < 1e-7) roots.add(x);
      if (prevY.isFinite && y.isFinite && prevY * y < 0) {
        roots.add(_bisect(f, prevX, x));
      }

      prevX = x;
      prevY = y;
    }

    return _dedupe(roots);
  }

  static double _bisect(double Function(double) f, double lo, double hi) {
    var a = lo;
    var b = hi;
    var fa = f(a);
    for (var i = 0; i < 80; i++) {
      final m = (a + b) / 2;
      final fm = f(m);
      if (!fm.isFinite) break;
      if (fm.abs() < 1e-10) return m;
      if (fa.isFinite && fa * fm <= 0) {
        b = m;
      } else {
        a = m;
        fa = fm;
      }
    }
    return (a + b) / 2;
  }

  static List<double> _dedupe(List<double> values) {
    values.sort();
    final out = <double>[];
    for (final value in values) {
      final clean = value.abs() < 1e-7 ? 0.0 : value;
      if (out.isEmpty || (clean - out.last).abs() > 1e-5) {
        out.add(clean);
      }
    }
    return out;
  }

  static List<_Span> _merge(List<_Span> spans) {
    if (spans.isEmpty) return spans;
    final sorted = spans
        .where((s) => s.lo < s.hi || (s.lo - s.hi).abs() < 1e-8 && s.closedLo && s.closedHi)
        .toList()
      ..sort((a, b) => a.lo.compareTo(b.lo));

    final out = <_Span>[];
    for (final span in sorted) {
      if (out.isEmpty) {
        out.add(span);
        continue;
      }
      final last = out.last;
      final touching = (span.lo - last.hi).abs() < 1e-7;
      final overlapping = span.lo < last.hi + 1e-7;
      if (overlapping || (touching && (last.closedHi || span.closedLo))) {
        out[out.length - 1] = _Span(
          last.lo,
          math.max(last.hi, span.hi),
          last.closedLo,
          span.hi > last.hi ? span.closedHi : last.closedHi || span.closedHi,
        );
      } else {
        out.add(span);
      }
    }
    return out;
  }
}

class _SolveData {
  final String answer;
  final String plainNotation;
  final String latexNotation;
  final String latexAnswer;
  final String domainLatex;
  final List<String> testRowsLatex;
  final List<double> points;
  final List<_Span> spans;

  const _SolveData({
    required this.answer,
    required this.plainNotation,
    required this.latexNotation,
    required this.latexAnswer,
    required this.domainLatex,
    required this.testRowsLatex,
    required this.points,
    required this.spans,
  });
}

class _TestRow {
  final String intervalLatex;
  final String sampleLatex;
  final String leftLatex;
  final String operatorLatex;
  final String rightLatex;
  final bool accepted;
  final bool isDefined;

  const _TestRow(
    this.intervalLatex,
    this.sampleLatex,
    this.leftLatex,
    this.operatorLatex,
    this.rightLatex,
    this.accepted,
    this.isDefined,
  );
}

class _Span {
  final double lo;
  final double hi;
  final bool closedLo;
  final bool closedHi;

  const _Span(this.lo, this.hi, this.closedLo, this.closedHi);

  String plainNotation() {
    if ((lo - hi).abs() < 1e-8 && closedLo && closedHi) {
      return '{${RadicalSolver._fmtPlain(lo)}}';
    }
    return '${closedLo ? '[' : '('}${RadicalSolver._fmtPlain(lo)}, ${RadicalSolver._fmtPlain(hi)}${closedHi ? ']' : ')'}';
  }

  String latexNotation() {
    if ((lo - hi).abs() < 1e-8 && closedLo && closedHi) {
      return r'\left\{' '${RadicalSolver._fmtLatex(lo)}' r'\right\}';
    }
    final leftBracket = closedLo ? '[' : '(';
    final rightBracket = closedHi ? ']' : ')';
    return r'\left' '$leftBracket${RadicalSolver._fmtLatex(lo)}, ${RadicalSolver._fmtLatex(hi)}' r'\right' '$rightBracket';
  }

  String answer() {
    if ((lo - hi).abs() < 1e-8 && closedLo && closedHi) {
      return 'x = ${RadicalSolver._fmtPlain(lo)}';
    }
    if (lo.isInfinite && hi.isInfinite) return 'All real numbers';
    if (lo.isInfinite) return 'x ${closedHi ? '<=' : '<'} ${RadicalSolver._fmtPlain(hi)}';
    if (hi.isInfinite) return 'x ${closedLo ? '>=' : '>'} ${RadicalSolver._fmtPlain(lo)}';
    return '${RadicalSolver._fmtPlain(lo)} ${closedLo ? '<=' : '<'} x ${closedHi ? '<=' : '<'} ${RadicalSolver._fmtPlain(hi)}';
  }

  String latexAnswer() {
    if ((lo - hi).abs() < 1e-8 && closedLo && closedHi) {
      return 'x = ${RadicalSolver._fmtLatex(lo)}';
    }
    if (lo.isInfinite && hi.isInfinite) return r'\mathbb{R}';
    if (lo.isInfinite) {
      return 'x ${closedHi ? r'\leq' : '<'} ${RadicalSolver._fmtLatex(hi)}';
    }
    if (hi.isInfinite) {
      return 'x ${closedLo ? r'\geq' : '>'} ${RadicalSolver._fmtLatex(lo)}';
    }
    final leftOp = closedLo ? r'\leq' : '<';
    final rightOp = closedHi ? r'\leq' : '<';
    return '${RadicalSolver._fmtLatex(lo)} $leftOp x $rightOp ${RadicalSolver._fmtLatex(hi)}';
  }
}

class _RadicalProblem {
  final _Expr left;
  final _Expr right;
  final String op;
  final String original;

  const _RadicalProblem(this.left, this.right, this.op, this.original);

  static _RadicalProblem? parse(String input) {
    final normalized = _normalize(input);
    final split = _splitInequality(normalized);
    if (split == null) return null;
    if (!normalized.contains('sqrt') && !normalized.contains('root')) return null;

    final left = _Parser(split.left).parse();
    final right = _Parser(split.right).parse();
    if (left == null || right == null) return null;

    return _RadicalProblem(left, right, split.op, input.trim());
  }

  String toLatex() {
    final opLatex = RadicalSolver._opLatex(op);
    return '${left.toLatex()} $opLatex ${right.toLatex()}';
  }

  static String _normalize(String input) {
    return input
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[\u2212\u2013\u2014\u2010\u2011]'), '-')
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll('>=', '>=')
        .replaceAll('<=', '<=')
        .replaceAll('\u2265', '>=')
        .replaceAll('\u2264', '<=')
        .replaceAll('\u221a', 'sqrt')
        .replaceAll('√', 'sqrt')
        .replaceAll('x\u00b2', 'x^2')
        .replaceAll('²', '^2');
  }

  static _Split? _splitInequality(String input) {
    var depth = 0;
    for (var i = 0; i < input.length; i++) {
      final ch = input[i];
      if (ch == '(') depth++;
      if (ch == ')') depth--;
      if (depth != 0) continue;

      if (input.startsWith('>=', i) || input.startsWith('<=', i)) {
        return _Split(input.substring(0, i), input.substring(i + 2), input.substring(i, i + 2));
      }
      if (ch == '>' || ch == '<') {
        return _Split(input.substring(0, i), input.substring(i + 1), ch);
      }
    }
    return null;
  }
}

class _Split {
  final String left;
  final String right;
  final String op;

  const _Split(this.left, this.right, this.op);
}

abstract class _Expr {
  double eval(double x);
  String toLatex();
  double maxConstant();
  List<_Expr> radicands() => const [];
  List<_Expr> denominators() => const [];
}

class _Const extends _Expr {
  final double value;

  _Const(this.value);

  @override
  double eval(double x) => value;

  @override
  String toLatex() => RadicalSolver._fmtLatex(value);

  @override
  double maxConstant() => value.abs();
}

class _Variable extends _Expr {
  @override
  double eval(double x) => x;

  @override
  String toLatex() => 'x';

  @override
  double maxConstant() => 1;
}

class _UnaryMinus extends _Expr {
  final _Expr child;

  _UnaryMinus(this.child);

  @override
  double eval(double x) => -child.eval(x);

  @override
  String toLatex() => '-${child.toLatex()}';

  @override
  double maxConstant() => child.maxConstant();

  @override
  List<_Expr> radicands() => child.radicands();

  @override
  List<_Expr> denominators() => child.denominators();
}

class _Binary extends _Expr {
  final String op;
  final _Expr left;
  final _Expr right;

  _Binary(this.op, this.left, this.right);

  @override
  double eval(double x) {
    final a = left.eval(x);
    final b = right.eval(x);
    if (!a.isFinite || !b.isFinite) return double.nan;
    switch (op) {
      case '+':
        return a + b;
      case '-':
        return a - b;
      case '*':
        return a * b;
      case '/':
        return b.abs() < 1e-10 ? double.nan : a / b;
      case '^':
        return math.pow(a, b).toDouble();
    }
    return double.nan;
  }

  @override
  String toLatex() {
    if (op == '/') return r'\frac{' '${left.toLatex()}}{${right.toLatex()}}';
    if (op == '^') return '${left.toLatex()}^{${right.toLatex()}}';
    if (op == '*') return _productLatex();
    return '${left.toLatex()} $op ${right.toLatex()}';
  }

  String _productLatex() {
    if (left is _Const && right is! _Const) {
      final coefficient = (left as _Const).value;
      if ((coefficient - 1).abs() < RadicalSolver._eps) {
        return _factorLatex(right);
      }
      if ((coefficient + 1).abs() < RadicalSolver._eps) {
        return '-${_factorLatex(right)}';
      }
      return '${RadicalSolver._fmtLatex(coefficient)}${_factorLatex(right)}';
    }
    if (left is _Const || right is _Const) {
      return '${_factorLatex(left, leftSide: true)} \\cdot ${_factorLatex(right)}';
    }
    return '${_factorLatex(left, leftSide: true)}${_factorLatex(right)}';
  }

  static String _factorLatex(_Expr expr, {bool leftSide = false}) {
    if (expr is _Binary && (expr.op == '+' || expr.op == '-')) {
      return r'\left(' '${expr.toLatex()}' r'\right)';
    }
    if (!leftSide && expr is _Const && expr.value.isNegative) {
      return r'\left(' '${expr.toLatex()}' r'\right)';
    }
    return expr.toLatex();
  }

  @override
  double maxConstant() => math.max(left.maxConstant(), right.maxConstant());

  @override
  List<_Expr> radicands() => [...left.radicands(), ...right.radicands()];

  @override
  List<_Expr> denominators() {
    final all = [...left.denominators(), ...right.denominators()];
    if (op == '/') all.add(right);
    return all;
  }
}

class _Sqrt extends _Expr {
  final _Expr radicand;

  _Sqrt(this.radicand);

  @override
  double eval(double x) {
    final value = radicand.eval(x);
    if (!value.isFinite || value < -1e-9) return double.nan;
    return math.sqrt(math.max(0, value));
  }

  @override
  String toLatex() => r'\sqrt{' '${radicand.toLatex()}}';

  @override
  double maxConstant() => radicand.maxConstant();

  @override
  List<_Expr> radicands() => [radicand, ...radicand.radicands()];

  @override
  List<_Expr> denominators() => radicand.denominators();
}

class _Parser {
  final String source;
  var _i = 0;

  _Parser(this.source);

  _Expr? parse() {
    final expr = _parseExpression();
    if (expr == null || _i != source.length) return null;
    return expr;
  }

  _Expr? _parseExpression() {
    _Expr? parsed = _parseTerm();
    if (parsed == null) return null;
    var expr = parsed;
    while (_match('+') || _match('-')) {
      final op = source[_i - 1];
      final rhs = _parseTerm();
      if (rhs == null) return null;
      expr = _Binary(op, expr, rhs);
    }
    return expr;
  }

  _Expr? _parseTerm() {
    _Expr? parsed = _parsePower();
    if (parsed == null) return null;
    var expr = parsed;
    while (true) {
      if (_match('*') || _match('/')) {
        final op = source[_i - 1];
        final rhs = _parsePower();
        if (rhs == null) return null;
        expr = _Binary(op, expr, rhs);
      } else if (_startsFactor()) {
        final rhs = _parsePower();
        if (rhs == null) return null;
        expr = _Binary('*', expr, rhs);
      } else {
        break;
      }
    }
    return expr;
  }

  _Expr? _parsePower() {
    var expr = _parseFactor();
    if (expr == null) return null;
    if (_match('^')) {
      final rhs = _parsePower();
      if (rhs == null) return null;
      expr = _Binary('^', expr, rhs);
    }
    return expr;
  }

  _Expr? _parseFactor() {
    if (_match('+')) return _parseFactor();
    if (_match('-')) {
      final child = _parseFactor();
      return child == null ? null : _UnaryMinus(child);
    }

    if (_match('(')) {
      final expr = _parseExpression();
      if (expr == null || !_match(')')) return null;
      return expr;
    }

    if (_matchWord('sqrt')) {
      if (!_match('(')) {
        final radicand = _parseRadicandWithoutParentheses();
        return radicand == null ? null : _Sqrt(radicand);
      }
      final radicand = _parseExpression();
      if (radicand == null || !_match(')')) return null;
      return _Sqrt(radicand);
    }

    if (_match('x')) return _Variable();

    return _parseNumber();
  }

  _Expr? _parseRadicandWithoutParentheses() {
    final first = _parseTerm();
    if (first == null) return null;
    _Expr expr = first;

    while (_match('+') || _match('-')) {
      final op = source[_i - 1];
      final rhs = _parseTerm();
      if (rhs == null) return null;
      expr = _Binary(op, expr, rhs);
    }

    return expr;
  }

  _Expr? _parseNumber() {
    final start = _i;
    var hasDot = false;
    while (_i < source.length) {
      final ch = source[_i];
      if (ch == '.') {
        if (hasDot) break;
        hasDot = true;
        _i++;
      } else if (_isDigit(ch)) {
        _i++;
      } else {
        break;
      }
    }
    if (start == _i) return null;
    return _Const(double.parse(source.substring(start, _i)));
  }

  bool _startsFactor() {
    if (_i >= source.length) return false;
    final ch = source[_i];
    return ch == '(' || ch == 'x' || ch == '.' || _isDigit(ch) || source.startsWith('sqrt', _i);
  }

  bool _match(String token) {
    if (source.startsWith(token, _i)) {
      _i += token.length;
      return true;
    }
    return false;
  }

  bool _matchWord(String word) {
    if (source.startsWith(word, _i)) {
      _i += word.length;
      return true;
    }
    return false;
  }

  bool _isDigit(String ch) => ch.codeUnitAt(0) >= 48 && ch.codeUnitAt(0) <= 57;
}
