import 'package:calculus_system/topics/calculus/finals/solvers/limits_infinity_solver/limits_infinity_solver.dart';
import 'package:calculus_system/topics/calculus/finals/screens/limits_infinity_screen/limits_answer_card.dart';
import 'package:calculus_system/topics/calculus/finals/screens/limits_infinity_screen/limits_input_field.dart';
import 'package:calculus_system/topics/calculus/finals/screens/limits_infinity_screen/limits_step_guide.dart';
import 'package:calculus_system/topics/calculus/finals/finals_theme.dart';
import 'package:calculus_system/shared/widgets/math_keyboard.dart';
import 'package:flutter/material.dart';

class LimitsInfinityScreen extends StatefulWidget {
  const LimitsInfinityScreen({super.key});

  @override
  State<LimitsInfinityScreen> createState() => _LimitsInfinityScreenState();
}

class _LimitsInfinityScreenState extends State<LimitsInfinityScreen> {
  final TextEditingController _exprController = TextEditingController();
  final TextEditingController _approachController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _stepsKey = GlobalKey();

  final _expressionFocus = FocusNode();
  final _approachFocus = FocusNode();
  TextEditingController? _activeController;
  final _hideKeyboardSignal = ValueNotifier<int>(0);

  String _variable = 'x';
  LimitSolution? _solution;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _expressionFocus.addListener(_onExpressionFocusChange);
    _approachFocus.addListener(_onApproachFocusChange);
  }

  void _onExpressionFocusChange() {
    if (_expressionFocus.hasFocus) {
      setState(() => _activeController = _exprController);
    }
  }

  void _onApproachFocusChange() {
    if (_approachFocus.hasFocus) {
      setState(() => _activeController = _approachController);
    }
  }

  @override
  void dispose() {
    _exprController.dispose();
    _approachController.dispose();
    _scrollController.dispose();
    _expressionFocus.removeListener(_onExpressionFocusChange);
    _approachFocus.removeListener(_onApproachFocusChange);
    _expressionFocus.dispose();
    _approachFocus.dispose();
    _hideKeyboardSignal.dispose();
    super.dispose();
  }

  Future<void> _solve() async {
    _hideKeyboardSignal.value++;
    final expression = _exprController.text.trim();
    final approachText = _approachController.text.trim();

    if (expression.isEmpty || approachText.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _solution = null;
    });

    // Small delay for UI feel
    await Future.delayed(const Duration(milliseconds: 400));

    try {
      double approachVal;
      final clean = approachText.trim().toLowerCase();
      if (clean == 'inf' || clean == 'infinity' || clean == '+inf' || clean == '+infinity') {
        approachVal = double.infinity;
      } else if (clean == '-inf' || clean == '-infinity') {
        approachVal = double.negativeInfinity;
      } else {
        approachVal = double.parse(approachText);
      }

      final solution = LimitSolver.solve(expression, approachVal);

      setState(() {
        _solution = solution;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e
            .toString()
            .replaceFirst('Exception: ', '')
            .replaceFirst('error: ', '');
        _isLoading = false;
      });
    }
  }

  void _scrollToStepsSection() {
    final context = _stepsKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: FinalsTheme.surface(context),
      child: SafeArea(
        child: Column(
          children: [
            SafeArea(bottom: false, child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: FinalsTheme.primary),
                onPressed: () => Navigator.of(context).pop(),
              ),
            )),
            Expanded(
              child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
// Header Section
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Container(
                    //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    //   decoration: BoxDecoration(
                    //     color: FinalsTheme.primary.withValues(alpha: 0.1),
                    //     borderRadius: BorderRadius.circular(20),
                    //   ),
                    //   child: Text(
                    //     'LIMITS SOLVER',
                    //     style: FinalsTheme.labelStyle(context).copyWith(fontSize: 10),
                    //   ),
                    // ),
                    // const SizedBox(height: 16),
                    Text(
                      'Infinity & Beyond',
                      style: FinalsTheme.titleStyle(context)
                          .copyWith(fontSize: 32, height: 1.1),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Solve limits approaching finite values or infinity with step-by-step algebraic breakdowns.',
                      style: FinalsTheme.subtitleStyle(context)
                          .copyWith(fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // Input Field Section
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverToBoxAdapter(
                child: LimitsInputField(
                  expressionController: _exprController,
                  approachController: _approachController,
                  expressionFocus: _expressionFocus,
                  approachFocus: _approachFocus,
                  currentVariable: _variable,
                  onVariableChanged: (v) => setState(() => _variable = v),
                  onSolve: _solve,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Answer Card / Loading / Error
            if (_isLoading)
              const SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(
                        color: FinalsTheme.primary,
                        strokeWidth: 3,
                      ),
                    ),
                  ),
                ),
              )
            else if (_error != null)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverToBoxAdapter(
                  child: LimitsAnswerCard(
                    problemNotation:
                        'lim($_variable â†’ ${_approachController.text}) ${_exprController.text}',
                    resultString: '',
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
                  child: LimitsAnswerCard(
                    problemNotation: _solution!.problemNotation,
                    resultString: _solution!.resultString,
                    onTap: _scrollToStepsSection,
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 48)),

            // Steps Section
            if (_solution != null)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    key: _stepsKey,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.auto_stories_rounded,
                              size: 24, color: FinalsTheme.primary),
                          const SizedBox(width: 12),
                          Text('Solution Steps',
                              style: FinalsTheme.titleStyle(context)
                                  .copyWith(fontSize: 20)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Method: ${_solution!.methodUsed}',
                        style: FinalsTheme.subtitleStyle(context).copyWith(
                            fontWeight: FontWeight.w600,
                            color: FinalsTheme.primary),
                      ),
                      const SizedBox(height: 32),

                      // Render Each Step
                      ..._solution!.steps.asMap().entries.map((entry) {
                        final step = entry.value;
                        final displayExpr =
                            step.formula ?? step.expression?.toString();
                        return LimitsStepGuide(
                          title: step.description,
                          subtitle: null,
                          mathExpression: displayExpr,
                          explanation: step.explanation,
                          isConclusion: step.type == StepType.conclusion,
                          stepNumber: entry.key + 1,
                        );
                      }),

                      const SizedBox(height: 16),

                      // Final Conclusion
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: FinalsTheme.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color:
                                  FinalsTheme.primary.withValues(alpha: 0.2)),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Final Conclusion',
                              style: FinalsTheme.labelStyle(context),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'The limit is ${_solution!.resultString}',
                              textAlign: TextAlign.center,
                              style: FinalsTheme.titleStyle(context)
                                  .copyWith(fontSize: 18),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 80),
                    ],
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
      ),
    );
  }
}
