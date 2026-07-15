import 'package:flutter/material.dart';
import 'animated_inequality_card.dart';
import 'package:provider/provider.dart';

class NonStrictCard extends StatelessWidget {
  const NonStrictCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedInequalityCard(
      title: 'Non-strict Inequality',
      subtitle: 'Uses = or =. The boundary IS included.',
      route: '/inequalities/non_strict',
      icon: Icons.drag_handle_rounded,
      accentColor: {'strict': const Color(0xFF334155), 'non_strict': const Color(0xFF334155), 'absolute': const Color(0xFF334155)}['non_strict'] ?? const Color(0xFF334155),
    );
  }
}
