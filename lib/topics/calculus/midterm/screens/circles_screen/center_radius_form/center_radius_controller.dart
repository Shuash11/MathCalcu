import 'general_form_parse.dart';
import 'package:calculus_system/topics/calculus/midterm/solvers/circles_solver/center_radius_solver.dart' hide GeneralFormParser;

import 'package:flutter/material.dart';

class CircleEquationController extends ChangeNotifier {
  // â”€â”€ Text controllers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  final hCtrl = TextEditingController();
  final kCtrl = TextEditingController();
  final rCtrl = TextEditingController();

  final equationCtrl = TextEditingController();

  // â”€â”€ State â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  int activeTab = 0;
  List<SolverStep> steps = [];
  bool hasResult = false;
  String? errorMessage;

  // â”€â”€ Tab switching â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void switchTab(int index) {
    activeTab = index;
    steps = [];
    hasResult = false;
    errorMessage = null;
    notifyListeners();
  }

  // â”€â”€ Standard → General â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  bool computeStandardToGeneral() {
    final h = double.tryParse(hCtrl.text);
    final k = double.tryParse(kCtrl.text);
    final r = double.tryParse(rCtrl.text);

    if (h == null || k == null || r == null || r <= 0) {
      errorMessage = 'Please enter valid h, k, and r > 0';
      notifyListeners();
      return false;
    }

    steps = CircleEquationSolver.standardToGeneral(h: h, k: k, r: r);
    hasResult = true;
    errorMessage = null;
    notifyListeners();
    return true;
  }

  // â”€â”€ General → Standard â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  bool computeGeneralToStandard() {
    if (equationCtrl.text.trim().isEmpty) {
      errorMessage = 'Please enter the equation.';
      notifyListeners();
      return false;
    }

    try {
      final parsed = GeneralFormParser.parse(equationCtrl.text.trim());
      final h = -parsed.D / 2;
      final k = -parsed.E / 2;
      final rSq = h * h + k * k - parsed.F;

      if (rSq <= 0) {
        errorMessage = 'No real circle: r² ≠¤ 0 for these values.';
        notifyListeners();
        return false;
      }

      steps = CircleEquationSolver.generalToStandard(
        D: parsed.D,
        E: parsed.E,
        F: parsed.F,
      );
      hasResult = true;
      errorMessage = null;
      notifyListeners();
      return true;
    } on FormatException catch (e) {
      errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }

  // â”€â”€ Dispose â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  @override
  void dispose() {
    hCtrl.dispose();
    kCtrl.dispose();
    rCtrl.dispose();
    equationCtrl.dispose();
    super.dispose();
  }
}
