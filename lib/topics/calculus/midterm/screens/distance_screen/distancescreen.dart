import 'dart:math';
import 'package:calculus_system/topics/calculus/midterm/graph/distance_graph/distance_graph.dart';
import 'package:calculus_system/topics/calculus/midterm/solvers/distance_solver/distancesolver.dart';
import 'package:calculus_system/shared/widgets/solution_steps_modal.dart';
import 'package:calculus_system/theme/app_design.dart';
import 'package:calculus_system/shared/widgets/responsive_text.dart';
import 'distancesteps.dart';
import 'package:flutter/material.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:calculus_system/shared/widgets/accent_glow.dart';

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

  double _parsedX1 = 0;
  double _parsedX2 = 0;
  double? _parsedY1;
  double? _parsedY2;
  double _calculatedDistance = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
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

  void _openStepsModal() {
    if (!_solved || _hasError) return;
    showSolutionStepsModal(
      context: context,
      title: 'Distance Formula \u2014 Step by Step',
      design: AppDesign.app,
      child: DistanceSteps(
        is2D: _is2D,
        x1: _parsedX1,
        y1: _parsedY1,
        x2: _parsedX2,
        y2: _parsedY2,
        distance: _calculatedDistance,
      ),
    );
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

  /// Formats the distance for display.
  /// - For 1D: returns absolute value (integer or trimmed decimal).
  /// - For 2D:
  ///   - Perfect square ? integer (e.g., "5")
  ///   - Non-perfect square ? exact radical + approximation (e.g., "v5 � 2.2361")
  String _formatDistance(double value, bool is2D) {
    if (!is2D) {
      final abs = value.abs();
      return abs == abs.toInt()
          ? abs.toInt().toString()
          : abs
              .toStringAsFixed(6)
              .replaceAll(RegExp(r'0+$'), '')
              .replaceAll(RegExp(r'\.$'), '');
    }

    final int squared = (value * value).round();
    final double sqrtVal = sqrt(squared);

    // Perfect square ? return integer only
    if (sqrtVal == sqrtVal.roundToDouble()) {
      return sqrtVal.round().toString();
    }

    // Simplify radical
    int largestSquare = 1;
    int remaining = squared;
    for (int i = 2; i * i <= squared; i++) {
      while (remaining % (i * i) == 0) {
        largestSquare *= i;
        remaining ~/= (i * i);
      }
    }

    String exact;
    if (remaining == 1) {
      exact = largestSquare.toString();
    } else if (largestSquare == 1) {
      exact = 'v$remaining';
    } else {
      exact = '$largestSquare√$remaining';
    }

    // Decimal approximation (trimmed to 4 decimal places)
    final approx = value
        .toStringAsFixed(4)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');

    return '$exact � $approx';
  }

  void _onCalculate() {
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
        ResponsiveText(label,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: context
                    .watch<ThemeProvider>()
                    .textPrimary
                    .withValues(alpha: 0.4),
                letterSpacing: 0.8)),
        const SizedBox(height: 6.0),
        GestureDetector(
          onTap: () => focusNode.requestFocus(),
          child: Container(
            decoration: BoxDecoration(
                color: context.watch<ThemeProvider>().card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: context
                        .watch<ThemeProvider>()
                        .accentColor
                        .withValues(alpha: 0.15),
                    width: 1)),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              keyboardType: TextInputType.text,
              textInputAction: nextFocus != null
                  ? TextInputAction.next
                  : TextInputAction.done,
              onEditingComplete: nextFocus != null
                  ? () => nextFocus.requestFocus()
                  : () => focusNode.unfocus(),
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: context.watch<ThemeProvider>().textPrimary),
              decoration: InputDecoration(
                hintText: '0',
                hintStyle: TextStyle(
                    color: context
                        .watch<ThemeProvider>()
                        .textPrimary
                        .withValues(alpha: 0.2),
                    fontSize: 18),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onChanged: null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModeButton(String label, bool active, VoidCallback onTap) {
    final theme = context.watch<ThemeProvider>();
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          decoration: BoxDecoration(
            color: active
                ? context.watch<ThemeProvider>().accentColor
                : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: ResponsiveText(
            label,
            textAlign: TextAlign.center,
            style: active
                ? TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.surface)
                : TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: context
                        .watch<ThemeProvider>()
                        .textPrimary
                        .withValues(alpha: 0.35)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: context.watch<ThemeProvider>().surface,
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -- Header ----------------------------------
              Row(
                children: [
                  AccentGlow.iconHalo(
                    context,
                    child: IconButton(
                      onPressed: _goBack,
                      icon: Icon(Icons.arrow_back_rounded,
                          color: context.watch<ThemeProvider>().accentColor,
                          size: 22),
                      style: IconButton.styleFrom(
                        backgroundColor: context
                            .watch<ThemeProvider>()
                            .accentColor
                            .withValues(alpha: 0.12),
                        foregroundColor:
                            context.watch<ThemeProvider>().accentColor,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: context
                                .watch<ThemeProvider>()
                                .accentColor
                                .withValues(alpha: 0.40),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                        color: context.watch<ThemeProvider>().accentColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: context
                                .watch<ThemeProvider>()
                                .accentColor
                                .withValues(alpha: 0.15))),
                    child: Icon(Icons.straighten_rounded,
                        color: context.watch<ThemeProvider>().surface,
                        size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ResponsiveText('Distance',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color:
                                    context.watch<ThemeProvider>().textPrimary,
                                letterSpacing: -0.5,
                                shadows: [
                                  Shadow(
                                    color: context
                                        .watch<ThemeProvider>()
                                        .accentColor
                                        .withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: Offset.zero,
                                  ),
                                ])),
                        ResponsiveText(
                          _is2D ? 'Two points in a plane' : 'Number line',
                          style: TextStyle(
                              fontSize: 12,
                              color: context.watch<ThemeProvider>().accentColor,
                              shadows: [
                                Shadow(
                                  color: context
                                      .watch<ThemeProvider>()
                                      .accentColor
                                      .withValues(alpha: 0.15),
                                  blurRadius: 4,
                                  offset: Offset.zero,
                                ),
                              ]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28.0),

              // -- Mode toggle ------------------------------
              Container(
                decoration: BoxDecoration(
                        color: context.watch<ThemeProvider>().card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: context
                                .watch<ThemeProvider>()
                                .accentColor
                                .withValues(alpha: 0.1)))
                    .copyWith(
                  border: Border.all(
                      color: context
                          .watch<ThemeProvider>()
                          .accentColor
                          .withValues(alpha: 0.12)),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    _buildModeButton('Number Line (1D)', !_is2D, () {
                      setState(() {
                        _is2D = false;
                        _solved = false;
                      });
                    }),
                    _buildModeButton('Coordinate (2D)', _is2D, () {
                      setState(() {
                        _is2D = true;
                        _solved = false;
                      });
                    }),

                    const SizedBox(height: 28.0),

// -- Formula hint -----------------------------
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10.0),
                      decoration: BoxDecoration(
                          color: context
                              .watch<ThemeProvider>()
                              .accentColor
                              .withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: context
                                  .watch<ThemeProvider>()
                                  .accentColor
                                  .withValues(alpha: 0.12))),
                      child: Row(
                        children: [
                          Icon(Icons.functions_rounded,
                              color: context.watch<ThemeProvider>().accentColor,
                              size: 16),
                          const SizedBox(width: 14.0),
                          ResponsiveText(
                            _is2D
                                ? 'd = v((x2-x1)² + (y2-y1)²)'
                                : 'd = |x2 - x1|',
                            style: TextStyle(
                                fontSize: 13,
                                color: context
                                    .watch<ThemeProvider>()
                                    .textPrimary
                                    .withValues(alpha: 0.55),
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28.0),

              // -- Inputs -----------------------------------
              if (!_is2D) ...[
                Row(
                  children: [
                    Expanded(
                      child: _buildInputField(
                        label: 'POINT x1',
                        controller: _x1Ctrl,
                        focusNode: _x1Focus,
                        nextFocus: _x2Focus,
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    const Padding(
                      padding: EdgeInsets.only(top: 22),
                      child: Icon(Icons.arrow_forward_rounded,
                          color: const Color(0x4D334155), size: 20),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: _buildInputField(
                        label: 'POINT x2',
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
                          ResponsiveText('POINT A',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: context
                                      .watch<ThemeProvider>()
                                      .accentColor,
                                  letterSpacing: 1.2)),
                          const SizedBox(height: 10.0),
                          _buildInputField(
                            label: 'x1',
                            controller: _x1Ctrl,
                            focusNode: _x1Focus,
                            nextFocus: _y1Focus,
                          ),
                          const SizedBox(height: 10.0),
                          _buildInputField(
                            label: 'y1',
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
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0x4D334155)),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0x26334155)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ResponsiveText('POINT B',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: context
                                      .watch<ThemeProvider>()
                                      .accentColor,
                                  letterSpacing: 1.2)),
                          const SizedBox(height: 10.0),
                          _buildInputField(
                            label: 'x2',
                            controller: _x2Ctrl,
                            focusNode: _x2Focus,
                            nextFocus: _y2Focus,
                          ),
                          const SizedBox(height: 10.0),
                          _buildInputField(
                            label: 'y2',
                            controller: _y2Ctrl,
                            focusNode: _y2Focus,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 24.0),

              // -- Calculate button -------------------------
              GestureDetector(
                onTap: _onCalculate,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14.0),
                    boxShadow: [AccentGlow.halo(context)],
                  ),
                  child: ElevatedButton(
                    onPressed: _onCalculate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          context.watch<ThemeProvider>().accentColor,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.0)),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calculate_rounded,
                            color: context.watch<ThemeProvider>().surface,
                            size: 18),
                        const SizedBox(width: 8.0),
                        ResponsiveText('Calculate Distance',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: context.watch<ThemeProvider>().surface,
                                letterSpacing: 0.3)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // -- Results Section ------------------------------
              if (_solved) ...[
                const SizedBox(height: 24.0),
                if (_hasError)
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                        color: context.watch<ThemeProvider>().isLight
                            ? const Color(0xFFFFEAEA)
                            : const Color(0xFF2A1010),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0x4DFF6B6B))),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded,
                            color: const Color(0xFFFF6B6B), size: 18),
                        const SizedBox(width: 14.0),
                        Expanded(
                            child: ResponsiveText(_errorMsg,
                                style: const TextStyle(
                                    color: Color(0xFFFF6B6B), fontSize: 14))),
                      ],
                    ),
                  )
                else ...[
                  // -- VIEW GRAPH BUTTON -------------------------
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [AccentGlow.soft(context)],
                    ),
                    child: OutlinedButton(
                      onPressed: _openGraph,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: context
                            .watch<ThemeProvider>()
                            .accentColor
                            .withValues(alpha: 0.1),
                        side: BorderSide(
                            color: context
                                .watch<ThemeProvider>()
                                .accentColor
                                .withValues(alpha: 0.3)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _is2D
                                ? Icons.scatter_plot_rounded
                                : Icons.linear_scale_rounded,
                            color: context.watch<ThemeProvider>().accentColor,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          ResponsiveText(
                            'View Graph',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: context.watch<ThemeProvider>().accentColor,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: context.watch<ThemeProvider>().accentColor,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // -- Result Card --------------------------------
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        context
                            .watch<ThemeProvider>()
                            .accentColor
                            .withValues(alpha: 0.15),
                        context
                            .watch<ThemeProvider>()
                            .accentColor
                            .withValues(alpha: 0.06)
                      ], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(18.0),
                      border: Border.all(
                        color: context
                            .watch<ThemeProvider>()
                            .accentColor
                            .withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ResponsiveText('DISTANCE',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color:
                                    context.watch<ThemeProvider>().accentColor,
                                letterSpacing: 1.4,
                                shadows: [
                                  Shadow(
                                    color: context
                                        .watch<ThemeProvider>()
                                        .accentColor
                                        .withValues(alpha: 0.3),
                                    blurRadius: 6,
                                    offset: Offset.zero,
                                  ),
                                ])),
                        const SizedBox(height: 10.0),
                        ResponsiveText(
                          'd = ${_distance ?? '\u2014'}',
                          style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              color: context.watch<ThemeProvider>().textPrimary,
                              letterSpacing: -1.0),
                        ),
                        if (_formula != null) ...[
                          const SizedBox(height: 12.0),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10.0),
                            decoration: BoxDecoration(
                              color: context
                                  .watch<ThemeProvider>()
                                  .accentColor
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: ResponsiveText(
                              _formula!,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: context
                                      .watch<ThemeProvider>()
                                      .textPrimary
                                      .withValues(alpha: 0.55),
                                  fontWeight: FontWeight.w500,
                                  height: 1.4),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // -- Show Steps Button --------------------------
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _openStepsModal,
                      icon: Icon(
                        Icons.receipt_long_rounded,
                        size: 14,
                        color: context.watch<ThemeProvider>().accentColor,
                      ),
                      label: ResponsiveText(
                        'Show Steps',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: context.watch<ThemeProvider>().accentColor,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: context
                              .watch<ThemeProvider>()
                              .accentColor
                              .withValues(alpha: 0.35),
                        ),
                        backgroundColor: context
                            .watch<ThemeProvider>()
                            .accentColor
                            .withValues(alpha: 0.08),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ],

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
