import 'package:calculus_system/Finals/Joashua/Derivatives/Widgets/derivatives_answer_card.dart';
import 'package:calculus_system/Finals/Joashua/Derivatives/Widgets/derivatives_input_field.dart';
import 'package:calculus_system/Finals/Joashua/Derivatives/Widgets/derivatives_steptile.dart';
import 'package:calculus_system/Finals/Joashua/Derivatives/solvers/derivatives_steps.dart';
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
      setState(() {
        _solution = AdvancedStepGenerator.generateDetailedSolution(
          _exprController.text.trim(),
          _variable,
        );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FinalsTheme.surface(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: FinalsTheme.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Differentiate',
                        style: FinalsTheme.titleStyle(context)
                            .copyWith(fontSize: 28)),
                    const SizedBox(height: 4),
                    Text(
                        'Enter a function to find its derivative step-by-step.',
                        style: FinalsTheme.subtitleStyle(context)),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // Input Field
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

            // Answer Card
            if (_isLoading)
              const SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverToBoxAdapter(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: FinalsTheme.primary,
                      strokeWidth: 3,
                    ),
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

            // Steps Section
            if (_solution != null)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    key: _stepsKey,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Step-by-Step Solution',
                          style: FinalsTheme.titleStyle(context)),
                      const SizedBox(height: 8),
                      Text('Understand the rules applied to reach the answer.',
                          style: FinalsTheme.subtitleStyle(context)),
                      const SizedBox(height: 24),

                      // Render Steps
                      ..._solution!.steps.asMap().entries.map((entry) {
                        return DerivativeStepTile(
                          step: entry.value,
                          index: entry.key,
                          isLast: entry.key == _solution!.steps.length - 1,
                        );
                      }),

                      const SizedBox(height: 32),

                      // Common Mistakes Section
                      _buildInfoCard(
                        context,
                        title: 'Common Mistakes',
                        icon: Icons.warning_amber_rounded,
                        color: FinalsTheme.danger,
                        items: _solution!.commonMistakes,
                      ),

                      const SizedBox(height: 24),

                      // Related Concepts Section
                      _buildInfoCard(
                        context,
                        title: 'Related Concepts',
                        icon: Icons.auto_awesome, // Fixed typo here
                        color: FinalsTheme.primary,
                        items: _solution!.relatedConcepts,
                      ),

                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required List<String> items,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Text(title,
                  style: FinalsTheme.titleStyle(context)
                      .copyWith(fontSize: 16, color: color)),
            ],
          ),
          const SizedBox(height: 12),
          ...items
              .map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                              color: color, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Text(item,
                                style: FinalsTheme.subtitleStyle(context))),
                      ],
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }
}
