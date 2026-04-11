// lib/Screens/center_screen.dart
// Thin shell — owns the controller lifecycle, renders sub-screens.

import 'package:flutter/material.dart';
import 'package:calculus_system/modules/circles/center/controller/centercontroller.dart';
import 'package:calculus_system/modules/circles/center/Theme/centertheme.dart';
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

  @override
  void initState() {
    super.initState();
    // Rebuild whenever the controller notifies (after calculate / clear).
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
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
              // ── Header ────────────────────────────────────
              const CenterHeaderBar(),
              const SizedBox(height: 28),

              // ── Formula reference ─────────────────────────
              const CenterFormulaCard(),
              const SizedBox(height: 24),

              // ── Inputs + buttons ──────────────────────────
              CenterInputSection(controller: _controller),

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
