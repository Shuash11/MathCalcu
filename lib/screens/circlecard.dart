import 'package:calculus_system/core/module_registry.dart';
import 'package:flutter/material.dart';
import 'package:calculus_system/shared/widgets/module_card.dart';
import 'package:go_router/go_router.dart';

class CircleModuleCard extends StatelessWidget {
  final ModuleEntry module;
  const CircleModuleCard({required this.module, super.key});

  @override
  Widget build(BuildContext context) {
    return ModuleCard(
      icon: module.icon,
      title: module.label,
      subtitle: module.subtitle,
      onTap: () => context.push(module.route),
    );
  }
}
