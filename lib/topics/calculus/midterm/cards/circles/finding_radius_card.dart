import 'package:flutter/material.dart';
import 'package:calculus_system/shared/widgets/module_card.dart';
import 'package:go_router/go_router.dart';

class FindingRadiusCard extends StatelessWidget {
  const FindingRadiusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ModuleCard(
      icon: Icons.radio_button_unchecked_rounded,
      title: 'Finding the Radius',
      subtitle: 'Standard form, geometry & radius calculations',
      accentColor: const Color(0xFF334155),
      onTap: () => context.push('/circle/finding-radius'),
    );
  }
}
