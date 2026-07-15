import 'package:flutter/material.dart';
import 'animated_inequality_card.dart';
import 'package:provider/provider.dart';

class ContinuedCard extends StatelessWidget {
  const ContinuedCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedInequalityCard(
      title: 'Continued Inequality',
      subtitle: 'A value sandwiched between two bounds.',
      route: '/inequalities/continued',
      icon: Icons.compare_arrows_rounded,
      accentColor: {'strict': const Color(0xFF334155), 'non_strict': const Color(0xFF334155), 'absolute': const Color(0xFF334155)}['continued'] ?? const Color(0xFF334155),
    );
  }
}
