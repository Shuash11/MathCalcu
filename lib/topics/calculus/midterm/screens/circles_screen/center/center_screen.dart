// lib/Screens/center_screen.dart
// Thin shell — owns the controller lifecycle, renders sub-screens.

import 'package:flutter/material.dart';
import 'package:calculus_system/topics/calculus/finals/finals_theme.dart';
import 'package:calculus_system/shared/widgets/solution_steps_modal.dart';
import 'package:calculus_system/theme/app_design.dart';
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

  void _openStepsModal() {
    if (_controller.result == null) return;
    showSolutionStepsModal(
      context: context,
      title: 'Center \u2014 Step by Step',
      design: AppDesign.calculus,
      child: CenterStepsSection(steps: _controller.result!.steps),
    );
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
                onCalculate: _controller.calculate,
              ),

              const SizedBox(height: 24),

              // ── Error (null → hidden) ─────────────────────
              if (_controller.errorMsg != null) ...[
                const SizedBox(height: 16),
                CenterErrorSection(errorMsg: _controller.errorMsg),
              ],

              // ── Steps button + result (null → hidden) ──────
              if (_controller.result != null) ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _openStepsModal,
                    icon: const Icon(
                      Icons.receipt_long_rounded,
                      size: 14,
                      color: FinalsTheme.primary,
                    ),
                    label: const Text(
                      'Show Steps',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: FinalsTheme.primary,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: FinalsTheme.primary.withValues(alpha: 0.35),
                      ),
                      backgroundColor:
                          FinalsTheme.primary.withValues(alpha: 0.08),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
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
