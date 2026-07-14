import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/topics/calculus/midterm/solvers/inequalities_solver/inequality_solver_router.dart';
import 'package:calculus_system/topics/calculus/midterm/graph/inequalities_graph/inequality_graph.dart';
import 'package:calculus_system/topics/calculus/midterm/theme/inequalities_theme/inequality_theme.dart';
import 'package:calculus_system/shared/widgets/answer_card.dart';
import 'package:calculus_system/shared/widgets/full_screen_graph_screen.dart';
import 'package:calculus_system/shared/widgets/graph_widget.dart';
import 'package:calculus_system/shared/widgets/math_input_field.dart';
import 'package:calculus_system/shared/widgets/math_keyboard.dart';
import 'package:calculus_system/shared/widgets/steps_drawer.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:calculus_system/shared/widgets/responsive_text.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class BaseInequalityScreen extends StatefulWidget {
  final String title;
  final String subtitle;
  final String hint;
  final SolveResult Function(String) solveFunction;
  final List<StepModel> Function(String) stepsFunction;

  const BaseInequalityScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.solveFunction,
    required this.stepsFunction,
    this.hint = 'e.g. 2x + 3 > 7',
  });

  @override
  State<BaseInequalityScreen> createState() => _BaseInequalityScreenState();
}

class _BaseInequalityScreenState extends State<BaseInequalityScreen> {
  final TextEditingController _inputCtrl = TextEditingController();
  final ValueNotifier<int> _hideKeyboardSignal = ValueNotifier(0);

  SolveResult? _result;
  bool _loading = false;
  bool _solved = false;

  int _requestId = 0;

