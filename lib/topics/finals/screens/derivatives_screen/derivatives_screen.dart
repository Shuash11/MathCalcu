import 'derivatives_answer_card.dart';
import 'derivatives_input_field.dart';
import 'derivatives_steptile.dart';
import 'package:calculus_system/topics/finals/solvers/derivatives_solver/derivatives_steps.dart';
import 'package:calculus_system/topics/finals/solvers/derivatives_solver/deriviatives_solver.dart';
import 'package:calculus_system/topics/finals/finals_theme.dart';
import 'package:calculus_system/shared/widgets/math_keyboard.dart';
import 'package:flutter/material.dart';

class DerivativeScreen extends StatefulWidget {
  const DerivativeScreen({super.key});

  @override
  State<DerivativeScreen> createState() => _DerivativeScreenState();
}

class _DerivativeScreenState extends State<DerivativeScreen> {
  final TextEditingController _exprController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _stepsKey = GlobalKey();

  final _expressionFocus = FocusNode();
  TextEditingController? _activeController;
  final _hideKeyboardSignal = ValueNotifier<int>(0);

  String _variable = 'x';
  ClassroomSolution? _solution;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _expressionFocus.addListener(_onExpressionFocusChange);
  }

  @override
  void dispose() {
    _exprController.dispose();
    _scrollController.dispose();
    _expressionFocus.removeListener(_onExpressionFocusChange);
    _expressionFocus.dispose();
    _hideKeyboardSignal.dispose();
    super.dispose();
  }

  void _onExpressionFocusChange() {
    if (_expressionFocus.hasFocus) {
      setState(() => _activeController = _exprController);
    }
  }

  Future<void> _solve() async {
    _hideKeyboardSignal.value++;
    if (_exprController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _solution = null;
    });

    await Future.delayed(const Duration(milliseconds: 400));

    try {
      final inputExpr = _exprController.text.trim();
      
      final result = AdvancedStepGenerator.generateDetailedSolution(
        inputExpr,
        _variable,
      );
      
      setState(() {
        _solution = result;
        _isLoading = false;
      });

      _scrollToStepsSection();
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('ParseException: ', '');
        _isLoading = false;
      });
    }
  }

  void _scrollToStepsSection() {
    final context = _stepsKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  Widget _buildStepsSection(BuildContext context, ClassroomSolution solution) {
    final stepCount = solution.steps.length;
    final hasSteps = stepCount > 2 && solution.steps.any((s) => s.expression.isNotEmpty);

    return Column(
      key: _stepsKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step-by-Step Solution', style: FinalsTheme.titleStyle(context)),
        const SizedBox(height: 8),
        Text('Understand the rules applied to reach the answer.',
            style: FinalsTheme.subtitleStyle(context)),
        const SizedBox(height: 24),

        if (!hasSteps)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: FinalsTheme.cardSecondary(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline_rounded, color: FinalsTheme.primary, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Direct computation. No step-by-step breakdown needed for this expression.',
                    style: FinalsTheme.subtitleStyle(context),
                  ),
                ),
              ],
            ),
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: solution.steps.asMap().entries.map((entry) {
              final step = entry.value;
              if (step.expression.isEmpty && step.type != StepType.original) {
                return const SizedBox.shrink();
              }
              return DerivativeStepTile(
                step: step,
                index: entry.key,
                isLast: entry.key == solution.steps.length - 1,
              );
            }).toList(),
          ),

        const SizedBox(height: 60),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: FinalsTheme.surface(context),
      child: Column(
        children: [
          SafeArea(
            bottom: false,
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: FinalsTheme.primary),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
          Expanded(
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Differentiate', style: FinalsTheme.titleStyle(context).copyWith(fontSize: 28)),
                        const SizedBox(height: 4),
                        Text('Enter a function to find its derivative step-by-step.',
                            style: FinalsTheme.subtitleStyle(context)),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 32)),

                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverToBoxAdapter(
                    child: DerivativeInputField(
                      controller: _exprController,
                      focusNode: _expressionFocus,
                      currentVariable: _variable,
                      onVariableChanged: (v) => setState(() => _variable = v),
                      onSolve: _solve,
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 32)),

                if (_isLoading)
                  const SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverToBoxAdapter(
                      child: Center(
                        child: CircularProgressIndicator(color: FinalsTheme.primary, strokeWidth: 3),
                      ),
                    ),
                  )
                else if (_error != null)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverToBoxAdapter(
                      child: DerivativeAnswerCard(
                        originalExpr: _exprController.text.trim(),
                        answerExpr: '',
                        hasError: true,
                        errorMessage: _error,
                        onTap: () {},
                      ),
                    ),
                  )
                else if (_solution != null)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverToBoxAdapter(
                      child: DerivativeAnswerCard(
                        originalExpr: _solution!.originalExpression,
                        answerExpr: _solution!.finalAnswer,
                        onTap: _scrollToStepsSection,
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 40)),

                if (_solution != null)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverToBoxAdapter(
                      child: _buildStepsSection(context, _solution!),
                    ),
                  ),
              ],
            ),
          ),
          MathKeyboard(
            controller: _activeController ?? _exprController,
            accentColor: FinalsTheme.primary,
            hideSignal: _hideKeyboardSignal,
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
