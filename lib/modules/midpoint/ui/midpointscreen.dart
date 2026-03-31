import 'package:flutter/material.dart';

import '../Solver/midpointsolver.dart';
import '../Theme/midpointtheme.dart';
import '../Solver/midpointsteps.dart';

class MidpointScreen extends StatefulWidget {
  const MidpointScreen({super.key});

  @override
  State<MidpointScreen> createState() => _MidpointScreenState();
}

class _MidpointScreenState extends State<MidpointScreen> {
  // ── Mode ──────────────────────────────────────────────────
  StepMode _mode = StepMode.midpoint;

  // ── Controllers & focus ───────────────────────────────────
  final _aXCtrl = TextEditingController();
  final _aYCtrl = TextEditingController();
  final _bXCtrl = TextEditingController();
  final _bYCtrl = TextEditingController();

  final _aXFocus = FocusNode();
  final _aYFocus = FocusNode();
  final _bXFocus = FocusNode();
  final _bYFocus = FocusNode();

  // ── Result state ──────────────────────────────────────────
  String? _resX;
  String? _resY;
  String? _formulaX;
  String? _formulaY;
  bool _solved = false;
  bool _hasError = false;
  String _errorMsg = '';
  bool _showSteps = false;

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
      _showSteps = false;
    });
  }

  void _toggleSteps() => setState(() => _showSteps = !_showSteps);

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
      _showSteps = false;

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

  // ── Label helpers ─────────────────────────────────────────
  String get _groupALabel =>
      _mode == StepMode.midpoint ? 'POINT A' : 'MIDPOINT';
  String get _groupBLabel =>
      _mode == StepMode.midpoint ? 'POINT B' : 'KNOWN POINT';

  String get _fieldAX => _mode == StepMode.midpoint ? 'x₁' : 'Mₓ';
  String get _fieldAY => _mode == StepMode.midpoint ? 'y₁' : 'Mᵧ';
  String get _fieldBX => _mode == StepMode.midpoint ? 'x₂' : 'x₁';
  String get _fieldBY => _mode == StepMode.midpoint ? 'y₂' : 'y₁';

  String get _resultLabel =>
      _mode == StepMode.midpoint ? 'MIDPOINT' : 'ENDPOINT';
  String get _resultPrefix => _mode == StepMode.midpoint ? 'M' : 'B';

  String get _formulaHint => _mode == StepMode.midpoint
      ? 'M = ((x₁+x₂)/2, (y₁+y₂)/2)'
      : 'x₂ = 2Mₓ − x₁ , y₂ = 2Mᵧ − y₁';

  String get _buttonLabel =>
      _mode == StepMode.midpoint ? 'Calculate Midpoint' : 'Find Endpoint';

  // ── Widgets ───────────────────────────────────────────────

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
          _buildSegment(
              'Midpoint', Icons.center_focus_strong_rounded, StepMode.midpoint),
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
            color:
                isActive ? MidpointTheme.accent(context) : Colors.transparent,
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
              Text(
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
    FocusNode? nextFocus,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: MidpointTheme.inputLabel(context)),
        const SizedBox(height: MidpointTheme.spaceXs),
        Container(
          decoration: MidpointTheme.inputDecoration(context),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: TextInputType.text,
            style: MidpointTheme.inputText(context),
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: MidpointTheme.inputHint(context),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            onEditingComplete: () {
              if (nextFocus != null) {
                nextFocus.requestFocus();
              } else {
                focusNode.unfocus();
                _onCalculate();
              }
            },
            autocorrect: false,
            enableSuggestions: false,
            cursorWidth: 2,
            cursorColor: MidpointTheme.accent(context),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          backgroundColor: MidpointTheme.surface(context),
          resizeToAvoidBottomInset: true,
          body: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollStartNotification) {
                FocusScope.of(context).unfocus();
              }
              return false;
            },
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
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
                            Text(
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
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      key: ValueKey(_formulaHint),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: MidpointTheme.spaceMd),
                      decoration: MidpointTheme.formulaHintDecoration(context),
                      child: Row(
                        children: [
                          Icon(Icons.functions_rounded,
                              color: MidpointTheme.accent50(context), size: 16),
                          const SizedBox(width: MidpointTheme.spaceXl),
                          Text(_formulaHint,
                              style: MidpointTheme.formulaText(context)),
                        ],
                      ),
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
                            Text(_groupALabel,
                                style: MidpointTheme.pointLabel(context)),
                            const SizedBox(height: MidpointTheme.spaceMd),
                            _buildInputField(
                              label: _fieldAX,
                              controller: _aXCtrl,
                              focusNode: _aXFocus,
                              nextFocus: _aYFocus,
                            ),
                            const SizedBox(height: MidpointTheme.spaceMd),
                            _buildInputField(
                              label: _fieldAY,
                              controller: _aYCtrl,
                              focusNode: _aYFocus,
                              nextFocus: _bXFocus,
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
                            Text(_groupBLabel,
                                style: MidpointTheme.pointLabel(context)),
                            const SizedBox(height: MidpointTheme.spaceMd),
                            _buildInputField(
                              label: _fieldBX,
                              controller: _bXCtrl,
                              focusNode: _bXFocus,
                              nextFocus: _bYFocus,
                            ),
                            const SizedBox(height: MidpointTheme.spaceMd),
                            _buildInputField(
                              label: _fieldBY,
                              controller: _bYCtrl,
                              focusNode: _bYFocus,
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
                          Text(_buttonLabel,
                              style: MidpointTheme.calculateButton(context)),
                        ],
                      ),
                    ),
                  ),
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
                                child: Text(_errorMsg,
                                    style: MidpointTheme.errorText)),
                          ],
                        ),
                      )
                    else ...[
                      GestureDetector(
                        onTap: _toggleSteps,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: MidpointTheme.resultGradient(context),
                            borderRadius:
                                BorderRadius.circular(MidpointTheme.radius2xl),
                            border: Border.all(
                              color: _showSteps
                                  ? MidpointTheme.accent(context)
                                  : MidpointTheme.accent30(context),
                              width: _showSteps ? 2 : 1,
                            ),
                            boxShadow: _showSteps
                                ? [
                                    BoxShadow(
                                      color: MidpointTheme.accent(context)
                                          .withValues(alpha: 0.2),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(_resultLabel,
                                      style: MidpointTheme.resultLabel(context)),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _showSteps
                                          ? MidpointTheme.accent(context)
                                              .withValues(alpha: 0.2)
                                          : MidpointTheme.accent(context)
                                              .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _showSteps
                                              ? 'Hide steps'
                                              : 'Show steps',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color:
                                                MidpointTheme.accent(context),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        AnimatedRotation(
                                          turns: _showSteps ? 0.5 : 0,
                                          duration:
                                              const Duration(milliseconds: 200),
                                          child: Icon(
                                              Icons.keyboard_arrow_down_rounded,
                                              color:
                                                  MidpointTheme.accent(context),
                                              size: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: MidpointTheme.spaceMd),
                              Text(
                                  '$_resultPrefix = (${_resX ?? '—'}, ${_resY ?? '—'})',
                                  style: MidpointTheme.resultValue(context)),
                              if (!_showSteps) ...[
                                const SizedBox(height: MidpointTheme.spaceLg),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: MidpointTheme.spaceMd),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(
                                        MidpointTheme.radiusSm),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(_formulaX ?? '',
                                          style: MidpointTheme.resultFormula(
                                              context)),
                                      const SizedBox(height: 4),
                                      Text(_formulaY ?? '',
                                          style: MidpointTheme.resultFormula(
                                              context)),
                                    ],
                                  ),
                                ),
                              ],
                              AnimatedCrossFade(
                                firstChild: const SizedBox.shrink(),
                                secondChild: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 20),
                                    Container(
                                      width: double.infinity,
                                      height: 1,
                                      color: MidpointTheme.accent(context)
                                          .withValues(alpha: 0.2),
                                      margin: const EdgeInsets.only(bottom: 20),
                                    ),
                                    if (_savedResX != null &&
                                        _savedResY != null)
                                      MidpointSteps(
                                        mode: _mode,
                                        rawAX: _savedAX,
                                        rawAY: _savedAY,
                                        rawBX: _savedBX,
                                        rawBY: _savedBY,
                                        resX: _savedResX!,
                                        resY: _savedResY!,
                                      ),
                                  ],
                                ),
                                crossFadeState: _showSteps
                                    ? CrossFadeState.showSecond
                                    : CrossFadeState.showFirst,
                                duration: const Duration(milliseconds: 250),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                  const SizedBox(height: 300),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
