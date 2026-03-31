// lib/solver/fraction.dart

import 'dart:math';

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

  // Factory to create Fraction from a double value
  factory Fraction.fromDouble(double value) {
    if (value.isNaN || value.isInfinite) {
      return const Fraction(numerator: 0, denominator: 1);
    }

    final rounded = value.round();
    if ((value - rounded).abs() < 0.000001) {
      return Fraction(numerator: rounded, denominator: 1, isWhole: true);
    }

    final scaled = (value * 1000).round();
    if ((scaled / 1000 - value).abs() < 0.0001) {
      return Fraction(numerator: scaled, denominator: 1000).simplified();
    }

    final str = value.toStringAsFixed(4);
    final decimalIndex = str.indexOf('.');

    if (decimalIndex == -1) {
      return Fraction(numerator: value.toInt(), denominator: 1, isWhole: true);
    }

    final wholePart = int.parse(str.substring(0, decimalIndex));
    final decimalPart = str.substring(decimalIndex + 1);
    final trimmedDecimal = decimalPart.replaceAll(RegExp(r'0+$'), '');

    if (trimmedDecimal.isEmpty) {
      return Fraction(numerator: wholePart, denominator: 1, isWhole: true);
    }

    final safeDecimal = trimmedDecimal.length > 4 
        ? trimmedDecimal.substring(0, 4) 
        : trimmedDecimal;

    final decimalValue = int.parse(safeDecimal);
    final decimalPlaces = safeDecimal.length;
    final den = pow(10, decimalPlaces).toInt();
    final num = wholePart * den + (value < 0 ? -decimalValue : decimalValue);

    return Fraction(numerator: num, denominator: den).simplified();
  }

  // Operator overloads for arithmetic operations
  operator +(Fraction other) {
    if (denominator == other.denominator) {
      return Fraction(
        numerator: numerator + other.numerator,
        denominator: denominator,
      ).simplified();
    }
    if (other.denominator == 1) {
      return Fraction(
        numerator: numerator + other.numerator * denominator,
        denominator: denominator,
      ).simplified();
    }
    if (denominator == 1) {
      return Fraction(
        numerator: numerator * other.denominator + other.numerator,
        denominator: other.denominator,
      ).simplified();
    }

    final newNum = numerator * other.denominator + other.numerator * denominator;
    final newDen = denominator * other.denominator;
    return Fraction(numerator: newNum, denominator: newDen).simplified();
  }

  operator -(Fraction other) {
    if (denominator == other.denominator) {
      return Fraction(
        numerator: numerator - other.numerator,
        denominator: denominator,
      ).simplified();
    }
    if (other.denominator == 1) {
      return Fraction(
        numerator: numerator - other.numerator * denominator,
        denominator: denominator,
      ).simplified();
    }
    if (denominator == 1) {
      return Fraction(
        numerator: numerator * other.denominator - other.numerator,
        denominator: other.denominator,
      ).simplified();
    }

    final newNum = numerator * other.denominator - other.numerator * denominator;
    final newDen = denominator * other.denominator;
    return Fraction(numerator: newNum, denominator: newDen).simplified();
  }

  operator *(Fraction other) {
    if (other.denominator == 1) {
      return Fraction(
        numerator: numerator * other.numerator,
        denominator: denominator,
      ).simplified();
    }
    if (denominator == 1) {
      return Fraction(
        numerator: numerator * other.numerator,
        denominator: other.denominator,
      ).simplified();
    }

    final a = numerator;
    final b = denominator;
    final c = other.numerator;
    final d = other.denominator;

    final gcd1 = _fastGcd(a.abs(), d);
    final gcd2 = _fastGcd(c.abs(), b);

    return Fraction(
      numerator: (a ~/ gcd1) * (c ~/ gcd2),
      denominator: (b ~/ gcd2) * (d ~/ gcd1),
    );
  }

  operator /(Fraction other) {
    return this * other.reciprocal();
  }

  operator -() => Fraction(numerator: -numerator, denominator: denominator);

  Fraction abs() => Fraction(
    numerator: numerator.abs(),
    denominator: denominator,
    isWhole: isWhole,
  );

  Fraction reciprocal() => Fraction(
    numerator: denominator,
    denominator: numerator,
  ).simplified();

  // Simplify the fraction
  Fraction simplified() {
    if (denominator == 0) return const Fraction(numerator: 0, denominator: 1);
    if (denominator == 1 || numerator == 0) {
      return Fraction(numerator: numerator, denominator: 1, isWhole: true);
    }

    int n = numerator;
    int d = denominator;

    if (d < 0) {
      n = -n;
      d = -d;
    }

    if (n.abs() < 1000 && d < 1000) {
      if (n % d == 0) {
        return Fraction(numerator: n ~/ d, denominator: 1, isWhole: true);
      }
      if (d % 2 == 0 && n % 2 == 0) {
        return Fraction(numerator: n ~/ 2, denominator: d ~/ 2).simplified();
      }
      if (d % 3 == 0 && n % 3 == 0) {
        return Fraction(numerator: n ~/ 3, denominator: d ~/ 3).simplified();
      }
    }

    final gcd = _fastGcd(n.abs(), d);
    if (gcd == 1) return Fraction(numerator: n, denominator: d);

    n = n ~/ gcd;
    d = d ~/ gcd;

    if (d == 1) return Fraction(numerator: n, denominator: 1, isWhole: true);
    return Fraction(numerator: n, denominator: d);
  }

  // Binary GCD algorithm
  static int _fastGcd(int a, int b) {
    if (a == 0) return b;
    if (b == 0) return a;
    if (a == b) return a;
    if (a == 1 || b == 1) return 1;

    if (a < 10000 && b < 10000) {
      while (b != 0) {
        final t = b;
        b = a % b;
        a = t;
      }
      return a;
    }

    int shift = 0;
    while (((a | b) & 1) == 0) {
      a >>= 1;
      b >>= 1;
      shift++;
    }

    while ((a & 1) == 0) {a >>= 1;}

    do {
      while ((b & 1) == 0) {b >>= 1;}
      if (a > b) {
        final t = b;
        b = a;
        a = t;
      }
      b = b - a;
    } while (b != 0);

    return a << shift;
  }
}