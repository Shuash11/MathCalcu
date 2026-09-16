// lib/topics/calculus/midterm/screens/yintercept_screen/parallel_perpendicular/pp_controller.dart

import 'package:calculus_system/topics/calculus/midterm/solvers/yintercept_solver/yi_solver.dart';
import 'package:flutter/material.dart';

/// Manages all mutable state and user-input controllers for the
/// Parallel & Perpendicular screen. Kept separate from the UI so the
/// screen widget stays a "dumb" view.
class PPScreenController extends ChangeNotifier {
  // ── Text controllers ──────────────────────────────────────
  final line1Ctrl = TextEditingController();
  final line2Ctrl = TextEditingController();
  final line1Focus = FocusNode();
  final line2Focus = FocusNode();

  // ── Output state ──────────────────────────────────────────
  PPResult? result;
  String? errorMsg;
  bool hasSolved = false;
  bool showGraph = false;

  // ── Actions ───────────────────────────────────────────────

  /// Parses both equations, calls the solver, and notifies listeners.
  void compute() {
    final l1 = line1Ctrl.text.trim();
    final l2 = line2Ctrl.text.trim();
    if (l1.isEmpty || l2.isEmpty) {
      result = null;
      errorMsg = null;
      hasSolved = false;
      notifyListeners();
      return;
    }
    final parsed = ParallelPerpendicularSolver.tryParse(line1: l1, line2: l2);
    if (parsed == null) {
      result = null;
      errorMsg =
          'Could not parse one or both equations.\nTry: 2x + 3y = 6  or  2x + 3y + 4 = 0';
      hasSolved = false;
      notifyListeners();
      return;
    }
    errorMsg = null;
    result = parsed;
    hasSolved = true;
    showGraph = false;
    notifyListeners();
  }

  /// Resets every field and clears output state.
  void reset() {
    line1Ctrl.clear();
    line2Ctrl.clear();
    result = null;
    errorMsg = null;
    hasSolved = false;
    notifyListeners();
  }

  /// Swaps the two equation fields and recomputes.
  void swap() {
    final temp = line1Ctrl.text;
    line1Ctrl.text = line2Ctrl.text;
    line2Ctrl.text = temp;
    compute();
  }

  void toggleGraph() {
    showGraph = !showGraph;
    notifyListeners();
  }

  @override
  void dispose() {
    line1Ctrl.dispose();
    line2Ctrl.dispose();
    line1Focus.dispose();
    line2Focus.dispose();
    super.dispose();
  }
}
