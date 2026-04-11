import 'dart:math';

class CircleEquationSolver {
  // ── Formatter helpers ──────────────────────────────────────────────────────

  static String fmt(double v) {
    if (v == v.truncateToDouble()) return v.truncate().toString();
    return v
        .toStringAsFixed(3)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  static String signedCoeff(double v, {bool leading = false}) {
    if (leading) return fmt(v);
    if (v >= 0) return '+ ${fmt(v)}';
    return '- ${fmt(v.abs())}';
  }

  // ── Equation Parser ────────────────────────────────────────────────────────

  static Map<String, double> parseGeneralForm(String raw) {
    // ── Step 1: Normalize input ────────────────────────────────────────────
    String input = raw
        .toLowerCase()
        .trim()
        // Handle superscripts
        .replaceAll('²', '2')
        .replaceAll('\u00B2', '2')
        // Handle various minus signs
        .replaceAll('−', '-')
        .replaceAll('–', '-')
        .replaceAll('—', '-')
        .replaceAll('\u2212', '-')
        .replaceAll('\u2013', '-')
        .replaceAll('\u2014', '-')
        // Handle multiplication
        .replaceAll('×', '*')
        .replaceAll('·', '*')
        .replaceAll('\u00D7', '*')
        .replaceAll('\u00B7', '*')
        .replaceAll('*', '')
        // Normalize x^2 and y^2 BEFORE removing spaces
        .replaceAll(RegExp(r'x\s*\^\s*2'), 'x2')
        .replaceAll(RegExp(r'y\s*\^\s*2'), 'y2')
        // Handle x2 and y2 (with possible spaces)
        .replaceAll(RegExp(r'x\s*2'), 'x2')
        .replaceAll(RegExp(r'y\s*2'), 'y2')
        // Remove all spaces
        .replaceAll(' ', '');

    // ── Step 2: Resolve inline fractions ───────────────────────────────────
    input = input.replaceAllMapped(
      RegExp(r'\((\d+(?:\.\d+)?)\/(\d+(?:\.\d+)?)\)'),
      (m) {
        final num = double.parse(m.group(1)!);
        final den = double.parse(m.group(2)!);
        return (num / den).toString();
      },
    );

    // ── Step 3: Split at equals ────────────────────────────────────────────
    final sides = input.split('=');
    String lhs = sides[0];
    String rhs = sides.length > 1 ? sides[1] : '0';

    // Swap if "0 = expression"
    if (lhs == '0') {
      final temp = lhs;
      lhs = rhs;
      rhs = temp;
    }

    // ── Step 4: Move RHS to LHS ────────────────────────────────────────────
    if (rhs != '0') {
      if (!rhs.startsWith('-') && !rhs.startsWith('+')) rhs = '+$rhs';
      final flipped = rhs
          .replaceAll('+', '__POS__')
          .replaceAll('-', '+')
          .replaceAll('__POS__', '-');
      lhs = lhs + flipped;
    }

    // ── Step 5: Clean up signs ─────────────────────────────────────────────
    String prev;
    int iterations = 0;
    do {
      prev = lhs;
      lhs = lhs
          .replaceAll('+-', '-')
          .replaceAll('-+', '-')
          .replaceAll('--', '+')
          .replaceAll('++', '+');
      iterations++;
    } while (lhs != prev && iterations < 10);

    // ── Step 6: Add leading sign ───────────────────────────────────────────
    if (!lhs.startsWith('-') && !lhs.startsWith('+')) lhs = '+$lhs';

    // ── Step 7: Tokenize ───────────────────────────────────────────────────
    final tokens = <String>[];
    int start = 0;

    for (int i = 1; i < lhs.length; i++) {
      if (lhs[i] == '+' || lhs[i] == '-') {
        tokens.add(lhs.substring(start, i));
        start = i;
      }
    }
    tokens.add(lhs.substring(start)); // Add last token

    // ── Step 8: Parse tokens ───────────────────────────────────────────────
    double x2coeff = 0, y2coeff = 0, D = 0, E = 0, F = 0;

    for (final token in tokens) {
      if (token.isEmpty || token == '+' || token == '-') continue;

      final sign = token.startsWith('-') ? -1.0 : 1.0;
      final body = token.substring(1);

      if (body.isEmpty) continue;

      if (body.contains('x2')) {
        final numPart = body.replaceAll('x2', '');
        final coeff = numPart.isEmpty ? 1.0 : (double.tryParse(numPart) ?? 1.0);
        x2coeff += sign * coeff;
      } else if (body.contains('y2')) {
        final numPart = body.replaceAll('y2', '');
        final coeff = numPart.isEmpty ? 1.0 : (double.tryParse(numPart) ?? 1.0);
        y2coeff += sign * coeff;
      } else if (body.contains('x')) {
        final numPart = body.replaceAll('x', '');
        final coeff = numPart.isEmpty ? 1.0 : (double.tryParse(numPart) ?? 1.0);
        D += sign * coeff;
      } else if (body.contains('y')) {
        final numPart = body.replaceAll('y', '');
        final coeff = numPart.isEmpty ? 1.0 : (double.tryParse(numPart) ?? 1.0);
        E += sign * coeff;
      } else {
        final parsed = double.tryParse(body);
        if (parsed == null) {
          throw FormatException('Cannot parse: "$body" in token "$token"');
        }
        F += sign * parsed;
      }
    }

    // ── Step 9: Validate ───────────────────────────────────────────────────
    const epsilon = 1e-10;

    if (x2coeff.abs() < epsilon || y2coeff.abs() < epsilon) {
      throw ArgumentError(
          'Invalid: missing x² or y² term (x²=$x2coeff, y²=$y2coeff)');
    }

    if ((x2coeff - y2coeff).abs() > epsilon) {
      throw ArgumentError(
          'Not a circle: x²=$x2coeff ≠ y²=$y2coeff (ellipse/hyperbola)');
    }

    // ── Step 10: Normalize ─────────────────────────────────────────────────
    if ((x2coeff - 1.0).abs() > epsilon) {
      D /= x2coeff;
      E /= x2coeff;
      F /= x2coeff;
    }

    return {'D': D, 'E': E, 'F': F};
  }

  // ── Solve from string ──────────────────────────────────────────────────────

  static List<SolverStep> solveFromString(String raw) {
    final coeffs = parseGeneralForm(raw);
    return generalToStandard(
      D: coeffs['D']!,
      E: coeffs['E']!,
      F: coeffs['F']!,
    );
  }

  // ── Standard → General ─────────────────────────────────────────────────────

  static List<SolverStep> standardToGeneral({
    required double h,
    required double k,
    required double r,
  }) {
    final D = -2 * h;
    final E = -2 * k;
    final F = h * h + k * k - r * r;
    final rSquared = r * r;
    final hSquared = h * h;
    final kSquared = k * k;

    return [
      SolverStep(
        label: 'Center-Radius Form',
        arrow: true,
        equation:
            '(x ${h >= 0 ? '-' : '+'} ${fmt(h.abs())})² + (y ${k >= 0 ? '-' : '+'} ${fmt(k.abs())})² = ${fmt(r)}²',
        color: SolverColors.teal,
      ),
      SolverStep(
        label: 'Substitute r² = ${fmt(rSquared)}',
        equation:
            '(x ${h >= 0 ? '-' : '+'} ${fmt(h.abs())})² + (y ${k >= 0 ? '-' : '+'} ${fmt(k.abs())})² = ${fmt(rSquared)}',
      ),
      SolverStep(
        label: 'Expand binomial squares',
        equation:
            'x² ${signedCoeff(-2 * h)}x + ${fmt(hSquared)} + y² ${signedCoeff(-2 * k)}y + ${fmt(kSquared)} = ${fmt(rSquared)}',
      ),
      SolverStep(
        label: 'Move ${fmt(rSquared)} to left',
        equation:
            'x² + y² ${signedCoeff(-2 * h)}x ${signedCoeff(-2 * k)}y + ${fmt(hSquared + kSquared - rSquared)} = 0',
      ),
      SolverStep(
        label: 'General Form',
        isFinal: true,
        equation:
            'x² + y² ${signedCoeff(D)}x ${signedCoeff(E)}y ${signedCoeff(F)} = 0',
        color: SolverColors.cyan,
      ),
    ];
  }

  // ── General → Standard ─────────────────────────────────────────────────────

  static List<SolverStep> generalToStandard({
    required double D,
    required double E,
    required double F,
  }) {
    final h = -D / 2;
    final k = -E / 2;
    final halfD = D / 2;
    final halfE = E / 2;
    final halfDSquared = halfD * halfD;
    final halfESquared = halfE * halfE;
    final rSquared = halfDSquared + halfESquared - F;

    if (rSquared <= 0) {
      throw ArgumentError('Invalid: r² = $rSquared ≤ 0 (imaginary circle)');
    }

    final r = sqrt(rSquared);
    final rightSide = -F + halfDSquared + halfESquared;

    return [
      SolverStep(
        label: 'General Form',
        arrow: true,
        equation:
            'x² + y² ${signedCoeff(D)}x ${signedCoeff(E)}y ${signedCoeff(F)} = 0',
        color: SolverColors.teal,
      ),
      SolverStep(
        label: 'Group terms; move constant to right',
        equation:
            '(x² ${signedCoeff(D)}x) + (y² ${signedCoeff(E)}y) = ${signedCoeff(-F, leading: true)}',
      ),
      SolverStep(
        label:
            'Complete the square:\n  x: add (${fmt(halfD)})² = ${fmt(halfDSquared)}\n  y: add (${fmt(halfE)})² = ${fmt(halfESquared)}',
        equation:
            '(x² ${signedCoeff(D)}x ${signedCoeff(halfDSquared)}) + (y² ${signedCoeff(E)}y ${signedCoeff(halfESquared)}) = ${fmt(rightSide)}',
      ),
      SolverStep(
        label: 'Factor as perfect squares',
        equation:
            '(x ${signedCoeff(halfD)})² + (y ${signedCoeff(halfE)})² = ${fmt(rSquared)}',
      ),
      SolverStep(
        label: 'Center-Radius Form',
        isFinal: true,
        equation:
            '(x ${h >= 0 ? '-' : '+'} ${fmt(h.abs())})² + (y ${k >= 0 ? '-' : '+'} ${fmt(k.abs())})² = ${fmt(r)}²',
        subLines: [
          'Center: (${fmt(h)}, ${fmt(k)})',
          'Radius: r = ${fmt(r)}',
        ],
        color: SolverColors.cyan,
      ),
    ];
  }
}

// ── Models ─────────────────────────────────────────────────────────────────

class SolverStep {
  final String label;
  final String equation;
  final List<String> subLines;
  final bool isFinal;
  final bool arrow;
  final SolverColors? color;

  const SolverStep({
    required this.label,
    required this.equation,
    this.subLines = const [],
    this.isFinal = false,
    this.arrow = false,
    this.color,
  });
}

enum SolverColors { teal, cyan }
