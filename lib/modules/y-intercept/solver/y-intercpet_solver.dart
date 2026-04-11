// ignore: file_names
import 'dart:math';
import 'fraction.dart';
import 'yi_helpers.dart';
import 'yi_steps.dart';

enum YIInputType { slopeIntercept, standardForm, generalForm, jumbled }

class YIResult {
  final YIFraction? yIntercept;
  final YIFraction? xIntercept;
  final String generalForm;
  final String standardForm;
  final YIFraction? slope;
  final String equation;
  final String direction;
  final String angle;
  final String riseRun;
  final YIInputType inputType;

  final List<YISolverStep> slopeStepsFromStandard;
  final List<YISolverStep> slopeStepsFromGeneral;
  final List<YISolverStep> xInterceptSteps;
  final List<YISolverStep> standardFormSteps;
  final List<YISolverStep> generalFormSteps;

  const YIResult({
    required this.yIntercept,
    required this.xIntercept,
    required this.generalForm,
    required this.standardForm,
    required this.slope,
    required this.equation,
    required this.direction,
    required this.angle,
    required this.riseRun,
    required this.inputType,
    required this.slopeStepsFromStandard,
    required this.slopeStepsFromGeneral,
    required this.xInterceptSteps,
    required this.standardFormSteps,
    required this.generalFormSteps,
  });
}

class _Term {
  final String variable;
  final YIFraction coeff;
  const _Term({required this.variable, required this.coeff});
}

// ══════════════════════════════════════════════════════════
// CORE SOLVER
// ══════════════════════════════════════════════════════════

class YInterceptSolver {
  YInterceptSolver._();

  static YIResult? tryParseAny(String input) {
    final parsed = _parseAnyForm(input);
    if (parsed == null) return null;
    final (a, b, c, type) = parsed;
    return _computeFromABC(a, b, c, type);
  }

  static YIResult? tryParseSlopeIntercept({
    required String mText,
    required String bText,
  }) {
    final mFrac = parseFractionString(mText);
    final bFrac = parseFractionString(bText);
    if (mFrac == null || bFrac == null) return null;
    return _computeSlopeIntercept(mFrac.simplified(), bFrac.simplified());
  }

  static YIResult fromSlopeIntercept({
    required YIFraction m,
    required YIFraction b,
  }) =>
      _computeSlopeIntercept(m.simplified(), b.simplified());

  static YIResult fromSlopeInterceptDoubles({
    required double m,
    required double b,
  }) =>
      _computeSlopeIntercept(
        YIFraction.fromDouble(m),
        YIFraction.fromDouble(b),
      );

  static YIResult fromStandardForm({
    required int A,
    required int B,
    required int C,
  }) =>
      _computeFromABC(A, B, C, YIInputType.standardForm);

  // ══════════════════════════════════════════════════════════
  // UNIVERSAL PARSER
  // ══════════════════════════════════════════════════════════

  static (int, int, int, YIInputType)? _parseAnyForm(String raw) {
    String s = raw.replaceAll('\u2212', '-').replaceAll('\u00d7', '*').trim();
    if (!s.contains('=')) return null;

    final eqIdx = s.indexOf('=');
    final lhsStr = s.substring(0, eqIdx).trim();
    final rhsStr = s.substring(eqIdx + 1).trim();

    final lhsTerms = _tokenise(lhsStr);
    final rhsTerms = _tokenise(rhsStr);
    if (lhsTerms == null || rhsTerms == null) return null;

    YIFraction lA = zeroFrac, lB = zeroFrac, lC = zeroFrac;
    for (final t in lhsTerms) {
      if (t.variable == 'x') {
        lA = fracAdd(lA, t.coeff);
      } else if (t.variable == 'y') {
        lB = fracAdd(lB, t.coeff);
      } else {
        lC = fracAdd(lC, t.coeff);
      }
    }

    YIFraction rA = zeroFrac, rB = zeroFrac, rC = zeroFrac;
    for (final t in rhsTerms) {
      if (t.variable == 'x') {
        rA = fracAdd(rA, t.coeff);
      } else if (t.variable == 'y') {
        rB = fracAdd(rB, t.coeff);
      } else {
        rC = fracAdd(rC, t.coeff);
      }
    }

    final A = fracSub(lA, rA);
    final B = fracSub(lB, rB);
    final C = fracSub(rC, lC);

    final denom = lcm(lcm(A.denominator, B.denominator), C.denominator);
    final iA = A.numerator * (denom ~/ A.denominator);
    final iB = B.numerator * (denom ~/ B.denominator);
    final iC = C.numerator * (denom ~/ C.denominator);

    final g = gcd3(iA.abs(), iB.abs(), iC.abs());
    final rA2 = g == 0 ? iA : iA ~/ g;
    final rB2 = g == 0 ? iB : iB ~/ g;
    final rC2 = g == 0 ? iC : iC ~/ g;

    return (rA2, rB2, rC2, _detectInputType(raw, rA2, rB2, rC2));
  }

