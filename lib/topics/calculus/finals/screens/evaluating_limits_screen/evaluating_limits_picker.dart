import 'package:calculus_system/topics/calculus/finals/cards/evaluating_limits/substitution_card.dart';
import 'package:calculus_system/topics/calculus/finals/cards/evaluating_limits/conjugate_card.dart';
import 'package:calculus_system/topics/calculus/finals/cards/evaluating_limits/factoring_card.dart';
import 'package:calculus_system/topics/calculus/finals/cards/evaluating_limits/lcd_card.dart';
import 'package:calculus_system/topics/calculus/finals/finals_theme.dart';
import 'package:calculus_system/shared/widgets/responsive_text.dart';
import 'package:flutter/material.dart';

class EvaluatingLimitsPicker extends StatefulWidget {
  const EvaluatingLimitsPicker({super.key});

  @override
  State<EvaluatingLimitsPicker> createState() => _EvaluatingLimitsPickerState();
}

class _EvaluatingLimitsPickerState extends State<EvaluatingLimitsPicker>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;

  final List<Widget> _topicCards = [
    const SubstitutionCard(),
    const ConjugateCard(),
    const FactoringCard(),
    const LcdCard(),
  ];

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      _topicCards.length,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      ),
    );

    _fadeAnims = _controllers
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeOut))
        .toList();

    _slideAnims = _controllers
        .map(
          (c) => Tween<Offset>(
            begin: const Offset(0, 0.2),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: c, curve: Curves.easeOutCubic)),
        )
        .toList();

    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: 100 + i * 100), () {
        if (mounted) _controllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FinalsTheme.surface(context),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button pill
                    GestureDetector(
                      onTap: () => Navigator.of(context).maybePop(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: FinalsTheme.primaryFor(context)
                                  .withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.arrow_back_ios_new_rounded,
                                size: 12,
                                color: FinalsTheme.primaryFor(context)),
                            const SizedBox(width: 8),
                            ResponsiveText(
                              'Back to Finals',
                              style: FinalsTheme.labelStyle(context)
                                  .copyWith(fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ResponsiveText(
                      'Evaluating Limits',
                      style: FinalsTheme.titleStyle(context)
                          .copyWith(fontSize: 32, height: 1.1),
                    ),
                    const SizedBox(height: 8),
                    ResponsiveText(
                      'Select a method to solve limits step-by-step using fundamental algebraic rules.',
                      style: FinalsTheme.subtitleStyle(context),
                    ),
                  ],
                ),
              ),
            ),

            // ── Topic Cards
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: FadeTransition(
                        opacity: _fadeAnims[index],
                        child: SlideTransition(
                          position: _slideAnims[index],
                          child: _topicCards[index],
                        ),
                      ),
                    );
                  },
                  childCount: _topicCards.length,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }
}
