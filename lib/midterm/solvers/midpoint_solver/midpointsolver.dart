// ═════════════════════════════════════════════════════════════
// MIDPOINT SOLVER  (generated via SymPy)
// ─────────────────────────────────────────────────────────────
// Calculates midpoint between two points and finds missing
// endpoint when given a midpoint. Uses exact fraction arithmetic.
//
// INPUT: Coordinates can be whole numbers, decimals, or
//        fractions using slash notation (3/5, -1/4, 2/3).
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

  double toDouble() => numerator / denominator;

  @override
  String toString() {
    if (isWhole || denominator == 1) return numerator.toString();
    return '$numerator/$denominator';
  }
}

class MidpointResult {
  final Fraction? x;
  final Fraction? y;
  final String? formulaX;
  final String? formulaY;
  final bool hasError;
  final String? errorMessage;

  const MidpointResult({
    this.x, this.y, this.formulaX, this.formulaY,
    this.hasError = false, this.errorMessage,
  });

  factory MidpointResult.error(String message) =>
      const MidpointResult()._copyWith(hasError: true, errorMessage: message);

  factory MidpointResult.success({
    required Fraction x, required Fraction y,
    required String formulaX, required String formulaY,
  }) => MidpointResult(x: x, y: y, formulaX: formulaX, formulaY: formulaY);

  MidpointResult _copyWith({
    Fraction? x, Fraction? y,
    String? formulaX, String? formulaY,
    bool hasError = false, String? errorMessage,
  }) => MidpointResult(
    x: x ?? this.x, y: y ?? this.y,
    formulaX: formulaX ?? this.formulaX,
    formulaY: formulaY ?? this.formulaY,
    hasError: hasError, errorMessage: errorMessage ?? this.errorMessage,
  );
}

class MidpointSolver {
  MidpointSolver._();

  // ── Main API ──────────────────────────────────────────────

  static MidpointResult solve({
    required String x1, required String y1,
    required String x2, required String y2,
  }) {
    final p = _parseAll(x1, y1, x2, y2);
    if (p.hasError) return MidpointResult.error(p.error!);
    final (a, b, c, d) = (p.f1!, p.f2!, p.f3!, p.f4!);
    final midX = midOfFractions(a, c);
    final midY = midOfFractions(b, d);
    return MidpointResult.success(
      x: midX, y: midY,
      formulaX: '($a + $c) / 2 = $midX',
      formulaY: '($b + $d) / 2 = $midY',
    );
  }

  static MidpointResult findEndpointFromMidpoint({
    required String midpointX, required String midpointY,
    required String knownX, required String knownY,
  }) {
    final p = _parseAll(midpointX, midpointY, knownX, knownY);
    if (p.hasError) return MidpointResult.error(p.error!);
    final (xm, ym, x1, y1) = (p.f1!, p.f2!, p.f3!, p.f4!);
    final fx = subtractFractions(multiplyFractionByInt(xm, 2), x1);
    final fy = subtractFractions(multiplyFractionByInt(ym, 2), y1);
    return MidpointResult.success(
      x: fx, y: fy,
      formulaX: 'x2 = 2($xm) - $x1 = $fx',
      formulaY: 'y2 = 2($ym) - $y1 = $fy',
    );
  }

  // ── Fraction Arithmetic (public for step builders) ──────────

  static Fraction midOfFractions(Fraction a, Fraction b) {
    final n = a.numerator * b.denominator + b.numerator * a.denominator;
    return simplify(n, a.denominator * b.denominator * 2);
  }

  static Fraction multiplyFractionByInt(Fraction f, int n) =>
      simplify(f.numerator * n, f.denominator);

  static Fraction subtractFractions(Fraction a, Fraction b) {
    final n = a.numerator * b.denominator - b.numerator * a.denominator;
    return simplify(n, a.denominator * b.denominator);
  }

  static Fraction simplify(int n, int d) {
    if (d == 0) return const Fraction(numerator: 0, denominator: 1);
    if (d < 0) { n = -n; d = -d; }
    final g = _gcd(n.abs(), d.abs());
    n ~/= g; d ~/= g;
    if (d == 1) return Fraction(numerator: n, denominator: 1, isWhole: true);
    return Fraction(numerator: n, denominator: d);
  }

  static int _gcd(int a, int b) {
    while (b != 0) { final t = b; b = a % b; a = t; }
    return a;
  }

  // ── Parsing ───────────────────────────────────────────────

  static _ParseResult _parseAll(String a, String b, String c, String d) {
    final f1 = parseFraction(a, 'x1'); if (f1.hasError) return _ParseResult(error: f1.error);
    final f2 = parseFraction(b, 'y1'); if (f2.hasError) return _ParseResult(error: f2.error);
    final f3 = parseFraction(c, 'x2'); if (f3.hasError) return _ParseResult(error: f3.error);
    final f4 = parseFraction(d, 'y2'); if (f4.hasError) return _ParseResult(error: f4.error);
    return _ParseResult(f1: f1.fraction, f2: f2.fraction, f3: f3.fraction, f4: f4.fraction);
  }

  static FractionParse parseFraction(String raw, String label) {
    final t = raw.trim();
    if (t.isEmpty) return FractionParse.error('$label is required');

    final slash = RegExp(r'^(-?\d+)\s*/\s*(-?\d+)$').firstMatch(t);
    if (slash != null) {
      final n = int.parse(slash.group(1)!);
      final d = int.parse(slash.group(2)!);
      if (d == 0) return FractionParse.error('$label: denominator cannot be 0');
      return FractionParse.success(simplify(n, d));
    }

    final dv = double.tryParse(t);
    if (dv == null || dv.isNaN || dv.isInfinite) {
      return FractionParse.error('$label must be a number or fraction (e.g. 3/4)');
    }
    return FractionParse.success(_fromDouble(dv));
  }

  static Fraction _fromDouble(double v) {
    if (v == v.toInt()) {
      return Fraction(numerator: v.toInt(), denominator: 1, isWhole: true);
    }
    final s = v.toStringAsFixed(6);
    final parts = s.split('.');
    final whole = int.parse(parts[0]);
    var dec = parts[1].replaceAll(RegExp(r'0+$'), '');
    if (dec.isEmpty) {
      return Fraction(numerator: whole, denominator: 1, isWhole: true);
    }
    final d = _pow10(dec.length);
    final n = whole * d + (v < 0 ? -int.parse(dec) : int.parse(dec));
    return simplify(n, d);
  }

  static int _pow10(int e) {
    int r = 1;
    for (int i = 0; i < e; i++) { r *= 10; }
    return r;
  }
}

class _ParseResult {
  final Fraction? f1, f2, f3, f4;
  final String? error;
  const _ParseResult({this.f1, this.f2, this.f3, this.f4, this.error});
  bool get hasError => error != null;
}

class FractionParse {
  final Fraction? fraction;
  final String? error;
  const FractionParse({this.fraction, this.error});
  bool get hasError => error != null;
  FractionParse._({this.fraction, this.error});
  factory FractionParse.success(Fraction f) => FractionParse._(fraction: f);
  factory FractionParse.error(String e) => FractionParse._(error: e);
}
