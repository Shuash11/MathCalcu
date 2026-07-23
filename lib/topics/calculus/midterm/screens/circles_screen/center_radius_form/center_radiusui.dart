import 'package:calculus_system/topics/calculus/finals/finals_theme.dart';
import 'package:calculus_system/shared/widgets/solution_steps_modal.dart';
import 'package:calculus_system/theme/app_design.dart';
import 'package:calculus_system/shared/widgets/responsive_text.dart';
import 'center_radius_controller.dart';
import 'models/field_def.dart';
import 'input_card.dart';
import 'solution_steps.dart';
import 'widgets_inputcard/equation_input_card.dart';
import 'package:flutter/material.dart';

class FindingCenterRadiusScreen extends StatefulWidget {
  const FindingCenterRadiusScreen({super.key});

  @override
  State<FindingCenterRadiusScreen> createState() =>
      _FindingCenterRadiusScreenState();
}

class _FindingCenterRadiusScreenState extends State<FindingCenterRadiusScreen> {
  late final CircleEquationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CircleEquationController();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleCompute() {
    final success = _controller.activeTab == 0
        ? _controller.computeStandardToGeneral()
        : _controller.computeGeneralToStandard();

    if (!success && _controller.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_controller.errorMessage!)),
      );
    }
  }

  void _openStepsModal() {
    if (!_controller.hasResult) return;
    showSolutionStepsModal(
      context: context,
      title: 'Circle Equation \u2014 Step by Step',
      design: AppDesign.app,
      child: SolutionSteps(steps: _controller.steps),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: Column(
                  children: [
                    _buildInputCard(),
                    const SizedBox(height: 28),
                    if (_controller.hasResult) ...[
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _openStepsModal,
                          icon: const Icon(
                            Icons.receipt_long_rounded,
                            size: 14,
                            color: FinalsTheme.primary,
                          ),
                          label: const ResponsiveText(
                            'Show Steps',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: FinalsTheme.primary,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color:
                                  FinalsTheme.primary.withValues(alpha: 0.35),
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
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF334155).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF334155).withValues(alpha: 0.3),
                ),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: const Color(0xFF334155),
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  const Color(0xFF334155),
                  const Color(0xFF334155),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.blur_circular_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ResponsiveText(
                'Circle Equations',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFE8E8F0),
                ),
              ),
              ResponsiveText(
                'Step-by-step solution',
                style: TextStyle(
                  fontSize: 12,
                  color: const Color(0xFF94A3B8).withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final labels = ['Standard ? General', 'General ? Standard'];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF334155),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: List.generate(2, (i) {
          final active = _controller.activeTab == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => _controller.switchTab(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient: active
                      ? const LinearGradient(
                          colors: [
                            const Color(0xFF334155),
                            const Color(0xFF334155),
                          ],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ResponsiveText(
                  labels[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: active
                        ? Colors.white
                        : const Color(0xFF94A3B8).withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildInputCard() {
    if (_controller.activeTab == 0) {
      return InputCard(
        title: 'Enter Center & Radius',
        formula: r'(x - h)^2 + (y - k)^2 = r^2',
        color: const Color(0xFF334155),
        fields: [
          FieldDef(ctrl: _controller.hCtrl, label: 'h', hint: 'x of center'),
          FieldDef(ctrl: _controller.kCtrl, label: 'k', hint: 'y of center'),
          FieldDef(ctrl: _controller.rCtrl, label: 'r', hint: 'radius > 0'),
        ],
        buttonLabel: 'Find General Form',
        onTap: _handleCompute,
      );
    }
    return EquationInputCard(
      ctrl: _controller.equationCtrl,
      color: const Color(0xFF334155),
      buttonLabel: 'Find Center-Radius Form',
      onTap: _handleCompute,
    );
  }
}
