import 'package:flutter/material.dart';
import 'animated_inequality_card.dart';
import 'package:provider/provider.dart';

class AbsoluteCard extends StatelessWidget {
  const AbsoluteCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedInequalityCard(
      title: 'Absolute Value',
      subtitle: 'Uses |expression|. Handles both cases.',
      route: '/inequalities/absolute',
      icon: Icons.vertical_align_center_rounded,
      accentColor: {'strict': const Color(0xFF334155), 'non_strict': const Color(0xFF334155), 'absolute': const Color(0xFF334155)}['absolute'] ?? const Color(0xFF334155),
    );
  }
}
