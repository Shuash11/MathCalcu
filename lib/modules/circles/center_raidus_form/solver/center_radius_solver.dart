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

  // ── Standard → General ────────────────────────────────────────────────────

  static List<SolverStep> standardToGeneral({
    required double h,
    required double k,
    required double r,
  }) {
    final D = -2 * h;
    final E = -2 * k;
    final F = h * h + k * k - r * r;

    return [
      SolverStep(
        label: 'Center-Radius Form',
        arrow: true,
        equation:
            '(x ${h >= 0 ? '-' : '+'} ${fmt(h.abs())})² + (y ${k >= 0 ? '-' : '+'} ${fmt(k.abs())})² = ${fmt(r)}²',
        color: SolverColors.teal,
      ),
      SolverStep(
        label: 'Substitute r² = ${fmt(r * r)}',
        equation:
            '(x ${h >= 0 ? '-' : '+'} ${fmt(h.abs())})² + (y ${k >= 0 ? '-' : '+'} ${fmt(k.abs())})² = ${fmt(r * r)}',
      ),
      SolverStep(
        label: 'Expand each binomial square',
        equation:
            'x² ${signedCoeff(-2 * h)}x + ${fmt(h * h)} + y² ${signedCoeff(-2 * k)}y + ${fmt(k * k)} = ${fmt(r * r)}',
      ),
      SolverStep(
        label: 'Move ${fmt(r * r)} to the left side',
        equation:
            'x² + y² ${signedCoeff(-2 * h)}x ${signedCoeff(-2 * k)}y + ${fmt(h * h)} + ${fmt(k * k)} - ${fmt(r * r)} = 0',
      ),
      SolverStep(
        label: 'Combine constant terms',
        equation:
            'x² + y² ${signedCoeff(D)}x ${signedCoeff(E)}y ${signedCoeff(F)} = 0',
        color: SolverColors.cyan,
      ),
      SolverStep(
        label: 'General Form',
        isFinal: true,
        equation:
            'x² + y² ${signedCoeff(D)}x ${signedCoeff(E)}y ${signedCoeff(F)} = 0',
        subLines: [
          'D = ${fmt(D)},   E = ${fmt(E)},   F = ${fmt(F)}',
        ],
        color: SolverColors.cyan,
      ),
    ];
  }

  // ── General → Standard ────────────────────────────────────────────────────

  static List<SolverStep> generalToStandard({
    required double D,
    required double E,
    required double F,
  }) {
    final h = -D / 2;
    final k = -E / 2;
    final rSq = h * h + k * k - F;
    final r = sqrt(rSq);
    final halfD = D / 2;
    final halfE = E / 2;

    return [
      SolverStep(
        label: 'General Form',
        arrow: true,
        equation:
            'x² + y² ${signedCoeff(D)}x ${signedCoeff(E)}y ${signedCoeff(F)} = 0',
        color: SolverColors.teal,
      ),
      SolverStep(
        label: 'Group x-terms and y-terms; move F to right',
        equation:
            '(x² ${signedCoeff(D)}x) + (y² ${signedCoeff(E)}y) = ${signedCoeff(-F, leading: true)}',
      ),
      SolverStep(
        label:
            'Complete the square\n  Add (D/2)² = ${fmt(halfD * halfD)} and (E/2)² = ${fmt(halfE * halfE)} to both sides',
        equation:
            '(x² ${signedCoeff(D)}x + ${fmt(halfD * halfD)}) + (y² ${signedCoeff(E)}y + ${fmt(halfE * halfE)}) = ${fmt(-F + halfD * halfD + halfE * halfE)}',
      ),
      SolverStep(
        label: 'Write as perfect squares',
        equation:
            '(x ${h >= 0 ? '-' : '+'} ${fmt(h.abs())})² + (y ${k >= 0 ? '-' : '+'} ${fmt(k.abs())})² = ${fmt(rSq)}',
      ),
      SolverStep(
        label: 'r² = ${fmt(rSq)}  →  r = √${fmt(rSq)} = ${fmt(r)}',
        equation:
            '(x ${h >= 0 ? '-' : '+'} ${fmt(h.abs())})² + (y ${k >= 0 ? '-' : '+'} ${fmt(k.abs())})² = ${fmt(r)}²',
        color: SolverColors.cyan,
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