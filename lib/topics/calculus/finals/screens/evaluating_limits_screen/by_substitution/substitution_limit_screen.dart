import 'substitution_answer_card.dart';
import 'substitution_input_field.dart';
import 'substitution_steps_view.dart';
import 'package:calculus_system/topics/calculus/finals/solvers/evaluating_limits_solver/by_substitution/substitution_engine.dart';
import 'package:calculus_system/topics/calculus/finals/solvers/evaluating_limits_solver/by_substitution/substitution_steps.dart';
import 'package:calculus_system/topics/calculus/finals/finals_theme.dart';
import 'package:calculus_system/shared/widgets/math_keyboard.dart';
import 'package:calculus_system/shared/widgets/responsive_text.dart';
import 'package:calculus_system/shared/widgets/solution_steps_modal.dart';
import 'package:calculus_system/theme/app_design.dart';
import 'package:flutter/material.dart';

class SubstitutionLimitScreen extends StatefulWidget {
  const SubstitutionLimitScreen({super.key});

  @override
  State<SubstitutionLimitScreen> createState() => _SubstitutionLimitScreenState();
}

class _SubstitutionLimitScreenState extends State<SubstitutionLimitScreen> with TickerProviderStateMixin {
  final TextEditingController _expressionController = TextEditingController();
  final TextEditingController _approachController = TextEditingController();
  final _expressionFocus = FocusNode();
  final _approachFocus = FocusNode();
  TextEditingController? _activeController;
  final _hideKeyboardSignal = ValueNotifier<int>(0);
  String _currentVariable = 'x';
  
  SubstitutionResult? _result;
  List<SolutionStep> _steps = [];
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
    _fadeAnim = CurvedAnimation(parent: _contentController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _contentController, curve: Curves.easeOutCubic));

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
    if (_expressionController.text.isEmpty || _approachController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter both an expression and an approach value.'),
          backgroundColor: FinalsTheme.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() {
      _isSolving = true;
    });

    // parse approach value
    double approachVal = 0;
    try {
      approachVal = double.parse(_approachController.text.replaceAll('inf', 'Infinity'));
    } catch (e) {
      approachVal = 0;
    }

    // Call engine after a short delay for UX feel
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      
      try {
        final engine = SubstitutionEngine();
        final result = engine.solve(LimitProblem(
          expression: _expressionController.text,
          approachValue: approachVal,
        ));
        
        final stepsGen = SubstitutionStepsGenerator();
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: FinalsTheme.surface(context),
      child: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────
            _buildHeader(context),

            // ── Scrollable Content ──────────────────────────────
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Input Section
                        SubstitutionInputField(
                          expressionController: _expressionController,
                          approachController: _approachController,
                          expressionFocus: _expressionFocus,
                          approachFocus: _approachFocus,
                          currentVariable: _currentVariable,
                          onVariableChanged: (v) => setState(() => _currentVariable = v),
                          onSolve: _solve,
                        ),

                        // Animated Result Section
                        if (_isSolving)
                          const Padding(
                            padding: EdgeInsets.all(40.0),
                            child: Center(
                              child: CircularProgressIndicator(color: FinalsTheme.primary),
                            ),
                          )
                        else if (_result != null) ...[
                          SubstitutionAnswerCard(
                            answer: _result!.finalValue,
                            method: 'By Substitution',
                            isShowingSteps: false,
                            onTap: () => showSolutionStepsModal(
                              context: context,
                              title: 'Solution Steps',
                              design: AppDesign.calculus,
                              child: SubstitutionStepsView(steps: _steps),
                            ),
                            error: _result!.errorMessage,
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
              accentColor: FinalsTheme.primary,
              hideSignal: _hideKeyboardSignal,
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Row(
        children: [
          // Back Button
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            style: IconButton.styleFrom(
              backgroundColor: FinalsTheme.card(context),
              foregroundColor: FinalsTheme.textPrimary(context),
              padding: const EdgeInsets.all(12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              side: BorderSide(color: FinalsTheme.primary.withValues(alpha: 0.1)),
            ),
          ),
          const SizedBox(width: 20),
          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ResponsiveText(
                  'Substitution',
                  style: FinalsTheme.titleStyle(context).copyWith(fontSize: 24),
                ),
                ResponsiveText(
                  'Evaluating Limits',
                  style: FinalsTheme.subtitleStyle(context),
                ),
              ],
            ),
          ),
          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: FinalsTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: FinalsTheme.primary.withValues(alpha: 0.2)),
            ),
            child: const Row(
              children: [
                Icon(Icons.swap_horiz_rounded, size: 14, color: FinalsTheme.primary),
                SizedBox(width: 6),
                ResponsiveText(
                  'BY SUBSTITUTION',
                  style: TextStyle(
                    color: FinalsTheme.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
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
