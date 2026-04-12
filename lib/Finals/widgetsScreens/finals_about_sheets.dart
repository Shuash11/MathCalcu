import 'package:flutter/material.dart';
import 'package:calculus_system/Finals/Finals_Theme.dart';

// ─────────────────────────────────────────────────────────────
// FINALS ABOUT SHEET
//
// Different visualization from the main AboutSheet.
// Uses same developer data but with Finals gold/amber theme.
// ─────────────────────────────────────────────────────────────

class _Developer {
  final String name;
  final String program;
  final String role;
  final String email;
  final String contribution;
  final String phone;
  final String groups;
  final String facebook;

  const _Developer({
    required this.name,
    required this.program,
    required this.role,
    this.email = '',
    this.contribution = '',
    required this.phone,
    this.groups = '',
    this.facebook = '',
  });
}

const _developers = [
  _Developer(
    name: 'Joashua Marl Barimbao',
    program: 'BS Computer Science',
    role: 'Lead Developer',
    email: 'joashuabarimbao10@gmail.com',
    facebook: 'Joashua Marl Barimbao',
    contribution:
        'Wiring, Debugging,',
    phone: '09639201328',
    groups:
        '',
  ),
  _Developer(
    name: 'Michaela Denise Ong',
    program: 'BS Computer Science',
    role: 'Developer 2 / Docs',
    facebook: 'Michaela Denise Ong',
    email: 'michaeladenis11@gmail.com',
    contribution: '',
    phone: '09452238406',
    groups:
        '',
  ),
  _Developer(
    name: 'Nash Bruce Quiros',
    program: 'BS Computer Science',
    role: 'Developer 3',
    email: 'quirosnash2@gmail.com',
    facebook: 'Nash Bruce Quiros',
    contribution: '',
    phone: '09953941510',
    groups:
        '',
  ),
  _Developer(
    name: 'John Carlo Legaste',
    program: 'BS Computer Science',
    role: 'Developer 4',
    email: 'johncarlolegaste@gmail.com',
    facebook: 'John Carlo legaste',
    contribution: '',
    phone: '09639201328',
    groups:
        '',
  ),
  _Developer(
    name: 'Clifford Probetso',
    program: 'BS Computer Science',
    role: 'Developer 5',
    email: 'clifford.probetso@gmail.com',
    contribution: '',
    facebook: 'Clifford Probetso',
    phone: '09510069125',
    groups: '',
  ),
  _Developer(
    name: 'Johnlin Redido',
    program: 'BS Computer Science',
    role: 'Developer 6',
    facebook: 'Johnlin Redido',
    email: 'linzy21x@gmail.com',
    contribution: '',
    phone: '09700455407',
    groups:
        '',
  ),
];

void showFinalsAboutSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _FinalsAboutSheet(),
  );
}

class _FinalsAboutSheet extends StatelessWidget {
  const _FinalsAboutSheet();

