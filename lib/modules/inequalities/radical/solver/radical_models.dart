// radical_models.dart

enum RhsType {
  constant,
  radical,
  linear,
  quadratic,
}

enum IvKind {
  allReals,
  point,
  bounded,
  unbounded,
  halfLeft,
  halfRight,
}

class Iv {
  final IvKind kind;
  final double? lo;
  final double? hi;
  final bool clo;
  final bool chi;
  final String? symbolicLo;
  final String? symbolicHi;

  const Iv({
    required this.kind,
    this.lo,
    this.hi,
    this.clo = false,
    this.chi = false,
    this.symbolicLo,
    this.symbolicHi,
  });

  factory Iv.allReals() => const Iv(kind: IvKind.allReals);

  factory Iv.point(double x, {String? symbolic}) => Iv(
        kind: IvKind.point,
        lo: x,
        hi: x,
        clo: true,
        chi: true,
        symbolicLo: symbolic,
        symbolicHi: symbolic,
      );

  factory Iv.bounded(double lo, double hi, bool closed,
          {String? symbolicLo, String? symbolicHi}) =>
      Iv(
        kind: IvKind.bounded,
        lo: lo,
        hi: hi,
        clo: closed,
        chi: closed,
        symbolicLo: symbolicLo,
        symbolicHi: symbolicHi,
      );

  factory Iv.unbounded(double lo, double hi, bool closed,
          {String? symbolicLo, String? symbolicHi}) =>
      Iv(
        kind: IvKind.unbounded,
        lo: lo,
        hi: hi,
        clo: closed,
        chi: closed,
        symbolicLo: symbolicLo,
        symbolicHi: symbolicHi,
      );

  // ADD THIS FACTORY CONSTRUCTOR:
  factory Iv.halfLine(double x, String op) {
    if (op == '>' || op == '≥') {
      return Iv(
        kind: IvKind.halfRight,
        lo: x,
        clo: op == '≥',
      );
    } else {
      return Iv(
        kind: IvKind.halfLeft,
        hi: x,
        chi: op == '≤',
      );
    }
  }

  factory Iv.halfLeft(double hi, String op, {String? symbolicHi}) => Iv(
        kind: IvKind.halfLeft,
        hi: hi,
        chi: op == '≤' || op == '≥',
        symbolicHi: symbolicHi,
      );

  factory Iv.halfRight(double lo, String op, {String? symbolicLo}) => Iv(
        kind: IvKind.halfRight,
        lo: lo,
        clo: op == '≤' || op == '≥',
        symbolicLo: symbolicLo,
      );

  String toNotation(String Function(double) fmt) {
    switch (kind) {
      case IvKind.allReals:
        return '(-∞, ∞)';
      case IvKind.point:
        final s = symbolicLo ?? fmt(lo!);
        return '{$s}';
      case IvKind.bounded:
        final ls = symbolicLo ?? fmt(lo!);
        final hs = symbolicHi ?? fmt(hi!);
        return '${clo ? '[' : '('}$ls, $hs${chi ? ']' : ')'}';
      case IvKind.unbounded:
        final ls = symbolicLo ?? fmt(lo!);
        final hs = symbolicHi ?? fmt(hi!);
        return '(-∞, $ls${clo ? ']' : ')'} ∪ ${chi ? '[' : '('}$hs, ∞)';
      case IvKind.halfLeft:
        final hs = symbolicHi ?? fmt(hi!);
        return '(-∞, $hs${chi ? ']' : ')'}';
      case IvKind.halfRight:
        final ls = symbolicLo ?? fmt(lo!);
        return '${clo ? '[' : '('}$ls, ∞)';
    }
  }

  String toAnswer(String Function(double) fmt) {
    switch (kind) {
      case IvKind.allReals:
        return 'All real numbers';
      case IvKind.point:
        return 'x = ${symbolicLo ?? fmt(lo!)}';
      case IvKind.bounded:
        final ls = symbolicLo ?? fmt(lo!);
        final hs = symbolicHi ?? fmt(hi!);
        return '$ls ≤ x ≤ $hs';
      case IvKind.unbounded:
        final ls = symbolicLo ?? fmt(lo!);
        final hs = symbolicHi ?? fmt(hi!);
        return 'x ≤ $ls or x ≥ $hs';
      case IvKind.halfLeft:
        final hs = symbolicHi ?? fmt(hi!);
        return 'x ≤ $hs';
      case IvKind.halfRight:
        final ls = symbolicLo ?? fmt(lo!);
        return 'x ≥ $ls';
    }
  }

  RadicalSpan toSpan() {
    return RadicalSpan(
      lo ?? double.negativeInfinity,
      hi ?? double.infinity,
      clo,
      chi,
      symbolicLo: symbolicLo,
      symbolicHi: symbolicHi,
    );
  }
}

class RadicalSpan {
  final double lo;
  final double hi;
  final bool clo;
  final bool chi;
  final String? symbolicLo;
  final String? symbolicHi;

  RadicalSpan(this.lo, this.hi, this.clo, this.chi,
      {this.symbolicLo, this.symbolicHi});

  RadicalSpan merge(RadicalSpan other) {
    // If they touch at a point b, and b is included in at least one,
    // then the union is continuous.
    return RadicalSpan(
      lo,
      other.hi,
      clo,
      other.chi,
      symbolicLo: symbolicLo,
      symbolicHi: other.symbolicHi,
    );
  }

  RadicalSpan withChi(bool newChi) => RadicalSpan(lo, hi, clo, newChi,
      symbolicLo: symbolicLo, symbolicHi: symbolicHi);

  RadicalSpan extendTo(double newHi, bool newChi) =>
      RadicalSpan(lo, newHi, clo, newChi,
          symbolicLo: symbolicLo, symbolicHi: symbolicHi);

  String toNotation(String Function(double) fmt) {
    final ls = symbolicLo ?? fmt(lo);
    final hs = symbolicHi ?? fmt(hi);
    return '${clo ? '[' : '('}$ls, $hs${chi ? ']' : ')'}';
  }

  String toAnswer(String Function(double) fmt) {
    if (lo == hi && clo && chi) {
      return 'x = ${symbolicLo ?? fmt(lo)}';
    }
    final ls = symbolicLo ?? fmt(lo);
    final hs = symbolicHi ?? fmt(hi);
    if (lo.isInfinite) return 'x ≤ $hs';
    if (hi.isInfinite) return 'x ≥ $ls';
    return '$ls ≤ x ≤ $hs';
  }
}

class RadicalPrep {
  final String original;
  final String inner;
  final double ia;
  final double ib;
  final String op;
  final RhsType rhsType;
  final bool wasFlipped;
  final double? k;
  final String? rhsExpr;
  final double? rc;
  final double? rd;
  final double? qe;

  RadicalPrep({
    required this.original,
    required this.inner,
    required this.ia,
    required this.ib,
    required this.op,
    required this.rhsType,
    required this.wasFlipped,
    this.k,
    this.rhsExpr,
    this.rc,
    this.rd,
    this.qe,
  });
}
