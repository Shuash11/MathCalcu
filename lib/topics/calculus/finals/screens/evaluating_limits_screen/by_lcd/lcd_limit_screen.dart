import 'lcd_answer_card.dart';
import 'lcd_input_field.dart';
import 'lcd_steps_view.dart';
import 'package:calculus_system/topics/calculus/finals/solvers/evaluating_limits_solver/by_lcd/math_limits_library.dart';
import 'package:calculus_system/topics/calculus/finals/finals_theme.dart';
import 'package:calculus_system/shared/widgets/math_keyboard.dart';
import 'package:flutter/material.dart';

class LCDLimitScreen extends StatefulWidget {
  const LCDLimitScreen({super.key});

  @override
  State<LCDLimitScreen> createState() => _LCDLimitScreenState();
}

class _LCDLimitScreenState extends State<LCDLimitScreen> with TickerProviderStateMixin {
  final TextEditingController _expressionController = TextEditingController();
  final TextEditingController _approachController = TextEditingController();
  final _expressionFocus = FocusNode();
  final _approachFocus = FocusNode();
  TextEditingController? _activeController;
  final _hideKeyboardSignal = ValueNotifier<int>(0);
  String _currentVariable = 'x';
  
  LimitSolution? _solution;
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

    _expressionFocus.addListener(_onExpressionFocusChange);
    _approachFocus.addListener(_onApproachFocusChange);
  }

  @override
  void dispose() {
    _expressionController.dispose();
    _approachController.dispose();
    _contentController.dispose();
    _expressionFocus.removeListener(_onExpressionFocusChange);
    _approachFocus.removeListener(_onApproachFocusChange);
    _expressionFocus.dispose();
    _approachFocus.dispose();
    _hideKeyboardSignal.dispose();
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
      _showSteps = false;
    });

    // parse approach value with proper validation
    final approachText = _approachController.text.trim().toLowerCase();
    double? approachVal;

    if (approachText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter an approach value.'),
          backgroundColor: FinalsTheme.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    if (approachText == 'inf' || approachText == '+inf' || approachText == 'infinity' || approachText == '+infinity') {
      approachVal = double.infinity;
    } else if (approachText == '-inf' || approachText == '-infinity') {
      approachVal = double.negativeInfinity;
    } else {
      final parsed = double.tryParse(approachText);
      if (parsed == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid approach value "$approachText". Please enter a number or infinity.'),
            backgroundColor: FinalsTheme.danger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        return;
      }
      approachVal = parsed;
    }

    // Call engine
    try {
      final sol = LimitEngine.solve(
        _expressionController.text,
        _currentVariable,
        approachVal,
      );
      
      setState(() {
        _solution = sol;
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 380;
    final padding = isCompact ? 16.0 : 24.0;

    return ColoredBox(
      color: FinalsTheme.surface(context),
      child: SafeArea(
        child: Column(
          children: [
            // â”€â”€ Header â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            _buildHeader(context, padding),

            // â”€â”€ Scrollable Content â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(padding, 8, padding, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Input Section
                        LCDInputField(
                          expressionFocus: _expressionFocus,
                          approachFocus: _approachFocus,

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
                              child: CircularProgressIndicator(color: FinalsTheme.danger),
                            ),
                          )
                        else if (_solution != null) ...[
                          LCDAnswerCard(
                            answer: _solution!.finalAnswer,
                            fractionalAnswer: _solution!.fractionalAnswer,
                            method: _solution!.methodUsed,
                            isShowingSteps: _showSteps,
                            onTap: () => setState(() => _showSteps = !_showSteps),
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
                                            const Icon(Icons.list_alt_rounded, color: FinalsTheme.danger, size: 18),
                                            const SizedBox(width: 10),
                                            Text(
                                              'SOLUTION STEPS',
                                              style: FinalsTheme.labelStyle(context).copyWith(
                                                color: FinalsTheme.danger,
                                                letterSpacing: 1.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 24),
                                        LCDStepsView(steps: _solution!.steps),
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
            MathKeyboard(
              controller: _activeController ?? _expressionController,
              accentColor: FinalsTheme.danger,
              hideSignal: _hideKeyboardSignal,
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double padding) {
    return Padding(
      padding: EdgeInsets.fromLTRB(padding, 24, padding, 16),
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
              side: BorderSide(color: FinalsTheme.danger.withValues(alpha: 0.1)),
            ),
          ),
          const SizedBox(width: 20),
          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LCD Method',
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
              color: FinalsTheme.danger.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: FinalsTheme.danger.withValues(alpha: 0.2)),
            ),
            child: const Row(
              children: [
                Icon(Icons.layers_rounded, size: 14, color: FinalsTheme.danger),
                SizedBox(width: 6),
                Text(
                  'By LCD',
                  style: TextStyle(
                    color: FinalsTheme.danger,
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
