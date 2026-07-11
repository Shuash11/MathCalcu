import 'package:calculus_system/topics/calculus/midterm/solvers/two_point_slope_solver/two_point_slope_solver.dart';
import 'package:flutter/material.dart';

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// CONTROLLER
// Manages input state, validation, and result.
// Extend ChangeNotifier so any widget can listen with Provider
// or ValueListenableBuilder.
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

enum SolveState { idle, solved, error }

class TwoPointSlopeController extends ChangeNotifier {
  // â”€â”€ Text controllers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  final TextEditingController x1Controller = TextEditingController();
  final TextEditingController y1Controller = TextEditingController();
  final TextEditingController x2Controller = TextEditingController();
  final TextEditingController y2Controller = TextEditingController();

  // â”€â”€ Form key â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // â”€â”€ State â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  SolveState _state = SolveState.idle;
  TwoPointSlopeResult? _result;
  String? _errorMessage;

  // â”€â”€ Getters â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  SolveState get state => _state;
  TwoPointSlopeResult? get result => _result;
  String? get errorMessage => _errorMessage;
  bool get hasSolved => _state == SolveState.solved;

  // â”€â”€ Solve â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  void solve() {
    if (!formKey.currentState!.validate()) return;

    try {
      final x1 = double.parse(x1Controller.text.trim());
      final y1 = double.parse(y1Controller.text.trim());
      final x2 = double.parse(x2Controller.text.trim());
      final y2 = double.parse(y2Controller.text.trim());

      _result = TwoPointSlopeSolver.solve(
        x1: x1,
        y1: y1,
        x2: x2,
        y2: y2,
      );
      _state = SolveState.solved;
      _errorMessage = null;
    } catch (e) {
      _state = SolveState.error;
      _errorMessage = 'Something went wrong. Check your inputs.';
    }

    notifyListeners();
  }

  // â”€â”€ Reset â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  void reset() {
    x1Controller.clear();
    y1Controller.clear();
    x2Controller.clear();
    y2Controller.clear();
    _state = SolveState.idle;
    _result = null;
    _errorMessage = null;
    formKey.currentState?.reset();
    notifyListeners();
  }

  // â”€â”€ Swap points â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  void swapPoints() {
    final tempX = x1Controller.text;
    final tempY = y1Controller.text;
    x1Controller.text = x2Controller.text;
    y1Controller.text = y2Controller.text;
    x2Controller.text = tempX;
    y2Controller.text = tempY;

    // Re-solve if we already have a result (result stays same, just cosmetic)
    if (_state == SolveState.solved) solve();
    notifyListeners();
  }

  // â”€â”€ Validator â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  String? validateNumber(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    if (double.tryParse(value.trim()) == null) return 'Enter a valid number';
    return null;
  }

  // â”€â”€ Quick fill (example data) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  void fillExample() {
    x1Controller.text = '2';
    y1Controller.text = '3';
    x2Controller.text = '6';
    y2Controller.text = '11';
    notifyListeners();
  }

  @override
  void dispose() {
    x1Controller.dispose();
    y1Controller.dispose();
    x2Controller.dispose();
    y2Controller.dispose();
    super.dispose();
  }
}
