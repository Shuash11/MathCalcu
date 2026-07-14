// ignore: file_names
import 'dart:async';
import 'package:calculus_system/topics/calculus/midterm/theme/yintercept_theme/theme.dart';
import 'package:calculus_system/topics/calculus/midterm/solvers/yintercept_solver/yi_solver.dart';
import 'package:calculus_system/topics/calculus/midterm/solvers/yintercept_solver/yi_steps.dart';
import 'package:calculus_system/shared/widgets/solution_steps_modal.dart';
import 'package:calculus_system/shared/widgets/responsive_text.dart';
import 'slope_intercept.dart';
import 'slope_intercept_steps.dart';
import 'package:flutter/material.dart';

enum InputMode { slopeIntercept, standardForm }

class YInterceptScreen extends StatefulWidget {
  const YInterceptScreen({super.key});

  @override
  State<YInterceptScreen> createState() => _YInterceptScreenState();
}

class _YInterceptScreenState extends State<YInterceptScreen>
    with SingleTickerProviderStateMixin {
  final _mCtrl = TextEditingController();
  final _bCtrl = TextEditingController();
  final _sfCtrl = TextEditingController();

  final _mFocus = FocusNode();
  final _bFocus = FocusNode();
  final _sfFocus = FocusNode();

  InputMode _mode = InputMode.slopeIntercept;
  final _resultNotifier = ValueNotifier<YIResult?>(null);
  final _errorNotifier = ValueNotifier<String?>(null);
  Timer? _debounce;

  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _mCtrl.addListener(_onChanged);
    _bCtrl.addListener(_onChanged);
    _sfCtrl.addListener(_onChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _pulseCtrl.dispose();
    for (final c in [_mCtrl, _bCtrl, _sfCtrl]) {
      c.removeListener(_onChanged);
      c.dispose();
    }
    for (final f in [_mFocus, _bFocus, _sfFocus]) {
      f.dispose();
    }
    _resultNotifier.dispose();
    _errorNotifier.dispose();
    super.dispose();
  }

  void _onChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), _compute);
  }

  void _switchMode(InputMode mode) {
    if (_mode == mode) return;
    setState(() {
      _mode = mode;
      _resultNotifier.value = null;
      _errorNotifier.value = null;
    });
  }

  void _compute() {
    if (_mode == InputMode.slopeIntercept) {
      final mText = _mCtrl.text.trim();
      final bText = _bCtrl.text.trim();
      if (mText.isEmpty || bText.isEmpty) {
        _resultNotifier.value = null;
        _errorNotifier.value = null;
        return;
      }
      final r = YInterceptSolver.tryParseSlopeIntercept(
        mText: mText,
        bText: bText,
      );
      if (r == null) {
        _errorNotifier.value =
            'Invalid input — use numbers or fractions like 3/4';
        _resultNotifier.value = null;
      } else {
        _errorNotifier.value = null;
        _resultNotifier.value = r;
      }
    } else {
      final text = _sfCtrl.text.trim();
      if (text.isEmpty) {
        _resultNotifier.value = null;
        _errorNotifier.value = null;
        return;
      }
      final r = YInterceptSolver.tryParseAny(text);
      if (r == null) {
        _errorNotifier.value =
            'Invalid format — try  6x - 3y = -3  or  3y - 6x = -3  or  -6x + 3y + 3 = 0';
        _resultNotifier.value = null;
      } else {
        _errorNotifier.value = null;
        _resultNotifier.value = r;
      }
    }
  }

  void _openStepsSheet({
    required List<YISolverStep> steps,
    required String cardTitle,
    required Color accentColor,
  }) {
    if (!mounted) return;
    if (steps.isEmpty) return;
    showSolutionStepsModal(
      context: context,
      title: cardTitle,
      accentColor: accentColor,
      child: YInterceptSteps(steps: steps, accentColor: accentColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final emeraldColor = YITheme.emerald(context);
    final goldColor = YITheme.gold(context);
    const blueColor = Color(0xFF7EB8F7);

    return Scaffold(
      backgroundColor: YITheme.surface(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            Expanded(
              child: YInterceptTab(
                mCtrl: _mCtrl,
                bCtrl: _bCtrl,
                sfCtrl: _sfCtrl,
                mFocus: _mFocus,
                bFocus: _bFocus,
                sfFocus: _sfFocus,
                mode: _mode,
                onSwitchMode: _switchMode,
                resultNotifier: _resultNotifier,
                errorNotifier: _errorNotifier,
                pulseAnim: _pulseAnim,
                emeraldColor: emeraldColor,
                goldColor: goldColor,
                onShowSlopeSteps: (result) {
                  final steps = result.inputType == YIInputType.generalForm
                      ? result.slopeStepsFromGeneral
                      : result.slopeStepsFromStandard;
                  _openStepsSheet(
                    steps: steps,
                    cardTitle: 'Slope-Intercept Form (y = mx + b)',
                    accentColor: emeraldColor,
                  );
                },
                onShowStandardFormSteps: (result) {
                  _openStepsSheet(
                    steps: result.standardFormSteps,
                    cardTitle: 'Convert to Standard Form (Ax + By = C)',
                    accentColor: blueColor,
                  );
                },
                onShowGeneralFormSteps: (result) {
                  _openStepsSheet(
                    steps: result.generalFormSteps,
                    cardTitle: 'Convert to General Form (Ax + By + C = 0)',
                    accentColor: blueColor,
                  );
                },
                onShowXInterceptSteps: (result) {
                  _openStepsSheet(
                    steps: result.xInterceptSteps,
                    cardTitle: 'Finding the X-Intercept',
                    accentColor: goldColor,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: YITheme.emerald(context).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: YITheme.emerald(context).withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: YITheme.emerald(context),
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          ResponsiveText('Slope-Intercept Form', style: YITheme.subtitleStyle(context)),
        ],
      ),
    );
  }
}
