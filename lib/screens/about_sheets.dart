// about_sheet.dart
//
// Call showAboutSheet(context) from anywhere to show the about bottom sheet.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calculus_system/theme/theme_provider.dart';

// ── Developer data ────────────────────────────────────────────────────────────
// Fill in each team member's details here.

class _Developer {
  final String name;
  final String program;
  final String role;

  const _Developer({
    required this.name,
    required this.program,
    required this.role,
  });
}

const _developers = [
  _Developer(
    name: 'Joashua Marl Barimbao',
    program: 'BS Computer Science',
    role: 'Lead\nDeveloper',
  ),
  _Developer(
    name: 'Michaela Denise Ong',
    program: 'BS Computer Science',
    role: 'Developer 2',
  ),
  _Developer(
    name: 'Nash Bruce Quiros',
    program: 'BS Computer Science',
    role: 'Developer 3',
  ),
  _Developer(
    name: 'John Carlo Legaste',
    program: 'BS Computer Science',
    role: 'Developer 4',
  ),
  _Developer(
    name: 'Clifford Probetso',
    program: 'BS Computer Science',
    role: 'Developer 5',
  ),
  _Developer(
    name: 'John Lin Redido',
    program: 'BS Computer Science',
    role: 'Developer 6',
  ),
  _Developer(
    name: 'Cresa Delacruz',
    program: 'BS Computer Science',
    role: 'Math Solver',
  ),
  _Developer(
    name: 'MORE INFOS TO COME',
    program: 'Finalizing the List of students',
    role: 'Info \ncoming soon',
  ),
  // Add more members here if needed:
  // _Developer(name: '...', program: '...', role: '...'),
];

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

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    const accent = Color(0xFF6C63FF);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 32,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag handle
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.textSecondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Scrollable content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(28, 16, 28, 40),
                  children: [
                    // ── App badge ────────────────────────────────────────
                    Center(
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: accent.withValues(alpha: 0.25),
                          ),
                        ),
                        child: const Icon(
                          Icons.functions_rounded,
                          color: accent,
                          size: 36,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── App name & description ────────────────────────────
                    Center(
                      child: Text(
                        'Calculus System',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: theme.textPrimary,
                          letterSpacing: -0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'A collaborative math solving app covering only \nslope, distance, inequalities, and more.\nIt only solves Specific Discussions of Miss K class',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: theme.textSecondary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── Divider label ─────────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: theme.textSecondary.withValues(alpha: 0.15),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'THE TEAM',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                              color: accent,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: theme.textSecondary.withValues(alpha: 0.15),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ── Developer cards ───────────────────────────────────
                    ..._developers.asMap().entries.map(
                          (e) => _DeveloperTile(
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
  }
}

// ── Single developer tile ─────────────────────────────────────────────────────

class _DeveloperTile extends StatelessWidget {
  final _Developer developer;
  final int index;
  final Color accent;

  const _DeveloperTile({
    required this.developer,
    required this.index,
    required this.accent,
  });

  // Cycles through a small palette so each avatar has a distinct colour.
  static const _avatarColors = [
    Color(0xFF6C63FF), // purple
    Color(0xFF00BFA5), // teal
    Color(0xFFFF6B6B), // coral
    Color(0xFFFFB300), // amber
    Color(0xFF42A5F5), // blue
    Color(0xFFAB47BC), // violet
  ];

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final color = _avatarColors[index % _avatarColors.length];
    final initials = developer.name
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: theme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  initials,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Name + program
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    developer.name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    developer.program,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Role badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                developer.role,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
