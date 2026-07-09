import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:calculus_system/models/developer.dart';
import 'package:calculus_system/widgets/developer_tile.dart';

// ── Public entry point ────────────────────────────────────────────────────────

void showAboutSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _AboutSheet(),
  );
}

// ── Sheet widget ──────────────────────────────────────────────────────────────

class _AboutSheet extends StatelessWidget {
  const _AboutSheet();

  static const double _baseDesignWidth = 400.0;

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    const accent = Color(0xFF6C63FF);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final double s = (constraints.maxWidth / _baseDesignWidth).clamp(0.75, 1.1);

            return Container(
              decoration: BoxDecoration(
                color: theme.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32 * s)),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.2),
                    blurRadius: 40 * s,
                    offset: Offset(0, -10 * s),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Drag handle
                  Padding(
                    padding: EdgeInsets.only(top: 16 * s, bottom: 8 * s),
                    child: Container(
                      width: 48 * s,
                      height: 5 * s,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(3 * s),
                      ),
                    ),
                  ),

                  // Header with icon
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 28 * s, vertical: 16 * s),
                    child: Row(
                      children: [
                        Container(
                          width: 56 * s,
                          height: 56 * s,
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(18 * s),
                            border: Border.all(
                              color: accent.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Image.asset(
                            'assets/images/app_icon.png',
                            width: 30 * s,
                            height: 30 * s,
                          ),
                        ),
                        SizedBox(width: 16 * s),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'MathCalc',
                                style: TextStyle(
                                  fontSize: 28 * s,
                                  fontWeight: FontWeight.w800,
                                  color: theme.textPrimary,
                                  letterSpacing: -0.8 * s,
                                ),
                              ),
                              SizedBox(height: 4 * s),
                              Text(
                                '${developers.length} developers · Math Solving App',
                                style: TextStyle(
                                  fontSize: 14 * s,
                                  color: theme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Scrollable content
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: EdgeInsets.fromLTRB(24 * s, 8 * s, 24 * s, 40 * s),
                      children: [
                        // Description card
                        Container(
                          padding: EdgeInsets.all(20 * s),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20 * s),
                            border: Border.all(
                              color: accent.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.emoji_events_rounded,
                                    color: accent,
                                    size: 20 * s,
                                  ),
                                  SizedBox(width: 8 * s),
                                  Text(
                                    'About MathCalc',
                                    style: TextStyle(
                                      fontSize: 14 * s,
                                      fontWeight: FontWeight.w700,
                                      color: theme.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10 * s),
                              Text(
                                'A collaborative math solving app covering slope, distance, inequalities, and more. '
                                'All The Glory and Honor Belongs To Jesus.',
                                style: TextStyle(
                                  fontSize: 13 * s,
                                  height: 1.5,
                                  color: theme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 24 * s),

                        // Section divider
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 1,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      accent.withValues(alpha: 0.3),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16 * s),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 14 * s,
                                  vertical: 6 * s,
                                ),
                                decoration: BoxDecoration(
                                  color: accent,
                                  borderRadius: BorderRadius.circular(20 * s),
                                ),
                                child: Text(
                                  'DEVELOPERS',
                                  style: TextStyle(
                                    fontSize: 11 * s,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 1,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      accent.withValues(alpha: 0.3),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20 * s),

                        // Developer cards
                        ...developers.asMap().entries.map(
                              (e) => DeveloperTile(
                                key: ValueKey(e.value.name),
                                developer: e.value,
                                index: e.key,
                                accent: accent,
                              ),
                            ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}


