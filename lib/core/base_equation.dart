// ─────────────────────────────────────────────────────────────
// BASE EQUATION — abstract contract
// ALL developer equation classes must extend this.
// Do NOT change method signatures without team approval.
// ─────────────────────────────────────────────────────────────

import 'step_model.dart';
import 'solve_result.dart';

abstract class BaseEquation {
  /// The raw string the user typed in the input field.
  String get rawInput;

  /// Validates the expression before solving.
  /// Return false to show an error state in the UI.
  bool validate();

  /// Core solve logic. Each subtype implements its own.
  SolveResult solve();

  /// Returns ordered steps for the StepsDrawer.
  List<StepModel> getSteps();
}
