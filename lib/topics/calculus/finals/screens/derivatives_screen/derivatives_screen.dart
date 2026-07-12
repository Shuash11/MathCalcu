import 'derivatives_answer_card.dart';
import 'derivatives_input_field.dart';
import 'package:calculus_system/topics/calculus/finals/solvers/derivatives_solver/derivatives_steps.dart';
import 'package:calculus_system/topics/calculus/finals/solvers/derivatives_solver/deriviatives_solver.dart';
import 'package:calculus_system/topics/calculus/finals/finals_theme.dart';
import 'package:calculus_system/shared/widgets/math_keyboard.dart';
import 'package:calculus_system/shared/widgets/solution_step_card.dart';
import 'package:calculus_system/shared/widgets/solution_steps_modal.dart';
import 'package:flutter/material.dart';

class DerivativeScreen extends StatefulWidget {
  const DerivativeScreen({super.key});

  @override
  State<DerivativeScreen> createState() => _DerivativeScreenState();
}

class _DerivativeScreenState extends State<DerivativeScreen> {
  final TextEditingController _exprController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

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
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('ParseException: ', '');
        _isLoading = false;
      });
    }
  }

  void _showStepsModal() {
    if (_solution == null) return;

    final solution = _solution!;
    final hasSteps = solution.steps.length > 2 && solution.steps.any((s) => s.expression.isNotEmpty);

    showSolutionStepsModal(
      context: context,
      title: 'Derivative Steps',
      accentColor: FinalsTheme.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
            ...solution.steps.asMap().entries.map((entry) {
              final step = entry.value;
              if (step.expression.isEmpty && step.type != StepType.original) {
                return const SizedBox.shrink();
              }
              return SolutionStepCard(
                stepNumber: entry.key + 1,
                title: step.title,
                description: step.explanation.split('\n').firstOrNull ?? '',
                mathContent: Text(
                  step.expression.toString(),
                  style: const TextStyle(color: FinalsTheme.primary),
                ),
              );
            }),
        ],
      ),
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
                        onTap: _showStepsModal,
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 40)),

                if (_solution != null)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: OutlinedButton.icon(
                          onPressed: _showStepsModal,
                          icon: const Icon(Icons.list_alt_rounded, size: 18),
                          label: const Text('Show Steps'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: FinalsTheme.primary,
                            side: const BorderSide(color: FinalsTheme.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          ),
                        ),
                      ),
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