  Future<void> _solve() async {
    final input = _inputCtrl.text.trim();
    if (input.isEmpty) return;

    final int currentRequest = ++_requestId;
    final detected = InequalitySolverRouter.detectType(input);

    setState(() => _loading = true);
    _detectedType = detected;

    try {
      final result = await compute(widget.solveFunction, input);

      if (!mounted || currentRequest != _requestId) return;

      setState(() {
        _result = result;
        _solved = true;
      });
      _hideKeyboardSignal.value++;
    } catch (e) {
      if (!mounted || currentRequest != _requestId) return;

      setState(() {
        _result = SolveResult.error(e.toString());
        _solved = true;
      });
      _hideKeyboardSignal.value++;
    } finally {
      if (mounted && currentRequest == _requestId) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _showSteps() async {
    if (_result == null || _result!.hasError) return;

    final input = _inputCtrl.text.trim();
    final steps = await compute(widget.stepsFunction, input);

    if (!mounted) return;

    showStepsDrawer(
      context: context,
      steps: steps,
      accentColor: InequalityTheme.accentColor,
      title: widget.title,
    );
  }

  void _openFullScreenGraph() {
    if (_result == null || _result!.hasError) return;

    final keyInfo = <FullScreenInfoItem>[
      if (_result!.intervalNotation != null)
        FullScreenInfoItem(
          label: 'Interval',
          value: _result!.intervalNotation!,
        ),
      if (_result!.points.isNotEmpty)
        FullScreenInfoItem(
          label: 'Boundaries',
          value: _result!.points.join(', '),
        ),
    ];

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullScreenGraphScreen(
          title: widget.title,
          graph: InequalityGraph(
            result: _result!,
            accentColor: InequalityTheme.accentColor,
          ),
          formula: _result!.answer,
          keyInfo: keyInfo.isNotEmpty ? keyInfo : null,
          accentColor: InequalityTheme.accentColor,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _hideKeyboardSignal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    return Scaffold(
      backgroundColor: theme.surface,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            _buildInput(),
            const SizedBox(height: 24),
            _buildBody(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: context.watch<ThemeProvider>().card,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.arrow_back_ios_rounded,
              size: 14,
              color: InequalityTheme.accentColor,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ResponsiveText(
                widget.title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: context.watch<ThemeProvider>().textPrimary,
                ),
              ),
              ResponsiveText(
                widget.subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: InequalityTheme.accentColor.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveText(
          'Enter your expression',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: context.watch<ThemeProvider>().textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        MathInputField(
          controller: _inputCtrl,
          accentColor: InequalityTheme.accentColor,
          hint: widget.hint,
          onSolve: _solve,
        ),
        MathKeyboard(
          controller: _inputCtrl,
          accentColor: InequalityTheme.accentColor,
          hideSignal: _hideKeyboardSignal,
        ),
        if (_result != null && !_result!.hasError && _detectedType != null) ...[
          const SizedBox(height: 8),
          _buildTypeDetectionBanner(),
        ],
      ],
    );
  }

  String? _detectedType;

  String? get _baseDetectedType {
    if (_detectedType == null) return null;
    // Strip -strict, -non-strict, or -continued suffix
    if (_detectedType!.endsWith('-strict') || _detectedType!.endsWith('-non-strict') || _detectedType!.endsWith('-continued')) {
      final lastDash = _detectedType!.lastIndexOf('-');
      return _detectedType!.substring(0, lastDash);
    }
    return _detectedType;
  }

  String? get _detectedStrictness {
    if (_detectedType == null) return null;
    if (_detectedType!.endsWith('-strict')) return 'strict';
    if (_detectedType!.endsWith('-non-strict')) return 'non-strict';
    if (_detectedType!.endsWith('-continued')) return 'continued';
    return null;
  }

  bool get _matchesScreen {
    if (_detectedType == null || _baseDetectedType == null) return false;
    
    final typeToTitle = {
      'linear': 'Basic',
      'quadratic': 'Quadratic',
      'rational': 'Rational',
      'radical': 'Radical',
      'sqrtRational': 'Radical',
      'absolute': 'Absolute',
    };
    
    // Check if base type matches
    final expectedTitle = typeToTitle[_baseDetectedType];
    if (expectedTitle == null) return false;
    
    final typeMatches = widget.title.contains(expectedTitle);
    if (!typeMatches) return false;
    
    // Special case: Continued Inequality
    if (_detectedStrictness == 'continued') {
      return widget.title.contains('Continued');
    }
    
    // Check if strictness matches screen type
    final isStrictScreen = widget.title.contains('Strict');
    final isNonStrictScreen = widget.title.contains('Non-strict');
    final detectedIsStrict = _detectedStrictness == 'strict';
    
    if (isStrictScreen && detectedIsStrict) return true;
    if (isNonStrictScreen && !detectedIsStrict) return true;
    
    // If screen has no strict/non-strict qualifier (e.g., just "Rational Inequality"),
    // match any strictness of that base type
    if (!isStrictScreen && !isNonStrictScreen && !widget.title.contains('Continued')) {
      return true;
    }
    
    return false;
  }

  Widget _buildTypeDetectionBanner() {
    final baseLabels = {
      'linear': 'Basic Inequality',
      'absolute': 'Absolute Value Inequality',
      'quadratic': 'Quadratic Inequality',
      'rational': 'Rational Inequality',
      'radical': 'Radical Inequality',
      'sqrtRational': 'Sqrt Rational Inequality',
    };

    final baseLabel = baseLabels[_baseDetectedType] ?? _baseDetectedType ?? 'Unknown';
    
    String detectedLabel;
    if (_detectedStrictness == 'continued') {
      detectedLabel = 'Continued $baseLabel';
    } else {
      final strictnessLabel = _detectedStrictness == 'strict' ? 'Strict' : 'Non-strict';
      detectedLabel = '$strictnessLabel $baseLabel';
    }
    
    final matchesScreen = _matchesScreen;
    final bgColor = matchesScreen
        ? InequalityTheme.accentColor.withValues(alpha: 0.1)
        : const Color(0xFF2A1F10);
    final textColor = matchesScreen
        ? InequalityTheme.accentColor
        : const Color(0xFFFFB84D);
    final icon = matchesScreen ? Icons.check_circle_outline : Icons.info_outline;
    final bannerText = matchesScreen
        ? 'Detected: $detectedLabel'
        : 'Detected as $detectedLabel - try $_suggestedScreen screen';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 8),
          Expanded(
            child: ResponsiveText(
              bannerText,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: textColor),
            ),
          ),
        ],
      ),
    );
  }

  String get _suggestedScreen {
    final suggestions = {
      'linear': 'Basic Inequality',
      'quadratic': 'Quadratic',
      'rational': 'Rational',
      'radical': 'Radical',
      'sqrtRational': 'Radical',
      'absolute': 'Absolute',
    };
    
    if (_detectedStrictness == 'continued') {
      return 'Continued Inequality';
    }
    
    final baseScreen = suggestions[_baseDetectedType] ?? 'appropriate';
    final correctStrictness = _detectedStrictness == 'strict' ? 'Strict' : 'Non-strict';
    return '$correctStrictness $baseScreen';
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: InequalityTheme.accentColor,
        ),
      );
    }

    if (!_solved || _result == null) {
      return const SizedBox();
    }

    if (_result!.hasError) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2A1010),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ResponsiveText(
          _result!.errorMessage ?? 'Unknown error',
          style: const TextStyle(color: Color(0xFFFF6B6B)),
        ),
      );
    }

    return Column(
      children: [
        GestureDetector(
          onTap: _openFullScreenGraph,
          child: GraphWidget(
            result: _result!,
            accentColor: InequalityTheme.accentColor,
            graphBody: InequalityGraph(
              result: _result!,
              accentColor: InequalityTheme.accentColor,
            ),
          ),
        ),
        const SizedBox(height: 16),
        AnswerCard(
          result: _result!,
          accentColor: InequalityTheme.accentColor,
          onTap: _showSteps,
        ),
      ],
    );
  }
}
