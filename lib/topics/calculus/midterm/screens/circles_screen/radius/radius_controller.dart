import 'package:calculus_system/topics/calculus/midterm/solvers/circles_solver/radius_solver.dart';
import 'package:flutter/material.dart';


/// Manages all mutable state and user-input controllers for the
/// Finding-Radius screen.  Kept separate from the UI so the screen
/// widget stays a "dumb" view.
class FindingRadiusController extends ChangeNotifier {
  // â”€â”€ Text controllers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  final xCtrl = TextEditingController(); // point on circle â€“ x
  final yCtrl = TextEditingController(); // point on circle â€“ y
  final hCtrl = TextEditingController(); // center â€“ h
  final kCtrl = TextEditingController(); // center â€“ k

  // â”€â”€ Output state â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  RadiusResult? result;
  String?       errorMsg;

  // â”€â”€ Actions â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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
