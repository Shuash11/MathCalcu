import 'dart:math';

// ═════════════════════════════════════════════════════════════
// POINT-SLOPE SOLVER  (generated via SymPy)
// ─────────────────────────────────────────────────────────────
// Converts point-slope form to slope-intercept, general,
// and standard forms. Shows direction, angle, rise/run.
//
// INPUT: Slope and point coordinates as fractions or numbers.
// ═════════════════════════════════════════════════════════════

class Fraction {
  final int numerator;
  final int denominator;
  final bool isWhole;

  const Fraction({
    required this.numerator,
    required this.denominator,
    this.isWhole = false,
  });

  factory Fraction.fromDouble(double v) {
    if (v.isNaN || v.isInfinite) return const Fraction(numerator: 0, denominator: 1);
    final r = v.round();
    if ((v - r).abs() < 1e-6) return Fraction(numerator: r, denominator: 1, isWhole: true);
    final s = (v * 1000).round();
    if ((s / 1000 - v).abs() < 0.0001) return _simplify(s, 1000);
    final str = v.toStringAsFixed(4);
    final dot = str.indexOf('.');
    if (dot == -1) return Fraction(numerator: v.toInt(), denominator: 1, isWhole: true);
    final whole = int.parse(str.substring(0, dot));
    var dec = str.substring(dot + 1).replaceAll(RegExp(r'0+$'), '');
    if (dec.isEmpty) return Fraction(numerator: whole, denominator: 1, isWhole: true);
    if (dec.length > 4) dec = dec.substring(0, 4);
    final den = _pow10(dec.length);
    final num = whole * den + (v < 0 ? -int.parse(dec) : int.parse(dec));
    return _simplify(num, den);
  }

  @override
  String toString() {
    if (isWhole || denominator == 1) return numerator.toString();
    return '$numerator/$denominator';
  }

  double toDouble() => numerator / denominator;

  Fraction operator +(Fraction o) => _simplify(
    numerator * o.denominator + o.numerator * denominator,
    denominator * o.denominator,
  );

  Fraction operator -(Fraction o) => _simplify(
    numerator * o.denominator - o.numerator * denominator,
    denominator * o.denominator,
  );

  Fraction operator *(Fraction o) {
    final g1 = _gcd(numerator.abs(), o.denominator);
    final g2 = _gcd(o.numerator.abs(), denominator);
    return Fraction(
      numerator: (numerator ~/ g1) * (o.numerator ~/ g2),
      denominator: (denominator ~/ g2) * (o.denominator ~/ g1),
    );
  }

  Fraction operator /(Fraction o) => this * o.reciprocal();
  Fraction operator -() => Fraction(numerator: -numerator, denominator: denominator);

  Fraction abs() => Fraction(numerator: numerator.abs(), denominator: denominator, isWhole: isWhole);
  Fraction reciprocal() => _simplify(denominator, numerator);

  Fraction simplified() {
    if (denominator == 0) return const Fraction(numerator: 0, denominator: 1);
    if (denominator == 1 || numerator == 0) return Fraction(numerator: numerator, denominator: 1, isWhole: true);
    int n = numerator;
    int d = denominator;
    if (d < 0) { n = -n; d = -d; }
    final g = _gcd(n.abs(), d);
    if (g == 1) return Fraction(numerator: n, denominator: d);
    n ~/= g; d ~/= g;
    if (d == 1) return Fraction(numerator: n, denominator: 1, isWhole: true);
    return Fraction(numerator: n, denominator: d);
  }
}

// ── Internal helpers ────────────────────────────────────────

Fraction _simplify(int n, int d) {
  if (d == 0) return const Fraction(numerator: 0, denominator: 1);
  if (d < 0) { n = -n; d = -d; }
  final g = _gcd(n.abs(), d);
  if (g == 1) return Fraction(numerator: n, denominator: d);
  n ~/= g; d ~/= g;
  if (d == 1) return Fraction(numerator: n, denominator: 1, isWhole: true);
  return Fraction(numerator: n, denominator: d);
}

int _gcd(int a, int b) {
  while (b != 0) { final t = b; b = a % b; a = t; }
  return a;
}

int _lcm(int a, int b) => (a * b) ~/ _gcd(a, b);

int _pow10(int e) {
  int r = 1;
  for (int i = 0; i < e; i++) { r *= 10; }
  return r;
}

// ── Models ──────────────────────────────────────────────────

class SolveStep {
  final String title;
  final String explanation;
  final String result;
  const SolveStep({required this.title, required this.explanation, required this.result});
}

class PointSlopeSolver {
  final Fraction m;
  final Fraction x1;
  final Fraction y1;

  const PointSlopeSolver({required this.m, required this.x1, required this.y1});

  factory PointSlopeSolver.fromDoubles({
    required double m, required double x1, required double y1,
  }) => PointSlopeSolver(
    m: Fraction.fromDouble(m), x1: Fraction.fromDouble(x1), y1: Fraction.fromDouble(y1),
  );

  factory PointSlopeSolver.fromStrings({
    required String mText, required String x1Text, required String y1Text,
  }) {
    final mF = _parseFrac(mText);
    final xF = _parseFrac(x1Text);
    final yF = _parseFrac(y1Text);
    if (mF == null || xF == null || yF == null) {
      throw const FormatException('Invalid fraction format');
    }
    return PointSlopeSolver(m: mF, x1: xF, y1: yF);
  }

  Fraction get b => y1 - (m * x1);

