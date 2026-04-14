// display.dart
// Two pure display classes that read a SlopeResult and produce output.
// Nothing here does any mathematics — it only formats and prints.
//   StepExplainer  — builds a list of step-by-step explanation strings
//   PrettyPrinter  — renders a SlopeResult to the terminal with ANSI colour

import 'dart:io';
import 'models.dart';
import 'math_engine.dart';

// ==================== STEP EXPLAINER ====================

class StepExplainer {
  /// Returns a list of lines that walk through the solution step by step.
  static List<String> explain(SlopeResult result) {
    switch (result.type) {
      case ProblemType.explicit:
        return _explainExplicit(result);
      case ProblemType.implicit:
        return _explainImplicit(result);
      case ProblemType.parametric:
        return _explainParametric(result);
    }
  }

  static List<String> _explainExplicit(SlopeResult r) {
    final steps = <String>[];
    final indep = r.independentVar;
    final dep = r.dependentVar ?? 'y';

    steps.add('GIVEN:  $dep = ${r.functionExpr.toMathString()}');
    steps.add('');
    steps.add('STEP 1 — Identify the function');
    steps.add('  f($indep) = ${r.functionExpr.toMathString()}');
    steps.add('');
    steps.add('STEP 2 — Differentiate with respect to $indep');
    steps.add('  d$dep/d$indep = ${r.derivative.toMathString()}');
    if (r.derivative.toMathString() != r.simplifiedDerivative.toMathString()) {
      steps.add('');
      steps.add('STEP 3 — Simplify the derivative');
      steps.add('  d$dep/d$indep = ${r.simplifiedDerivative.toMathString()}');
    } else {
      steps.add('  (already in simplified form)');
    }

    if (r.point.containsKey(indep) && r.slopeValue != null) {
      final xVal = r.point[indep]!;
      final stepNum =
          r.derivative.toMathString() != r.simplifiedDerivative.toMathString()
              ? 4
              : 3;
      steps.add('');
      steps.add('STEP $stepNum — Evaluate at $indep = ${_fmt(xVal)}');
      steps.add(
          '  slope = ${r.simplifiedDerivative.toMathString()} | $indep=${_fmt(xVal)} = ${_fmt(r.slopeValue!)}');
    }

    _appendLines(steps, r);
    return steps;
  }

  static List<String> _explainImplicit(SlopeResult r) {
    final steps = <String>[];

    steps.add(
        'GIVEN (implicit):  ${r.leftSide?.toMathString() ?? ''} = ${r.rightSide?.toMathString() ?? ''}');
    steps.add('');
    steps.add('STEP 1 — Differentiate both sides with respect to x');
    steps.add('  Treat y as a function of x: y = y(x)');
    steps.add(
        '  Left  side: d/dx[${r.leftSide?.toMathString() ?? ''}] = ${r.leftDerivative?.toMathString() ?? ''}');
    steps.add(
        '  Right side: d/dx[${r.rightSide?.toMathString() ?? ''}] = ${r.rightDerivative?.toMathString() ?? ''}');
    steps.add('');
    steps.add('STEP 2 — Set derivatives equal and collect dy/dx terms');
    steps.add('  ${r.derivative.toMathString()} = 0');
    steps.add('');
    steps.add('STEP 3 — Solve for dy/dx');
    steps.add(
        '  dy/dx = ${r.implicitSlopeExpr?.toMathString() ?? r.simplifiedDerivative.toMathString()}');

    if (r.point.containsKey('x') &&
        r.point.containsKey('y') &&
        r.slopeValue != null) {
      final xVal = r.point['x']!;
      final yVal = r.point['y']!;
      steps.add('');
      steps.add('STEP 4 — Evaluate at (${_fmt(xVal)}, ${_fmt(yVal)})');
      steps.add('  dy/dx = ${_fmt(r.slopeValue!)}');
    }

    _appendLines(steps, r);
    return steps;
  }

  static List<String> _explainParametric(SlopeResult r) {
    final steps = <String>[];
    final t = r.independentVar;

    steps.add('GIVEN (parametric):');
    steps.add('  x($t) = ${r.paramXExpr?.toMathString() ?? ''}');
    steps.add('  y($t) = ${r.paramYExpr?.toMathString() ?? ''}');
    steps.add('');
    steps.add('STEP 1 — Find dx/d$t and dy/d$t');
    steps.add('  dx/d$t = ${r.dxDt?.toMathString() ?? ''}');
    steps.add('  dy/d$t = ${r.dyDt?.toMathString() ?? ''}');
    steps.add('');
    steps.add('STEP 2 — Apply the parametric slope formula');
    steps.add('  dy/dx = (dy/d$t) / (dx/d$t)');
    steps.add(
        '        = (${r.dyDt?.toMathString() ?? ''}) / (${r.dxDt?.toMathString() ?? ''})');
    steps.add('        = ${r.simplifiedDerivative.toMathString()}');

    if (r.secondDerivative != null) {
      steps.add('');
      steps.add('STEP 3 — Second derivative (concavity)');
      steps.add('  d²y/dx² = (d/d$t[dy/dx]) / (dx/d$t)');
      steps.add('          = ${r.secondDerivative!.toMathString()}');
    }

    if (r.point.containsKey(t) && r.slopeValue != null) {
      final stepNum = r.secondDerivative != null ? 4 : 3;
      final tVal = r.point[t]!;
      steps.add('');
      steps.add('STEP $stepNum — Evaluate at $t = ${_fmt(tVal)}');
      final xVal = r.paramXExpr != null
          ? ExprUtils.evaluate(r.paramXExpr!, r.point)
          : double.nan;
      final yVal = r.paramYExpr != null
          ? ExprUtils.evaluate(r.paramYExpr!, r.point)
          : double.nan;
      if (!xVal.isNaN && !yVal.isNaN) {
        steps.add('  x = ${_fmt(xVal)},  y = ${_fmt(yVal)}');
      }
      steps.add('  dy/dx = ${_fmt(r.slopeValue!)}');
    }

    _appendLines(steps, r);
    return steps;
  }

