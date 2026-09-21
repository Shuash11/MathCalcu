import 'package:calculus_system/topics/calculus/finals/solvers/derivatives_solver/derivatives_solver.dart';

import 'expr_evaluator.dart';

// ═════════════════════════════════════════════════════════════
// L'HOPITAL'S RULE SOLVER
//
// 5th Evaluating Limits method. Detects the indeterminate forms
// 0/0 (finite approach point) and ∞/∞ (infinite approach), then
// applies L'Hopital's rule — differentiate numerator and
// denominator — up to 3 rounds until a numeric result emerges.
// Reuses the derivatives-solver Expr AST for f' and g' and falls
// to the existing error path when the form is not indeterminate.
// Never throws.
// ═════════════════════════════════════════════════════════════

class LhopitalProblem {
  final String expression;
  final double approachValue;
  final String variable;

  const LhopitalProblem({
    required this.expression,
    required this.approachValue,
    this.variable = 'x',
  });

  @override
  String toString() => 'lim($variable -> $approachValue) $expression';
}

class LhopitalRound {
  final Expr derivativeNumerator;
  final Expr derivativeDenominator;
  final double numeratorValue;
  final double denominatorValue;
  final String form;

  const LhopitalRound({
    required this.derivativeNumerator,
    required this.derivativeDenominator,
    required this.numeratorValue,
    required this.denominatorValue,
    required this.form,
  });
}

class LhopitalResult {
  final String originalExpression;
  final double approachValue;
  final String variable;

  final Expr? originalNumerator;
  final Expr? originalDenominator;

  final double numeratorAtPoint;
  final double denominatorAtPoint;
  final bool isIndeterminate;
  final bool isInfinityOverInfinity;

  final List<LhopitalRound> rounds;
  final int roundsApplied;

  final double finalValue;
  final bool solved;
  final String? errorMessage;

  const LhopitalResult({
    required this.originalExpression,
    required this.approachValue,
    required this.variable,
    this.originalNumerator,
    this.originalDenominator,
    required this.numeratorAtPoint,
    required this.denominatorAtPoint,
    required this.isIndeterminate,
    this.isInfinityOverInfinity = false,
    this.rounds = const [],
    this.roundsApplied = 0,
    required this.finalValue,
    required this.solved,
    this.errorMessage,
  });

  String get problemNotation =>
      'lim($variable -> $approachValue) $originalExpression';

  String get resultString {
    if (!solved) return errorMessage ?? 'Cannot solve';
    if (finalValue.isNaN) return 'undefined';
    if (finalValue.isInfinite) {
      return finalValue > 0 ? 'infinity' : '-infinity';
    }
    return formatValue(finalValue);
  }

  static String formatValue(double n) {
    const tolerance = 1e-9;
    if ((n - n.round()).abs() < tolerance) {
      return n.round().toString();
    }

    for (int denom = 2; denom <= 64; denom++) {
      final numer = n * denom;
      if ((numer - numer.round()).abs() < tolerance) {
        final intNumer = numer.round();
        if (intNumer == 0) return '0';
        final gcdVal = _gcd(intNumer.abs(), denom);
        final simpleNum = intNumer ~/ gcdVal;
        final simpleDen = denom ~/ gcdVal;
        if (simpleDen == 1) return simpleNum.toString();
        if (simpleDen == -1) return (-simpleNum).toString();
        if (simpleNum < 0 && simpleDen < 0) {
          return '${(-simpleNum)}/${(-simpleDen)}';
        }
        return '$simpleNum/$simpleDen';
      }
    }

    return n
        .toStringAsFixed(4)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  static int _gcd(int a, int b) {
    a = a.abs();
    b = b.abs();
    while (b != 0) {
      final t = b;
      b = a % b;
      a = t;
    }
    return a;
  }
}

class LhopitalSolverEngine {
  static const int _maxRounds = 3;

  final ExprEvaluator _evaluator = ExprEvaluator();

  LhopitalResult solve(LhopitalProblem problem) {
    try {
      final (numerator, denominator) =
          _parseExpressionAsFraction(problem.expression.trim());

      if (problem.approachValue.isFinite) {
        return _solveAtPoint(problem, numerator, denominator);
      }
      return _solveAtInfinity(problem, numerator, denominator);
    } catch (e) {
      return _parseError(problem, 'Error: $e');
    }
  }

  // ── Finite approach point ────────────────────────────────────

  LhopitalResult _solveAtPoint(
    LhopitalProblem problem,
    Expr numerator,
    Expr denominator,
  ) {
    final numAtPoint =
        _evaluator.evaluate(numerator, problem.approachValue, problem.variable);
    final denAtPoint = _evaluator.evaluate(
      denominator,
      problem.approachValue,
      problem.variable,
    );

    final isIndeterminate = numAtPoint.abs() < 1e-9 && denAtPoint.abs() < 1e-9;

    if (!isIndeterminate) {
      return _notIndeterminate(
        problem,
        numerator,
        denominator,
        numAtPoint,
        denAtPoint,
      );
    }

    return _applyRounds(
      problem,
      numerator,
      denominator,
      numAtPoint,
      denAtPoint,
      isInfinityOverInfinity: false,
    );
  }