  static List<_Term>? _tokenise(String expr) {
    expr = expr.trim();
    if (expr.isEmpty) return [];
    if (!expr.startsWith('-') && !expr.startsWith('+')) expr = '+$expr';

    final tokens = <String>[];
    int start = 0;
    for (int i = 1; i < expr.length; i++) {
      final ch = expr[i];
      if (ch == '+' || ch == '-') {
        tokens.add(expr.substring(start, i).trim());
        start = i;
      }
    }
    tokens.add(expr.substring(start).trim());

    final terms = <_Term>[];
    for (final tok in tokens) {
      if (tok.isEmpty) continue;
      final t = _parseTerm(tok);
      if (t == null) return null;
      terms.add(t);
    }
    return terms;
  }

  static _Term? _parseTerm(String tok) {
    tok = tok.trim();
    if (tok.isEmpty) return null;

    int sign = 1;
    if (tok.startsWith('-')) {
      sign = -1;
      tok = tok.substring(1).trim();
    } else if (tok.startsWith('+')) {
      tok = tok.substring(1).trim();
    }

    final hasX = tok.toLowerCase().contains('x');
    final hasY = tok.toLowerCase().contains('y');
    if (hasX && hasY) return null;

    String variable = 'const';
    String coeffStr = tok;

    if (hasX) {
      variable = 'x';
      coeffStr = tok.toLowerCase().replaceAll('x', '').replaceAll('*', '').trim();
    } else if (hasY) {
      variable = 'y';
      coeffStr = tok.toLowerCase().replaceAll('y', '').replaceAll('*', '').trim();
    }

    YIFraction coeff;
    if (coeffStr.isEmpty) {
      coeff = oneFrac;
    } else if (coeffStr.contains('/')) {
      final parts = coeffStr.split('/');
      if (parts.length != 2) return null;
      final n = int.tryParse(parts[0].trim());
      final d = int.tryParse(parts[1].trim());
      if (n == null || d == null || d == 0) return null;
      coeff = YIFraction(numerator: n, denominator: d).simplified();
    } else {
      final n = int.tryParse(coeffStr);
      if (n != null) {
        coeff = YIFraction(numerator: n, denominator: 1);
      } else {
        final d = double.tryParse(coeffStr);
        if (d == null) return null;
        coeff = YIFraction.fromDouble(d);
      }
    }

    return _Term(
      variable: variable,
      coeff: YIFraction(
        numerator: sign * coeff.numerator,
        denominator: coeff.denominator,
      ).simplified(),
    );
  }

  static YIInputType _detectInputType(String raw, int A, int B, int C) {
    final s = raw.replaceAll(' ', '').toLowerCase();
    if (s.endsWith('=0')) return YIInputType.generalForm;
    if (s.startsWith('y=')) return YIInputType.slopeIntercept;
    final xIdx = s.indexOf('x');
    final yIdx = s.indexOf('y');
    if (xIdx != -1 && yIdx != -1 && xIdx < yIdx) {
      return YIInputType.standardForm;
    }
    return YIInputType.jumbled;
  }

  // ══════════════════════════════════════════════════════════
  // CORE COMPUTATION
  // ══════════════════════════════════════════════════════════

