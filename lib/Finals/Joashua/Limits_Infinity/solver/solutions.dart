// lib/models/solution.dart

import 'ast_nodes.dart';
import 'limit_result_type.dart';

/// Type of step in the solution
enum StepType {
  initial,           // Starting point
  substitution,      // Direct substitution attempt
  formDetection,     // Detecting indeterminate form
  factoring,         // Factoring the expression
  cancellation,      // Canceling common factors
  rationalization,   // Multiplying by conjugate
  expansion,         // Expanding the expression
  simplification,    // Simplifying the result
  lhopital,          // Applying L'Hôpital's rule
  trigIdentity,      // Using trigonometric identity
  specialLimit,      // Using known special limit
  infinityAnalysis,  // Analyzing behavior at infinity
  leadingTerm,       // Identifying leading term
  conclusion,        // Final answer
  error,             // Error occurred
}

/// A single step in the solution process
class SolutionStep {
  /// Type of this step
  final StepType type;
  
  /// Description of what's happening
  final String description;
  
  /// The expression at this step
  final ASTNode? expression;
  
  /// Optional additional explanation
  final String? explanation;
  
  /// Mathematical formula or identity used
  final String? formula;
  
  const SolutionStep({
    required this.type,
    required this.description,
    this.expression,
    this.explanation,
    this.formula,
  });
  
  @override
  String toString() => description;
  
  /// Convert to a formatted string for display
  String toFormattedString() {
    var buffer = StringBuffer();
    
    // Add step type indicator
    switch (type) {
      case StepType.initial:
        buffer.write('📝 Problem: ');
        break;
      case StepType.substitution:
        buffer.write('🔢 Substitution: ');
        break;
      case StepType.formDetection:
        buffer.write('⚠️ Form Detection: ');
        break;
      case StepType.factoring:
        buffer.write('📐 Factoring: ');
        break;
      case StepType.cancellation:
        buffer.write('✂️ Cancellation: ');
        break;
      case StepType.rationalization:
        buffer.write('🔄 Rationalization: ');
        break;
      case StepType.lhopital:
        buffer.write('📊 L\'Hôpital\'s Rule: ');
        break;
      case StepType.trigIdentity:
        buffer.write('📏 Trigonometric Identity: ');
        break;
      case StepType.specialLimit:
        buffer.write('⭐ Special Limit: ');
        break;
      case StepType.simplification:
        buffer.write('✨ Simplification: ');
        break;
      case StepType.infinityAnalysis:
        buffer.write('🌌 Infinity Analysis: ');
        break;
      case StepType.leadingTerm:
        buffer.write('📌 Leading Term: ');
        break;
      case StepType.conclusion:
        buffer.write('✅ Answer: ');
        break;
      case StepType.error:
        buffer.write('❌ Error: ');
        break;
      default:
        buffer.write('• ');
    }
    
    buffer.write(description);
    
    if (expression != null) {
      buffer.write('\n   = ${expression}');
    }
    
    if (formula != null) {
      buffer.write('\n   Using: $formula');
    }
    
    if (explanation != null) {
      buffer.write('\n   $explanation');
    }
    
    return buffer.toString();
  }
}

/// Type of result for the limit
// LimitResultType enum removed as it is now imported from limit_result_type.dart

/// Complete solution for a limit problem
class LimitSolution {
  /// The original problem
  final String problemNotation;
  
  /// All steps in order
  final List<SolutionStep> steps;
  
  /// The final result value
  final ASTNode? result;
  
  /// Type of result
  final LimitResultType resultType;
  
  /// Number of times L'Hôpital's rule was applied
  final int lhopitalCount;
  
  /// Main method used to solve
  final String methodUsed;
  
  const LimitSolution({
    required this.problemNotation,
    required this.steps,
    this.result,
    required this.resultType,
    this.lhopitalCount = 0,
    this.methodUsed = '',
  });
  
  /// Get the numeric result if available
  double? get numericResult => result?.tryEvaluate();
  
  /// Get result as a string
  String get resultString {
    if (result == null) {
      switch (resultType) {
        case LimitResultType.doesNotExist: return 'DNE';
        case LimitResultType.indeterminate: return 'Indeterminate';
        default: return 'Unknown';
      }
    }
    return result.toString();
  }
  
  /// Get full solution as formatted text
  String get fullSolution {
    var buffer = StringBuffer();
    buffer.writeln('=' * 50);
    buffer.writeln('LIMIT SOLUTION');
    buffer.writeln('=' * 50);
    buffer.writeln();
    buffer.writeln(problemNotation);
    buffer.writeln('-' * 50);
    
    for (var step in steps) {
      buffer.writeln(step.toFormattedString());
      buffer.writeln();
    }
    
    buffer.writeln('=' * 50);
    buffer.writeln('RESULT: $resultString');
    buffer.writeln('Method: $methodUsed');
    if (lhopitalCount > 0) {
      buffer.writeln('L\'Hôpital\'s Rule applied $lhopitalCount time(s)');
    }
    buffer.writeln('=' * 50);
    
    return buffer.toString();
  }
  
  /// Get steps as a list of maps for UI
  List<Map<String, dynamic>> toList() {
    return steps.map((step) => {
      'type': step.type.name,
      'description': step.description,
      'expression': step.expression?.toString(),
      'explanation': step.explanation,
      'formula': step.formula,
    }).toList();
  }
}