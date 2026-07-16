import 'package:calculus_system/shared/widgets/accent_glow.dart';
import 'package:calculus_system/topics/calculus/midterm/solvers/slope_solver/slope_solver.dart';
import 'package:calculus_system/shared/widgets/responsive_text.dart';
import 'package:flutter/material.dart';
import 'slope_comparison.dart';
import 'slope_input_field.dart';
import 'slope_result.dart';
import 'slope_step_dialog.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class SlopeScreen extends StatefulWidget {
  const SlopeScreen({super.key});

  @override
  State<SlopeScreen> createState() => _SlopeScreenState();
}

class _SlopeScreenState extends State<SlopeScreen> {
  // -- Controllers ------------------------------------------
  final _x1 = TextEditingController();
  final _y1 = TextEditingController();
  final _x2 = TextEditingController();
  final _y2 = TextEditingController();
  final _x3 = TextEditingController();
  final _y3 = TextEditingController();
  final _x4 = TextEditingController();
  final _y4 = TextEditingController();

  // -- Focus Nodes ------------------------------------------
  final _x1Focus = FocusNode();
  final _y1Focus = FocusNode();
  final _x2Focus = FocusNode();
  final _y2Focus = FocusNode();
  final _x3Focus = FocusNode();
  final _y3Focus = FocusNode();
  final _x4Focus = FocusNode();
  final _y4Focus = FocusNode();

  // -- State -------------------------------------------------
  SlopeSolverResult? _result1;
  SlopeSolverResult? _result2;
  SlopeComparisonResult? _comparisonResult;
  bool _error = false;
  String? _errorMessage;
  bool _showCompareSection = false;

  // -- Lifecycle ---------------------------------------------
  @override
  void dispose() {
    for (final c in [_x1, _y1, _x2, _y2, _x3, _y3, _x4, _y4]) {
      c.dispose();
    }
    for (final f in [
      _x1Focus,
      _y1Focus,
      _x2Focus,
      _y2Focus,
      _x3Focus,
      _y3Focus,
      _x4Focus,
      _y4Focus
    ]) {
      f.dispose();
    }
    super.dispose();
  }

  // -- Logic -------------------------------------------------

  void _calculate() {
    if (_x1.text.trim().isEmpty ||
        _y1.text.trim().isEmpty ||
        _x2.text.trim().isEmpty ||
        _y2.text.trim().isEmpty) {
      return _setError('Please fill in all four coordinates for Line 1');
    }

    final result1 = SlopeSolver.solveFromStrings(
      _x1.text,
      _y1.text,
      _x2.text,
      _y2.text,
    );

    if (result1.hasError) {
      return _setError(
        result1.error ?? 'Invalid input — use numbers or fractions like 3/5',
      );
    }

    if (!_showCompareSection) {
      setState(() {
        _result1 = result1;
        _result2 = null;
        _comparisonResult = null;
        _error = false;
        _errorMessage = null;
      });
      return;
    }

    if (_x3.text.trim().isEmpty ||
        _y3.text.trim().isEmpty ||
        _x4.text.trim().isEmpty ||
        _y4.text.trim().isEmpty) {
      return _setError('Please fill in all four coordinates for Line 2');
    }

    final result2 = SlopeSolver.solveFromStrings(
      _x3.text,
      _y3.text,
      _x4.text,
      _y4.text,
    );

    if (result2.hasError) {
      return _setError(
        result2.error ?? 'Invalid input — use numbers or fractions like 3/5',
      );
    }

    final comparison = SlopeSolver.compareSlopes(result1, result2);

    setState(() {
      _result1 = result1;
      _result2 = result2;
      _comparisonResult = comparison;
      _error = false;
      _errorMessage = null;
    });
  }

  void _setError(String message) {
    setState(() {
      _error = true;
      _errorMessage = message;
      _result1 = null;
      _result2 = null;
      _comparisonResult = null;
    });
  }

  void _openStepsDialog({bool showSecond = false}) {
    final result = showSecond ? _result2 : _result1;
    if (result == null || _error) return;
    showSlopeStepsModal(context: context, result: result);
  }

