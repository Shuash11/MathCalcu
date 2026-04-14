// solver.dart
// SlopeSolver: the single public entry point for all slope computation.
// Detects problem type, delegates to the correct private strategy,
// and returns a fully-populated SlopeResult.
// Nothing here prints, formats, or parses raw text beyond calling
// Tokenizer/Parser to turn the input string into an Expr tree.

import 'models.dart';
import 'parser.dart';
import 'math_engine.dart';

// ==================== SLOPE SOLVER ====================

class SlopeSolver {
  // ── Public entry point ──────────────────────────────────────────────────────

  /// Solve for the slope/derivative given an input string and optional point.
  ///
  /// [input] may be:
  ///   • Explicit:    "y = 3x^2 - 2x + 1"  or  "f(x) = sin(x)*e^x"
  ///   • Implicit:    "x^2 + y^2 = 25"  or  "x^3 + y^3 = 6xy"
  ///   • Parametric:  "x=cos(t), y=sin(t)"  (comma-separated pair)
  ///
  /// [pointValues] maps variable names → numeric values.
  /// For explicit/implicit supply {"x": value}; for parametric supply {"t": value}.
  static SlopeResult solve(String input, {Map<String, double>? pointValues}) {
    final trimmed = input.trim();

    if (_isParametric(trimmed)) {
      return _solveParametric(trimmed, pointValues ?? {});
    }

    final tokens = Tokenizer(trimmed).tokenize();
    final (left, right) = Parser(tokens).parse();

    if (right == null) {
      return _solveExplicit(Var('y'), left, trimmed, pointValues ?? {});
    }

    if (left is Var && left.name == 'y') {
      return _solveExplicit(left, right, trimmed, pointValues ?? {});
    }

    final lVars = ExprUtils.collectVars(left);
    final rVars = ExprUtils.collectVars(right);

    if (left is Var && (left.name == 'y' || !rVars.contains('y'))) {
      return _solveExplicit(left, right, trimmed, pointValues ?? {});
    }

    if (lVars.contains('y') ||
        rVars.contains('y') ||
        lVars.contains('x') ||
        rVars.contains('x')) {
      return _solveImplicit(left, right, trimmed, pointValues ?? {});
    }

    return _solveImplicit(left, right, trimmed, pointValues ?? {});
  }

  // ── Parametric detection ────────────────────────────────────────────────────

  static bool _isParametric(String s) {
    int depth = 0;
    for (int i = 0; i < s.length; i++) {
      if (s[i] == '(')
        depth++;
      else if (s[i] == ')')
        depth--;
      else if (s[i] == ',' && depth == 0) return true;
    }
    return false;
  }

  // ── Explicit solver: y = f(x) ───────────────────────────────────────────────

  static SlopeResult _solveExplicit(
    Expr lhsVar,
    Expr rhs,
    String originalInput,
    Map<String, double> pointValues,
  ) {
    final indepVar = 'x';
    final depVar = (lhsVar is Var) ? lhsVar.name : 'y';

    final rawDeriv = Differentiator.differentiate(rhs, indepVar);
    final simplified = Simplifier.simplify(rawDeriv);

    double? slopeVal;
    double? tangentSlope;
    double? tangentYIntercept;
    double? normalSlope;
    String? tangentEq;
    String? normalEq;

    if (pointValues.containsKey(indepVar)) {
      final xVal = pointValues[indepVar]!;
      try {
        slopeVal = ExprUtils.evaluate(simplified, pointValues);
        tangentSlope = slopeVal;

        final yVal = ExprUtils.evaluate(rhs, pointValues);
        tangentYIntercept = yVal - tangentSlope * xVal;
        tangentEq = _lineEquation(tangentSlope, tangentYIntercept, xVal, yVal);

        if (tangentSlope != 0 && tangentSlope.isFinite) {
          normalSlope = -1.0 / tangentSlope;
          final normYInt = yVal - normalSlope * xVal;
          normalEq = _lineEquation(normalSlope, normYInt, xVal, yVal);
        } else if (tangentSlope == 0) {
          normalEq = 'x = ${_fmt(xVal)} (vertical line)';
        }
      } catch (_) {}
    }

    return SlopeResult(
      type: ProblemType.explicit,
      originalInput: originalInput,
      functionExpr: rhs,
      derivative: rawDeriv,
      simplifiedDerivative: simplified,
      slopeValue: slopeVal,
      point: pointValues,
      independentVar: indepVar,
      dependentVar: depVar,
      tangentSlope: tangentSlope,
      tangentYIntercept: tangentYIntercept,
      normalSlope: normalSlope,
      tangentLineEquation: tangentEq,
      normalLineEquation: normalEq,
    );
  }

