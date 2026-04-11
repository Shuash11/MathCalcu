// ignore: file_names
import 'fraction.dart';

// ══════════════════════════════════════════════════════════
// CONSTANTS
// ══════════════════════════════════════════════════════════

const zeroFrac = YIFraction(numerator: 0, denominator: 1);
const oneFrac = YIFraction(numerator: 1, denominator: 1);
const negOneFrac = YIFraction(numerator: -1, denominator: 1);

// ══════════════════════════════════════════════════════════
// LATEX FORMATTING HELPERS
// ══════════════════════════════════════════════════════════

/// Render a YIFraction as LaTeX.
/// Whole numbers → just the number. Fractions → \frac{n}{d}.
String fracLatex(YIFraction f) {
  final s = f.simplified();
  if (s.denominator == 1) return '${s.numerator}';
  final neg = s.numerator < 0;
  final absN = s.numerator.abs();
  final core = r'\frac{' '$absN' r'}{' '${s.denominator}' '}';
  return neg ? '-$core' : core;
}

/// Boxed LaTeX result: \boxed{...}
String boxLatex(String inner) => r'\boxed{' '$inner' '}';

/// Render plain instructional text inside the math renderer without losing spaces.
String textLatex(String text) {
  final escaped = text
      .replaceAll(r'\', r'\\')
      .replaceAll('{', r'\{')
      .replaceAll('}', r'\}')
      .replaceAll('%', r'\%')
      .replaceAll('&', r'\&')
      .replaceAll('#', r'\#')
      .replaceAll('_', r'\_')
      .replaceAll(r'$', r'\$');
  return r'\text{' + escaped + '}';
}

/// Build "mx" LaTeX part, handling ±1 coefficients.
String mxLatex(YIFraction m) {
  final s = m.simplified();
  if (s == oneFrac) return 'x';
  if (s == negOneFrac) return '-x';
  return '${fracLatex(s)}x';
}

/// Build full slope-intercept equation LaTeX: y = mx + b  (or y = b, y = mx)
String eqLatex(YIFraction m, YIFraction b) {
  final ms = m.simplified();
  final bs = b.simplified();
  if (ms.isZero) return 'y = ${fracLatex(bs)}';
  final mPart = mxLatex(ms);
  if (bs.isZero) return 'y = $mPart';
  if (bs.numerator > 0) return 'y = $mPart + ${fracLatex(bs)}';
  return 'y = $mPart - ${fracLatex(bs.abs())}';
}

/// Standard form LaTeX: Ax + By = C
String sfLatex(int A, int B, int C) {
  String x = termLatex(A, 'x', isFirst: true);
  String y = termLatex(B, 'y', isFirst: false);
  return '${x.trim()} ${y.trim()} = $C'.trim();
}

/// General form LaTeX: Ax + By + C = 0
String gfLatex(int A, int B, int C) {
  // C here is the constant on the left side (already negated from std form)
  final xPart = termLatex(A, 'x', isFirst: true).trim();
  final yPart = termLatex(B, 'y', isFirst: false).trim();
  String cPart = '';
  if (C != 0) cPart = C > 0 ? '+ $C' : '- ${C.abs()}';
  final parts = [xPart, yPart, cPart].where((s) => s.isNotEmpty).join(' ');
  return '$parts = 0';
}

String termLatex(int coeff, String v, {required bool isFirst}) {
  if (coeff == 0) return '';
  final abs = coeff.abs();
  final varStr = abs == 1 ? v : '$abs$v';
  if (isFirst) return coeff < 0 ? '-$varStr' : varStr;
  return coeff < 0 ? '- $varStr' : '+ $varStr';
}

String termStr(int coeff, String v, {required bool isFirst}) {
  if (coeff == 0) return '';
  final abs = coeff.abs();
  final varStr = abs == 1 ? v : '$abs$v';
  if (isFirst) return coeff < 0 ? '-$varStr' : varStr;
  return coeff < 0 ? '- $varStr' : '+ $varStr';
}

/// RHS after moving x-term: By = C ± Ax
String rhsAfterMovingXLatex(int A, int B, int C) {
  final byPart = B == 1
      ? 'y'
      : B == -1
          ? '-y'
          : '${B}y';
  final xPart = termLatex(-A, 'x', isFirst: true).trim();
  final cSign = C >= 0 ? '+' : '-';
  final cAbs = C.abs();
  return '$byPart = $xPart $cSign $cAbs';
}

String direction(double m) {
  if (m > 0) return 'Rising \u2197';
  if (m < 0) return 'Falling \u2198';
  return 'Horizontal \u2192';
}

String riseRun(YIFraction m) {
  final s = m.simplified();
  return s.denominator == 1
      ? '${s.numerator} / 1'
      : '${s.numerator} / ${s.denominator}';
}

// ══════════════════════════════════════════════════════════
// FORM CONVERSION HELPERS (for answer card)
// ══════════════════════════════════════════════════════════

String standardFormFromSlopeIntercept(YIFraction m, YIFraction b) {
  if (m.isZero) return 'y = ${fracLatex(b)}';
  final scale = lcm(m.denominator, b.denominator);
  final A = -(m.numerator * (scale ~/ m.denominator));
  final B = scale;
  final C = b.numerator * (scale ~/ b.denominator);
  final g = gcd3(A.abs(), B.abs(), C.abs());
  return sfString(A ~/ g, B ~/ g, C ~/ g);
}

String generalFormFromSlopeIntercept(YIFraction m, YIFraction b) {
  if (m.isZero) {
    final neg = -b.numerator;
    final denom = b.denominator;
    if (denom == 1) {
      return neg >= 0 ? 'y + $neg = 0' : 'y - ${neg.abs()} = 0';
    }
    return 'y + ${YIFraction(numerator: neg, denominator: denom).simplified()} = 0';
  }
  final scale = lcm(m.denominator, b.denominator);
  final A = -(m.numerator * (scale ~/ m.denominator));
  final B = scale;
  final C = -(b.numerator * (scale ~/ b.denominator));
  final g = gcd3(A.abs(), B.abs(), C.abs());
  return gfString(A ~/ g, B ~/ g, C ~/ g);
}

String sfTexFromSlopeIntercept(YIFraction m, YIFraction b) {
  if (m.isZero) return 'y = ${fracLatex(b)}';
  final scale = lcm(m.denominator, b.denominator);
  final A = -(m.numerator * (scale ~/ m.denominator));
  final B = scale;
  final C = b.numerator * (scale ~/ b.denominator);
  final g = gcd3(A.abs(), B.abs(), C.abs());
  return sfLatex(A ~/ g, B ~/ g, C ~/ g);
}

String gfTexFromSlopeIntercept(YIFraction m, YIFraction b) {
  if (m.isZero) {
    final neg = -(b.numerator);
    return 'y ${neg >= 0 ? '+' : '-'} ${neg.abs()} = 0';
  }
  final scale = lcm(m.denominator, b.denominator);
  final A = -(m.numerator * (scale ~/ m.denominator));
  final B = scale;
  final C = -(b.numerator * (scale ~/ b.denominator));
  final g = gcd3(A.abs(), B.abs(), C.abs());
  return gfLatex(A ~/ g, B ~/ g, C ~/ g);
}

String generalFormFromABC(int A, int B, int C) => gfString(A, B, -C);

String sfString(int A, int B, int C) {
  final x = termStr(A, 'x', isFirst: true);
  final y = termStr(B, 'y', isFirst: false);
  return '$x $y = $C'.replaceAll('  ', ' ').trim();
}

String gfString(int A, int B, int C) {
  final xPart = termStr(A, 'x', isFirst: true);
  final yPart = termStr(B, 'y', isFirst: false);
  String cPart = '';
  if (C != 0) cPart = C > 0 ? '+ $C' : '- ${C.abs()}';
  final parts = [xPart, yPart, cPart]
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .join(' ');
  return '$parts = 0';
}

// ══════════════════════════════════════════════════════════
// FRACTION ARITHMETIC
// ══════════════════════════════════════════════════════════

YIFraction fracAdd(YIFraction a, YIFraction b) => YIFraction(
      numerator: a.numerator * b.denominator + b.numerator * a.denominator,
      denominator: a.denominator * b.denominator,
    ).simplified();

YIFraction fracSub(YIFraction a, YIFraction b) => YIFraction(
      numerator: a.numerator * b.denominator - b.numerator * a.denominator,
      denominator: a.denominator * b.denominator,
    ).simplified();

int lcm(int a, int b) {
  if (a == 0 || b == 0) return 1;
  return (a * b).abs() ~/ gcd2(a.abs(), b.abs());
}

int gcd2(int a, int b) {
  while (b != 0) {
    final t = b;
    b = a % b;
    a = t;
  }
  return a;
}

int gcd3(int a, int b, int c) => gcd2(gcd2(a, b), c);

YIFraction? parseFractionString(String text) {
  text = text.trim().replaceAll('\u2212', '-');
  if (text.contains(' ') && text.contains('/')) {
    final parts = text.split(' ');
    if (parts.length == 2) {
      final whole = int.tryParse(parts[0]);
      final fracParts = parts[1].split('/');
      if (whole != null && fracParts.length == 2) {
        final n = int.tryParse(fracParts[0]);
        final d = int.tryParse(fracParts[1]);
        if (n != null && d != null && d != 0) {
          final sign = whole < 0 ? -1 : 1;
          final totalNum = (whole.abs() * d + n) * sign;
          return YIFraction(numerator: totalNum, denominator: d).simplified();
        }
      }
    }
  }
  if (text.contains('/')) {
    final parts = text.split('/');
    if (parts.length == 2) {
      final n = int.tryParse(parts[0]);
      final d = int.tryParse(parts[1]);
      if (n != null && d != null && d != 0) {
        return YIFraction(numerator: n, denominator: d).simplified();
      }
    }
  }
  final intVal = int.tryParse(text);
  if (intVal != null) return YIFraction(numerator: intVal, denominator: 1);
  final dblVal = double.tryParse(text);
  if (dblVal != null) return YIFraction.fromDouble(dblVal);
  return null;
}
