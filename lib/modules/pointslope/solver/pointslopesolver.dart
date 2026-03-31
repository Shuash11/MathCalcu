// lib/solver/pointslopesolver.dart

import 'dart:math';
import 'fractionsolver.dart';

class SolveStep {
  final String title;
  final String explanation;
  final String result;

  const SolveStep({
    required this.title,
    required this.explanation,
    required this.result,
  });
}

class PointSlopeSolver {
  final Fraction m;
  final Fraction x1;
  final Fraction y1;

  const PointSlopeSolver({
    required this.m,
    required this.x1,
    required this.y1,
  });

  factory PointSlopeSolver.fromDoubles({
    required double m,
    required double x1,
    required double y1,
  }) {
    return PointSlopeSolver(
      m: Fraction.fromDouble(m),
      x1: Fraction.fromDouble(x1),
      y1: Fraction.fromDouble(y1),
    );
  }

  factory PointSlopeSolver.fromStrings({
    required String mText,
    required String x1Text,
    required String y1Text,
  }) {
    final mFrac = _parseFraction(mText);
    final x1Frac = _parseFraction(x1Text);
    final y1Frac = _parseFraction(y1Text);

    if (mFrac == null || x1Frac == null || y1Frac == null) {
      throw const FormatException('Invalid fraction format');
    }

    return PointSlopeSolver(m: mFrac, x1: x1Frac, y1: y1Frac);
  }

  /// Calculate y-intercept (b = y1 - m*x1)
  Fraction get b => y1 - (m * x1);

  /// 1. POINT-SLOPE FORM: y - y₁ = m(x - x₁)
  String get pointSlopeForm {
    final ySign = y1.numerator >= 0 ? '-' : '+';
    final xSign = x1.numerator >= 0 ? '-' : '+';
    return 'y $ySign ${y1.abs()} = ${m.simplified()}(x $xSign ${x1.abs()})';
  }

  /// 2. GENERAL FORM: Ax + By + C = 0
  String get generalForm {
    // From point-slope: y - y1 = m(x - x1)
    // Expand: y - y1 = mx - m*x1
    // Rearrange: mx - y + (y1 - m*x1) = 0
    // Which is: mx - y + b = 0
    
    final mSimplified = m.simplified();
    final bSimplified = b.simplified();
    
    // Clear fractions by finding common denominator
    final mNum = mSimplified.numerator;
    final mDen = mSimplified.denominator;
    final bNum = bSimplified.numerator;
    final bDen = bSimplified.denominator;
    
    final lcm = _lcm(mDen, bDen);
    
    // Coefficients: A = mNum * (lcm/mDen), B = -lcm, C = bNum * (lcm/bDen)
    int a = mNum * (lcm ~/ mDen);
    int bCoeff = -lcm;
    int c = bNum * (lcm ~/ bDen);
    
    // Simplify by GCD
    final gcd = _gcd(_gcd(a.abs(), bCoeff.abs()), c.abs());
    if (gcd > 1) {
      a = a ~/ gcd;
      bCoeff = bCoeff ~/ gcd;
      c = c ~/ gcd;
    }
    
    // Ensure A is positive
    if (a < 0) {
      a = -a;
      bCoeff = -bCoeff;
      c = -c;
    }
    
    // Format
    final aStr = _formatCoeff(a, 'x', true);
    final bStr = _formatCoeff(bCoeff, 'y', false);
    final cStr = _formatConst(c);
    
    return '$aStr$bStr$cStr = 0';
  }

  /// 3. STANDARD FORM: Ax + By = C
  String get standardForm {
    // Same as general but C on RHS: Ax + By = -C
    final mSimplified = m.simplified();
    final bSimplified = b.simplified();
    
    final mNum = mSimplified.numerator;
    final mDen = mSimplified.denominator;
    final bNum = bSimplified.numerator;
    final bDen = bSimplified.denominator;
    
    final lcm = _lcm(mDen, bDen);
    
    int a = mNum * (lcm ~/ mDen);
    int bCoeff = -lcm;
    int c = -(bNum * (lcm ~/ bDen)); // Negated for RHS
    
    // Simplify
    final gcd = _gcd(_gcd(a.abs(), bCoeff.abs()), c.abs());
    if (gcd > 1) {
      a = a ~/ gcd;
      bCoeff = bCoeff ~/ gcd;
      c = c ~/ gcd;
    }
    
    // Ensure A is positive
    if (a < 0) {
      a = -a;
      bCoeff = -bCoeff;
      c = -c;
    }
    
    // Format
    final aStr = _formatCoeff(a, 'x', true);
    final bStr = _formatCoeff(bCoeff, 'y', false);
    
    return '$aStr$bStr= $c';
  }

