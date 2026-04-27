import 'package:calculus_system/Finals/Joashua/Derivatives/Widgets/derivatives_answer_card.dart';
import 'package:calculus_system/Finals/Joashua/Derivatives/Widgets/derivatives_input_field.dart';
import 'package:calculus_system/Finals/Joashua/Derivatives/Widgets/derivatives_steptile.dart';
import 'package:calculus_system/Finals/Joashua/Derivatives/solvers/derivatives_steps.dart';
import 'package:calculus_system/Finals/Joashua/Derivatives/solvers/deriviatives_solver.dart';
import 'package:calculus_system/Finals/finals_theme.dart';
import 'package:flutter/material.dart';

class DerivativeScreen extends StatefulWidget {
  const DerivativeScreen({super.key});

  @override
  State<DerivativeScreen> createState() => _DerivativeScreenState();
}

class _DerivativeScreenState extends State<DerivativeScreen> {
  final TextEditingController _exprController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _stepsKey = GlobalKey();

  String _variable = 'x';
  ClassroomSolution? _solution;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _exprController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _solve() async {
    if (_exprController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _solution = null;
    });

    await Future.delayed(const Duration(milliseconds: 400));

    try {
      final inputExpr = _exprController.text.trim();
      
      final result = AdvancedStepGenerator.generateDetailedSolution(
        inputExpr,
        _variable,
      );
      
      setState(() {
        _solution = result;
        _isLoading = false;
      });

      _scrollToStepsSection();
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('ParseException: ', '');
        _isLoading = false;
      });
    }
  }

  void _scrollToStepsSection() {
    final context = _stepsKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  Widget _buildStepsSection(BuildContext context, ClassroomSolution solution) {
    final stepCount = solution.steps.length;
    final hasSteps = stepCount > 2 && solution.steps.any((s) => s.expression.isNotEmpty);

    return Column(
      key: _stepsKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step-by-Step Solution', style: FinalsTheme.titleStyle(context)),
        const SizedBox(height: 8),
        Text('Understand the rules applied to reach the answer.',
            style: FinalsTheme.subtitleStyle(context)),
        const SizedBox(height: 24),

        if (!hasSteps)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: FinalsTheme.cardSecondary(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle_outline_rounded, color: FinalsTheme.primary, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Direct computation. No step-by-step breakdown needed for this expression.',
                    style: FinalsTheme.subtitleStyle(context),
                  ),
                ),
              ],
            ),
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: solution.steps.asMap().entries.map((entry) {
              final step = entry.value;
              if (step.expression.isEmpty && step.type != StepType.original) {
                return const SizedBox.shrink();
              }
              return DerivativeStepTile(
                step: step,
                index: entry.key,
                isLast: entry.key == solution.steps.length - 1,
              );
            }).toList(),
          ),

        const SizedBox(height: 60),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FinalsTheme.surface(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: FinalsTheme.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Differentiate', style: FinalsTheme.titleStyle(context).copyWith(fontSize: 28)),
                    const SizedBox(height: 4),
                    Text('Enter a function to find its derivative step-by-step.',
                        style: FinalsTheme.subtitleStyle(context)),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverToBoxAdapter(
                child: DerivativeInputField(
                  controller: _exprController,
                  currentVariable: _variable,
                  onVariableChanged: (v) => setState(() => _variable = v),
                  onSolve: _solve,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            if (_isLoading)
              const SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverToBoxAdapter(
                  child: Center(
                    child: CircularProgressIndicator(color: FinalsTheme.primary, strokeWidth: 3),
                  ),
                ),
              )
            else if (_error != null)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverToBoxAdapter(
                  child: DerivativeAnswerCard(
                    originalExpr: _exprController.text.trim(),
                    answerExpr: '',
                    hasError: true,
                    errorMessage: _error,
                    onTap: () {},
                  ),
                ),
              )
            else if (_solution != null)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverToBoxAdapter(
                  child: DerivativeAnswerCard(
                    originalExpr: _solution!.originalExpression,
                    answerExpr: _solution!.finalAnswer,
                    onTap: _scrollToStepsSection,
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),

            if (_solution != null)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverToBoxAdapter(
                  child: _buildStepsSection(context, _solution!),
                ),
              ),
          ],
        ),
      ),
    );
  }
}