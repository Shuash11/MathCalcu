import 'dart:math';

/// Represents a number as either whole or fraction
class Fraction {
  final int numerator;
  final int denominator;
  final bool isWhole;

  const Fraction({
    required this.numerator,
    required this.denominator,
    this.isWhole = false,
  });

  @override
  String toString() {
    if (isWhole || denominator == 1) return numerator.toString();
    return '$numerator/$denominator';
  }

  double toDouble() => numerator / denominator;
}

/// Result container
class MidpointResult {
  final Fraction? x;
  final Fraction? y;
  final String? formulaX;
  final String? formulaY;
  final bool hasError;
  final String? errorMessage;

  const MidpointResult({
    this.x,
    this.y,
    this.formulaX,
    this.formulaY,
    this.hasError = false,
    this.errorMessage,
  });

  factory MidpointResult.error(String message) => MidpointResult(
        hasError: true,
        errorMessage: message,
      );

  factory MidpointResult.success({
    required Fraction x,
    required Fraction y,
    required String formulaX,
    required String formulaY,
  }) {
    return MidpointResult(
      x: x,
      y: y,
      formulaX: formulaX,
      formulaY: formulaY,
      hasError: false,
    );
  }
}

/// Solver
class MidpointSolver {
  /// MIDPOINT
  /// M = ((x1+x2)/2 , (y1+y2)/2)
  static MidpointResult solve({
    required String x1,
    required String y1,
    required String x2,
    required String y2,
  }) {
    final pX1 = parseFraction(x1, 'x₁');
    final pY1 = parseFraction(y1, 'y₁');
    final pX2 = parseFraction(x2, 'x₂');
    final pY2 = parseFraction(y2, 'y₂');

    if (pX1.hasError) return pX1.errorResult!;
    if (pY1.hasError) return pY1.errorResult!;
    if (pX2.hasError) return pX2.errorResult!;
    if (pY2.hasError) return pY2.errorResult!;

    final a = pX1.fraction!;
    final b = pY1.fraction!;
    final c = pX2.fraction!;
    final d = pY2.fraction!;

    final midX = midOfFractions(a, c);
    final midY = midOfFractions(b, d);

    return MidpointResult.success(
      x: midX,
      y: midY,
      formulaX: '($a + $c) / 2 = $midX',
      formulaY: '($b + $d) / 2 = $midY',
    );
  }

  /// ENDPOINT
  /// x2 = 2xm - x1
  /// y2 = 2ym - y1
  static MidpointResult findEndpointFromMidpoint({
    required String midpointX,
    required String midpointY,
    required String knownX,
    required String knownY,
  }) {
    final mX = parseFraction(midpointX, 'Midpoint x');
    final mY = parseFraction(midpointY, 'Midpoint y');
    final kX = parseFraction(knownX, 'Known x');
    final kY = parseFraction(knownY, 'Known y');

    if (mX.hasError) return mX.errorResult!;
    if (mY.hasError) return mY.errorResult!;
    if (kX.hasError) return kX.errorResult!;
    if (kY.hasError) return kY.errorResult!;

    final xm = mX.fraction!;
    final ym = mY.fraction!;
    final x1 = kX.fraction!;
    final y1 = kY.fraction!;

    // x2 = 2*xm - x1  =>  (2*xm.num*x1.den - x1.num*xm.den) / (xm.den*x1.den)
    final fx = subtractFractions(multiplyFractionByInt(xm, 2), x1);
    final fy = subtractFractions(multiplyFractionByInt(ym, 2), y1);

    return MidpointResult.success(
      x: fx,
      y: fy,
      formulaX: 'x₂ = 2($xm) - $x1 = $fx',
      formulaY: 'y₂ = 2($ym) - $y1 = $fy',
    );
  }

  // ── Fraction arithmetic ────────────────────────────────────

  /// Midpoint of two fractions: (a + b) / 2
  static Fraction midOfFractions(Fraction a, Fraction b) {
    // sum = (a.num * b.den + b.num * a.den) / (a.den * b.den)
    final sumNum = a.numerator * b.denominator + b.numerator * a.denominator;
    final sumDen = a.denominator * b.denominator;
    // divide by 2
    return simplify(sumNum, sumDen * 2);
  }

  static Fraction multiplyFractionByInt(Fraction f, int n) {
    return simplify(f.numerator * n, f.denominator);
  }

  static Fraction subtractFractions(Fraction a, Fraction b) {
    final num = a.numerator * b.denominator - b.numerator * a.denominator;
    final den = a.denominator * b.denominator;
    return simplify(num, den);
  }

  // ── Simplify ───────────────────────────────────────────────

  static Fraction simplify(int n, int d) {
    if (d == 0) return const Fraction(numerator: 0, denominator: 1);

    if (d < 0) {
      n = -n;
      d = -d;
    }

    final g = _gcd(n.abs(), d.abs());
    n ~/= g;
    d ~/= g;

    if (d == 1) {
      return Fraction(numerator: n, denominator: 1, isWhole: true);
    }

    return Fraction(numerator: n, denominator: d);
  }

  static int _gcd(int a, int b) {
    while (b != 0) {
      final t = b;
      b = a % b;
      a = t;
    }
    return a;
  }

  // ── Parsing ────────────────────────────────────────────────

  static Fraction doubleToFraction(double v) {
    if (v == v.toInt()) {
      return Fraction(numerator: v.toInt(), denominator: 1, isWhole: true);
    }

    final s = v.toStringAsFixed(6);
    final parts = s.split('.');
    final whole = int.parse(parts[0]);
    final dec = parts[1].replaceAll(RegExp(r'0+$'), '');

    if (dec.isEmpty) {
      return Fraction(numerator: whole, denominator: 1, isWhole: true);
    }

    final d = pow(10, dec.length).toInt();
    final n = whole * d + (v < 0 ? -int.parse(dec) : int.parse(dec));

    return simplify(n, d);
  }

  static FractionParse parseFraction(String input, String label) {
    final t = input.trim();

    if (t.isEmpty) {
      return FractionParse.error('$label is required');
    }

    // ── Slash fraction: optional sign, digits, slash, digits ──
    final slashRegex = RegExp(r'^(-?\d+)\s*/\s*(-?\d+)$');
    final slashMatch = slashRegex.firstMatch(t);

    if (slashMatch != null) {
      final n = int.parse(slashMatch.group(1)!);
      final d = int.parse(slashMatch.group(2)!);
      if (d == 0) return FractionParse.error('$label: denominator cannot be 0');
      return FractionParse.success(simplify(n, d));
    }

    // ── Decimal or integer ─────────────────────────────────────
    final dVal = double.tryParse(t);
    if (dVal == null || dVal.isNaN || dVal.isInfinite) {
      return FractionParse.error('$label must be a number or fraction (e.g. 3/4)');
    }

    return FractionParse.success(doubleToFraction(dVal));
  }
}

// ── Internal helpers ───────────────────────────────────────────

class FractionParse {
  final Fraction? fraction;
  final String? error;

  const FractionParse({this.fraction, this.error});

  bool get hasError => error != null;

  MidpointResult? get errorResult =>
      hasError ? MidpointResult.error(error!) : null;

  factory FractionParse.success(Fraction f) => FractionParse(fraction: f);
  factory FractionParse.error(String e) => FractionParse(error: e);
}