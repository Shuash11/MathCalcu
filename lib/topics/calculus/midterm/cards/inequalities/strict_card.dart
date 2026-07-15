import 'package:flutter/material.dart';
import 'animated_inequality_card.dart';
import 'package:provider/provider.dart';

class StrictCard extends StatelessWidget {
  const StrictCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedInequalityCard(
      title: 'Strict Inequality',
      subtitle: 'Uses < or >. The boundary is NOT included.',
      route: '/inequalities/strict',
      icon: Icons.code_rounded,
      accentColor: {'strict': const Color(0xFF334155), 'non_strict': const Color(0xFF334155), 'absolute': const Color(0xFF334155)}['strict'] ?? const Color(0xFF334155),
    );
  }
}
