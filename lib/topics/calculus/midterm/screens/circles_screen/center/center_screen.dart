// lib/Screens/center_screen.dart
// Thin shell â€” owns the controller lifecycle, renders sub-screens.

import 'package:flutter/material.dart';
import 'centercontroller.dart';
import 'package:calculus_system/topics/calculus/midterm/theme/circles_theme/centertheme.dart';
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
    super.dispose();
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
              // â”€â”€ Header â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              const CenterHeaderBar(),
              const SizedBox(height: 28),

              // â”€â”€ Formula reference â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              const CenterFormulaCard(),
              const SizedBox(height: 24),

              // â”€â”€ Inputs + buttons â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              CenterInputSection(
                controller: _controller,
                x1Focus: _x1Focus,
                y1Focus: _y1Focus,
                x2Focus: _x2Focus,
                y2Focus: _y2Focus,
                onCalculate: _controller.calculate,
              ),

              const SizedBox(height: 24),

              // â”€â”€ Error (null → hidden) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              if (_controller.errorMsg != null) ...[
                const SizedBox(height: 16),
                CenterErrorSection(errorMsg: _controller.errorMsg),
              ],

              // â”€â”€ Steps + result (null → hidden) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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