  // ── Implicit solver: F(x,y) = G(x,y) ──────────────────────────────────────

  static SlopeResult _solveImplicit(
    Expr lhs,
    Expr rhs,
    String originalInput,
    Map<String, double> pointValues,
  ) {
    final F = Simplifier.simplify(BinOp(lhs, '-', rhs));

    final dLhs = Differentiator.differentiate(lhs, 'x', dependentVars: {'y'});
    final dRhs = Differentiator.differentiate(rhs, 'x', dependentVars: {'y'});

    final diffExpr = Simplifier.simplify(BinOp(dLhs, '-', dRhs));
    final (coeff, remainder) = Simplifier.extractDerivCoeff(diffExpr, 'y');

    // dy/dx = -remainder / coeff  (from coeff * dy/dx + remainder = 0)
    final implicitSlope = Simplifier.simplify(
      BinOp(UnaryNeg(remainder), '/', coeff),
    );

    double? slopeVal;
    double? tangentSlope;
    String? tangentEq;
    double? normalSlope;
    String? normalEq;

    if (pointValues.containsKey('x') && pointValues.containsKey('y')) {
      try {
        slopeVal = ExprUtils.evaluate(implicitSlope, pointValues);
        tangentSlope = slopeVal;
        final xVal = pointValues['x']!;
        final yVal = pointValues['y']!;

        final yInt = yVal - tangentSlope * xVal;
        tangentEq = _lineEquation(tangentSlope, yInt, xVal, yVal);

        if (tangentSlope != 0 && tangentSlope.isFinite) {
          normalSlope = -1.0 / tangentSlope;
          final nYInt = yVal - normalSlope * xVal;
          normalEq = _lineEquation(normalSlope, nYInt, xVal, yVal);
        } else if (tangentSlope == 0) {
          normalEq = 'x = ${_fmt(pointValues['x']!)} (vertical line)';
        }
      } catch (_) {}
    }

    return SlopeResult(
      type: ProblemType.implicit,
      originalInput: originalInput,
      functionExpr: F,
      derivative: diffExpr,
      simplifiedDerivative: implicitSlope,
      slopeValue: slopeVal,
      point: pointValues,
      independentVar: 'x',
      dependentVar: 'y',
      leftSide: lhs,
      rightSide: rhs,
      leftDerivative: dLhs,
      rightDerivative: dRhs,
      implicitSlopeExpr: implicitSlope,
      tangentSlope: tangentSlope,
      tangentLineEquation: tangentEq,
      normalSlope: normalSlope,
      normalLineEquation: normalEq,
    );
  }

  // ── Parametric solver: x=f(t), y=g(t) ─────────────────────────────────────