  @override
  Widget build(BuildContext context) {


    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: FinalsTheme.surface(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: FinalsTheme.primary.withValues(alpha: 0.2),
                blurRadius: 40,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: Column(
            children: [
              // ── Gold drag handle ─────────────────────────────
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 8),
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    gradient: FinalsTheme.headerGradient,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),

              // ── Header with flame icon ──────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: FinalsTheme.headerGradient,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: FinalsTheme.primary.withValues(alpha: 0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.local_fire_department_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) =>
                                FinalsTheme.headerGradient.createShader(bounds),
                            child: const Text(
                              'Finals Team',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.8,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_developers.length} developers · Finals Period',
                            style: TextStyle(
                              fontSize: 14,
                              color: FinalsTheme.textSecondary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Scrollable content ──────────────────────────
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
                  children: [
                    // ── Description card ────────────────────────
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            FinalsTheme.primary.withValues(alpha: 0.08),
                            FinalsTheme.secondary.withValues(alpha: 0.04),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: FinalsTheme.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.emoji_events_rounded,
                                color: FinalsTheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'About Finals Module',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: FinalsTheme.textPrimary(context),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Advanced calculus topics developed for the final term examination. '
                            'All The Glory and Honor Belongs To Jesus.',
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.5,
                              color: FinalsTheme.textSecondary(context),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Section divider ─────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 1,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  FinalsTheme.primary.withValues(alpha: 0.3),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: FinalsTheme.headerGradient,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'DEVELOPERS',
                              style: TextStyle(
                                fontSize: 11,
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
                                  FinalsTheme.primary.withValues(alpha: 0.3),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ── Developer grid cards ────────────────────
                    ..._developers.asMap().entries.map(
                          (e) => _FinalsDeveloperCard(
                            developer: e.value,
                            index: e.key,
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

// ── Developer card with Finals styling ───────────────────────────────────────

class _FinalsDeveloperCard extends StatefulWidget {
  final _Developer developer;
  final int index;

  const _FinalsDeveloperCard({
    required this.developer,
    required this.index,
  });

  @override
  State<_FinalsDeveloperCard> createState() => _FinalsDeveloperCardState();
}

class _FinalsDeveloperCardState extends State<_FinalsDeveloperCard> {
  bool _expanded = false;

  static const _cardColors = [
    Color(0xFFFFB020), // Primary amber
    Color(0xFFFF6B35), // Secondary orange
    Color(0xFFFFD166), // Tertiary yellow
    Color(0xFFEF476F), // Danger rose
    Color(0xFF06D6A0), // Teal accent
    Color(0xFF118AB2), // Blue accent
  ];

  @override
  Widget build(BuildContext context) {
    final dev = widget.developer;
    final color = _cardColors[widget.index % _cardColors.length];
    final initials = dev.name
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GestureDetector(
        onTap: () => setState(() => _expanded = !_expanded),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: FinalsTheme.card(context),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _expanded
                  ? color.withValues(alpha: 0.6)
                  : color.withValues(alpha: 0.15),
              width: _expanded ? 2.5 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: _expanded ? 0.25 : 0.08),
                blurRadius: _expanded ? 24 : 16,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: FinalsTheme.shadowColor(context),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: -4,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Column(
              children: [
                // ── Top accent bar ──────────────────────────
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: _expanded ? 4 : 3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color,
                        color.withValues(alpha: 0.6),
                      ],
                    ),
                  ),
                ),

                // ── Main content ────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      // Avatar with ring
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: _expanded
                              ? LinearGradient(
                                  colors: [
                                    color,
                                    color.withValues(alpha: 0.7),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : LinearGradient(
                                  colors: [
                                    color.withValues(alpha: 0.15),
                                    color.withValues(alpha: 0.05),
                                  ],
                                ),
                          border: Border.all(
                            color: _expanded
                                ? color.withValues(alpha: 0.8)
                                : color.withValues(alpha: 0.3),
                            width: _expanded ? 3 : 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            initials,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: _expanded ? Colors.white : color,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dev.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: FinalsTheme.textPrimary(context),
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dev.program,
                              style: TextStyle(
                                fontSize: 13,
                                color: FinalsTheme.textSecondary(context),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Role pill
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: color.withValues(alpha: 0.4),
                                ),
                              ),
                              child: Text(
                                dev.role,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: color,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Expand icon
                      AnimatedRotation(
                        turns: _expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: _expanded
                                ? color.withValues(alpha: 0.15)
                                : FinalsTheme.cardSecondary(context),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: _expanded ? color : FinalsTheme.textSecondary(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Expanded details ────────────────────────
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Column(
                      children: [
                        Divider(
                          color: color.withValues(alpha: 0.2),
                          height: 1,
                        ),
                        const SizedBox(height: 16),

                        // Details grid
                        _DetailItem(
                          icon: Icons.email_outlined,
                          label: 'Email',
                          value: dev.email.isNotEmpty ? dev.email : 'Not provided',
                          color: color,
                        ),
                        const SizedBox(height: 12),
                        _DetailItem(
                          icon: Icons.facebook_rounded,
                          label: 'Facebook',
                          value: dev.facebook.isNotEmpty ? dev.facebook : 'Not provided',
                          color: color,
                        ),
                        const SizedBox(height: 12),
                        _DetailItem(
                          icon: Icons.code_rounded,
                          label: 'Contribution',
                          value: dev.contribution,
                          color: color,
                          isMultiline: true,
                        ),
                        const SizedBox(height: 12),
                        _DetailItem(
                          icon: Icons.phone_android_rounded,
                          label: 'Contact',
                          value: dev.phone,
                          color: color,
                        ),
                        const SizedBox(height: 12),
                        _DetailItem(
                          icon: Icons.groups_rounded,
                          label: 'Team Members',
                          value: dev.groups,
                          color: color,
                          isMultiline: true,
                        ),
                      ],
                    ),
                  ),
                  crossFadeState: _expanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Detail item widget ───────────────────────────────────────────────────────

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isMultiline;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.isMultiline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: FinalsTheme.textSecondary(context),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: FinalsTheme.textPrimary(context),
              height: isMultiline ? 1.5 : 1.2,
            ),
          ),
        ),
      ],
    );
  }
}