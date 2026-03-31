// lib/modules/yintercept/solver/yi_fraction.dart


// ─────────────────────────────────────────────────────────────
// YIFraction — immutable exact rational number
// All operations return a fully reduced result with a
// non-negative denominator. The numerator carries the sign.
// ─────────────────────────────────────────────────────────────

class YIFraction {
  final int numerator;
  final int denominator;

  /// True when this fraction is a whole number (denominator == 1).
  final bool isWhole;

  const YIFraction({
    required this.numerator,
    required this.denominator,
    this.isWhole = false,
  });

  // ── Equality ─────────────────────────────────────────────

  /// Two fractions are equal when they reduce to the same value.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! YIFraction) return false;
    // Cross-multiply to avoid floating-point: a/b == c/d ↔ a*d == c*b
    return numerator * other.denominator == other.numerator * denominator;
  }

  @override
  int get hashCode {
    // Normalise before hashing so equal fractions hash identically.
    final s = simplified();
    return Object.hash(s.numerator, s.denominator);
  }

  // ── Convenience getters ───────────────────────────────────

  bool get isZero => numerator == 0;

  bool get isPositive => numerator > 0 && denominator > 0 ||
      numerator < 0 && denominator < 0;

  bool get isNegative => !isZero && !isPositive;

  // ── Display ───────────────────────────────────────────────

  @override
  String toString() {
    if (isWhole || denominator == 1) return numerator.toString();
    return '$numerator/$denominator';
  }

  double toDouble() => numerator / denominator;

  // ── Construction ─────────────────────────────────────────

  /// Converts a double to the closest exact fraction.
  ///
  /// Uses a scale-by-1000 approach which correctly handles common
  /// decimals like 0.75 → 3/4, 1.5 → 3/2, -0.333 → -333/1000.
  factory YIFraction.fromDouble(double value) {
    // Whole number fast path
    if (value == value.truncateToDouble()) {
      return YIFraction(
        numerator: value.toInt(),
        denominator: 1,
        isWhole: true,
      );
    }

    // Scale to integer by multiplying by 1000, then reduce.
    // This captures up to 3 decimal places exactly.
    final scaled = (value * 1000).round();
    return YIFraction(numerator: scaled, denominator: 1000).simplified();
  }

  // ── Arithmetic ────────────────────────────────────────────

  YIFraction operator +(YIFraction other) {
    if (denominator == other.denominator) {
      return YIFraction(
        numerator: numerator + other.numerator,
        denominator: denominator,
      ).simplified();
    }
    return YIFraction(
      numerator: numerator * other.denominator + other.numerator * denominator,
      denominator: denominator * other.denominator,
    ).simplified();
  }

  YIFraction operator -(YIFraction other) {
    if (denominator == other.denominator) {
      return YIFraction(
        numerator: numerator - other.numerator,
        denominator: denominator,
      ).simplified();
    }
    return YIFraction(
      numerator: numerator * other.denominator - other.numerator * denominator,
      denominator: denominator * other.denominator,
    ).simplified();
  }

  /// Multiplies with cross-simplification to keep numbers small.
  YIFraction operator *(YIFraction other) {
    // Cross-simplify before multiplying to prevent integer overflow.
    final gcd1 = _gcd(numerator.abs(), other.denominator.abs());
    final gcd2 = _gcd(other.numerator.abs(), denominator.abs());
    return YIFraction(
      numerator: (numerator ~/ gcd1) * (other.numerator ~/ gcd2),
      denominator: (denominator ~/ gcd2) * (other.denominator ~/ gcd1),
    ).simplified();
  }

  YIFraction operator /(YIFraction other) => this * other.reciprocal();

  /// Alias for `/` — used by the solver for readability.
  YIFraction divided(YIFraction other) => this / other;

  YIFraction operator -() =>
      YIFraction(numerator: -numerator, denominator: denominator);

  // ── Other operations ──────────────────────────────────────

  YIFraction abs() => YIFraction(
        numerator: numerator.abs(),
        denominator: denominator,
        isWhole: denominator == 1,
      );

  YIFraction reciprocal() {
    if (numerator == 0) throw StateError('Reciprocal of zero is undefined');
    return YIFraction(
      numerator: denominator,
      denominator: numerator,
    ).simplified();
  }

  // ── Comparison ────────────────────────────────────────────

  int compareTo(YIFraction other) {
    // a/b compared to c/d: compare a*d vs c*b
    final lhs = numerator * other.denominator;
    final rhs = other.numerator * denominator;
    return lhs.compareTo(rhs);
  }

  bool operator <(YIFraction other) => compareTo(other) < 0;
  bool operator >(YIFraction other) => compareTo(other) > 0;
  bool operator <=(YIFraction other) => compareTo(other) <= 0;
  bool operator >=(YIFraction other) => compareTo(other) >= 0;

  // ── Reduction ─────────────────────────────────────────────

  /// Returns this fraction in lowest terms with a positive denominator.
  ///
  /// Invariants guaranteed on return:
  ///   - denominator > 0
  ///   - gcd(|numerator|, denominator) == 1
  ///   - isWhole == (denominator == 1)
  YIFraction simplified() {
    // Guard: zero denominator returns 0
    if (denominator == 0) {
      return const YIFraction(numerator: 0, denominator: 1, isWhole: true);
    }

    int n = numerator;
    int d = denominator;

    // Move sign to numerator
    if (d < 0) {
      n = -n;
      d = -d;
    }

    // Zero numerator
    if (n == 0) {
      return const YIFraction(numerator: 0, denominator: 1, isWhole: true);
    }

    // Already whole
    if (d == 1) {
      return YIFraction(numerator: n, denominator: 1, isWhole: true);
    }

    // Reduce by GCD
    final g = _gcd(n.abs(), d);
    if (g == 1) {
      return YIFraction(numerator: n, denominator: d);
    }

    final rn = n ~/ g;
    final rd = d ~/ g;

    return YIFraction(
      numerator: rn,
      denominator: rd,
      isWhole: rd == 1,
    );
  }

  // ── GCD (Binary / Stein's algorithm) ─────────────────────
  //
  // Handles all sizes efficiently.
  // Precondition: a >= 0, b >= 0.

  static int _gcd(int a, int b) {
    if (a == 0) return b == 0 ? 1 : b;
    if (b == 0) return a;
    if (a == b) return a;
    if (a == 1 || b == 1) return 1;

    // Binary GCD (Stein's algorithm) — avoids modulo for large numbers
    int shift = 0;
    while (((a | b) & 1) == 0) {
      a >>= 1;
      b >>= 1;
      shift++;
    }
    while ((a & 1) == 0) {
      a >>= 1;
    }
    do {
      while ((b & 1) == 0) {
        b >>= 1;
      }
      if (a > b) {
        final t = b;
        b = a;
        a = t;
      }
      b -= a;
    } while (b != 0);

    return a << shift;
  }
}