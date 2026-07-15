import 'package:flutter/material.dart';
import 'package:calculus_system/shared/widgets/module_card.dart';
import 'package:go_router/go_router.dart';

class FindingCenterCard extends StatelessWidget {
  const FindingCenterCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ModuleCard(
      icon: Icons.adjust_rounded,
      title: 'Finding the Center',
      subtitle: 'Standard form, general form & center coordinates',
      accentColor: const Color(0xFF6366F1),
      onTap: () => context.push('/circle/finding-center'),
    );
  }
}
