import 'package:flutter/material.dart';
import 'package:calculus_system/shared/widgets/module_card.dart';
import 'package:calculus_system/topics/calculus/finals/finals_module_registry.dart';
import 'package:go_router/go_router.dart';

class FinalsSlopeDerivativeCard extends StatelessWidget {
  final FinalsModuleEntry module;
  const FinalsSlopeDerivativeCard({super.key, required this.module});

  @override
  Widget build(BuildContext context) {
    return ModuleCard(
      icon: Icons.show_chart_rounded,
      title: 'Slope Using Derivatives',
      subtitle: 'Tangent line slope, evaluate at point & instantaneous rate',
      onTap: () => context.go('/topics/calculus/finals/slope-derivative'),
    );
  }
}
