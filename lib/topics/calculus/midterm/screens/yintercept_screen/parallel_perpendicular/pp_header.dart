// lib/topics/calculus/midterm/screens/yintercept_screen/parallel_perpendicular/pp_header.dart

import 'package:calculus_system/shared/widgets/accent_glow.dart';
import 'package:calculus_system/shared/widgets/responsive_text.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// App bar row for the Parallel & Perpendicular screen.
class PPAppBar extends StatelessWidget {
  final Animation<double> headerFade;

  const PPAppBar({super.key, required this.headerFade});

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: headerFade,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: context.watch<ThemeProvider>().card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: context
                      .watch<ThemeProvider>()
                      .accentColor
                      .withValues(alpha: 0.2),
                ),
                boxShadow: AccentGlow.stack(context),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: context.watch<ThemeProvider>().textSecondary,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: context
                  .watch<ThemeProvider>()
                  .accentColor
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context
                    .watch<ThemeProvider>()
                    .accentColor
                    .withValues(alpha: 0.2),
              ),
              boxShadow: AccentGlow.stack(context),
            ),
            child: Icon(
              Icons.show_chart_rounded,
              color: context.watch<ThemeProvider>().accentColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ResponsiveText(
                  'Parallel & Perpendicular',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: context.watch<ThemeProvider>().textPrimary,
                    letterSpacing: -1.0,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