  void _openComparisonDialog() {
    if (_comparisonResult == null ||
        _result1 == null ||
        _result2 == null ||
        _error) {
      return;
    }
    showSlopeComparisonModal(
      context: context,
      comparisonResult: _comparisonResult!,
      result1: _result1!,
      result2: _result2!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.watch<ThemeProvider>().surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _backButton(),
              const SizedBox(height: 28),
              _header(),
              const SizedBox(height: 32),
              _pointRow(
                'Point 1: (x1, y1)',
                'x1',
                _x1,
                _x1Focus,
                'y1',
                _y1,
                _y1Focus,
                xTextInputAction: TextInputAction.next,
                xOnEditingComplete: () => _y1Focus.requestFocus(),
                yTextInputAction: TextInputAction.next,
                yOnEditingComplete: () => _x2Focus.requestFocus(),
              ),
              const SizedBox(height: 20),
              _pointRow(
                'Point 2: (x2, y2)',
                'x2',
                _x2,
                _x2Focus,
                'y2',
                _y2,
                _y2Focus,
                xTextInputAction: TextInputAction.next,
                xOnEditingComplete: () => _y2Focus.requestFocus(),
                yTextInputAction: TextInputAction.next,
                yOnEditingComplete: () {
                  if (_showCompareSection) {
                    _x3Focus.requestFocus();
                  }
                },
              ),
              const SizedBox(height: 20),
              _compareToggle(),
              if (_showCompareSection) ...[
                const SizedBox(height: 28),
                _pointRow(
                  'Point 3: (x3, y3)',
                  'x3',
                  _x3,
                  _x3Focus,
                  'y3',
                  _y3,
                  _y3Focus,
                  xTextInputAction: TextInputAction.next,
                  xOnEditingComplete: () => _y3Focus.requestFocus(),
                  yTextInputAction: TextInputAction.next,
                  yOnEditingComplete: () => _x4Focus.requestFocus(),
                ),
                const SizedBox(height: 20),
                _pointRow(
                  'Point 4: (x4, y4)',
                  'x4',
                  _x4,
                  _x4Focus,
                  'y4',
                  _y4,
                  _y4Focus,
                  xTextInputAction: TextInputAction.next,
                  xOnEditingComplete: () => _y4Focus.requestFocus(),
                  yTextInputAction: TextInputAction.done,
                  yOnEditingComplete: () => _y4Focus.unfocus(),
                ),
              ],
              const SizedBox(height: 28),
              _calculateButton(),
              if (_error && _errorMessage != null) ...[
                const SizedBox(height: 24),
                _errorBanner(_errorMessage!),
              ],
              if (_result1 != null && !_error) ...[
                const SizedBox(height: 28),
                _results(),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _backButton() {
    final theme = context.watch<ThemeProvider>();
    return AccentGlow.iconHalo(
      context,
      child: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(Icons.arrow_back_ios_rounded, size: 16, color: theme.accentColor),
        style: IconButton.styleFrom(
          backgroundColor: theme.accentColor.withValues(alpha: 0.12),
          foregroundColor: theme.accentColor,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: theme.accentColor.withValues(alpha: 0.15), width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    final theme = context.watch<ThemeProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveText(
          'Equation of a line',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: theme.textPrimary,
            letterSpacing: -0.8,
            shadows: [
              Shadow(
                color: theme.accentColor.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: Offset.zero,
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        ResponsiveText(
          'Enter coordinates — supports fractions like 3/5 or -1/4',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: theme.textSecondary,
            shadows: [
              Shadow(
                color: theme.accentColor.withValues(alpha: 0.15),
                blurRadius: 4,
                offset: Offset.zero,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _pointRow(
    String sectionLabel,
    String xLabel,
    TextEditingController xCtrl,
    FocusNode xFocus,
    String yLabel,
    TextEditingController yCtrl,
    FocusNode yFocus,
    {TextInputAction? xTextInputAction,
    VoidCallback? xOnEditingComplete,
    TextInputAction? yTextInputAction,
    VoidCallback? yOnEditingComplete,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText(
            sectionLabel,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.watch<ThemeProvider>().textSecondary.withValues(alpha: 0.7), letterSpacing: 0.5).copyWith(
              letterSpacing: 0,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              SlopeInputField(
                label: xLabel,
                controller: xCtrl,
                focusNode: xFocus,
                textInputAction: xTextInputAction,
                onEditingComplete: xOnEditingComplete,
              ),
              const SizedBox(width: 12),
              SlopeInputField(
                label: yLabel,
                controller: yCtrl,
                focusNode: yFocus,
                textInputAction: yTextInputAction,
                onEditingComplete: yOnEditingComplete,
              ),
            ],
          ),
        ],
      );

  Widget _compareToggle() => GestureDetector(
        onTap: () => setState(() {
          _showCompareSection = !_showCompareSection;
          _result1 = null;
          _result2 = null;
          _comparisonResult = null;
        }),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _showCompareSection
                ? const Color(0xFF4ECDC4).withValues(alpha: 0.1)
                : context.watch<ThemeProvider>().card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _showCompareSection
                  ? const Color(0xFF4ECDC4).withValues(alpha: 0.3)
                  : const Color(0xFF334155).withValues(alpha: 0.15),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: _showCompareSection
                      ? const Color(0xFF4ECDC4)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: _showCompareSection
                        ? const Color(0xFF4ECDC4)
                        : const Color(0xFF334155).withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: _showCompareSection
                    ? const Icon(Icons.check_rounded,
                        size: 14, color: Color(0xFF1A1A2E))
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ResponsiveText(
                  'Compare with another line',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _showCompareSection
                        ? const Color(0xFF4ECDC4)
                        : context.watch<ThemeProvider>().textPrimary,
                  ),
                ),
              ),
              Icon(
                _showCompareSection
                    ? Icons.expand_less_rounded
                    : Icons.expand_more_rounded,
                color: _showCompareSection
                    ? const Color(0xFF4ECDC4)
                    : const Color(0xFF334155).withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      );

  Widget _calculateButton() {
    final theme = context.watch<ThemeProvider>();
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [AccentGlow.halo(context)],
        ),
        child: ElevatedButton(
          onPressed: _calculate,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.accentColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
            shadowColor: Colors.transparent,
          ),
          child: ResponsiveText(
            'Calculate Slope',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: theme.surface,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }

  Widget _errorBanner(String message) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFF6B6B).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFFF6B6B).withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.error_rounded,
                color: const Color(0xFFFF6B6B).withValues(alpha: 0.8),
                size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: const Color(0xFFFF6B6B).withValues(alpha: 0.9),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _results() {
    if (!_showCompareSection) {
      return SlopeAnswerCard(result: _result1!, onTap: _openStepsDialog);
    }

    if (_result2 != null && _comparisonResult != null) {
      return Column(
        children: [
          SlopeComparisonCard(
            result: _comparisonResult!,
            onTap: _openComparisonDialog,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                  child: SlopeAnswerCard(
                      result: _result1!, onTap: _openStepsDialog)),
              const SizedBox(width: 12),
              Expanded(
                  child: SlopeAnswerCard(
                      result: _result2!, onTap: () => _openStepsDialog(showSecond: true))),
            ],
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}
