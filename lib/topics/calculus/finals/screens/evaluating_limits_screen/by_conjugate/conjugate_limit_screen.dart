import 'package:calculus_system/topics/calculus/finals/solvers/evaluating_limits_solver/by_conjugate/solver_engine.dart';
import 'package:calculus_system/topics/calculus/finals/solvers/evaluating_limits_solver/by_conjugate/solution_steps.dart';
import 'package:calculus_system/shared/widgets/solution_steps_modal.dart';
import 'package:calculus_system/theme/app_design.dart';
import 'conjugate_answer_card.dart';
import 'conjugate_input_field.dart';
import 'conjugate_steps_view.dart';
import 'package:calculus_system/topics/calculus/finals/finals_theme.dart';
import 'package:calculus_system/shared/widgets/math_keyboard.dart';
import 'package:flutter/material.dart';
import 'package:calculus_system/shared/widgets/responsive_text.dart';

class ConjugateLimitScreen extends StatelessWidget {
  const ConjugateLimitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isCompact = screenWidth < 380;
        final isMedium = screenWidth >= 380 && screenWidth < 600;

        return _ConjugateLimitScreenContent(
          isCompact: isCompact,
          isMedium: isMedium,
        );
      },
    );
  }
}

class _ConjugateLimitScreenContent extends StatefulWidget {
  final bool isCompact;
  final bool isMedium;

  const _ConjugateLimitScreenContent({
    required this.isCompact,
    required this.isMedium,
  });

  @override
  State<_ConjugateLimitScreenContent> createState() =>
      _ConjugateLimitScreenContentState();
}