  String get pointSlopeForm {
    final ySign = y1.numerator >= 0 ? '-' : '+';
    final xSign = x1.numerator >= 0 ? '-' : '+';
    return 'y $ySign ${y1.abs()} = ${m.simplified()}(x $xSign ${x1.abs()})';
  }

  String get generalForm => _buildGeneral(m.simplified(), b.simplified());

  String get standardForm {
    final ms = m.simplified();
    final bs = b.simplified();
    final l = _lcm(ms.denominator, bs.denominator);
    int a = ms.numerator * (l ~/ ms.denominator);
    int bc = -l;
    int c = -(bs.numerator * (l ~/ bs.denominator));
    final g = _gcd(_gcd(a.abs(), bc.abs()), c.abs());
    if (g > 1) { a ~/= g; bc ~/= g; c ~/= g; }
    if (a < 0) { a = -a; bc = -bc; c = -c; }
    return '${_fmtCoeff(a, 'x', true)}${_fmtCoeff(bc, 'y', false)}= $c';
  }

  String get direction {
    final v = m.toDouble();
    if (v > 0) return 'Rising ↗';
    if (v < 0) return 'Falling ↘';
    return 'Horizontal →';
  }

  String get angle => '${atan(m.toDouble()) * 180 / pi}°';

  String get riseRun => '${m.simplified()} / 1';
  String get pointSlopeEquation => pointSlopeForm;
  String get simplifiedAnswer => standardForm;

  List<SolveStep> get steps => [
    SolveStep(
      title: 'Point-Slope Form',
      explanation: 'Write the equation using the point and slope: y - y1 = m(x - x1).',
      result: pointSlopeForm,
    ),
    const SolveStep(
      title: 'Expand to Slope-Intercept Form',
      explanation: 'Distribute m: y - y1 = m * (x - x1). Then, solve for y.',
      result: 'y = y1 + m(x - x1)',
    ),
    SolveStep(
      title: 'Simplify Constant Term',
      explanation: 'Combine y1 and -m*x1 into a single constant term.',
      result: 'y = (${y1.toString()}) + ${m.simplified()}(x ${x1.numerator >= 0 ? '-' : '+'} ${x1.abs()})',
    ),
    SolveStep(
      title: 'Convert to General Form',
      explanation: 'Bring all terms to one side: mx - y + (y1 - m*x1) = 0.',
      result: generalForm,
    ),
    SolveStep(
      title: 'Convert to Standard Form',
      explanation: 'Rearrange to get Ax + By = C.',
      result: standardForm,
    ),
  ];

  static PointSlopeSolver? tryParse({
    required String mText, required String x1Text, required String y1Text,
  }) {
    final mF = _parseFrac(mText);
    final xF = _parseFrac(x1Text);
    final yF = _parseFrac(y1Text);
    if (mF != null && xF != null && yF != null) {
      return PointSlopeSolver(m: mF, x1: xF, y1: yF);
    }
    final md = double.tryParse(mText);
    final xd = double.tryParse(x1Text);
    final yd = double.tryParse(y1Text);
    if (md == null || xd == null || yd == null) return null;
    return PointSlopeSolver.fromDoubles(m: md, x1: xd, y1: yd);
  }

  // ── Private ───────────────────────────────────────────────

  static String _buildGeneral(Fraction ms, Fraction bs) {
    final l = _lcm(ms.denominator, bs.denominator);
    int a = ms.numerator * (l ~/ ms.denominator);
    int bc = -l;
    int c = bs.numerator * (l ~/ bs.denominator);
    final g = _gcd(_gcd(a.abs(), bc.abs()), c.abs());
    if (g > 1) { a ~/= g; bc ~/= g; c ~/= g; }
    if (a < 0) { a = -a; bc = -bc; c = -c; }
    return '${_fmtCoeff(a, 'x', true)}${_fmtCoeff(bc, 'y', false)}${_fmtConst(c)} = 0';
  }

  static String _fmtCoeff(int v, String vari, bool first) {
    if (v == 0) return '';
    final av = v.abs();
    final sign = v < 0 ? '-' : (first ? '' : '+');
    final sp = first ? '' : ' ';
    if (av == 1) return '$sp $sign $vari';
    return '$sp $sign $av $vari';
  }

  static String _fmtConst(int v) {
    if (v == 0) return '';
    if (v > 0) return ' + $v';
    return ' - ${v.abs()}';
  }

  static Fraction? _parseFrac(String text) {
    text = text.trim();
    if (text.contains(' ') && text.contains('/')) {
      final p = text.split(' ');
      if (p.length == 2) {
        final w = int.tryParse(p[0].trim());
        final fp = p[1].split('/');
        if (w != null && fp.length == 2) {
          final n = int.tryParse(fp[0].trim());
          final d = int.tryParse(fp[1].trim());
          if (n != null && d != null && d != 0) {
            final s = w < 0 ? -1 : 1;
            return _simplify((w.abs() * d + n) * s, d);
          }
        }
      }
    }
    if (text.contains('/')) {
      final p = text.split('/');
      if (p.length == 2) {
        final n = int.tryParse(p[0].trim());
        final d = int.tryParse(p[1].trim());
        if (n != null && d != null && d != 0) return _simplify(n, d);
      }
    }
    final iv = int.tryParse(text);
    if (iv != null) return Fraction(numerator: iv, denominator: 1, isWhole: true);
    final dv = double.tryParse(text);
    if (dv != null) return Fraction.fromDouble(dv);
    return null;
  }
}