  // Helper to format coefficients
  String _formatCoeff(int val, String vari, bool isFirst) {
    if (val == 0) return '';
    
    final absVal = val.abs();
    final sign = val < 0 ? '-' : (isFirst ? '' : '+');
    final space = isFirst ? '' : ' ';
    
    if (absVal == 1) {
      return '$space $sign $vari';
    }
    return '$space $sign $absVal $vari';
  }

  // Helper to format constant
  String _formatConst(int val) {
    if (val == 0) return '';
    if (val > 0) return ' + $val';
    return ' - ${val.abs()}';
  }

  // GCD and LCM helpers
  static int _gcd(int a, int b) {
    while (b != 0) {
      final t = b;
      b = a % b;
      a = t;
    }
    return a;
  }

  static int _lcm(int a, int b) {
    return (a * b) ~/ _gcd(a, b);
  }

  // Parse fraction
  static Fraction? _parseFraction(String text) {
    text = text.trim();

    if (text.contains(' ') && text.contains('/')) {
      final parts = text.split(' ');
      if (parts.length == 2) {
        final whole = int.tryParse(parts[0].trim());
        final fracParts = parts[1].split('/');
        if (whole != null && fracParts.length == 2) {
          final num = int.tryParse(fracParts[0].trim());
          final den = int.tryParse(fracParts[1].trim());
          if (num != null && den != null && den != 0) {
            final sign = whole < 0 ? -1 : 1;
            final totalNum = (whole.abs() * den + num) * sign;
            return Fraction(numerator: totalNum, denominator: den).simplified();
          }
        }
      }
    }

    if (text.contains('/')) {
      final parts = text.split('/');
      if (parts.length == 2) {
        final num = int.tryParse(parts[0].trim());
        final den = int.tryParse(parts[1].trim());
        if (num != null && den != null && den != 0) {
          return Fraction(numerator: num, denominator: den).simplified();
        }
      }
    }

    final integerValue = int.tryParse(text);
    if (integerValue != null) {
      return Fraction(numerator: integerValue, denominator: 1, isWhole: true);
    }

    final doubleValue = double.tryParse(text);
    if (doubleValue != null) {
      return Fraction.fromDouble(doubleValue);
    }

    return null;
  }

  static PointSlopeSolver? tryParse({
    required String mText,
    required String x1Text,
    required String y1Text,
  }) {
    final mFrac = _parseFraction(mText);
    final x1Frac = _parseFraction(x1Text);
    final y1Frac = _parseFraction(y1Text);

    if (mFrac != null && x1Frac != null && y1Frac != null) {
      return PointSlopeSolver(m: mFrac, x1: x1Frac, y1: y1Frac);
    }

    final m = double.tryParse(mText);
    final x1 = double.tryParse(x1Text);
    final y1 = double.tryParse(y1Text);
    if (m == null || x1 == null || y1 == null) return null;

    return PointSlopeSolver.fromDoubles(m: m, x1: x1, y1: y1);
  }

  // Stats
  String get direction {
    final mVal = m.toDouble();
    if (mVal > 0) return 'Rising ↗';
    if (mVal < 0) return 'Falling ↘';
    return 'Horizontal →';
  }

  String get angle => '${(atan(m.toDouble()) * 180 / pi).toStringAsFixed(1)}°';

  String get riseRun => '${m.simplified()} / 1';

  // Legacy
  String get pointSlopeEquation => pointSlopeForm;
  String get simplifiedAnswer => standardForm;

  // Steps
  List<SolveStep> get steps {
  return [
    SolveStep(
      title: 'Point-Slope Form',
      explanation: 'Write the equation using the point and slope: y - y₁ = m(x - x₁).',
      result: pointSlopeForm,
    ),
 const SolveStep(
  title: 'Expand to Slope-Intercept Form',
  explanation: 'Distribute m: y - y₁ = m * (x - x₁). Then, solve for y.',
  result: 'y = y₁ + m(x - x₁)',
),
    SolveStep(
      title: 'Simplify Constant Term',
      explanation: 'Combine y₁ and -m * x₁ into a single constant term.',
      result: 'y = (${y1.toString()}) + ${m.simplified()}(x ${x1.numerator >= 0 ? '-' : '+'} ${x1.abs()})',
    ),
    SolveStep(
      title: 'Convert to General Form',
      explanation: 'Bring all terms to one side: mx - y + (y₁ - m x₁) = 0.',
      result: generalForm,
    ),
    SolveStep(
      title: 'Convert to Standard Form',
      explanation: 'Rearrange to get Ax + By = C.',
      result: standardForm,
    ),
  ];
}
}