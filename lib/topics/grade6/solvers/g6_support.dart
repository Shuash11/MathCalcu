// ─────────────────────────────────────────────────────────────
// G6 SUPPORT — shared kernel for Grade 6 solvers.
// Pure Dart, offline-first. No colors, no packages.
// One responsibility: number formatting + integer math so the
// eleven solver files stay small and consistent.
// ─────────────────────────────────────────────────────────────

/// Display formatting for G6 answers (trimmed, readable).
class G6Format {
  G6Format._();

  /// Formats [v], trimming trailing zeros (up to [decimals] places).
  static String num(double v, {int decimals = 6}) {
    if (v.isNaN) {
      return 'NaN';
    }
    if (v.isInfinite) {
      return v > 0 ? '∞' : '-∞';
    }
    final double rounded = double.parse(v.toStringAsFixed(decimals));
    if (rounded == rounded.truncateToDouble() && rounded.abs() < 1e15) {
      return rounded.truncate().toString();
    }
    var s = rounded.toStringAsFixed(decimals);
    s = s.replaceAll(RegExp(r'0+$'), '');
    s = s.replaceAll(RegExp(r'\.$'), '');
    return s;
  }

  /// Peso formatting with two decimals.
  static String money(double v) => '₱${v.toStringAsFixed(2)}';
}

/// Small integer helpers (GCF/LCM core) shared by solvers.
class G6Math {
  G6Math._();

  static int gcd(int a, int b) {
    a = a.abs();
    b = b.abs();
    while (b != 0) {
      final int t = a % b;
      a = b;
      b = t;
    }
    return a == 0 ? 1 : a;
  }

  static int lcm(int a, int b) {
    if (a == 0 || b == 0) {
      return 0;
    }
    return (a.abs() ~/ gcd(a, b)) * b.abs();
  }

  static int gcdList(List<int> values) {
    var result = values.first.abs();
    for (final v in values.skip(1)) {
      result = gcd(result, v);
    }
    return result;
  }

  static int lcmList(List<int> values) {
    var result = values.first.abs();
    for (final v in values.skip(1)) {
      result = lcm(result, v);
    }
    return result;
  }
}
