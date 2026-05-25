// lib/Screens/center_screen.dart
// Thin shell — owns the controller lifecycle, renders sub-screens.

import 'package:calculus_system/shared/widgets/math_keyboard.dart';
import 'package:flutter/material.dart';
import 'centercontroller.dart';
import 'package:calculus_system/midterm/theme/circles_theme/centertheme.dart';
import 'header_bar.dart';
import 'formula_card.dart';
import 'input_section.dart';
import 'step_section.dart';
import 'result_section.dart';
import 'error_section.dart';

class FindingCenterScreen extends StatefulWidget {
  const FindingCenterScreen({super.key});

  @override
  State<FindingCenterScreen> createState() => _FindingCenterScreenState();
}

class _FindingCenterScreenState extends State<FindingCenterScreen> {
  // Controller lives here so it's disposed with the screen.
  final _controller = CenterController();
  final _x1Focus = FocusNode();
  final _y1Focus = FocusNode();
  final _x2Focus = FocusNode();
  final _y2Focus = FocusNode();
  TextEditingController? _activeController;
  final _hideKeyboardSignal = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    // Rebuild whenever the controller notifies (after calculate / clear).
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _x1Focus.dispose();
    _y1Focus.dispose();
    _x2Focus.dispose();
    _y2Focus.dispose();
    _hideKeyboardSignal.dispose();
    super.dispose();
  }

  void _onFieldFocus(TextEditingController ctrl, FocusNode node) {
    node.requestFocus();
    setState(() => _activeController = ctrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FindingCenterTheme.bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ────────────────────────────────────
              const CenterHeaderBar(),
              const SizedBox(height: 28),

              // ── Formula reference ─────────────────────────
              const CenterFormulaCard(),
              const SizedBox(height: 24),

              // ── Inputs + buttons ──────────────────────────
              CenterInputSection(
                controller: _controller,
                x1Focus: _x1Focus,
                y1Focus: _y1Focus,
                x2Focus: _x2Focus,
                y2Focus: _y2Focus,
                onFieldFocus: _onFieldFocus,
                onCalculate: () {
                  _hideKeyboardSignal.value++;
                  _controller.calculate();
                },
              ),

              const SizedBox(height: 20),
              MathKeyboard(
                controller: _activeController ?? _controller.x1Ctrl,
                accentColor: FindingCenterTheme.indigo,
                hideSignal: _hideKeyboardSignal,
              ),
              const SizedBox(height: 24),

              // ── Error (null → hidden) ─────────────────────
              if (_controller.errorMsg != null) ...[
                const SizedBox(height: 16),
                CenterErrorSection(errorMsg: _controller.errorMsg),
              ],

              // ── Steps + result (null → hidden) ────────────
              if (_controller.result != null) ...[
                const SizedBox(height: 24),
                CenterStepsSection(steps: _controller.result!.steps),
                const SizedBox(height: 16),
                CenterResultSection(result: _controller.result),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
