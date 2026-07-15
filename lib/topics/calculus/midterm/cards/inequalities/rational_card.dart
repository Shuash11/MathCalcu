import 'package:flutter/material.dart';
import 'animated_inequality_card.dart';
import 'package:provider/provider.dart';

class RationalCard extends StatelessWidget {
  const RationalCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedInequalityCard(
      title: 'Rational Inequality',
      subtitle: 'Involves a fraction with variable in numerator/denominator.',
      route: '/inequalities/rational',
      icon: Icons.pie_chart_rounded,
      accentColor: {'strict': const Color(0xFF334155), 'non_strict': const Color(0xFF334155), 'absolute': const Color(0xFF334155)}['rational'] ?? const Color(0xFF334155),
    );
  }
}
