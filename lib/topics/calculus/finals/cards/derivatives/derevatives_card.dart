import 'package:flutter/material.dart';
import 'package:calculus_system/shared/widgets/module_card.dart';
import 'package:calculus_system/topics/calculus/finals/finals_module_registry.dart';
import 'package:go_router/go_router.dart';

class FinalsDerivativesCard extends StatelessWidget {
  final FinalsModuleEntry module;
  const FinalsDerivativesCard({super.key, required this.module});

  @override
  Widget build(BuildContext context) {
    return ModuleCard(
      icon: Icons.trending_up_rounded,
      title: 'Derivatives',
      subtitle: 'Power rule, product rule, quotient rule & chain rule',
      accentColor: const Color(0xFF7F1D1D),
      onTap: () => context.go('/topics/calculus/finals/derivatives'),
    );
  }
}
