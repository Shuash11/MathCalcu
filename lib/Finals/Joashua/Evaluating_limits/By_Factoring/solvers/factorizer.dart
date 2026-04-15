import 'polynomial.dart';

/// Represents a linear factor of the form (ax + b)
class LinearFactor {
  final double a; // coefficient of x
  final double b; // constant term

  LinearFactor(this.a, this.b);

  /// Create a factor (x - root)
  LinearFactor.fromRoot(double root)
      : a = 1.0,
        b = -root;

  /// Get the root of this factor (where ax + b = 0)
  double get root => -b / a;

  /// Check if this factor evaluates to zero at the given x value
  bool hasRootAt(double x) => (a * x + b).abs() < 1e-9;

  /// Convert this factor to a Polynomial
  Polynomial toPolynomial() => Polynomial.linear(a, b);

  /// Get a normalized version where a = 1 (if possible)
  LinearFactor get normalized {
    if (a.abs() < 1e-12) return this;
    return LinearFactor(1.0, b / a);
  }

  @override
  String toString() {
    final norm = normalized;
    final bVal = norm.b;

    if (bVal.abs() < 1e-9) return 'x';

    final bStr = _fmt(bVal.abs());
    if (bVal > 0) return '(x + $bStr)';
    return '(x - $bStr)';
  }

  String _fmt(double n) {
    if (n == n.toInt()) return n.toInt().toString();
    return n.toString();
  }

  /// Convert to LaTeX format
  String toTex() {
    final norm = normalized;
    final bVal = norm.b;

    if (bVal.abs() < 1e-9) return 'x';

    final bStr = _fmt(bVal.abs());
    if (bVal > 0) return '(x + $bStr)';
    return '(x - $bStr)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is LinearFactor && _sameRoot(this, other);

  @override
  int get hashCode => root.round().hashCode;

  static bool _sameRoot(LinearFactor a, LinearFactor b) {
    if (a.a.abs() < 1e-12 || b.a.abs() < 1e-12) {
      return false;
    }
    return (a.root - b.root).abs() < 1e-9;
  }
}

/// Result of factoring a polynomial
class FactoredForm {
  final double leadingCoeff;
  final List<LinearFactor> linearFactors;
  final Polynomial? remaining; // Irreducible polynomial (if any)

  const FactoredForm(this.leadingCoeff, this.linearFactors, [this.remaining]);

  /// Convert the factored form back to a polynomial
  Polynomial toPolynomial() {
    Polynomial result = Polynomial.constant(leadingCoeff);
    for (var factor in linearFactors) {
      result = result * factor.toPolynomial();
    }
    if (remaining != null && !remaining!.isZero) {
      result = result * remaining!;
    }
    return result;
  }

  /// Get the factored form as a string
  @override
  String toString() {
    final buffer = StringBuffer();

    // Leading coefficient
    if (leadingCoeff != 1) {
      buffer.write(_fmt(leadingCoeff));
    }

    // Linear factors
    for (var factor in linearFactors) {
      buffer.write(factor);
    }

    // Remaining irreducible polynomial
    if (remaining != null && !remaining!.isZero) {
      buffer.write('($remaining)');
    }

    return buffer.isEmpty ? '1' : buffer.toString();
  }

  String _fmt(double n) {
    if (n == n.toInt()) return n.toInt().toString();
    return n.toString();
  }

  /// Convert to LaTeX format
  String toTex() {
    final buffer = StringBuffer();

    // Leading coefficient
    if (leadingCoeff != 1) {
      buffer.write(_fmt(leadingCoeff));
    }

    // Linear factors
    for (var factor in linearFactors) {
      buffer.write(factor.toTex());
    }

    // Remaining irreducible polynomial
    if (remaining != null && !remaining!.isZero) {
      buffer.write('(${remaining!.toTex()})');
    }

    return buffer.isEmpty ? '1' : buffer.toString();
  }
}

/// Provides polynomial factoring capabilities using various methods:
/// - Greatest Common Factor (GCF)
/// - Rational Root Theorem
/// - Synthetic Division
class PolynomialFactorizer {
  /// Factor a polynomial into linear factors where possible.
  ///
  /// Returns a [FactoredForm] containing:
  /// - Leading coefficient
  /// - List of linear factors
  /// - Optional remaining irreducible polynomial
  FactoredForm factor(Polynomial p) {
    if (p.isZero) return const FactoredForm(0, []);
    if (p.isConstant) return FactoredForm(p.constantTerm, []);

    // Step 1: Factor out GCF (numeric coefficient and powers of x)
    final gcfResult = _factorOutGCF(p);
    final gcfCoeff = gcfResult.$1;
    final gcfXPower = gcfResult.$2;
    var remaining = gcfResult.$3;

    double leadingCoeff = gcfCoeff;
    final linearFactors = <LinearFactor>[];

    // Add x factors from GCF
    for (int i = 0; i < gcfXPower; i++) {
      linearFactors.add(LinearFactor(1, 0)); // factor of x
    }

    // Step 2: Find linear factors using Rational Root Theorem
    int maxIterations = remaining.degree;
    while (remaining.degree >= 2 && maxIterations > 0) {
      final root = _findRationalRoot(remaining);
      if (root != null) {
        linearFactors.add(LinearFactor.fromRoot(root));
        remaining = _syntheticDivision(remaining, root);
        maxIterations--;
      } else {
        break;
      }
    }

    // Step 3: Handle remaining polynomial
    if (remaining.degree == 1 && !remaining.isZero) {
      // Remaining is linear - add as factor
      linearFactors.add(LinearFactor(remaining[1], remaining[0]));
    } else if (remaining.degree > 1 && !remaining.isZero) {
      // Remaining is irreducible over rationals
      return FactoredForm(leadingCoeff, linearFactors, remaining);
    }

    return FactoredForm(leadingCoeff, linearFactors);
  }

