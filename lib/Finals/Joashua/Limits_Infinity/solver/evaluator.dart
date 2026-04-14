// lib/engine/evaluator.dart

import 'dart:math';

import 'ast_nodes.dart';
import 'limit_result_type.dart';

/// Evaluates expressions numerically with precision handling
class Evaluator {
  final double tolerance;
  
  Evaluator({this.tolerance = 1e-10});
  
  /// Evaluate expression at a specific value
  double? evaluate(ASTNode node, String variable, double value) {
    var substituted = node.substitute(variable, NumberNode(value));
    return substituted.tryEvaluate();
  }
  
  /// Evaluate expression approaching a value from both sides
  EvaluationResult evaluateApproaching(
    ASTNode node,
    String variable,
    double approachValue, {
    double delta = 1e-6,
    int iterations = 20,
  }) {
    var leftResults = <double>[];
    var rightResults = <double>[];
    
    for (var i = 0; i < iterations; i++) {
      var h = delta * pow(0.5, i);
      
      // From left
      var leftVal = evaluate(node, variable, approachValue - h);
      if (leftVal != null && leftVal.isFinite) {
        leftResults.add(leftVal);
      }
      
      // From right
      var rightVal = evaluate(node, variable, approachValue + h);
      if (rightVal != null && rightVal.isFinite) {
        rightResults.add(rightVal);
      }
    }
    
    return EvaluationResult(
      leftResults: leftResults,
      rightResults: rightResults,
      leftLimit: _analyzeSequence(leftResults),
      rightLimit: _analyzeSequence(rightResults),
    );
  }
  
  /// Evaluate expression as variable approaches infinity
  EvaluationResult evaluateAtInfinity(
    ASTNode node,
    String variable, {
    bool negative = false,
    int iterations = 20,
  }) {
    var results = <double>[];
    
    for (var i = 0; i < iterations; i++) {
      var value = pow(10, i + 1).toDouble();
      if (negative) value = -value;
      
      var val = evaluate(node, variable, value);
      if (val != null) {
        results.add(val);
      }
    }
    
    return EvaluationResult(
      leftResults: negative ? results : [],
      rightResults: negative ? [] : results,
      leftLimit: negative ? _analyzeSequence(results) : null,
      rightLimit: negative ? null : _analyzeSequence(results),
    );
  }
  
  LimitAnalysis _analyzeSequence(List<double> values) {
    if (values.isEmpty) return LimitAnalysis.unknown();
    
    // Check if values are converging
    var lastValues = values.length > 5 ? values.sublist(values.length - 5) : values;
    
    // Check for infinity
    bool growingPositively = true;
    bool growingNegatively = true;
    
    for (var i = 1; i < lastValues.length; i++) {
      if (lastValues[i] <= lastValues[i-1]) growingPositively = false;
      if (lastValues[i] >= lastValues[i-1]) growingNegatively = false;
    }
    
    if (growingPositively && lastValues.last > 1e10) {
      return LimitAnalysis.positiveInfinity();
    }
    if (growingNegatively && lastValues.last < -1e10) {
      return LimitAnalysis.negativeInfinity();
    }
    
    // Check for convergence
    var range = lastValues.reduce((a, b) => a > b ? a : b) -
                lastValues.reduce((a, b) => a < b ? a : b);
    
    if (range < tolerance) {
      return LimitAnalysis.finite(lastValues.last);
    }
    
    // Check for oscillation
    var signChanges = 0;
    for (var i = 1; i < lastValues.length; i++) {
      if ((lastValues[i] >= 0) != (lastValues[i-1] >= 0)) {
        signChanges++;
      }
    }
    if (signChanges > 2) {
      return LimitAnalysis.oscillating();
    }
    
    return LimitAnalysis.unknown();
  }
  
  /// Detect indeterminate form
  IndeterminateForm detectForm(ASTNode numerator, ASTNode denominator, double value, String variable) {
    var numVal = evaluate(numerator, variable, value);
    var denVal = evaluate(denominator, variable, value);
    
    if (numVal == null || denVal == null) {
      return IndeterminateForm.unknown;
    }
    
    if (numVal.abs() < tolerance && denVal.abs() < tolerance) {
      return IndeterminateForm.zeroOverZero;
    }
    
    if (numVal.abs() > 1e10 && denVal.abs() > 1e10) {
      return IndeterminateForm.infinityOverInfinity;
    }
    
    if (numVal.abs() < tolerance && denVal.abs() > 1e10) {
      return IndeterminateForm.zeroOverInfinity;
    }
    
    if (numVal.abs() > 1e10 && denVal.abs() < tolerance) {
      return IndeterminateForm.infinityOverZero;
    }
    
    return IndeterminateForm.determinate;
  }
  
  /// Check if expression evaluates to 0
  bool evaluatesToZero(ASTNode node, String variable, double value) {
    var val = evaluate(node, variable, value);
    return val != null && val.abs() < tolerance;
  }
  
  /// Check if expression evaluates to infinity
  bool evaluatesToInfinity(ASTNode node, String variable, double value) {
    var val = evaluate(node, variable, value);
    return val == null || val.abs() > 1e10;
  }
}

enum IndeterminateForm {
  zeroOverZero,
  infinityOverInfinity,
  zeroOverInfinity,
  infinityOverZero,
  determinate,
  unknown,
}

class LimitAnalysis {
  final LimitResultType type;
  final double? value;
  
  const LimitAnalysis._(this.type, this.value);
  
  factory LimitAnalysis.finite(double value) => LimitAnalysis._(LimitResultType.finiteValue, value);
  factory LimitAnalysis.positiveInfinity() => LimitAnalysis._(LimitResultType.positiveInfinity, null);
  factory LimitAnalysis.negativeInfinity() => LimitAnalysis._(LimitResultType.negativeInfinity, null);
  factory LimitAnalysis.oscillating() => LimitAnalysis._(LimitResultType.doesNotExist, null);
  factory LimitAnalysis.unknown() => LimitAnalysis._(LimitResultType.indeterminate, null);
}

class EvaluationResult {
  final List<double> leftResults;
  final List<double> rightResults;
  final LimitAnalysis? leftLimit;
  final LimitAnalysis? rightLimit;
  
  const EvaluationResult({
    required this.leftResults,
    required this.rightResults,
    this.leftLimit,
    this.rightLimit,
  });
  
  bool get limitsMatch {
    if (leftLimit == null || rightLimit == null) return true;
    if (leftLimit!.type != rightLimit!.type) return false;
    if (leftLimit!.type == LimitResultType.finiteValue && 
        rightLimit!.type == LimitResultType.finiteValue) {
      return (leftLimit!.value! - rightLimit!.value!).abs() < 1e-6;
    }
    return true;
  }
}

// LimitResultType enum removed as it is now imported from limit_result_type.dart