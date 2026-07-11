import 'package:calculus_system/topics/calculus/midterm/theme/circles_theme/radiustheme.dart';
import 'radius_controller.dart';
import 'radius_action_buttons.dart';
import 'radius_error_card.dart';
import 'radius_formula_card.dart';
import 'radius_header.dart';
import 'radius_input_card.dart';
import 'radius_result.dart';
import 'radius_steps.dart';
import 'package:flutter/material.dart';

class FindingRadiusScreen extends StatefulWidget {
  const FindingRadiusScreen({super.key});

  @override
  State<FindingRadiusScreen> createState() => _FindingRadiusScreenState();
}

class _FindingRadiusScreenState extends State<FindingRadiusScreen> {
  late final FindingRadiusController _ctrl;

  final _xFocus = FocusNode();
  final _yFocus = FocusNode();
  final _hFocus = FocusNode();
  final _kFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _ctrl = FindingRadiusController()..addListener(_onStateChanged);
  }

  void _onStateChanged() => setState(() {});

  @override
  void dispose() {
    _ctrl
      ..removeListener(_onStateChanged)
      ..dispose();
    for (final f in [_xFocus, _yFocus, _hFocus, _kFocus]) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FindingRadiusTheme.bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const RadiusHeader(),
              const SizedBox(height: 28),
              const RadiusFormulaCard(),
              const SizedBox(height: 24),

              // Point on circle (x, y)
              RadiusInputCard(
                label: 'Point on the Circle',
                color: FindingRadiusTheme.cyan,
                icon: Icons.circle_outlined,
                leftController: _ctrl.xCtrl,
                leftLabel: 'x',
                leftHint: 'e.g. −2',
                rightController: _ctrl.yCtrl,
                rightLabel: 'y',
                rightHint: 'e.g. 3',
                leftFocusNode: _xFocus,
                rightFocusNode: _yFocus,
                leftTextInputAction: TextInputAction.next,
                leftOnEditingComplete: () => _yFocus.requestFocus(),
                rightTextInputAction: TextInputAction.next,
                rightOnEditingComplete: () => _hFocus.requestFocus(),
              ),
              const SizedBox(height: 16),

              // Center (h, k)
              RadiusInputCard(
                label: 'Center of the Circle',
                color: FindingRadiusTheme.indigo,
                icon: Icons.adjust_rounded,
                leftController: _ctrl.hCtrl,
                leftLabel: 'h',
                leftHint: 'e.g. 1',
                rightController: _ctrl.kCtrl,
                rightLabel: 'k',
                rightHint: 'e.g. 4',
                leftFocusNode: _hFocus,
                rightFocusNode: _kFocus,
                leftTextInputAction: TextInputAction.next,
                leftOnEditingComplete: () => _kFocus.requestFocus(),
                rightTextInputAction: TextInputAction.done,
                rightOnEditingComplete: () => _kFocus.unfocus(),
              ),
              const SizedBox(height: 32),

              RadiusActionButtons(
                onClear: _ctrl.clear,
                onCalculate: _ctrl.calculate,
              ),

              if (_ctrl.errorMsg != null) ...[
                const SizedBox(height: 16),
                RadiusErrorCard(message: _ctrl.errorMsg!),
              ],

              if (_ctrl.result != null) ...[
                const SizedBox(height: 24),
                RadiusStepsCard(steps: _ctrl.result!.steps),
                const SizedBox(height: 16),
                RadiusResultCard(
                    formattedRadius: _ctrl.result!.formattedRadius),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
