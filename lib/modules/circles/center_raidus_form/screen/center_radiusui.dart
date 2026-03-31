import 'package:calculus_system/modules/circles/center_raidus_form/Theme/center_radius_theme.dart';
import 'package:calculus_system/modules/circles/center_raidus_form/controller/center_radius_controller.dart';
import 'package:calculus_system/modules/circles/center_raidus_form/screen/subscreen/input_card.dart';
import 'package:calculus_system/modules/circles/center_raidus_form/screen/subscreen/solution_steps.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FindingCenterRadiusTheme.bgDark,
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
                    if (_controller.hasResult)
                      SolutionSteps(steps: _controller.steps),
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
                color: FindingCenterRadiusTheme.teal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: FindingCenterRadiusTheme.teal.withValues(alpha: 0.3),
                ),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: FindingCenterRadiusTheme.teal,
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
                  FindingCenterRadiusTheme.teal,
                  FindingCenterRadiusTheme.emerald,
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
              const Text(
                'Circle Equations',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: FindingCenterRadiusTheme.textPrimary,
                ),
              ),
              Text(
                'Step-by-step solution',
                style: TextStyle(
                  fontSize: 12,
                  color: FindingCenterRadiusTheme.textSecondary
                      .withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final labels = ['Standard → General', 'General → Standard'];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: FindingCenterRadiusTheme.inputBg,
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
                            FindingCenterRadiusTheme.teal,
                            FindingCenterRadiusTheme.emerald,
                          ],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  labels[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: active
                        ? Colors.white
                        : FindingCenterRadiusTheme.textSecondary
                            .withValues(alpha: 0.5),
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
        formula: '(x - h)² + (y - k)² = r²',
        color: FindingCenterRadiusTheme.teal,
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
      color: FindingCenterRadiusTheme.cyan,
      buttonLabel: 'Find Center-Radius Form',
      onTap: _handleCompute,
    );
  }
}
