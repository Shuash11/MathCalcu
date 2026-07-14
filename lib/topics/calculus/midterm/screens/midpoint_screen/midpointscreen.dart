import 'package:calculus_system/topics/calculus/midterm/graph/midpoint_graph/midpoint_graph.dart';
import 'package:calculus_system/topics/calculus/midterm/solvers/midpoint_solver/midpointsolver.dart';
import 'package:calculus_system/topics/calculus/midterm/screens/midpoint_screen/midpointsteps.dart';
import 'package:calculus_system/topics/calculus/midterm/theme/midpoint_theme/midpointtheme.dart';
import 'package:calculus_system/topics/calculus/finals/finals_theme.dart';
import 'package:calculus_system/shared/widgets/solution_steps_modal.dart';
import 'package:calculus_system/shared/widgets/responsive_text.dart';
import 'package:flutter/material.dart';

class MidpointScreen extends StatefulWidget {
  const MidpointScreen({super.key});

  @override
  State<MidpointScreen> createState() => _MidpointScreenState();
}

class _MidpointScreenState extends State<MidpointScreen> {
  StepMode _mode = StepMode.midpoint;

  final _aXCtrl = TextEditingController();
  final _aYCtrl = TextEditingController();
  final _bXCtrl = TextEditingController();
  final _bYCtrl = TextEditingController();
  final _aXFocus = FocusNode();
  final _aYFocus = FocusNode();
  final _bXFocus = FocusNode();
  final _bYFocus = FocusNode();

  String? _resX;
  String? _resY;
  String? _formulaX;
  String? _formulaY;
  bool _solved = false;
  bool _hasError = false;
  String _errorMsg = '';

  String _savedAX = '';
  String _savedAY = '';
  String _savedBX = '';
  String _savedBY = '';
  Fraction? _savedResX;
  Fraction? _savedResY;

  @override
  void dispose() {
    _aXCtrl.dispose();
    _aYCtrl.dispose();
    _bXCtrl.dispose();
    _bYCtrl.dispose();
    _aXFocus.dispose();
    _aYFocus.dispose();
    _bXFocus.dispose();
    _bYFocus.dispose();
    super.dispose();
  }

  void _switchMode(StepMode mode) {
    if (_mode == mode) return;
    setState(() {
      _mode = mode;
      _aXCtrl.clear();
      _aYCtrl.clear();
      _bXCtrl.clear();
      _bYCtrl.clear();
      _solved = false;
    });
  }

  void _openStepsModal() {
    if (!_solved || _hasError) return;
    if (_savedResX == null || _savedResY == null) return;
    showSolutionStepsModal(
      context: context,
      title: _mode == StepMode.midpoint
          ? 'Midpoint \u2014 Step by Step'
          : 'Endpoint \u2014 Step by Step',
      accentColor: FinalsTheme.primary,
      child: MidpointSteps(
        mode: _mode,
        rawAX: _savedAX,
        rawAY: _savedAY,
        rawBX: _savedBX,
        rawBY: _savedBY,
        resX: _savedResX!,
        resY: _savedResY!,
      ),
    );
  }

  void _onCalculate() {
    final MidpointResult result;

    if (_mode == StepMode.midpoint) {
      result = MidpointSolver.solve(
        x1: _aXCtrl.text,
        y1: _aYCtrl.text,
        x2: _bXCtrl.text,
        y2: _bYCtrl.text,
      );
    } else {
      result = MidpointSolver.findEndpointFromMidpoint(
        midpointX: _aXCtrl.text,
        midpointY: _aYCtrl.text,
        knownX: _bXCtrl.text,
        knownY: _bYCtrl.text,
      );
    }

    setState(() {
      _solved = true;
      _hasError = result.hasError;

      if (result.hasError) {
        _errorMsg = result.errorMessage ?? 'Calculation error';
        _resX = null;
        _resY = null;
        _formulaX = null;
        _formulaY = null;
      } else {
        _resX = result.x.toString();
        _resY = result.y.toString();
        _formulaX = result.formulaX;
        _formulaY = result.formulaY;
        _savedResX = result.x;
        _savedResY = result.y;

        _savedAX = _aXCtrl.text.trim();
        _savedAY = _aYCtrl.text.trim();
        _savedBX = _bXCtrl.text.trim();
        _savedBY = _bYCtrl.text.trim();
      }
    });
  }

  String get _groupALabel => _mode == StepMode.midpoint ? 'POINT A' : 'MIDPOINT';
  String get _groupBLabel => _mode == StepMode.midpoint ? 'POINT B' : 'KNOWN POINT';

