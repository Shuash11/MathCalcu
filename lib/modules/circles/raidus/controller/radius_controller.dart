import 'package:calculus_system/modules/circles/raidus/solver/radius_solver.dart';
import 'package:flutter/material.dart';


/// Manages all mutable state and user-input controllers for the
/// Finding-Radius screen.  Kept separate from the UI so the screen
/// widget stays a "dumb" view.
class FindingRadiusController extends ChangeNotifier {
  // ── Text controllers ──────────────────────────────────────
  final xCtrl = TextEditingController(); // point on circle – x
  final yCtrl = TextEditingController(); // point on circle – y
  final hCtrl = TextEditingController(); // center – h
  final kCtrl = TextEditingController(); // center – k

  // ── Output state ──────────────────────────────────────────
  RadiusResult? result;
  String?       errorMsg;

  // ── Actions ───────────────────────────────────────────────

  /// Parses inputs, calls the solver, and notifies listeners.
void calculate() {
  final inputs = [xCtrl.text, yCtrl.text, hCtrl.text, kCtrl.text];
  if (inputs.any((s) => s.trim().isEmpty)) {
    result   = null;
    errorMsg = 'Please fill in all four fields.';
    notifyListeners();
    return;
  }

  try {
    result   = RadiusSolver.solveFromStrings(
      x: xCtrl.text,
      y: yCtrl.text,
      h: hCtrl.text,
      k: kCtrl.text,
    );
    errorMsg = null;
  } on ArgumentError catch (e) {
    result   = null;
    errorMsg = e.message.toString();
  }

  notifyListeners();
}
  /// Resets every field and clears output state.
  void clear() {
    xCtrl.clear();
    yCtrl.clear();
    hCtrl.clear();
    kCtrl.clear();
    result   = null;
    errorMsg = null;
    notifyListeners();
  }

  @override
  void dispose() {
    xCtrl.dispose();
    yCtrl.dispose();
    hCtrl.dispose();
    kCtrl.dispose();
    super.dispose();
  }
}