  static SlopeResult _solveParametric(
    String input,
    Map<String, double> pointValues,
  ) {
    final parts = _splitTopLevel(input);
    if (parts.length != 2) {
      throw FormatException(
          'Parametric input must have exactly two expressions: "x=..., y=..."');
    }

    Expr? xExpr, yExpr;
    String paramVar = 't';

    for (final part in parts) {
      final tokens = Tokenizer(part.trim()).tokenize();
      final (lhs, rhs) = Parser(tokens).parse();
      if (rhs == null) {
        throw FormatException(
            'Parametric part must be an equation: "${part.trim()}"');
      }
      if (lhs is Var && lhs.name == 'x') {
        xExpr = rhs;
        final vars = ExprUtils.collectVars(rhs);
        if (vars.isNotEmpty) paramVar = vars.first;
      } else if (lhs is Var && lhs.name == 'y') {
        yExpr = rhs;
      } else {
        throw FormatException(
            'Expected "x=..." and "y=...", got "${part.trim()}"');
      }
    }

    if (xExpr == null || yExpr == null) {
      throw FormatException(
          'Could not find both x(t) and y(t) in parametric input');
    }

    final xVars = ExprUtils.collectVars(xExpr);
    final yVars = ExprUtils.collectVars(yExpr);
    final allVars = xVars.union(yVars).difference({'x', 'y'});
    if (allVars.isNotEmpty) paramVar = allVars.first;

    final dxDt =
        Simplifier.simplify(Differentiator.differentiate(xExpr, paramVar));
    final dyDt =
        Simplifier.simplify(Differentiator.differentiate(yExpr, paramVar));

    // dy/dx = (dy/dt) / (dx/dt)
    final parametricSlope = Simplifier.simplify(BinOp(dyDt, '/', dxDt));

    // d²y/dx² = (d/dt[dy/dx]) / (dx/dt)
    final dSlopeDt = Simplifier.simplify(
      Differentiator.differentiate(parametricSlope, paramVar),
    );
    final secondDeriv = Simplifier.simplify(BinOp(dSlopeDt, '/', dxDt));

    double? slopeVal;
    double? tangentSlope;
    String? tangentEq;
    double? normalSlope;
    String? normalEq;

    if (pointValues.containsKey(paramVar)) {
      try {
        final tVal = pointValues[paramVar]!;
        final xVal = ExprUtils.evaluate(xExpr, pointValues);
        final yVal = ExprUtils.evaluate(yExpr, pointValues);
        final dxVal = ExprUtils.evaluate(dxDt, pointValues);
        final dyVal = ExprUtils.evaluate(dyDt, pointValues);

        if (dxVal == 0) {
          tangentEq =
              'x = ${_fmt(xVal)} (vertical tangent at $paramVar=${_fmt(tVal)})';
        } else {
          slopeVal = dyVal / dxVal;
          tangentSlope = slopeVal;
          final yInt = yVal - tangentSlope * xVal;
          tangentEq =
              '${_lineEquation(tangentSlope, yInt, xVal, yVal)}  [at $paramVar=${_fmt(tVal)}]';

          if (tangentSlope != 0 && tangentSlope.isFinite) {
            normalSlope = -1.0 / tangentSlope;
            final nYInt = yVal - normalSlope * xVal;
            normalEq =
                '${_lineEquation(normalSlope, nYInt, xVal, yVal)}  [at $paramVar=${_fmt(tVal)}]';
          } else if (tangentSlope == 0) {
            normalEq =
                'x = ${_fmt(xVal)} (vertical line at $paramVar=${_fmt(tVal)})';
          }
        }
      } catch (_) {}
    }

    return SlopeResult(
      type: ProblemType.parametric,
      originalInput: input,
      functionExpr: parametricSlope,
      derivative: parametricSlope,
      simplifiedDerivative: parametricSlope,
      slopeValue: slopeVal,
      point: pointValues,
      independentVar: paramVar,
      dependentVar: 'y',
      paramXExpr: xExpr,
      paramYExpr: yExpr,
      dxDt: dxDt,
      dyDt: dyDt,
      secondDerivative: secondDeriv,
      tangentSlope: tangentSlope,
      tangentLineEquation: tangentEq,
      normalSlope: normalSlope,
      normalLineEquation: normalEq,
    );
  }

  // ── Private helpers ─────────────────────────────────────────────────────────

  /// Splits a string at top-level commas (not inside parentheses).
  static List<String> _splitTopLevel(String s) {
    final parts = <String>[];
    int depth = 0;
    int start = 0;
    for (int i = 0; i < s.length; i++) {
      if (s[i] == '(')
        depth++;
      else if (s[i] == ')')
        depth--;
      else if (s[i] == ',' && depth == 0) {
        parts.add(s.substring(start, i).trim());
        start = i + 1;
      }
    }
    parts.add(s.substring(start).trim());
    return parts;
  }

  /// Formats a double for use inside line equations.
  static String _fmt(double v) {
    if (v == v.truncateToDouble() && v.abs() < 1e10)
      return v.toInt().toString();
    return v.toStringAsFixed(6).replaceAll(RegExp(r'\.?0+$'), '');
  }

  /// Builds a "y = mx + b" string, handling zero slope and sign of b.
  static String _lineEquation(double m, double b, double x0, double y0) {
    if (m == 0) return 'y = ${_fmt(y0)}';
    if (!m.isFinite) return 'x = ${_fmt(x0)} (vertical line)';
    final mStr = _fmt(m);
    if (b == 0) return 'y = ${mStr}x';
    if (b > 0) return 'y = ${mStr}x + ${_fmt(b)}';
    return 'y = ${mStr}x - ${_fmt(b.abs())}';
  }
}