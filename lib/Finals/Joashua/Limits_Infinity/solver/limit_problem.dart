enum LimitType {
  finite,
  infinity,
  negativeInfinity,
  undefined,
}

class LimitProblem {
  final String expression;
  final double approachValue;
  final String variable;
  final LimitType limitType;

  const LimitProblem({
    required this.expression,
    required this.approachValue,
    required this.variable,
    required this.limitType,
  });

  String get problemNotation {
    String approachStr;
    switch (limitType) {
      case LimitType.infinity:
        approachStr = '∞';
        break;
      case LimitType.negativeInfinity:
        approachStr = '-∞';
        break;
      case LimitType.finite:
        approachStr = approachValue.toString();
        break;
      case LimitType.undefined:
        approachStr = '?';
        break;
    }
    return 'lim($variable → $approachStr) $expression';
  }

  factory LimitProblem.fromNotation({
    required String expression,
    required String approach,
    required String variable,
  }) {
    final cleanApproach = approach.trim().toLowerCase();

    LimitType limitType;
    double approachValue;

    if (cleanApproach == 'inf' ||
        cleanApproach == 'infinity' ||
        cleanApproach == '+inf' ||
        cleanApproach == '+infinity') {
      limitType = LimitType.infinity;
      approachValue = double.infinity;
    } else if (cleanApproach == '-inf' || cleanApproach == '-infinity') {
      limitType = LimitType.negativeInfinity;
      approachValue = double.negativeInfinity;
    } else {
      final parsed = double.tryParse(cleanApproach);
      if (parsed == null) {
        throw Exception('Invalid approach value: $approach');
      }
      limitType = LimitType.finite;
      approachValue = parsed;
    }

    return LimitProblem(
      expression: expression.trim(),
      approachValue: approachValue,
      variable: variable,
      limitType: limitType,
    );
  }
}
