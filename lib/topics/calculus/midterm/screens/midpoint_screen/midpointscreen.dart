import 'package:calculus_system/topics/calculus/midterm/graph/midpoint_graph/midpoint_graph.dart';
import 'package:calculus_system/topics/calculus/midterm/solvers/midpoint_solver/midpointsolver.dart';
import 'package:calculus_system/topics/calculus/midterm/screens/midpoint_screen/midpointsteps.dart';
import 'package:calculus_system/shared/widgets/solution_steps_modal.dart';
import 'package:calculus_system/theme/app_design.dart';
import 'package:calculus_system/shared/widgets/responsive_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:calculus_system/shared/widgets/accent_glow.dart';

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
      design: AppDesign.app,
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

  String get _fieldAX => _mode == StepMode.midpoint ? 'x1' : 'M?';
  String get _fieldAY => _mode == StepMode.midpoint ? 'y1' : 'M?';
  String get _fieldBX => _mode == StepMode.midpoint ? 'x2' : 'x1';
  String get _fieldBY => _mode == StepMode.midpoint ? 'y2' : 'y1';

  String get _resultLabel => _mode == StepMode.midpoint ? 'MIDPOINT' : 'ENDPOINT';
  String get _resultPrefix => _mode == StepMode.midpoint ? 'M' : 'B';

  String get _formulaHint => _mode == StepMode.midpoint
      ? 'M = ((x1+x2)/2, (y1+y2)/2)'
      : 'x2 = 2M? - x1 , y2 = 2M? - y1';

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
    final accent = context.watch<ThemeProvider>().accentColor;
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.watch<ThemeProvider>().card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.15)),
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
    final accent = context.watch<ThemeProvider>().accentColor;
    return Expanded(
      child: GestureDetector(
        onTap: () => _switchMode(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isActive ? accent : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 14,
                  color: isActive
                      ? context.watch<ThemeProvider>().surface
                      : context.watch<ThemeProvider>().textPrimary.withValues(alpha: 0.4)),
              const SizedBox(width: 6),
              ResponsiveText(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isActive
                      ? context.watch<ThemeProvider>().surface
                      : context.watch<ThemeProvider>().textPrimary.withValues(alpha: 0.4),
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
        ResponsiveText(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: context.watch<ThemeProvider>().textPrimary.withValues(alpha: 0.4), letterSpacing: 0.8)),
        const SizedBox(height: 6.0),
        Container(
          decoration: BoxDecoration(color: context.watch<ThemeProvider>().card, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF334155).withValues(alpha: 0.15), width: 1)),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: TextInputType.text,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: context.watch<ThemeProvider>().textPrimary),
            textInputAction: textInputAction,
            onEditingComplete: onEditingComplete,
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: TextStyle(color: context.watch<ThemeProvider>().textPrimary.withValues(alpha: 0.2), fontSize: 18),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            onChanged: null,
            autocorrect: false,
            enableSuggestions: false,
            cursorWidth: 2,
            cursorColor: const Color(0xFF334155),
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard(double screenWidth) {
    final theme = context.watch<ThemeProvider>();
    final accent = theme.accentColor;
    final cardPadding = screenWidth < 380 ? 14.0 : 20.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [accent.withValues(alpha: 0.15), accent.withValues(alpha: 0.06)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(18.0),
        border: Border.all(
          color: accent.withValues(alpha: 0.3),
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
              ResponsiveText(_resultLabel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: accent.withValues(alpha: 0.5), letterSpacing: 1.4)),
              GestureDetector(
                onTap: _openStepsModal,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: accent.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.receipt_long_rounded,
                          size: 14, color: accent),
                      const SizedBox(width: 4),
                      ResponsiveText(
                        'Show steps',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: accent,
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
          const SizedBox(height: 10.0),
          ResponsiveText(
            '$_resultPrefix = (${_resX ?? '\u2014'}, ${_resY ?? '\u2014'})',
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: theme.textPrimary, letterSpacing: -1.0),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12.0),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10.0),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius:
                      BorderRadius.circular(8.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ResponsiveText(
                      _formulaX ?? '',
                      style: TextStyle(fontSize: 12, color: theme.textPrimary.withValues(alpha: 0.5), fontWeight: FontWeight.w500, height: 1.4),
                    ),
                    const SizedBox(height: 4),
                    ResponsiveText(
                      _formulaY ?? '',
                      style: TextStyle(fontSize: 12, color: theme.textPrimary.withValues(alpha: 0.5), fontWeight: FontWeight.w500, height: 1.4),
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
    final accent = context.watch<ThemeProvider>().accentColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
            color: accent.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.show_chart_rounded,
              size: 14, color: accent),
          const SizedBox(width: 4),
          ResponsiveText(
            'Graph',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: accent,
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
      backgroundColor: context.watch<ThemeProvider>().surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(hPad, 28, hPad, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AccentGlow.iconHalo(
                      context,
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(Icons.arrow_back_rounded,
                            color: context.watch<ThemeProvider>().accentColor, size: 22),
                        style: IconButton.styleFrom(
                          backgroundColor: context.watch<ThemeProvider>().accentColor.withValues(alpha: 0.12),
                          foregroundColor: context.watch<ThemeProvider>().accentColor,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: context.watch<ThemeProvider>().accentColor.withValues(alpha: 0.40),
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
                      decoration: BoxDecoration(color: context.watch<ThemeProvider>().accentColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: context.watch<ThemeProvider>().accentColor.withValues(alpha: 0.15))),
                      child: Icon(Icons.center_focus_strong_rounded,
                          color: context.watch<ThemeProvider>().surface, size: 22),
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
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: context.watch<ThemeProvider>().textPrimary, letterSpacing: -0.5,
                                shadows: [
                                  Shadow(
                                    color: context.watch<ThemeProvider>().accentColor.withValues(alpha: 0.3),
                                    blurRadius: 8,
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
                _buildSegmentedControl(),
                const SizedBox(height: 28.0),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10.0),
                  decoration: BoxDecoration(color: context.watch<ThemeProvider>().accentColor.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(10), border: Border.all(color: context.watch<ThemeProvider>().accentColor.withValues(alpha: 0.1))),
                  child: Row(
                    children: [
                      Icon(Icons.functions_rounded,
                          color: context.watch<ThemeProvider>().accentColor.withValues(alpha: 0.5), size: 16),
                      const SizedBox(width: 14.0),
                      Expanded(
                        child: ResponsiveText(
                          _formulaHint,
                          style: TextStyle(fontSize: 13, color: context.watch<ThemeProvider>().textPrimary.withValues(alpha: 0.5), fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28.0),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ResponsiveText(_groupALabel,
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF334155).withValues(alpha: 0.5), letterSpacing: 1.2)),
                          const SizedBox(height: 10.0),
                          _buildInputField(
                            label: _fieldAX,
                            controller: _aXCtrl,
                            focusNode: _aXFocus,
                            textInputAction: TextInputAction.next,
                            onEditingComplete: () => _aYFocus.requestFocus(),
                          ),
                          const SizedBox(height: 10.0),
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
                              color: const Color(0xFF334155).withValues(alpha: 0.3),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF334155).withValues(alpha: 0.15),
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
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF334155).withValues(alpha: 0.5), letterSpacing: 1.2)),
                          const SizedBox(height: 10.0),
                          _buildInputField(
                            label: _fieldBX,
                            controller: _bXCtrl,
                            focusNode: _bXFocus,
                            textInputAction: TextInputAction.next,
                            onEditingComplete: () => _bYFocus.requestFocus(),
                          ),
                          const SizedBox(height: 10.0),
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
                const SizedBox(height: 24.0),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14.0),
                    boxShadow: [AccentGlow.halo(context)],
                  ),
                  child: ElevatedButton(
                    onPressed: _onCalculate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.watch<ThemeProvider>().accentColor,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calculate_rounded,
                            color: context.watch<ThemeProvider>().surface, size: 18),
                        const SizedBox(width: 8.0),
                        ResponsiveText(_buttonLabel,
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: context.watch<ThemeProvider>().surface, letterSpacing: 0.3)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (_solved) ...[
                  const SizedBox(height: 24.0),
                  if (_hasError)
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: const BoxDecoration(color: Color(0xFFFF6B6B)),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded,
                              color: const Color(0xFFFF6B6B), size: 18),
                          const SizedBox(width: 14.0),
                          Expanded(
                              child: ResponsiveText(_errorMsg,
                                   style: const TextStyle(color: Color(0xFFFF6B6B)))),
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
