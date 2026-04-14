// lib/Finals/Joashua/Limits_Infinity/solver/limit_result_type.dart

/// Type of result for the limit
enum LimitResultType {
  finiteValue,     // Limit exists and is a finite number
  positiveInfinity,
  negativeInfinity,
  doesNotExist,    // Limit DNE
  indeterminate,   // Could not determine
}