  // ── Infinite approach (∞/∞ detection) ────────────────────────

  LhopitalResult _solveAtInfinity(
    LhopitalProblem problem,
    Expr numerator,
    Expr denominator,
  ) {
    final sign = problem.approachValue > 0 ? 1.0 : -1.0;
    final v = problem.variable;

    final isInfinityOverInfinity = _isUnboundedAt(numerator, sign * 1e3, v) &&
        _isUnboundedAt(numerator, sign * 1e6, v) &&
        _isUnboundedAt(denominator, sign * 1e3, v) &&
        _isUnboundedAt(denominator, sign * 1e6, v);

    if (!isInfinityOverInfinity) {
      return _notIndeterminate(
          problem, numerator, denominator, double.nan, double.nan);
    }

    return _applyRounds(
      problem,
      numerator,
      denominator,
      double.nan,
      double.nan,
      isInfinityOverInfinity: true,
    );
  }

  bool _isUnboundedAt(Expr node, double x, String v) {
    final value = _evaluator.evaluate(node, x, v);
    return value.isFinite && value.abs() > 1e2;
  }

  // ── L'Hopital rounds ─────────────────────────────────────────

  LhopitalResult _applyRounds(LhopitalProblem problem, Expr numerator,
      Expr denominator, double numAtPoint, double denAtPoint,
      {required bool isInfinityOverInfinity}) {
    final v = problem.variable;
    var curNum = numerator;
    var curDen = denominator;
    final rounds = <LhopitalRound>[];

    for (var round = 1; round <= _maxRounds; round++) {
      final dNum =
          DerivativeSolver.simplify(DerivativeSolver.differentiate(curNum, v));
      final dDen =
          DerivativeSolver.simplify(DerivativeSolver.differentiate(curDen, v));

      final numVal = isInfinityOverInfinity
          ? _evaluator.evaluate(dNum, _largeSampleX, v)
          : _evaluator.evaluate(dNum, problem.approachValue, v);
      final denVal = isInfinityOverInfinity
          ? _evaluator.evaluate(dDen, _largeSampleX, v)
          : _evaluator.evaluate(dDen, problem.approachValue, v);

      final ratio = _safeDivide(numVal, denVal);

      if (_isUsableNumber(ratio)) {
        rounds.add(LhopitalRound(
          derivativeNumerator: dNum,
          derivativeDenominator: dDen,
          numeratorValue: numVal,
          denominatorValue: denVal,
          form: '${_fmtValue(numVal)}/${_fmtValue(denVal)}',
        ));
        return LhopitalResult(
          originalExpression: problem.expression,
          approachValue: problem.approachValue,
          variable: v,
          originalNumerator: numerator,
          originalDenominator: denominator,
          numeratorAtPoint: numAtPoint,
          denominatorAtPoint: denAtPoint,
          isIndeterminate: true,
          isInfinityOverInfinity: isInfinityOverInfinity,
          rounds: rounds,
          roundsApplied: round,
          finalValue: ratio,
          solved: true,
        );
      }

      final stillIndeterminate = numVal.abs() < 1e-9 && denVal.abs() < 1e-9;
      final stillInfinityForm = isInfinityOverInfinity &&
          numVal.isFinite &&
          denVal.isFinite &&
          numVal.abs() > 1e2 &&
          denVal.abs() > 1e2;

      rounds.add(LhopitalRound(
        derivativeNumerator: dNum,
        derivativeDenominator: dDen,
        numeratorValue: numVal,
        denominatorValue: denVal,
        form: stillIndeterminate
            ? '0/0'
            : (stillInfinityForm
                ? '∞/∞'
                : '${_fmtValue(numVal)}/${_fmtValue(denVal)}'),
      ));

      if (stillIndeterminate || stillInfinityForm) {
        curNum = dNum;
        curDen = dDen;
        continue;
      }

      return _failure(
        problem,
        numerator,
        denominator,
        numAtPoint,
        denAtPoint,
        isInfinityOverInfinity: isInfinityOverInfinity,
        rounds: rounds,
        roundsApplied: round,
        message:
            "Still indeterminate after $round round(s) of L'Hopital's rule.",
      );
    }

    return _failure(
      problem,
      numerator,
      denominator,
      numAtPoint,
      denAtPoint,
      isInfinityOverInfinity: isInfinityOverInfinity,
      rounds: rounds,
      roundsApplied: _maxRounds,
      message:
          "Still indeterminate after $_maxRounds rounds of L'Hopital's rule. Try a different method.",
    );
  }

