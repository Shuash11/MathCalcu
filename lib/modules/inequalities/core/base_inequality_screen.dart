import 'dart:async';
import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/modules/inequalities/graph/inequality_graph.dart';
import 'package:calculus_system/modules/inequalities/theme/inequality_theme.dart';
import 'package:calculus_system/shared/widgets/answer_card.dart';
import 'package:calculus_system/shared/widgets/graph_widget.dart';
import 'package:calculus_system/shared/widgets/math_input_field.dart';
import 'package:calculus_system/shared/widgets/steps_drawer.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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

  SolveResult? _result;
  bool _loading = false;
  bool _solved = false;

  Timer? _debounce;
  int _requestId = 0;

  void _onInputChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _solve();
    });
  }

  Future<void> _solve() async {
    final input = _inputCtrl.text.trim();
    if (input.isEmpty) return;

    final int currentRequest = ++_requestId;

    setState(() => _loading = true);

    try {
      final result = await compute(widget.solveFunction, input);

      if (!mounted || currentRequest != _requestId) return;

      setState(() {
        _result = result;
        _solved = true;
      });
    } catch (e) {
      if (!mounted || currentRequest != _requestId) return;

      setState(() {
        _result = SolveResult.error(e.toString());
        _solved = true;
      });
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

  @override
  void dispose() {
    _inputCtrl.dispose();
    _debounce?.cancel();
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
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: context.watch<ThemeProvider>().textPrimary,
                ),
              ),
              Text(
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
        Text(
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
          onChanged: _onInputChanged,
          onSolve: _solve,
        ),
      ],
    );
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
        child: Text(
          _result!.errorMessage ?? 'Unknown error',
          style: const TextStyle(color: Color(0xFFFF6B6B)),
        ),
      );
    }

    return Column(
      children: [
        GraphWidget(
          result: _result!,
          accentColor: InequalityTheme.accentColor,
          graphBody: InequalityGraph(
            result: _result!,
            accentColor: InequalityTheme.accentColor,
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