class _ConjugateLimitScreenContentState
    extends State<_ConjugateLimitScreenContent> with TickerProviderStateMixin {
  final TextEditingController _expressionController = TextEditingController();
  final TextEditingController _approachController = TextEditingController();
  final _expressionFocus = FocusNode();
  final _approachFocus = FocusNode();
  TextEditingController? _activeController;
  final _hideKeyboardSignal = ValueNotifier<int>(0);
  String _currentVariable = 'x';

  ConjugateResult? _result;
  List<ConjugateStep> _steps = [];
  bool _isSolving = false;

  late final AnimationController _contentController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim =
        CurvedAnimation(parent: _contentController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _contentController, curve: Curves.easeOutCubic));

    _contentController.forward();
    _expressionFocus.addListener(_onExpressionFocusChange);
    _approachFocus.addListener(_onApproachFocusChange);
  }

  @override
  void dispose() {
    _expressionFocus.removeListener(_onExpressionFocusChange);
    _approachFocus.removeListener(_onApproachFocusChange);
    _expressionController.dispose();
    _approachController.dispose();
    _expressionFocus.dispose();
    _approachFocus.dispose();
    _hideKeyboardSignal.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _onExpressionFocusChange() {
    if (_expressionFocus.hasFocus) {
      setState(() => _activeController = _expressionController);
    }
  }

  void _onApproachFocusChange() {
    if (_approachFocus.hasFocus) {
      setState(() => _activeController = _approachController);
    }
  }

  void _solve() {
    _hideKeyboardSignal.value++;
    if (_expressionController.text.isEmpty ||
        _approachController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Please enter both an expression and an approach value.'),
          backgroundColor: FinalsTheme.danger,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() {
      _isSolving = true;
    });

    double approachVal = 0;
    try {
      approachVal =
          double.parse(_approachController.text.replaceAll('inf', 'Infinity'));
    } catch (e) {
      approachVal = 0;
    }

    try {
      final engine = ConjugateSolverEngine();
      final result = engine.solve(ConjugateProblem(
        expression: _expressionController.text,
        approachValue: approachVal,
        variable: _currentVariable,
      ));

      final stepsGen = ConjugateStepsGenerator();
      final steps = stepsGen.generate(result);

      setState(() {
        _result = result;
        _steps = steps;
        _isSolving = false;
      });
    } catch (e) {
      setState(() {
        _isSolving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: FinalsTheme.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = widget.isCompact;
    final isMedium = widget.isMedium;

    final screenPaddingH = isCompact ? 16.0 : (isMedium ? 20.0 : 24.0);
    final screenPaddingBottom = isCompact ? 24.0 : (isMedium ? 32.0 : 40.0);
    final headerPaddingH = isCompact ? 16.0 : (isMedium ? 20.0 : 24.0);
    final headerTitleFontSize = isCompact ? 20.0 : (isMedium ? 22.0 : 24.0);
    final headerBackSpacing = isCompact ? 12.0 : (isMedium ? 16.0 : 20.0);
    final headerBadgePaddingH = isCompact ? 8.0 : (isMedium ? 10.0 : 12.0);
    final headerBadgePaddingV = isCompact ? 4.0 : (isMedium ? 5.0 : 6.0);
    final headerBadgeIconSize = isCompact ? 12.0 : (isMedium ? 13.0 : 14.0);
    final headerBadgeFontSize = isCompact ? 9.0 : (isMedium ? 9.5 : 10.0);
    final headerBackPadding = isCompact ? 10.0 : (isMedium ? 11.0 : 12.0);

    return ColoredBox(
      color: FinalsTheme.surface(context),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context,
                headerPaddingH: headerPaddingH,
                titleFontSize: headerTitleFontSize,
                backSpacing: headerBackSpacing,
                badgePaddingH: headerBadgePaddingH,
                badgePaddingV: headerBadgePaddingV,
                backPadding: headerBackPadding,
                badgeIconSize: headerBadgeIconSize,
                badgeFontSize: headerBadgeFontSize),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                        screenPaddingH, 8, screenPaddingH, screenPaddingBottom),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ConjugateInputField(
                          expressionFocus: _expressionFocus,
                          approachFocus: _approachFocus,
                          expressionController: _expressionController,
                          approachController: _approachController,
                          currentVariable: _currentVariable,
                          onVariableChanged: (v) =>
                              setState(() => _currentVariable = v),
                          onSolve: _solve,
                          isLoading: _isSolving,
                        ),
                        if (_result != null && !_isSolving) ...[
                          SizedBox(height: isCompact ? 16.0 : 24.0),
                          ConjugateAnswerCard(
                            problemNotation:
                                'lim($_currentVariable ? ${_approachController.text}) ${_expressionController.text}',
                            resultString: _result!.resultString,
                            method: 'By Conjugate',
                            isShowingSteps: false,
                            hasError: !_result!.solved &&
                                _result!.errorMessage != null,
                            errorMessage: _result!.errorMessage,
                            onTap: () => showSolutionStepsModal(
                              context: context,
                              title: 'Solution Steps',
                              design: AppDesign.app,
                              child: ConjugateStepsView(steps: _steps),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            MathKeyboard(
              controller: _activeController ?? _expressionController,
              accentColor: FinalsTheme.secondaryFor(context),
              hideSignal: _hideKeyboardSignal,
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context,
      {double headerPaddingH = 24,
      double titleFontSize = 24,
      double backSpacing = 20,
      double badgePaddingH = 12,
      double badgePaddingV = 6,
      double backPadding = 12,
      double badgeIconSize = 14,
      double badgeFontSize = 10}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(headerPaddingH, 24, headerPaddingH, 16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            style: IconButton.styleFrom(
              backgroundColor: FinalsTheme.card(context),
              foregroundColor: FinalsTheme.textPrimary(context),
              padding: EdgeInsets.all(backPadding),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              side: BorderSide(
                  color:
                      FinalsTheme.secondaryFor(context).withValues(alpha: 0.1)),
            ),
          ),
          SizedBox(width: backSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ResponsiveText(
                  '',
                  style: FinalsTheme.titleStyle(context)
                      .copyWith(fontSize: titleFontSize),
                ),
                ResponsiveText(
                  '',
                  style: FinalsTheme.subtitleStyle(context),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: badgePaddingH, vertical: badgePaddingV),
            decoration: BoxDecoration(
              color: FinalsTheme.secondaryFor(context).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color:
                      FinalsTheme.secondaryFor(context).withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.unfold_more_double_rounded,
                    size: badgeIconSize,
                    color: FinalsTheme.secondaryFor(context)),
                SizedBox(width: badgePaddingH * 0.5),
                ResponsiveText(
                  '',
                  style: TextStyle(
                    color: FinalsTheme.secondaryFor(context),
                    fontWeight: FontWeight.w800,
                    fontSize: badgeFontSize,
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
