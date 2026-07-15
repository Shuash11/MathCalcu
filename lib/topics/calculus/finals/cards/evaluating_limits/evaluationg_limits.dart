import 'package:flutter/material.dart';
import 'package:calculus_system/shared/widgets/module_card.dart';
import 'package:calculus_system/topics/calculus/finals/finals_module_registry.dart';
import 'package:go_router/go_router.dart';

class FinalsLimitsCard extends StatelessWidget {
  final FinalsModuleEntry module;
  const FinalsLimitsCard({super.key, required this.module});

  @override
  Widget build(BuildContext context) {
    return ModuleCard(
      icon: Icons.functions_rounded,
      title: 'Evaluating Limits',
      subtitle: 'Direct substitution, factoring, rationalization & special limits',
      accentColor: const Color(0xFF9CA3AF),
      onTap: () => context.go(module.route),
    );
  }
}