  /// Factor out the GCF from a polynomial.
  ///
  /// Returns (numeric GCF, power of x factored out, remaining polynomial)
  (double, int, Polynomial) _factorOutGCF(Polynomial p) {
    // Find GCF of non-zero coefficients
    double gcf = 0;
    for (int i = 0; i <= p.degree; i++) {
      final c = p[i];
      if (c.abs() > 1e-12) {
        gcf = (gcf == 0) ? c.abs() : _gcd(gcf, c.abs());
      }
    }

    if (gcf < 1e-12) return (0, 0, p);

    // Find minimum power of x among non-zero terms
    int minPower = p.degree;
    for (int i = 0; i <= p.degree; i++) {
      if (p[i].abs() > 1e-12) {
        minPower = i;
        break;
      }
    }

    // Divide out GCF and x^minPower
    final newCoeffs = <int, double>{};
    for (int i = 0; i <= p.degree; i++) {
      if (p[i].abs() > 1e-12) {
        newCoeffs[i - minPower] = p[i] / gcf;
      }
    }

    return (gcf, minPower, Polynomial.fromCoeffs(newCoeffs));
  }

  /// Find a rational root using the Rational Root Theorem.
  ///
  /// For polynomial with integer coefficients, possible rational roots
  /// are ±(factors of constant term) / (factors of leading coefficient)
  double? _findRationalRoot(Polynomial p) {
    final constant = p[0];
    final leading = p[p.degree];

    // If constant term is 0, then x = 0 is a root
    if (constant.abs() < 1e-12) return 0;

    // Get factors of constant and leading coefficient
    final constFactors = _getIntegerFactors(constant.abs());
    final leadFactors = _getIntegerFactors(leading.abs());

    // Generate all possible rational roots
    final possibleRoots = <double>{};
    for (var cf in constFactors) {
      for (var lf in leadFactors) {
        if (lf.abs() > 1e-12) {
          possibleRoots.add(cf / lf);
          possibleRoots.add(-cf / lf);
        }
      }
    }

    // Sort for deterministic behavior (smaller roots first)
    final sortedRoots = possibleRoots.toList()
      ..sort((a, b) => a.abs().compareTo(b.abs()));

    // Test each possible root
    for (var root in sortedRoots) {
      if (p.evaluate(root).abs() < 1e-8) {
        return root;
      }
    }

    return null;
  }

  /// Get all positive integer factors of a number
  List<double> _getIntegerFactors(double n) {
    if (n.abs() < 1e-12) return [0];

    final intN = n.round().abs();
    // Verify it's actually an integer
    if ((intN - n).abs() > 1e-9) {
      return [n];
    }

    final factors = <double>[1.0];
    if (intN <= 1) return factors;

    for (int i = 2; i * i <= intN; i++) {
      if (intN % i == 0) {
        factors.add(i.toDouble());
        if (i != intN ~/ i) {
          factors.add((intN ~/ i).toDouble());
        }
      }
    }
    if (!factors.contains(intN.toDouble())) {
      factors.add(intN.toDouble());
    }

    return factors;
  }

  /// Perform synthetic division: divide polynomial by (x - root).
  ///
  /// Uses Horner's method for efficient division.
  Polynomial _syntheticDivision(Polynomial p, double root) {
    final n = p.degree;
    if (n < 1) return p;

    // Get coefficients in descending order of degree
    final coeffs = List<double>.generate(n + 1, (i) => p[n - i]);

    final newCoeffs = <int, double>{};
    double carry = 0;

    for (int i = 0; i < n; i++) {
      carry = coeffs[i] + carry * root;
      newCoeffs[n - 1 - i] = carry;
    }

    return Polynomial.fromCoeffs(newCoeffs);
  }

  /// Calculate GCD using Euclidean algorithm
  double _gcd(double a, double b) {
    while (b > 1e-12) {
      final t = b;
      b = a % b;
      a = t;
    }
    return a;
  }

  /// Check if polynomial is a difference of squares pattern
  bool isDifferenceOfSquares(Polynomial p) {
    if (p.degree != 2) return false;
    final b = p[1];
    final a = p[2];
    final c = p[0];
    // Pattern: ax² - c (no x term) with a, c > 0
    return b.abs() < 1e-12 && a > 0 && c < 0;
  }

  /// Check if polynomial is a sum or difference of cubes pattern
  bool isSumOrDifferenceOfCubes(Polynomial p) {
    if (p.degree != 3) return false;
    // Pattern: ax³ ± c (no x² or x terms)
    return p[2].abs() < 1e-12 && p[1].abs() < 1e-12;
  }
}