  // For ∞/∞ rounds the derivative ratio is sampled at a large x to
  // approximate lim(x -> ∞) f'/g'.
  static const double _largeSampleX = 1e5;

  // ── Error paths ──────────────────────────────────────────────

  LhopitalResult _notIndeterminate(
    LhopitalProblem problem,
    Expr numerator,
    Expr denominator,
    double numAtPoint,
    double denAtPoint,
  ) {
    return LhopitalResult(
      originalExpression: problem.expression,
      approachValue: problem.approachValue,
      variable: problem.variable,
      originalNumerator: numerator,
      originalDenominator: denominator,
      numeratorAtPoint: numAtPoint,
      denominatorAtPoint: denAtPoint,
      isIndeterminate: false,
      finalValue: double.nan,
      solved: false,
      errorMessage:
          'Not an indeterminate form. L\'Hopital\'s rule applies to 0/0 or ∞/∞. Try using Substitution method instead.',
    );
  }

  LhopitalResult _parseError(LhopitalProblem problem, String message) {
    return LhopitalResult(
      originalExpression: problem.expression,
      approachValue: problem.approachValue,
      variable: problem.variable,
      numeratorAtPoint: 0,
      denominatorAtPoint: 0,
      isIndeterminate: false,
      finalValue: double.nan,
      solved: false,
      errorMessage: message,
    );
  }

  LhopitalResult _failure(
    LhopitalProblem problem,
    Expr numerator,
    Expr denominator,
    double numAtPoint,
    double denAtPoint, {
    required bool isInfinityOverInfinity,
    required List<LhopitalRound> rounds,
    required int roundsApplied,
    required String message,
  }) {
    return LhopitalResult(
      originalExpression: problem.expression,
      approachValue: problem.approachValue,
      variable: problem.variable,
      originalNumerator: numerator,
      originalDenominator: denominator,
      numeratorAtPoint: numAtPoint,
      denominatorAtPoint: denAtPoint,
      isIndeterminate: true,
      isInfinityOverInfinity: isInfinityOverInfinity,
      rounds: rounds,
      roundsApplied: roundsApplied,
      finalValue: double.nan,
      solved: false,
      errorMessage: message,
    );
  }

  // ── Parsing (main fraction split, mirrors by_conjugate) ──────

  (Expr, Expr) _parseExpressionAsFraction(String expression) {
    final splitIndex = _findMainFractionSlash(expression);
    if (splitIndex != -1) {
      final numerator = expression.substring(0, splitIndex).trim();
      final denominator = expression.substring(splitIndex + 1).trim();
      if (numerator.isNotEmpty && denominator.isNotEmpty) {
        return (_parse(numerator), _parse(denominator));
      }
    }

    final ast = _parse(expression);
    if (ast is BinOp && ast.op == '/') {
      return (ast.left, ast.right);
    }
    return (ast, const Num(1));
  }

  Expr _parse(String expression) {
    final stripped = _stripOuterParentheses(expression);
    final ast = DerivativeSolver.parse(stripped);
    return DerivativeSolver.simplify(ast);
  }

  int _findMainFractionSlash(String expression) {
    var depth = 0;
    var slashIndex = -1;
    for (var i = 0; i < expression.length; i++) {
      final ch = expression[i];
      if (ch == '(') {
        depth++;
      } else if (ch == ')') {
        depth--;
      } else if (ch == '/' && depth == 0) {
        slashIndex = i;
      }
    }
    return slashIndex;
  }

  String _stripOuterParentheses(String expression) {
    var result = expression.trim();
    while (result.startsWith('(') &&
        result.endsWith(')') &&
        _outerParenthesesWrapAll(result)) {
      result = result.substring(1, result.length - 1).trim();
    }
    return result;
  }

  bool _outerParenthesesWrapAll(String expression) {
    var depth = 0;
    for (var i = 0; i < expression.length; i++) {
      final ch = expression[i];
      if (ch == '(') depth++;
      if (ch == ')') depth--;
      if (depth == 0 && i < expression.length - 1) return false;
      if (depth < 0) return false;
    }
    return depth == 0;
  }

  // ── Numeric helpers ──────────────────────────────────────────

  double _safeDivide(double numerator, double denominator) {
    if (numerator.isNaN || denominator.isNaN) return double.nan;
    if (denominator.abs() < 1e-12) {
      if (numerator.abs() < 1e-12) return double.nan;
      return numerator > 0 ? double.infinity : double.negativeInfinity;
    }
    return numerator / denominator;
  }

  bool _isUsableNumber(double value) {
    return !value.isNaN && !value.isInfinite;
  }

  String _fmtValue(double n) {
    if (n.isNaN) return 'undefined';
    if (n.isInfinite) return n > 0 ? 'infinity' : '-infinity';
    return LhopitalResult.formatValue(n);
  }
}
