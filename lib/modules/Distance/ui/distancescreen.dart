import 'dart:math';
import 'package:flutter/material.dart';
import '../solver/distancesolver.dart';
import '../Theme/distancetheme.dart';
import '../solver/distancesteps.dart';
import '../Graph/distance_graph.dart';

class Distancescreen extends StatefulWidget {
  const Distancescreen({super.key});

  @override
  State<Distancescreen> createState() => _DistancescreenState();
}

class _DistancescreenState extends State<Distancescreen> 
    with TickerProviderStateMixin {
  bool _is2D = false;

  final _x1Ctrl = TextEditingController();
  final _y1Ctrl = TextEditingController();
  final _x2Ctrl = TextEditingController();
  final _y2Ctrl = TextEditingController();

  final _x1Focus = FocusNode();
  final _y1Focus = FocusNode();
  final _x2Focus = FocusNode();
  final _y2Focus = FocusNode();

  // Result state
  String? _distance;
  String? _formula;
  bool _solved = false;
  bool _hasError = false;
  String _errorMsg = '';
  bool _showSteps = false;
  
  double _parsedX1 = 0;
  double _parsedX2 = 0;
  double? _parsedY1;
  double? _parsedY2;
  double _calculatedDistance = 0;

  @override
  void initState() {
    super.initState();
    _x1Ctrl.addListener(_onTextChanged);
    _y1Ctrl.addListener(_onTextChanged);
    _x2Ctrl.addListener(_onTextChanged);
    _y2Ctrl.addListener(_onTextChanged);
  }

  void _onTextChanged() {
  }

  @override
  void dispose() {
    _x1Ctrl.removeListener(_onTextChanged);
    _y1Ctrl.removeListener(_onTextChanged);
    _x2Ctrl.removeListener(_onTextChanged);
    _y2Ctrl.removeListener(_onTextChanged);
    
    _x1Ctrl.dispose();
    _y1Ctrl.dispose();
    _x2Ctrl.dispose();
    _y2Ctrl.dispose();
    _x1Focus.dispose();
    _y1Focus.dispose();
    _x2Focus.dispose();
    _y2Focus.dispose();
    super.dispose();
  }

  void _goBack() => Navigator.of(context).pop();

  void _toggleSteps() {
    setState(() {
      _showSteps = !_showSteps;
    });
  }

  void _openGraph() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DistanceGraphScreen(
          is2D: _is2D,
          x1: _parsedX1,
          y1: _parsedY1,
          x2: _parsedX2,
          y2: _parsedY2,
          distance: _calculatedDistance,
          distanceLabel: _distance ?? '',
        ),
      ),
    );
  }

  String _formatDistance(double value, bool is2D) {
    if (!is2D) {
      final abs = value.abs();
      return abs == abs.toInt() 
          ? abs.toInt().toString() 
          : abs.toStringAsFixed(6).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    }
    
    final int squared = (value * value).round();
    final double sqrtVal = sqrt(squared);
    
    if (sqrtVal == sqrtVal.roundToDouble()) {
      return sqrtVal.round().toString();
    }
    
    int largestSquare = 1;
    int remaining = squared;
    
    for (int i = 2; i * i <= squared; i++) {
      while (remaining % (i * i) == 0) {
        largestSquare *= i;
        remaining ~/= (i * i);
      }
    }
    
    if (largestSquare == 1) {
      return value.toStringAsFixed(4).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    }
    
    if (remaining == 1) return largestSquare.toString();
    return '$largestSquare√$remaining';
  }

  void _onCalculate() {
    FocusScope.of(context).unfocus();

    final result = DistanceSolver.solve(
      x1: _x1Ctrl.text,
      x2: _x2Ctrl.text,
      y1: _is2D ? _y1Ctrl.text : null,
      y2: _is2D ? _y2Ctrl.text : null,
      is2D: _is2D,
    );

    setState(() {
      _solved = true;
      _hasError = result.hasError;
      _showSteps = false;
      
      if (result.hasError) {
        _errorMsg = result.errorMessage ?? 'Calculation error';
        _distance = null;
        _formula = null;
      } else {
        final d = result.distance!;
        _calculatedDistance = d;
        _distance = _formatDistance(d, _is2D);
        _formula = result.formula;
        
        _parsedX1 = double.parse(_x1Ctrl.text);
        _parsedX2 = double.parse(_x2Ctrl.text);
        _parsedY1 = _is2D ? double.parse(_y1Ctrl.text) : null;
        _parsedY2 = _is2D ? double.parse(_y2Ctrl.text) : null;
      }
    });
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
        Text(label, style: DistanceTheme.inputLabel(context)),
        const SizedBox(height: DistanceTheme.spaceXs),
        Container(
          decoration: DistanceTheme.inputDecoration(context),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
            style: DistanceTheme.inputText(context),
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: DistanceTheme.inputHint(context),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            onChanged: null,
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
            enableInteractiveSelection: true,
            cursorWidth: 2,
            cursorColor: DistanceTheme.accent,
          ),
        ),
      ],
    );
  }

  Widget _buildModeButton(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: DistanceTheme.modeSwitchDuration,
          padding: const EdgeInsets.symmetric(vertical: DistanceTheme.spaceMd),
          decoration: BoxDecoration(
            color: active ? DistanceTheme.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: active ? DistanceTheme.modeButtonActive : DistanceTheme.modeButtonInactive(context),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: DistanceTheme.surface(context),
        resizeToAvoidBottomInset: false,
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

                // ── Header ──────────────────────────────────
                Row(
                  children: [
                    GestureDetector(
                      onTap: _goBack,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: DistanceTheme.card(context),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: DistanceTheme.accent15),
                        ),
                        child: Icon(Icons.arrow_back_rounded, color: DistanceTheme.text(context), size: 22),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: DistanceTheme.headerIconDecoration(DistanceTheme.accent12),
                      child: const Icon(Icons.straighten_rounded, color: DistanceTheme.accent, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Distance', style: DistanceTheme.headerTitle(context)),
                          Text(
                            _is2D ? 'Two points in a plane' : 'Number line',
                            style: DistanceTheme.headerSubtitle,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: DistanceTheme.space5xl),

                // ── Mode toggle ──────────────────────────────
                Container(
                  decoration: DistanceTheme.cardDecoration(context).copyWith(
                    border: Border.all(color: DistanceTheme.accent12),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      _buildModeButton('Number Line (1D)', !_is2D, () {
                        setState(() { _is2D = false; _solved = false; _showSteps = false; });
                      }),
                      _buildModeButton('Coordinate (2D)', _is2D, () {
                        setState(() { _is2D = true; _solved = false; _showSteps = false; });
                      }),
                    ],
                  ),
                ),

                const SizedBox(height: DistanceTheme.space5xl),

                // ── Formula hint ─────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: DistanceTheme.spaceMd),
                  decoration: DistanceTheme.formulaHintDecoration,
                  child: Row(
                    children: [
                      const Icon(Icons.functions_rounded, color: DistanceTheme.accent70, size: 16),
                      const SizedBox(width: DistanceTheme.spaceXl),
                      Text(
                        _is2D ? 'd = √((x₂−x₁)² + (y₂−y₁)²)' : 'd = |x₂ − x₁|',
                        style: DistanceTheme.formulaText(context),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: DistanceTheme.space5xl),

                // ── Inputs ───────────────────────────────────
                if (!_is2D) ...[
                  Row(
                    children: [
                      Expanded(
                        child: _buildInputField(
                          label: 'POINT x₁',
                          controller: _x1Ctrl,
                          focusNode: _x1Focus,
                          nextFocus: _x2Focus,
                         ),
                      ),
                      const SizedBox(width: DistanceTheme.spaceLg),
                  const    Padding(
                        padding:  EdgeInsets.only(top: 22),
                        child: Icon(Icons.arrow_forward_rounded, color: DistanceTheme.accent30, size: 20),
                      ),
                      const SizedBox(width: DistanceTheme.spaceLg),
                      Expanded(
                        child: _buildInputField(
                          label: 'POINT x₂',
                          controller: _x2Ctrl,
                          focusNode: _x2Focus,
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('POINT A', style: DistanceTheme.pointLabel),
                            const SizedBox(height: DistanceTheme.spaceMd),
                            _buildInputField(
                              label: 'x₁',
                              controller: _x1Ctrl,
                              focusNode: _x1Focus,
                              nextFocus: _y1Focus,
                            ),
                            const SizedBox(height: DistanceTheme.spaceMd),
                            _buildInputField(
                              label: 'y₁',
                              controller: _y1Ctrl,
                              focusNode: _y1Focus,
                              nextFocus: _x2Focus,
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
                              decoration: const BoxDecoration(shape: BoxShape.circle, color: DistanceTheme.accent30),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(shape: BoxShape.circle, color: DistanceTheme.accent15),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('POINT B', style: DistanceTheme.pointLabel),
                            const SizedBox(height: DistanceTheme.spaceMd),
                            _buildInputField(
                              label: 'x₂',
                              controller: _x2Ctrl,
                              focusNode: _x2Focus,
                              nextFocus: _y2Focus,
                            ),
                            const SizedBox(height: DistanceTheme.spaceMd),
                            _buildInputField(
                              label: 'y₂',
                              controller: _y2Ctrl,
                              focusNode: _y2Focus,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: DistanceTheme.space4xl),

                // ── Calculate button ─────────────────────────
                GestureDetector(
                  onTap: _onCalculate,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: DistanceTheme.space2xl),
                    decoration: BoxDecoration(
                      color: DistanceTheme.accent,
                      borderRadius: BorderRadius.circular(DistanceTheme.radiusXl),
                      boxShadow: DistanceTheme.accentShadow,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calculate_rounded, color: Colors.white, size: 18),
                        SizedBox(width: DistanceTheme.spaceSm),
                        Text('Calculate Distance', style: DistanceTheme.calculateButton),
                      ],
                    ),
                  ),
                ),

                // ── Results Section ──────────────────────────────
                if (_solved) ...[
                  const SizedBox(height: DistanceTheme.space4xl),
                  
                  if (_hasError)
                    Container(
                      padding: const EdgeInsets.all(DistanceTheme.space2xl),
                      decoration: DistanceTheme.errorDecoration(context),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded, color: DistanceTheme.error, size: 18),
                          const SizedBox(width: DistanceTheme.spaceXl),
                          Expanded(child: Text(_errorMsg, style: DistanceTheme.errorText)),
                        ],
                      ),
                    )
                  else ...[
                    // ── VIEW GRAPH BUTTON ─────────────────────────
                    GestureDetector(
                      onTap: _openGraph,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: DistanceTheme.accent.withValues(alpha :0.1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: DistanceTheme.accent30),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _is2D ? Icons.scatter_plot_rounded : Icons.linear_scale_rounded,
                              color: DistanceTheme.accent,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                       const     Text(
                              'View Graph',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: DistanceTheme.accent,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(width: 8),
                         const    Icon(
                              Icons.arrow_forward_rounded,
                              color: DistanceTheme.accent,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── Result Card with Steps ─────────────────
                    GestureDetector(
                      onTap: _toggleSteps,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: DistanceTheme.resultGradient,
                          borderRadius: BorderRadius.circular(DistanceTheme.radius2xl),
                          border: Border.all(
                            color: _showSteps ? DistanceTheme.accent : DistanceTheme.accent30,
                            width: _showSteps ? 2 : 1,
                          ),
                          boxShadow: _showSteps ? [
                            BoxShadow(
                              color: DistanceTheme.accent.withValues(alpha :0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ] : null,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text('DISTANCE', style: DistanceTheme.resultLabel),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _showSteps 
                                        ? DistanceTheme.accent.withValues(alpha :0.2)
                                        : DistanceTheme.accent.withValues(alpha :0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _showSteps ? 'Hide steps' : 'Show steps',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: DistanceTheme.accent,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      AnimatedRotation(
                                        turns: _showSteps ? 0.5 : 0,
                                        duration: const Duration(milliseconds: 200),
                                        child: const Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: DistanceTheme.accent,
                                          size: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: DistanceTheme.spaceMd),
                            
                            Text(
                              'd = ${_distance ?? '—'}',
                              style: DistanceTheme.resultValue(context),
                            ),
                            
                            if (_formula != null && !_showSteps) ...[
                              const SizedBox(height: DistanceTheme.spaceLg),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: DistanceTheme.spaceMd),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha :0.12),
                                  borderRadius: BorderRadius.circular(DistanceTheme.radiusSm),
                                ),
                                child: Text(
                                  _formula!,
                                  style: DistanceTheme.resultFormula(context),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
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
                                    color: DistanceTheme.accent.withValues(alpha :0.2),
                                    margin: const EdgeInsets.only(bottom: 20),
                                  ),
                                  DistanceSteps(
                                    is2D: _is2D,
                                    x1: _parsedX1,
                                    y1: _parsedY1,
                                    x2: _parsedX2,
                                    y2: _parsedY2,
                                    distance: _calculatedDistance,
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
    );
  }
}