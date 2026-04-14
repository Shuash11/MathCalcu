// lib/models/limit_problem.dart

import 'ast_nodes.dart';

/// Represents the type of limit to evaluate
enum LimitType {
  finitePoint,    // lim(x → a) where a is finite
  positiveInfinity, // lim(x → ∞)
  negativeInfinity, // lim(x → -∞)
}

/// Represents one-sided limit direction
enum LimitDirection {
  both,       // Two-sided limit
  fromRight,  // x → a⁺
  fromLeft,   // x → a⁻
}

/// Input model for a limit problem
class LimitProblem {
  /// The expression to evaluate
  final String expression;
  
  /// The variable name (default 'x')
  final String variable;
  
  /// Type of limit
  final LimitType limitType;
  
  /// The finite value to approach (used when limitType is finitePoint)
  final double? approachingValue;
  
  /// Direction of the limit
  final LimitDirection direction;
  
  const LimitProblem({
    required this.expression,
    this.variable = 'x',
    required this.limitType,
    this.approachingValue,
    this.direction = LimitDirection.both,
  });
  
  /// Parse the approaching value as an AST node
  ASTNode get approachingNode {
    switch (limitType) {
      case LimitType.finitePoint:
        return NumberNode(approachingValue ?? 0);
      case LimitType.positiveInfinity:
        return InfinityNode(false);
      case LimitType.negativeInfinity:
        return InfinityNode(true);
    }
  }
  
  /// Get string representation of the limit point
  String get limitPointString {
    switch (limitType) {
      case LimitType.finitePoint:
        var val = approachingValue;
        if (val != null && val == val.truncateToDouble()) return val.toInt().toString();
        return val.toString();
      case LimitType.positiveInfinity:
        return '∞';
      case LimitType.negativeInfinity:
        return '-∞';
    }
  }
  
  /// Get direction symbol
  String get directionSymbol {
    switch (direction) {
      case LimitDirection.both: return '';
      case LimitDirection.fromRight: return '⁺';
      case LimitDirection.fromLeft: return '⁻';
    }
  }
  
  /// Full limit notation
  String get fullNotation {
    return 'lim($variable → $limitPointString$directionSymbol) $expression';
  }
  
  /// Create from a simple notation string like "x->3" or "x->inf"
  factory LimitProblem.fromNotation({
    required String expression,
    required String approach,
    String variable = 'x',
    LimitDirection direction = LimitDirection.both,
  }) {
    var normalized = approach.replaceAll(' ', '').toLowerCase();
    
    LimitType type;
    double? value;
    
    if (normalized == '∞' || normalized == 'inf' || normalized == '+∞' || normalized == '+inf') {
      type = LimitType.positiveInfinity;
    } else if (normalized == '-∞' || normalized == '-inf') {
      type = LimitType.negativeInfinity;
    } else {
      type = LimitType.finitePoint;
      value = double.tryParse(normalized);
    }
    
    return LimitProblem(
      expression: expression,
      variable: variable,
      limitType: type,
      approachingValue: value,
      direction: direction,
    );
  }
}