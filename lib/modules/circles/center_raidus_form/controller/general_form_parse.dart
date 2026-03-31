class GeneralFormParser {
  static GeneralFormResult parse(String input) {
    String eq = input
        .replaceAll(' ', '')
        .replaceAll('x²', 'x^2')
        .replaceAll('y²', 'y^2')
        .replaceAll('X²', 'x^2')
        .replaceAll('Y²', 'y^2')
        .replaceAll('X^2', 'x^2')
        .replaceAll('Y^2', 'y^2')
        .replaceAll('x2', 'x^2')   // handles x2 notation
        .replaceAll('y2', 'y^2')   // handles y2 notation
        .replaceAll('X2', 'x^2')
        .replaceAll('Y2', 'y^2')
        .replaceAll('X', 'x')
        .replaceAll('Y', 'y');

    // Remove "= 0" or "=0" at the end
    eq = eq.replaceAll(RegExp(r'=\s*0$'), '');

    // Must contain x^2 and y^2
    if (!eq.contains('x^2') || !eq.contains('y^2')) {
      throw const FormatException('Equation must contain x² and y² terms.');
    }

    // Remove x^2 and y^2 — use replaceFirst to avoid stomping on x/y terms
    eq = eq.replaceFirst('x^2', '').replaceFirst('y^2', '');

    // Clean up any double signs like +-  or ++
    eq = eq
        .replaceAll('+-', '-')
        .replaceAll('-+', '-')
        .replaceAll('++', '+')
        .replaceAll('--', '+');

    // Ensure leading sign
    if (eq.isNotEmpty && eq[0] != '+' && eq[0] != '-') {
      eq = '+$eq';
    }

    // Extract D (coefficient of x)
    double D = 0;
    final xMatch = RegExp(r'([+-][0-9.]*)x(?!\^)').firstMatch(eq);
    if (xMatch != null) {
      final raw = xMatch.group(1)!;
      D = raw == '+' ? 1 : raw == '-' ? -1 : double.parse(raw);
      eq = eq.replaceFirst(xMatch.group(0)!, '');
    }

    // Extract E (coefficient of y)
    double E = 0;
    final yMatch = RegExp(r'([+-][0-9.]*)y(?!\^)').firstMatch(eq);
    if (yMatch != null) {
      final raw = yMatch.group(1)!;
      E = raw == '+' ? 1 : raw == '-' ? -1 : double.parse(raw);
      eq = eq.replaceFirst(yMatch.group(0)!, '');
    }

    // Whatever remains is F
    double F = 0;
    if (eq.isNotEmpty && eq != '+' && eq != '-') {
      final parsed = double.tryParse(eq);
      if (parsed == null) throw FormatException('Cannot parse constant: "$eq"');
      F = parsed;
    }

    return GeneralFormResult(D: D, E: E, F: F);
  }
}

class GeneralFormResult {
  final double D, E, F;
  const GeneralFormResult({required this.D, required this.E, required this.F});
}