import 'dart:math';

/// Represents a polynomial in one variable (x).
///
/// Coefficients are stored as a map from degree to coefficient.
/// Example: 3x² + 2x - 1 is stored as {2: 3, 1: 2, 0: -1}
class Polynomial {
  final Map<int, double> _coeffs;

  /// Create an empty polynomial (zero polynomial)
  Polynomial() : _coeffs = {};

  /// Create a polynomial from a coefficient map
  Polynomial.fromCoeffs(Map<int, double> coeffs) : _coeffs = Map.from(coeffs) {
    _cleanup();
  }

  /// Create a constant polynomial
  Polynomial.constant(double value) : _coeffs = {} {
    if (value.abs() > 1e-12) _coeffs[0] = value;
  }

  /// Create a linear polynomial: ax + b
  Polynomial.linear(double a, double b) : _coeffs = {} {
    if (a.abs() > 1e-12) _coeffs[1] = a;
    if (b.abs() > 1e-12) _coeffs[0] = b;
  }

  /// Remove near-zero coefficients for cleanliness
  void _cleanup() {
    _coeffs.removeWhere((_, v) => v.abs() < 1e-12);
  }

  /// Get coefficient for the given degree (returns 0 if not present)
  double operator [](int degree) => _coeffs[degree] ?? 0.0;

  /// Degree of the polynomial (highest degree with non-zero coefficient)
  int get degree {
    if (_coeffs.isEmpty) return 0;
    return _coeffs.keys.reduce(max);
  }

  /// Check if polynomial is identically zero
  bool get isZero => _coeffs.isEmpty;

  /// Check if polynomial is a constant (degree 0 or zero polynomial)
  bool get isConstant => degree == 0;

  /// Get the constant term (coefficient of x⁰)
  double get constantTerm => this[0];

  /// Get the leading coefficient (coefficient of highest degree term)
  double get leadingCoeff => this[degree];

  /// Get all non-zero coefficients as a map
  Map<int, double> get coefficients => Map.unmodifiable(_coeffs);

  /// Evaluate the polynomial at a given x value
  double evaluate(double x) {
    double result = 0;
    for (var entry in _coeffs.entries) {
      result += entry.value * pow(x, entry.key);
    }
    return result;
  }

  /// Polynomial addition
  Polynomial operator +(Polynomial other) {
    final result = <int, double>{};
    final maxDeg = max(degree, other.degree);
    for (int i = 0; i <= maxDeg; i++) {
      final sum = this[i] + other[i];
      if (sum.abs() >= 1e-12) result[i] = sum;
    }
    return Polynomial.fromCoeffs(result);
  }

  /// Polynomial subtraction
  Polynomial operator -(Polynomial other) {
    return this + (-other);
  }

  /// Polynomial negation
  Polynomial operator -() {
    final result = <int, double>{};
    for (var entry in _coeffs.entries) {
      result[entry.key] = -entry.value;
    }
    return Polynomial.fromCoeffs(result);
  }

  /// Polynomial multiplication
  Polynomial operator *(Polynomial other) {
    final result = <int, double>{};
    for (var entry1 in _coeffs.entries) {
      for (var entry2 in other._coeffs.entries) {
        final deg = entry1.key + entry2.key;
        result[deg] = (result[deg] ?? 0) + entry1.value * entry2.value;
      }
    }
    return Polynomial.fromCoeffs(result);
  }

  /// Scalar multiplication
  Polynomial scale(double scalar) {
    if (scalar.abs() < 1e-12) return Polynomial();
    final result = <int, double>{};
    for (var entry in _coeffs.entries) {
      result[entry.key] = entry.value * scalar;
    }
    return Polynomial.fromCoeffs(result);
  }

  /// Check equality with another polynomial (within floating-point tolerance)
  bool equals(Polynomial other) {
    if (degree != other.degree) return false;
    for (int i = 0; i <= degree; i++) {
      if ((this[i] - other[i]).abs() >= 1e-9) return false;
    }
    return true;
  }

  @override
  String toString() {
    if (isZero) return '0';

    final buffer = StringBuffer();
    bool isFirst = true;

    for (int i = degree; i >= 0; i--) {
      final c = this[i];
      if (c.abs() < 1e-12) continue;

      if (isFirst) {
        isFirst = false;
        buffer.write(_formatTerm(c, i, true));
      } else {
        if (c > 0) {
          buffer.write(' + ');
          buffer.write(_formatTerm(c, i, false));
        } else {
          buffer.write(' - ');
          buffer.write(_formatTerm(c.abs(), i, false));
        }
      }
    }

    return buffer.toString();
  }

  /// Convert to LaTeX format for display
  String toTex() {
    if (isZero) return '0';

    final buffer = StringBuffer();
    bool isFirst = true;

    for (int i = degree; i >= 0; i--) {
      final c = this[i];
      if (c.abs() < 1e-12) continue;

      if (isFirst) {
        isFirst = false;
        buffer.write(_formatTermTex(c, i, true));
      } else {
        if (c > 0) {
          buffer.write(' + ');
          buffer.write(_formatTermTex(c, i, false));
        } else {
          buffer.write(' - ');
          buffer.write(_formatTermTex(c.abs(), i, false));
        }
      }
    }

    return buffer.toString();
  }

  String _formatTermTex(double coeff, int deg, bool isFirst) {
    if (deg == 0) return _formatNumber(coeff);
    
    final varPart = deg == 1 ? 'x' : 'x^{$deg}';
    
    if ((coeff.abs() - 1.0).abs() < 1e-9) {
      if (isFirst && coeff < 0) return '-$varPart';
      return varPart;
    }
    
    return '${_formatNumber(coeff)}$varPart';
  }

  String _formatTerm(double coeff, int deg, bool isFirst) {
    // Constant term
    if (deg == 0) {
      return _formatNumber(coeff);
    }

    final varPart = deg == 1 ? 'x' : 'x^$deg';

    // Handle coefficient of 1 or -1
    if ((coeff.abs() - 1).abs() < 1e-9) {
      if (isFirst && coeff < 0) return '-$varPart';
      return varPart;
    }

    return '${_formatNumber(coeff)}$varPart';
  }

  String _formatNumber(double n) {
    if (n == n.toInt()) return n.toInt().toString();
    return n.toString();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Polynomial && equals(other);

  @override
  int get hashCode => Object.hashAll(
      _coeffs.entries.map((e) => Object.hash(e.key, e.value.round())));
}