  String get _fieldAX => _mode == StepMode.midpoint ? 'x₁' : 'Mₓ';
  String get _fieldAY => _mode == StepMode.midpoint ? 'y₁' : 'Mᵧ';
  String get _fieldBX => _mode == StepMode.midpoint ? 'x₂' : 'x₁';
  String get _fieldBY => _mode == StepMode.midpoint ? 'y₂' : 'y₁';

  String get _resultLabel => _mode == StepMode.midpoint ? 'MIDPOINT' : 'ENDPOINT';
  String get _resultPrefix => _mode == StepMode.midpoint ? 'M' : 'B';

  String get _formulaHint => _mode == StepMode.midpoint
      ? 'M = ((x₁+x₂)/2, (y₁+y₂)/2)'
      : 'x₂ = 2Mₓ − x₁ , y₂ = 2Mᵧ − y₁';

  String get _buttonLabel =>
      _mode == StepMode.midpoint ? 'Calculate Midpoint' : 'Find Endpoint';

  void _openGraph() {
    if (_savedResX == null || _savedResY == null) return;

    double p(String s) {
      if (s.contains('/')) {
        final parts = s.split('/');
        if (parts.length == 2) {
          final n = double.tryParse(parts[0].trim());
          final d = double.tryParse(parts[1].trim());
          if (n != null && d != null && d != 0) return n / d;
        }
      }
      return double.tryParse(s) ?? 0.0;
    }

    final ax = p(_savedAX);
    final ay = p(_savedAY);
    final bx = p(_savedBX);
    final by = p(_savedBY);
    final rx = _savedResX!.toDouble();
    final ry = _savedResY!.toDouble();

    if (_mode == StepMode.midpoint) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MidpointGraphScreen(
            x1: ax,
            y1: ay,
            x2: bx,
            y2: by,
            mx: rx,
            my: ry,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MidpointGraphScreen(
            x1: bx,
            y1: by,
            x2: rx,
            y2: ry,
            mx: ax,
            my: ay,
          ),
        ),
      );
    }
  }

  Widget _buildSegmentedControl() {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: MidpointTheme.card(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MidpointTheme.accent15(context)),
      ),
      child: Row(
        children: [
          _buildSegment('Midpoint', Icons.center_focus_strong_rounded, StepMode.midpoint),
          _buildSegment('Endpoint', Icons.adjust_rounded, StepMode.endpoint),
        ],
      ),
    );
  }

  Widget _buildSegment(String label, IconData icon, StepMode mode) {
    final isActive = _mode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => _switchMode(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isActive ? MidpointTheme.accent(context) : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 14,
                  color: isActive
                      ? MidpointTheme.surface(context)
                      : MidpointTheme.text40(context)),
              const SizedBox(width: 6),
              ResponsiveText(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isActive
                      ? MidpointTheme.surface(context)
                      : MidpointTheme.text40(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    TextInputAction? textInputAction,
    VoidCallback? onEditingComplete,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveText(label, style: MidpointTheme.inputLabel(context)),
        const SizedBox(height: MidpointTheme.spaceXs),
        Container(
          decoration: MidpointTheme.inputDecoration(context),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: TextInputType.text,
            style: MidpointTheme.inputText(context),
            textInputAction: textInputAction,
            onEditingComplete: onEditingComplete,
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: MidpointTheme.inputHint(context),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            onChanged: null,
            autocorrect: false,
            enableSuggestions: false,
            cursorWidth: 2,
            cursorColor: MidpointTheme.accent(context),
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard(double screenWidth) {
    final cardPadding = screenWidth < 380 ? 14.0 : 20.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        gradient: MidpointTheme.resultGradient(context),
        borderRadius: BorderRadius.circular(MidpointTheme.radius2xl),
        border: Border.all(
          color: MidpointTheme.accent30(context),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              ResponsiveText(_resultLabel, style: MidpointTheme.resultLabel(context)),
              GestureDetector(
                onTap: _openStepsModal,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: FinalsTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: FinalsTheme.primary.withValues(alpha: 0.35),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.receipt_long_rounded,
                          size: 14, color: FinalsTheme.primary),
                      SizedBox(width: 4),
                      ResponsiveText(
                        'Show steps',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: FinalsTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: _openGraph,
                child: _buildGraphChip(),
              ),
            ],
          ),
          const SizedBox(height: MidpointTheme.spaceMd),
          ResponsiveText(
            '$_resultPrefix = (${_resX ?? '\u2014'}, ${_resY ?? '\u2014'})',
            style: MidpointTheme.resultValue(context),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: MidpointTheme.spaceLg),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: MidpointTheme.spaceMd),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  borderRadius:
                      BorderRadius.circular(MidpointTheme.radiusSm),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ResponsiveText(
                      _formulaX ?? '',
                      style: MidpointTheme.resultFormula(context),
                    ),
                    const SizedBox(height: 4),
                    ResponsiveText(
                      _formulaY ?? '',
                      style: MidpointTheme.resultFormula(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGraphChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: MidpointTheme.accent(context).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
            color: MidpointTheme.accent(context).withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.show_chart_rounded,
              size: 14, color: MidpointTheme.accent(context)),
          const SizedBox(width: 4),
          ResponsiveText(
            'Graph',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: MidpointTheme.accent(context),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final hPad = screenWidth < 360 ? 14.0 : 20.0;

    return Scaffold(
      backgroundColor: MidpointTheme.surface(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(hPad, 28, hPad, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: MidpointTheme.card(context),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: MidpointTheme.accent15(context)),
                        ),
                        child: Icon(Icons.arrow_back_rounded,
                            color: MidpointTheme.text(context), size: 22),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: MidpointTheme.headerIconDecoration(
                          context, MidpointTheme.accent10(context)),
                      child: Icon(Icons.center_focus_strong_rounded,
                          color: MidpointTheme.accent(context), size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ResponsiveText(
                            _mode == StepMode.midpoint
                                ? 'Midpoint'
                                : 'Endpoint',
                            style: MidpointTheme.headerTitle(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: MidpointTheme.space5xl),
                _buildSegmentedControl(),
                const SizedBox(height: MidpointTheme.space5xl),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: MidpointTheme.spaceMd),
                  decoration: MidpointTheme.formulaHintDecoration(context),
                  child: Row(
                    children: [
                      Icon(Icons.functions_rounded,
                          color: MidpointTheme.accent50(context), size: 16),
                      const SizedBox(width: MidpointTheme.spaceXl),
                      Expanded(
                        child: ResponsiveText(
                          _formulaHint,
                          style: MidpointTheme.formulaText(context),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: MidpointTheme.space5xl),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ResponsiveText(_groupALabel,
                              style: MidpointTheme.pointLabel(context)),
                          const SizedBox(height: MidpointTheme.spaceMd),
                          _buildInputField(
                            label: _fieldAX,
                            controller: _aXCtrl,
                            focusNode: _aXFocus,
                            textInputAction: TextInputAction.next,
                            onEditingComplete: () => _aYFocus.requestFocus(),
                          ),
                          const SizedBox(height: MidpointTheme.spaceMd),
                          _buildInputField(
                            label: _fieldAY,
                            controller: _aYCtrl,
                            focusNode: _aYFocus,
                            textInputAction: TextInputAction.next,
                            onEditingComplete: () => _bXFocus.requestFocus(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Padding(
                      padding: const EdgeInsets.only(top: 52),
                      child: Column(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: MidpointTheme.accent30(context),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: MidpointTheme.accent15(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ResponsiveText(_groupBLabel,
                              style: MidpointTheme.pointLabel(context)),
                          const SizedBox(height: MidpointTheme.spaceMd),
                          _buildInputField(
                            label: _fieldBX,
                            controller: _bXCtrl,
                            focusNode: _bXFocus,
                            textInputAction: TextInputAction.next,
                            onEditingComplete: () => _bYFocus.requestFocus(),
                          ),
                          const SizedBox(height: MidpointTheme.spaceMd),
                          _buildInputField(
                            label: _fieldBY,
                            controller: _bYCtrl,
                            focusNode: _bYFocus,
                            textInputAction: TextInputAction.done,
                            onEditingComplete: () => _bYFocus.unfocus(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: MidpointTheme.space4xl),
                GestureDetector(
                  onTap: _onCalculate,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: MidpointTheme.space2xl),
                    decoration: BoxDecoration(
                      color: MidpointTheme.accent(context),
                      borderRadius:
                          BorderRadius.circular(MidpointTheme.radiusXl),
                      boxShadow: MidpointTheme.accentShadow(context),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calculate_rounded,
                            color: MidpointTheme.surface(context), size: 18),
                        const SizedBox(width: MidpointTheme.spaceSm),
                        ResponsiveText(_buttonLabel,
                            style: MidpointTheme.calculateButton(context)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (_solved) ...[
                  const SizedBox(height: MidpointTheme.space4xl),
                  if (_hasError)
                    Container(
                      padding: const EdgeInsets.all(MidpointTheme.space2xl),
                      decoration: MidpointTheme.errorDecoration(context),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded,
                              color: MidpointTheme.error, size: 18),
                          const SizedBox(width: MidpointTheme.spaceXl),
                          Expanded(
                              child: ResponsiveText(_errorMsg,
                                  style: MidpointTheme.errorText)),
                        ],
                      ),
                    )
                  else
                    _buildResultCard(screenWidth),
                ],
              ],
            ),
          ),
        ),
    );
  }
}
