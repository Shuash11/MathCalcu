// lib/Controller/center_controller.dart

import 'package:calculus_system/modules/circles/center/solver/centersolver.dart';
import 'package:flutter/material.dart';

class CenterController extends ChangeNotifier {
  final x1Ctrl = TextEditingController();
  final y1Ctrl = TextEditingController();
  final x2Ctrl = TextEditingController();
  final y2Ctrl = TextEditingController();

  CenterResult? result;
  String? errorMsg;

  void calculate() {
    // Check if any field is empty first
    if (x1Ctrl.text.trim().isEmpty ||
        y1Ctrl.text.trim().isEmpty ||
        x2Ctrl.text.trim().isEmpty ||
        y2Ctrl.text.trim().isEmpty) {
      result = null;
      errorMsg = 'Please fill in all fields';

      notifyListeners();
      return;
    }

    final computed = CenterSolver.computeExact(
      x1: x1Ctrl.text,
      y1: y1Ctrl.text,
      x2: x2Ctrl.text,
      y2: y2Ctrl.text,
    );

    if (computed == null) {
      result = null;
      errorMsg =
          'Invalid input. Check that all numbers are valid (e.g., 2, 3.5, 1/2)';
      notifyListeners();
      return;
    }

    result = computed;
    errorMsg = null;
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
