import 'package:calculus_system/modules/slope/theme/slope_theme.dart';
import 'package:calculus_system/modules/slope/types/slope_solver.dart';
import 'package:flutter/material.dart';
import 'slope_comparison.dart';
import 'slope_input_field.dart';
import 'slope_result.dart';
import 'slope_step_dialog.dart';

class SlopeScreen extends StatefulWidget {
  const SlopeScreen({super.key});

  @override
  State<SlopeScreen> createState() => _SlopeScreenState();
}

class _SlopeScreenState extends State<SlopeScreen> {
  // ── Controllers ──────────────────────────────────────────
  final _x1 = TextEditingController();
  final _y1 = TextEditingController();
  final _x2 = TextEditingController();
  final _y2 = TextEditingController();
  final _x3 = TextEditingController();
  final _y3 = TextEditingController();
  final _x4 = TextEditingController();
  final _y4 = TextEditingController();

  // ── State ─────────────────────────────────────────────────
  SlopeSolverResult? _result1;
  SlopeSolverResult? _result2;
  SlopeComparisonResult? _comparisonResult;
  bool _error = false;
  String? _errorMessage;
  bool _showCompareSection = false;

  // ── Lifecycle ─────────────────────────────────────────────
  @override
  void dispose() {
    for (final c in [_x1, _y1, _x2, _y2, _x3, _y3, _x4, _y4]) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Logic ─────────────────────────────────────────────────

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

  void _openStepsDialog() {
    if (_result1 == null || _error) return;
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => SlopeStepDialog(result: _result1!),
    );
  }

  void _openComparisonDialog() {
    if (_comparisonResult == null ||
        _result1 == null ||
        _result2 == null ||
        _error) {
      return;
    }
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => SlopeComparisonDialog(
        comparisonResult: _comparisonResult!,
        result1: _result1!,
        result2: _result2!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SlopeTheme.surface(context),
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
              _pointRow('Point 1: (x₁, y₁)', 'x₁', _x1, 'y₁', _y1),
              const SizedBox(height: 20),
              _pointRow('Point 2: (x₂, y₂)', 'x₂', _x2, 'y₂', _y2),
              const SizedBox(height: 20),
              _compareToggle(),
              if (_showCompareSection) ...[
                const SizedBox(height: 28),
                _pointRow('Point 3: (x₃, y₃)', 'x₃', _x3, 'y₃', _y3),
                const SizedBox(height: 20),
                _pointRow('Point 4: (x₄, y₄)', 'x₄', _x4, 'y₄', _y4),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _backButton() => GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: SlopeTheme.cardColor(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: SlopeTheme.accentColor.withValues(alpha: 0.15),
            ),
          ),
          child: const Icon(Icons.arrow_back_ios_rounded,
              size: 16, color: SlopeTheme.accentColor),
        ),
      );

  Widget _header() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Equation of a line', style: SlopeTheme.titleStyle(context)),
          const SizedBox(height: 6),
          Text(
            'Enter coordinates — supports fractions like 3/5 or -1/4',
            style: SlopeTheme.subtitleStyle(context),
          ),
        ],
      );

  Widget _pointRow(
    String sectionLabel,
    String xLabel,
    TextEditingController xCtrl,
    String yLabel,
    TextEditingController yCtrl,
  ) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sectionLabel,
            style: SlopeTheme.labelStyle(context).copyWith(
              letterSpacing: 0,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              SlopeInputField(label: xLabel, controller: xCtrl),
              const SizedBox(width: 12),
              SlopeInputField(label: yLabel, controller: yCtrl),
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
                : SlopeTheme.cardColor(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _showCompareSection
                  ? const Color(0xFF4ECDC4).withValues(alpha: 0.3)
                  : SlopeTheme.accentColor.withValues(alpha: 0.15),
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
                        : SlopeTheme.accentColor.withValues(alpha: 0.3),
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
                child: Text(
                  'Compare with another line',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _showCompareSection
                        ? const Color(0xFF4ECDC4)
                        : SlopeTheme.textPrimary(context),
                  ),
                ),
              ),
              Icon(
                _showCompareSection
                    ? Icons.expand_less_rounded
                    : Icons.expand_more_rounded,
                color: _showCompareSection
                    ? const Color(0xFF4ECDC4)
                    : SlopeTheme.accentColor.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      );

  Widget _calculateButton() => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _calculate,
          style: ElevatedButton.styleFrom(
            backgroundColor: SlopeTheme.accentColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: Text(
            'Calculate Slope',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: SlopeTheme.surface(context),
              letterSpacing: 0.3,
            ),
          ),
        ),
      );

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
                      result: _result2!, onTap: _openStepsDialog)),
            ],
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}
