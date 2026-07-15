import 'package:flutter/material.dart';
import 'package:calculus_system/shared/widgets/module_card.dart';
import 'package:calculus_system/topics/calculus/finals/finals_module_registry.dart';
import 'package:go_router/go_router.dart';

class FinalsInfinityLimitsCard extends StatelessWidget {
  final FinalsModuleEntry module;
  const FinalsInfinityLimitsCard({super.key, required this.module});

  @override
  Widget build(BuildContext context) {
    return ModuleCard(
      icon: Icons.all_inclusive_rounded,
      title: 'Limits at Infinity',
      subtitle: 'Horizontal asymptotes, end behavior & rational functions',
      accentColor: const Color(0xFF9CA3AF),
      onTap: () => context.go('/topics/calculus/finals/infinity'),
    );
  }
}