  static YIResult _computeFromABC(int A, int B, int C, YIInputType type) {
    final sfStr = sfString(A, B, C);
    final gfStr = generalFormFromABC(A, B, C);
    final sfTex = sfLatex(A, B, C);
    final gfTex = gfLatex(A, B, -C); // gf constant = -C

    if (B == 0) {
      if (A == 0) {
        return YIResult(
          yIntercept: null,
          xIntercept: null,
          generalForm: gfStr,
          standardForm: sfStr,
          slope: null,
          equation: C == 0 ? 'All real numbers' : 'No solution',
          direction: 'N/A',
          angle: 'N/A',
          riseRun: 'N/A',
          inputType: type,
          slopeStepsFromStandard: const [],
          slopeStepsFromGeneral: const [],
          xInterceptSteps: const [],
          standardFormSteps: const [],
          generalFormSteps: const [],
        );
      }
      final xVal = YIFraction(numerator: C, denominator: A).simplified();
      return YIResult(
        yIntercept: null,
        xIntercept: xVal,
        generalForm: gfStr,
        standardForm: sfStr,
        slope: null,
        equation: 'x = $xVal',
        direction: 'Vertical |',
        angle: '90.0°',
        riseRun: 'Undefined',
        inputType: type,
        slopeStepsFromStandard: buildVerticalSlopeSteps(A, C, sfTex, gfTex),
        slopeStepsFromGeneral: buildVerticalSlopeSteps(A, C, sfTex, gfTex),
        xInterceptSteps: buildVerticalXSteps(A, C, xVal),
        standardFormSteps: const [],
        generalFormSteps: const [],
      );
    }

    final m = YIFraction(numerator: -A, denominator: B).simplified();
    final b = YIFraction(numerator: C, denominator: B).simplified();
    final eqTex = eqLatex(m, b);

    YIFraction? xInt;
    if (!m.isZero) {
      xInt = (b * negOneFrac).divided(m).simplified();
    }

    final angleVal = atan(m.toDouble()) * 180 / pi;

    return YIResult(
      yIntercept: b,
      xIntercept: xInt,
      generalForm: gfStr,
      standardForm: sfStr,
      slope: m,
      equation: eqTex,
      direction: direction(m.toDouble()),
      angle: '${angleVal.toStringAsFixed(1)}°',
      riseRun: riseRun(m),
      inputType: type,
      slopeStepsFromStandard:
          buildSlopeStepsFromStandard(A, B, C, m, b, sfTex, gfTex, eqTex),
      slopeStepsFromGeneral:
          buildSlopeStepsFromGeneral(A, B, C, m, b, sfTex, gfTex, eqTex),
      xInterceptSteps: buildXInterceptSteps(m, b, xInt),
      standardFormSteps: buildStandardFormSteps(A, B, C, gfTex, sfTex),
      generalFormSteps: buildGeneralFormSteps(A, B, C, sfTex, gfTex),
    );
  }

  // ══════════════════════════════════════════════════════════
  // SLOPE-INTERCEPT DIRECT
  // ══════════════════════════════════════════════════════════

  static YIResult _computeSlopeIntercept(YIFraction m, YIFraction b) {
    final ms = m.simplified();
    final bs = b.simplified();
    final eqTex = eqLatex(ms, bs);

    final sfStr = standardFormFromSlopeIntercept(ms, bs);
    final gfStr = generalFormFromSlopeIntercept(ms, bs);

    // Compute LaTeX versions of sf/gf from coefficients
    final sfTex = sfTexFromSlopeIntercept(ms, bs);
    final gfTex = gfTexFromSlopeIntercept(ms, bs);

    YIFraction? xInt;
    if (!ms.isZero) {
      xInt = (bs * negOneFrac).divided(ms).simplified();
    }

    final angleVal = atan(ms.toDouble()) * 180 / pi;

    return YIResult(
      yIntercept: bs,
      xIntercept: xInt,
      generalForm: gfStr,
      standardForm: sfStr,
      slope: ms,
      equation: eqTex,
      direction: direction(ms.toDouble()),
      angle: '${angleVal.toStringAsFixed(1)}°',
      riseRun: riseRun(ms),
      inputType: YIInputType.slopeIntercept,
      slopeStepsFromStandard:
          buildSlopeInterceptDirectSteps(ms, bs, eqTex, sfTex, gfTex),
      slopeStepsFromGeneral:
          buildSlopeInterceptDirectSteps(ms, bs, eqTex, sfTex, gfTex),
      xInterceptSteps: buildXInterceptSteps(ms, bs, xInt),
      standardFormSteps:
          buildStandardFormFromSlopeInterceptSteps(ms, bs, sfTex, gfTex),
      generalFormSteps:
          buildGeneralFormFromSlopeInterceptSteps(ms, bs, sfTex, gfTex),
    );
  }
}
