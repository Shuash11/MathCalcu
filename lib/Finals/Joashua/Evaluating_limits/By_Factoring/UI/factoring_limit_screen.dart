import 'package:calculus_system/Finals/Joashua/Evaluating_limits/By_Factoring/Widget/factoring_answer_card.dart';
import 'package:calculus_system/Finals/Joashua/Evaluating_limits/By_Factoring/Widget/factoring_input_field.dart';
import 'package:calculus_system/Finals/Joashua/Evaluating_limits/By_Factoring/Widget/factoring_steps_view.dart';
import 'package:calculus_system/Finals/Joashua/Evaluating_limits/By_Factoring/solvers/solver_engine.dart';
import 'package:calculus_system/Finals/Joashua/Evaluating_limits/By_Factoring/solvers/solution_steps.dart';
import 'package:calculus_system/Finals/finals_theme.dart';
import 'package:flutter/material.dart';

class FactoringLimitScreen extends StatefulWidget {
  const FactoringLimitScreen({super.key});

  @override
  State<FactoringLimitScreen> createState() => _FactoringLimitScreenState();
}

class _FactoringLimitScreenState extends State<FactoringLimitScreen> with TickerProviderStateMixin {
  final TextEditingController _expressionController = TextEditingController();
  final TextEditingController _approachController = TextEditingController();
  String _currentVariable = 'x';
  
  SolutionResult? _result;
  List<SolutionStep> _steps = [];
  bool _showSteps = false;
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
  }

  @override
  void dispose() {
    _expressionController.dispose();
    _approachController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _solve() {
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
      _showSteps = false;
    });

    // parse approach value
    double approachVal = 0;
    try {
      approachVal = double.parse(_approachController.text.replaceAll('inf', 'Infinity'));
    } catch (e) {
      approachVal = 0;
    }

    // Call engine
    try {
      final engine = LimitSolverEngine();
      final result = engine.solve(LimitProblem(
        expression: _expressionController.text,
        approachValue: approachVal,
      ));
      
      final stepsGen = SolutionStepsGenerator();
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
    return Scaffold(
      backgroundColor: FinalsTheme.surface(context),
      body: SafeArea(
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
                        FactoringInputField(
                          expressionController: _expressionController,
                          approachController: _approachController,
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
                          FactoringAnswerCard(
                            answer: _result!.finalValue,
                            method: 'Factoring Method',
                            isShowingSteps: _showSteps,
                            onTap: () => setState(() => _showSteps = !_showSteps),
                            error: _result!.errorMessage,
                          ),

                          // Steps Section
                          AnimatedSize(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.fastOutSlowIn,
                            child: _showSteps
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 32, left: 8, right: 8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.list_alt_rounded, color: FinalsTheme.primary, size: 18),
                                            const SizedBox(width: 10),
                                            Text(
                                              'SOLUTION STEPS',
                                              style: FinalsTheme.labelStyle(context).copyWith(
                                                color: FinalsTheme.primary,
                                                letterSpacing: 1.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 24),
                                        FactoringStepsView(steps: _steps),
                                      ],
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
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
                Text(
                  'Factoring Method',
                  style: FinalsTheme.titleStyle(context).copyWith(fontSize: 24),
                ),
                Text(
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
                Icon(Icons.layers_rounded, size: 14, color: FinalsTheme.primary),
                SizedBox(width: 6),
                Text(
                  'By Factoring',
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
