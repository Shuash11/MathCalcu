import 'package:calculus_system/topics/calculus/finals/solvers/slope_using_derivatives_solver/steps.dart';
import 'answer_card.dart';
import 'package:flutter/material.dart';
import 'package:calculus_system/shared/widgets/accent_glow.dart';
import 'package:calculus_system/shared/widgets/responsive_text.dart';
import 'package:calculus_system/topics/calculus/finals/widgets/finals_solver_controls.dart';
import 'package:go_router/go_router.dart';
import 'package:calculus_system/topics/calculus/finals/finals_theme.dart';
import 'package:calculus_system/shared/widgets/math_keyboard.dart';
import 'package:calculus_system/topics/calculus/finals/solvers/slope_using_derivatives_solver/slope_using_derivatives_solver.dart';

class SlopeSolverScreen extends StatefulWidget {
  const SlopeSolverScreen({super.key});

  @override
  State<SlopeSolverScreen> createState() => _SlopeSolverScreenState();
}

class _SlopeSolverScreenState extends State<SlopeSolverScreen> {
  final TextEditingController _eqController =
      TextEditingController(text: 'y = x^3 - 2x + 1');
  final TextEditingController _varsController =
      TextEditingController(text: 'x=2');

  final _eqFocus = FocusNode();
  final _varsFocus = FocusNode();
  TextEditingController? _activeController;
  final _hideKeyboardSignal = ValueNotifier<int>(0);

  bool _isLoading = false;
  ClassroomSolution? _solution;
  String? _error;

  @override
  void initState() {
    super.initState();
    _eqFocus.addListener(_onEqFocusChange);
    _varsFocus.addListener(_onVarsFocusChange);
  }

  void _onEqFocusChange() {
    if (_eqFocus.hasFocus) {
      setState(() => _activeController = _eqController);
    }
  }

  void _onVarsFocusChange() {
    if (_varsFocus.hasFocus) {
      setState(() => _activeController = _varsController);
    }
  }

  void _solve() {
    _hideKeyboardSignal.value++;
    setState(() {
      _isLoading = true;
      _error = null;
      _solution = null;
    });

    try {
      final vars = <String, double>{};
      final varParts = _varsController.text.split(RegExp(r'\s+'));
      for (final part in varParts) {
        final kv = RegExp(r'^([a-zA-Z_])=([-\d.]+)$').firstMatch(part);
        if (kv != null) {
          vars[kv.group(1)!] = double.parse(kv.group(2)!);
        }
      }

      final result =
          SlopeSolver.solve(_eqController.text.trim(), pointValues: vars);
      final solution = SolutionBuilder.build(result);

      setState(() {
        _solution = solution;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _eqFocus.removeListener(_onEqFocusChange);
    _varsFocus.removeListener(_onVarsFocusChange);
    _eqFocus.dispose();
    _varsFocus.dispose();
    _hideKeyboardSignal.dispose();
    _eqController.dispose();
    _varsController.dispose();
    super.dispose();
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
                leading: AccentGlow.iconHalo(
                  context,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_ios_new,
                        color: FinalsTheme.textPrimary(context)),
                    onPressed: () => context.pop(),
                  ),
                ),
                title: Text('Slope Solver',
                    style: FinalsTheme.titleStyle(context)),
              )),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildInputField(
                    controller: _eqController,
                    hint: 'e.g. y = x^2 + 1, x^2 + y^2 = 25',
                    label: 'EQUATION',
                    focusNode: _eqFocus,
                    textInputAction: TextInputAction.next,
                    onEditingComplete: () => _varsFocus.requestFocus(),
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    controller: _varsController,
                    hint: 'e.g. x=2 or x=3 y=4',
                    label: 'POINT VALUES',
                    focusNode: _varsFocus,
                    textInputAction: TextInputAction.done,
                    onEditingComplete: () => _varsFocus.unfocus(),
                  ),
                  const SizedBox(height: 24),
                  FinalsSolverButton(onPressed: _solve, isLoading: _isLoading),
                  if (_error != null) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: FinalsTheme.danger.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: FinalsTheme.danger.withValues(alpha: 0.3)),
                      ),
                      child: Text(_error!,
                          style: const TextStyle(
                              color: FinalsTheme.danger,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                  if (_solution != null && !_isLoading) ...[
                    const SizedBox(height: 32),
                    AnswerCard(solution: _solution!),
                    const SizedBox(height: 12),
                    Center(
                      child: ResponsiveText(
                        '',
                        style: TextStyle(
                            color: FinalsTheme.textSecondary(context)
                                .withValues(alpha: 0.5),
                            fontSize: 12,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ),
          MathKeyboard(
            controller: _activeController ?? _eqController,
            accentColor: FinalsTheme.primaryFor(context),
            hideSignal: _hideKeyboardSignal,
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required String label,
    FocusNode? focusNode,
    TextInputAction? textInputAction,
    VoidCallback? onEditingComplete,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: FinalsTheme.labelStyle(context)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: FinalsTheme.card(context),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color:
                    FinalsTheme.textSecondary(context).withValues(alpha: 0.15)),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: TextInputType.none,
            textInputAction: textInputAction,
            onEditingComplete: onEditingComplete,
            style: TextStyle(
                color: FinalsTheme.textPrimary(context),
                fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                  color:
                      FinalsTheme.textSecondary(context).withValues(alpha: 0.4),
                  fontSize: 14),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}