  static void _appendLines(List<String> steps, SlopeResult r) {
    if (r.tangentLineEquation != null) {
      steps.add('');
      steps.add('TANGENT LINE:  ${r.tangentLineEquation}');
    }
    if (r.normalLineEquation != null) {
      steps.add('NORMAL LINE:   ${r.normalLineEquation}');
    }
  }

  static String _fmt(double v) {
    if (v == v.truncateToDouble() && v.abs() < 1e10)
      return v.toInt().toString();
    return v.toStringAsFixed(6).replaceAll(RegExp(r'\.?0+$'), '');
  }
}

// ==================== PRETTY PRINTER ====================

class PrettyPrinter {
  static const _reset  = '\x1B[0m';
  static const _bold   = '\x1B[1m';
  static const _cyan   = '\x1B[36m';
  static const _green  = '\x1B[32m';
  static const _yellow = '\x1B[33m';
  static const _blue   = '\x1B[34m';

  /// Prints a fully-formatted, ANSI-coloured result block to stdout.
  static void print(SlopeResult result) {
    const w = 62;
    final bar = '═' * w;

    _writeln('$_bold$_cyan╔$bar╗$_reset');
    _writeln('$_bold$_cyan║${_center('SLOPE SOLVER', w)}║$_reset');
    _writeln('$_bold$_cyan╚$bar╝$_reset');
    _writeln('');

    final typeLabel = {
      ProblemType.explicit:   '  EXPLICIT  ',
      ProblemType.implicit:   '  IMPLICIT  ',
      ProblemType.parametric: ' PARAMETRIC ',
    }[result.type]!;
    _writeln('$_bold$_blue[$typeLabel]$_reset  ${result.originalInput}');
    _writeln('');

    final steps = StepExplainer.explain(result);
    for (final step in steps) {
      if (step.startsWith('GIVEN') ||
          step.startsWith('STEP') ||
          step.startsWith('TANGENT') ||
          step.startsWith('NORMAL')) {
        _writeln('$_bold$_yellow$step$_reset');
      } else {
        _writeln(step);
      }
    }

    _writeln('');
    _writeln('$_bold$_green┌─── RESULT SUMMARY ${'─' * (w - 19)}┐$_reset');
    _writeln(
        '$_bold$_green│$_reset  Derivative:  ${result.simplifiedDerivative.toMathString()}'
        '${' ' * _pad(result.simplifiedDerivative.toMathString(), w - 15)}'
        '$_bold$_green│$_reset');

    if (result.secondDerivative != null) {
      final sd = result.secondDerivative!.toMathString();
      _writeln(
          '$_bold$_green│$_reset  2nd deriv:   $sd'
          '${' ' * _pad(sd, w - 15)}'
          '$_bold$_green│$_reset');
    }
    if (result.slopeValue != null) {
      final sv = _fmtD(result.slopeValue!);
      _writeln(
          '$_bold$_green│$_reset  Slope value: $sv'
          '${' ' * _pad(sv, w - 15)}'
          '$_bold$_green│$_reset');
    }
    if (result.tangentLineEquation != null) {
      final tl = result.tangentLineEquation!;
      _writeln(
          '$_bold$_green│$_reset  Tangent:     $tl'
          '${' ' * _pad(tl, w - 15)}'
          '$_bold$_green│$_reset');
    }
    if (result.normalLineEquation != null) {
      final nl = result.normalLineEquation!;
      _writeln(
          '$_bold$_green│$_reset  Normal:      $nl'
          '${' ' * _pad(nl, w - 15)}'
          '$_bold$_green│$_reset');
    }
    _writeln('$_bold$_green└${'─' * w}┘$_reset');
  }

  static void _writeln(String s) => stdout.writeln(s);

  static String _center(String s, int width) {
    final pad = (width - s.length) ~/ 2;
    return ' ' * pad + s + ' ' * (width - pad - s.length);
  }

  static int _pad(String s, int total) {
    final rem = total - s.length;
    return rem < 0 ? 0 : rem;
  }

  static String _fmtD(double v) {
    if (v == v.truncateToDouble() && v.abs() < 1e10)
      return v.toInt().toString();
    return v.toStringAsFixed(8).replaceAll(RegExp(r'\.?0+$'), '');
  }
}