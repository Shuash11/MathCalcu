// ignore: file_names
import 'dart:async';
import 'package:calculus_system/modules/y-intercept/Theme/theme.dart';
import 'package:calculus_system/modules/y-intercept/solver/y-intercpet_solver.dart';
import 'package:calculus_system/modules/y-intercept/solver/yi_steps.dart';
import 'package:calculus_system/modules/y-intercept/ui/widgets/slope_intercept.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (context) => StepsBottomSheet(
        steps: steps,
        cardTitle: cardTitle,
        accentColor: accentColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final emeraldColor = YITheme.emerald(context);
    final goldColor = YITheme.gold(context);

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
                    accentColor: const Color(0xFF7EB8F7),
                  );
                },
                onShowGeneralFormSteps: (result) {
                  _openStepsSheet(
                    steps: result.generalFormSteps,
                    cardTitle: 'Convert to General Form (Ax + By + C = 0)',
                    accentColor: const Color(0xFF7EB8F7),
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
          Text('Slope-Intercept Form', style: YITheme.subtitleStyle(context)),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// STEPS BOTTOM SHEET
// ═════════════════════════════════════════════════════════════

class StepsBottomSheet extends StatefulWidget {
  final List<YISolverStep> steps;
  final String cardTitle;
  final Color accentColor;

  const StepsBottomSheet({
    super.key,
    required this.steps,
    required this.cardTitle,
    required this.accentColor,
  });

  @override
  State<StepsBottomSheet> createState() => _StepsBottomSheetState();
}

class _StepsBottomSheetState extends State<StepsBottomSheet> {
  late DraggableScrollableController _dragController;

  @override
  void initState() {
    super.initState();
    _dragController = DraggableScrollableController();
  }

  @override
  void dispose() {
    _dragController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: _dragController,
      initialChildSize: 0.7,
      minChildSize: 0.35,
      maxChildSize: 0.95,
      expand: false,
      snap: true,
      snapSizes: const [0.35, 0.7, 0.95],
      builder: (context, scrollController) =>
          _buildSheetContent(context, scrollController),
    );
  }

  Widget _buildSheetContent(
      BuildContext context, ScrollController scrollController) {
    return Container(
      decoration: BoxDecoration(
        color: YITheme.surface(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: widget.accentColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.accentColor.withValues(alpha: 0.12),
            blurRadius: 32,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView.separated(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              itemCount: widget.steps.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) => StepCard(
                step: widget.steps[index],
                accentColor: widget.accentColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: widget.accentColor.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: widget.accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: widget.accentColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Icon(
                    Icons.receipt_long_rounded,
                    color: widget.accentColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Solution Steps',
                        style:
                            YITheme.titleStyle(context).copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.cardTitle,
                        style: YITheme.inputLabelStyle(context).copyWith(
                          color: widget.accentColor.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: YITheme.textSecondary(context)
                          .withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color:
                          YITheme.textSecondary(context).withValues(alpha: 0.5),
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Divider
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  widget.accentColor.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// STEP CARD  —  renders every field as LaTeX
// ═════════════════════════════════════════════════════════════

class StepCard extends StatelessWidget {
  final YISolverStep step;
  final Color accentColor;

  const StepCard({
    super.key,
    required this.step,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(),
          const SizedBox(height: 12),
          if (step.layout == YIStepLayout.single)
            _buildSingleLayout(context)
          else
            _buildDualLayout(context),
        ],
      ),
    );
  }

  // ── Header row  (circle number + title) ──────────────────

  Widget _buildStepHeader() {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.18),
            shape: BoxShape.circle,
            border: Border.all(
              color: accentColor.withValues(alpha: 0.45),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              '${step.number}',
              style: TextStyle(
                color: accentColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            step.title,
            style: TextStyle(
              color: accentColor.withValues(alpha: 0.9),
              fontWeight: FontWeight.w600,
              fontSize: 13.5,
            ),
          ),
        ),
      ],
    );
  }

  // ── Single layout ─────────────────────────────────────────

  Widget _buildSingleLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Formula chip  (small, grey, monospace-style)
        if (step.formulaLatex.isNotEmpty) ...[
          _FormulaChip(latex: step.formulaLatex, accentColor: accentColor),
          const SizedBox(height: 10),
        ],

        // Substitution text  (medium LaTeX, dim)
        if (step.substitutionLatex.isNotEmpty) ...[
          _LatexLine(
            latex: step.substitutionLatex,
            fontSize: 14,
            color: accentColor.withValues(alpha: 0.55),
          ),
          const SizedBox(height: 10),
        ],

        // Sub-steps  (bullet list, each line rendered as LaTeX)
        if (step.subSteps.isNotEmpty) ...[
          ...step.subSteps.map((sub) => _SubStepLine(
                subStep: sub,
                accentColor: accentColor,
              )),
          const SizedBox(height: 10),
        ],

        // Result box  (prominent, coloured border)
        _ResultBox(
          latex: step.resultLatex,
          accentColor: accentColor,
        ),

        // Explanation hint
        if (step.explanation.isNotEmpty) ...[
          const SizedBox(height: 8),
          _ExplanationText(
            text: step.explanation,
            context: context,
          ),
        ],
      ],
    );
  }

  // ── Dual layout  (side-by-side panels) ───────────────────

  Widget _buildDualLayout(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _DualPanel(
                label: step.leftLabel ?? '',
                latex: step.leftLatex ?? '',
                accentColor: accentColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _DualPanel(
                label: step.rightLabel ?? '',
                latex: step.rightLatex ?? '',
                accentColor: accentColor,
              ),
            ),
          ],
        ),
        // Optionally show the combined result below the panels
        if (step.resultLatex.isNotEmpty) ...[
          const SizedBox(height: 12),
          _ResultBox(latex: step.resultLatex, accentColor: accentColor),
        ],
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════
// SMALL REUSABLE WIDGETS
// ═════════════════════════════════════════════════════════════

/// Grey chip that shows the formula template (e.g. y = mx + b)
class _FormulaChip extends StatelessWidget {
  final String latex;
  final Color accentColor;
  const _FormulaChip({required this.latex, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Math.tex(
        latex,
        textStyle: TextStyle(
          fontSize: 13,
          color: accentColor.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}

/// A single line of LaTeX with configurable size / colour
class _LatexLine extends StatelessWidget {
  final String latex;
  final double fontSize;
  final Color color;
  const _LatexLine({
    required this.latex,
    this.fontSize = 14,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Math.tex(
      latex,
      textStyle: TextStyle(fontSize: fontSize, color: color),
    );
  }
}

/// Highlighted result box with a coloured border
class _ResultBox extends StatelessWidget {
  final String latex;
  final Color accentColor;
  const _ResultBox({required this.latex, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accentColor.withValues(alpha: 0.35)),
      ),
      child: Math.tex(
        latex,
        textStyle: TextStyle(
          fontSize: 16,
          color: accentColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Italic hint text below the result
class _ExplanationText extends StatelessWidget {
  final String text;
  final BuildContext context;
  const _ExplanationText({required this.text, required this.context});

  @override
  Widget build(BuildContext outerContext) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11.5,
        color: YITheme.textSecondary(context).withValues(alpha: 0.45),
        fontStyle: FontStyle.italic,
      ),
    );
  }
}

/// One bullet inside the sub-steps list
class _SubStepLine extends StatelessWidget {
  final YISubStep subStep;
  final Color accentColor;
  const _SubStepLine({required this.subStep, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bullet dot
          Padding(
            padding: const EdgeInsets.only(top: 6, right: 8),
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.55),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Optional italic label
                if (subStep.label.isNotEmpty)
                  Text(
                    subStep.label,
                    style: TextStyle(
                      fontSize: 10.5,
                      color: YITheme.textSecondary(context)
                          .withValues(alpha: 0.45),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                const SizedBox(height: 2),
                // LaTeX body of this sub-step
                Math.tex(
                  subStep.latex,
                  textStyle: TextStyle(
                    fontSize: 14,
                    color:
                        YITheme.textSecondary(context).withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One panel inside a dual-layout step card
class _DualPanel extends StatelessWidget {
  final String label;
  final String latex;
  final Color accentColor;
  const _DualPanel({
    required this.label,
    required this.latex,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Label header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: accentColor.withValues(alpha: 0.85),
              ),
            ),
          ),
          // LaTeX content
          Padding(
            padding: const EdgeInsets.all(12),
            child: SelectableMath.tex(
              latex,
              textStyle: TextStyle(
                fontSize: 16,
                color: accentColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
