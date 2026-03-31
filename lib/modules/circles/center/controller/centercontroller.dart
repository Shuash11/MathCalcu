// lib/Controller/center_controller.dart
import 'package:calculus_system/modules/circles/center/solver/centersolver.dart';
import 'package:flutter/material.dart';

/// Holds all mutable state for the Finding-Center screen.
/// Pass this into sub-widgets so they stay stateless / dumb.
class CenterController extends ChangeNotifier {
  final x1Ctrl = TextEditingController();
  final y1Ctrl = TextEditingController();
  final x2Ctrl = TextEditingController();
  final y2Ctrl = TextEditingController();

  CenterResult? result;
  String? errorMsg;

  // ── Public API ────────────────────────────────────────────

  void calculate() {
    final x1 = CenterSolver.parse(x1Ctrl.text);
    final y1 = CenterSolver.parse(y1Ctrl.text);
    final x2 = CenterSolver.parse(x2Ctrl.text);
    final y2 = CenterSolver.parse(y2Ctrl.text);

    if (x1 == null || y1 == null || x2 == null || y2 == null) {
      result = null;
      errorMsg = 'Please fill in all four fields correctly.';
      notifyListeners();
      return;
    }

    errorMsg = null;
    result = CenterSolver.compute(x1: x1, y1: y1, x2: x2, y2: y2);
    notifyListeners();
  }

  void clear() {
    x1Ctrl.clear();
    y1Ctrl.clear();
    x2Ctrl.clear();
    y2Ctrl.clear();
    result = null;
    errorMsg = null;
    notifyListeners();
  }

  @override
  void dispose() {
    x1Ctrl.dispose();
    y1Ctrl.dispose();
    x2Ctrl.dispose();
    y2Ctrl.dispose();
    super.dispose();
  }
}
