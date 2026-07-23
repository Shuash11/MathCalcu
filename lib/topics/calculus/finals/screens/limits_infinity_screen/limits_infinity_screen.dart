import 'package:calculus_system/topics/calculus/finals/solvers/limits_infinity_solver/limits_infinity_solver.dart';
import 'package:calculus_system/topics/calculus/finals/screens/limits_infinity_screen/limits_answer_card.dart';
import 'package:calculus_system/topics/calculus/finals/screens/limits_infinity_screen/limits_input_field.dart';
import 'package:calculus_system/topics/calculus/finals/finals_theme.dart';
import 'package:calculus_system/shared/widgets/accent_glow.dart';
import 'package:calculus_system/shared/widgets/math_keyboard.dart';
import 'package:calculus_system/shared/widgets/solution_step_card.dart';
import 'package:calculus_system/shared/widgets/solution_steps_modal.dart';
import 'package:calculus_system/theme/app_design.dart';
import 'package:flutter/material.dart';
import 'package:calculus_system/shared/widgets/responsive_text.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class LimitsInfinityScreen extends StatefulWidget {
  const LimitsInfinityScreen({super.key});

  @override
  State<LimitsInfinityScreen> createState() => _LimitsInfinityScreenState();
}

class _LimitsInfinityScreenState extends State<LimitsInfinityScreen> {
  final TextEditingController _exprController = TextEditingController();
  final TextEditingController _approachController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

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
      if (clean == 'inf' ||
          clean == 'infinity' ||
          clean == '+inf' ||
          clean == '+infinity') {
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

  void _showStepsModal() {
    if (_solution == null) return;

    showSolutionStepsModal(
      context: context,
      title: 'Solution Steps',
      design: AppDesign.app,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: FinalsTheme.cardSecondary(context),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ResponsiveText(
              '',
              style: FinalsTheme.subtitleStyle(context).copyWith(
                fontWeight: FontWeight.w600,
                color: FinalsTheme.primaryFor(context),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ..._solution!.steps.asMap().entries.map((entry) {
            final step = entry.value;
            final displayExpr = step.formula ?? step.expression?.toString();
            return SolutionStepCard(
              stepNumber: entry.key + 1,
              title: step.description,
              description: step.explanation,
              design: AppDesign.app,
              mathContent: displayExpr != null
                  ? _buildMathDisplay(displayExpr)
                  : const SizedBox.shrink(),
            );
          }),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: FinalsTheme.primaryFor(context).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color:
                      FinalsTheme.primaryFor(context).withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                ResponsiveText(
                  '',
                  style: FinalsTheme.labelStyle(context),
                ),
                const SizedBox(height: 12),
                ResponsiveText(
                  '',
                  textAlign: TextAlign.center,
                  style: FinalsTheme.titleStyle(context).copyWith(fontSize: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMathDisplay(String expr) {
    final latex = expr
        .replaceAll('*', ' \\cdot ')
        .replaceAllMapped(
            RegExp(r'(\w+)\s*\^\s*(\d+)'), (m) => '${m[1]}^{${m[2]}}')
        .replaceAll('x ^ 2', 'x^{2}')
        .replaceAll('x ^ 3', 'x^{3}')
        .replaceAll('x ^ 4', 'x^{4}')
        .replaceAllMapped(
            RegExp(r'(\d+)\s*\^\s*(\d+)'), (m) => '${m[1]}^{${m[2]}}')
        .replaceAllMapped(RegExp(r'([^\s]+)\s*/\s*([^\s]+)'),
            (m) => '\\frac{${m[1]}}{${m[2]}}');

    try {
      return Math.tex(
        latex,
        textStyle: TextStyle(
          fontSize: 15,
          color: FinalsTheme.primaryFor(context),
          fontWeight: FontWeight.w500,
        ),
        onErrorFallback: (error) {
          return Text(
            expr,
            style: const TextStyle(fontSize: 14, fontFamily: 'monospace'),
          );
        },
      );
    } catch (e) {
      return Text(
        expr,
        style: const TextStyle(fontSize: 14, fontFamily: 'monospace'),
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
            SafeArea(
                bottom: false,
                child: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: AccentGlow.iconHalo(
                    context,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_ios_new_rounded,
                          color: FinalsTheme.primaryFor(context)),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
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
                          ResponsiveText(
                            '',
                            style: FinalsTheme.titleStyle(context)
                                .copyWith(fontSize: 32, height: 1.1),
                          ),
                          const SizedBox(height: 8),
                          ResponsiveText(
                            '',
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
                        isLoading: _isLoading,
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),

                  // Answer Card / Error
                  if (_error != null)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      sliver: SliverToBoxAdapter(
                        child: LimitsAnswerCard(
                          problemNotation:
                              'lim($_variable ? ${_approachController.text}) ${_exprController.text}',
                          resultString: '',
                          hasError: true,
                          errorMessage: _error,
                          onTap: () {},
                        ),
                      ),
                    )
                  else if (_solution != null && !_isLoading)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      sliver: SliverToBoxAdapter(
                        child: LimitsAnswerCard(
                          problemNotation: _solution!.problemNotation,
                          resultString: _solution!.resultString,
                          onTap: _showStepsModal,
                        ),
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 48)),

                  // Show Steps Button
                  if (_solution != null && !_isLoading)
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
                              foregroundColor: FinalsTheme.primaryFor(context),
                              side: BorderSide(
                                  color: FinalsTheme.primaryFor(context)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 14),
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
              accentColor: FinalsTheme.primaryFor(context),
              hideSignal: _hideKeyboardSignal,
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
}
