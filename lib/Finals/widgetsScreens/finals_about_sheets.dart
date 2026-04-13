import 'package:flutter/material.dart';
import 'package:calculus_system/Finals/finals_theme.dart';

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
  final String Facebook;

  const _Developer({
    required this.name,
    required this.program,
    required this.role,
    this.email = '',
    this.contribution = '',
    required this.phone,
    this.groups = '',
    this.Facebook = '',
  });
}

const _developers = [
  _Developer(
    name: 'Joashua Marl Barimbao',
    program: 'BS Computer Science',
    role: 'Lead Developer',
    email: 'joashuabarimbao10@gmail.com',
    Facebook: 'Joashua Marl Barimbao',
    contribution: 'Wiring, Debugging,',
    phone: '09639201328',
    groups: '',
  ),
  _Developer(
    name: 'Michaela Denise Ong',
    program: 'BS Computer Science',
    role: 'Developer 2 / Docs',
    Facebook: 'Michaela Denise Ong',
    email: 'michaeladenis11@gmail.com',
    contribution: '',
    phone: '09452238406',
    groups: '',
  ),
  _Developer(
    name: 'Nash Bruce Quiros',
    program: 'BS Computer Science',
    role: 'Developer 3',
    email: 'quirosnash2@gmail.com',
    Facebook: 'Nash Bruce Quiros',
    contribution: '',
    phone: '09953941510',
    groups: '',
  ),
  _Developer(
    name: 'John Carlo Legaste',
    program: 'BS Computer Science',
    role: 'Developer 4',
    email: 'johncarlolegaste@gmail.com',
    Facebook: 'John Carlo legaste',
    contribution: '',
    phone: '09639201328',
    groups: '',
  ),
  _Developer(
    name: 'Clifford Probetso',
    program: 'BS Computer Science',
    role: 'Developer 5',
    email: 'clifford.probetso@gmail.com',
    contribution: '',
    Facebook: 'Clifford Probetso',
    phone: '09510069125',
    groups: '',
  ),
  _Developer(
    name: 'Johnlin Redido',
    program: 'BS Computer Science',
    role: 'Developer 6',
    Facebook: 'Johnlin Redido',
    email: 'linzy21x@gmail.com',
    contribution: '',
    phone: '09700455407',
    groups: '',
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

  // Design baseline for scaling
  static const double _baseDesignWidth = 400.0;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        // Wrap in LayoutBuilder to get exact screen width for scaling
        return LayoutBuilder(
          builder: (context, constraints) {
            final double s = (constraints.maxWidth / _baseDesignWidth).clamp(0.75, 1.1);

            return Container(
              decoration: BoxDecoration(
                color: FinalsTheme.surface(context),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: FinalsTheme.primary.withValues(alpha: 0.2),
                    blurRadius: 40 * s,
                    offset: Offset(0, -10 * s),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // ── Gold drag handle ─────────────────────────────
                  Padding(
                    padding: EdgeInsets.only(top: 16 * s, bottom: 8 * s),
                    child: Container(
                      width: 48 * s,
                      height: 5 * s,
                      decoration: BoxDecoration(
                        gradient: FinalsTheme.headerGradient,
                        borderRadius: BorderRadius.circular(3 * s),
                      ),
                    ),
                  ),

                  // ── Header with flame icon ──────────────────────
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 28 * s, vertical: 16 * s),
                    child: Row(
                      children: [
                        Container(
                          width: 56 * s,
                          height: 56 * s,
                          decoration: BoxDecoration(
                            gradient: FinalsTheme.headerGradient,
                            borderRadius: BorderRadius.circular(18 * s),
                            boxShadow: [
                              BoxShadow(
                                color: FinalsTheme.primary.withValues(alpha: 0.4),
                                blurRadius: 20 * s,
                                offset: Offset(0, 6 * s),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.local_fire_department_rounded,
                            color: Colors.white,
                            size: 30 * s,
                          ),
                        ),
                        SizedBox(width: 16 * s),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) =>
                                    FinalsTheme.headerGradient.createShader(bounds),
                                child: Text(
                                  'Finals Team',
                                  style: TextStyle(
                                    fontSize: 28 * s,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -0.8 * s,
                                  ),
                                ),
                              ),
                              SizedBox(height: 4 * s),
                              Text(
                                '${_developers.length} developers · Finals Period',
                                style: TextStyle(
                                  fontSize: 14 * s,
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
                      padding: EdgeInsets.fromLTRB(24 * s, 8 * s, 24 * s, 40 * s),
                      children: [
                        // ── Description card ────────────────────────
                        Container(
                          padding: EdgeInsets.all(20 * s),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                FinalsTheme.primary.withValues(alpha: 0.08),
                                FinalsTheme.secondary.withValues(alpha: 0.04),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20 * s),
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
                                    size: 20 * s,
                                  ),
                                  SizedBox(width: 8 * s),
                                  Text(
                                    'About Finals Module',
                                    style: TextStyle(
                                      fontSize: 14 * s,
                                      fontWeight: FontWeight.w700,
                                      color: FinalsTheme.textPrimary(context),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10 * s),
                              Text(
                                'Advanced calculus topics developed for the final term examination. '
                                'All The Glory and Honor Belongs To Jesus.',
                                style: TextStyle(
                                  fontSize: 13 * s,
                                  height: 1.5,
                                  color: FinalsTheme.textSecondary(context),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 24 * s),

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
                              padding: EdgeInsets.symmetric(horizontal: 16 * s),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 14 * s,
                                  vertical: 6 * s,
                                ),
                                decoration: BoxDecoration(
                                  gradient: FinalsTheme.headerGradient,
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
                                      FinalsTheme.primary.withValues(alpha: 0.3),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20 * s),

                        // ── Developer grid cards ────────────────────
                        ..._developers.asMap().entries.map(
                              (e) => _FinalsDeveloperCard(
                                developer: e.value,
                                index: e.key,
                                scale: s, // Pass scale down to cards
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

// ── Developer card with Finals styling ───────────────────────────────────────

class _FinalsDeveloperCard extends StatefulWidget {
  final _Developer developer;
  final int index;
  final double scale; // Added scale parameter

  const _FinalsDeveloperCard({
    required this.developer,
    required this.index,
    required this.scale,
  });

  @override
  State<_FinalsDeveloperCard> createState() => _FinalsDeveloperCardState();
}

class _FinalsDeveloperCardState extends State<_FinalsDeveloperCard> {
  bool _expanded = false;

  static const _cardColors = [
    Color(0xFFFFB020),
    Color(0xFFFF6B35),
    Color(0xFFFFD166),
    Color(0xFFEF476F),
    Color(0xFF06D6A0),
    Color(0xFF118AB2),
  ];

  @override
  Widget build(BuildContext context) {
    final dev = widget.developer;
    final s = widget.scale; // Local scale variable
    final color = _cardColors[widget.index % _cardColors.length];
    final initials = dev.name
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();

    return Padding(
      padding: EdgeInsets.only(bottom: 14 * s),
      child: GestureDetector(
        onTap: () => setState(() => _expanded = !_expanded),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: FinalsTheme.card(context),
            borderRadius: BorderRadius.circular(24 * s),
            border: Border.all(
              color: _expanded
                  ? color.withValues(alpha: 0.6)
                  : color.withValues(alpha: 0.15),
              width: _expanded ? 2.5 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: _expanded ? 0.25 : 0.08),
                blurRadius: _expanded ? 24 * s : 16 * s,
                offset: Offset(0, 8 * s),
              ),
              BoxShadow(
                color: FinalsTheme.shadowColor(context),
                blurRadius: 12 * s,
                offset: Offset(0, 4 * s),
                spreadRadius: -4 * s,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24 * s),
            child: Column(
              children: [
                // ── Top accent bar ──────────────────────────
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: _expanded ? 4 * s : 3 * s,
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
                  padding: EdgeInsets.all(20 * s),
                  child: Row(
                    children: [
                      // Avatar with ring
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 56 * s,
                        height: 56 * s,
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
                              fontSize: 18 * s,
                              fontWeight: FontWeight.w800,
                              color: _expanded ? Colors.white : color,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: 16 * s),

                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dev.name,
                              style: TextStyle(
                                fontSize: 16 * s,
                                fontWeight: FontWeight.w700,
                                color: FinalsTheme.textPrimary(context),
                                letterSpacing: -0.3 * s,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4 * s),
                            Text(
                              dev.program,
                              style: TextStyle(
                                fontSize: 13 * s,
                                color: FinalsTheme.textSecondary(context),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 8 * s),
                            // Role pill
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12 * s,
                                vertical: 5 * s,
                              ),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12 * s),
                                border: Border.all(
                                  color: color.withValues(alpha: 0.4),
                                ),
                              ),
                              child: Text(
                                dev.role,
                                style: TextStyle(
                                  fontSize: 11 * s,
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
                          width: 36 * s,
                          height: 36 * s,
                          decoration: BoxDecoration(
                            color: _expanded
                                ? color.withValues(alpha: 0.15)
                                : FinalsTheme.cardSecondary(context),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 20 * s,
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
                    padding: EdgeInsets.fromLTRB(20 * s, 0, 20 * s, 20 * s),
                    child: Column(
                      children: [
                        Divider(
                          color: color.withValues(alpha: 0.2),
                          height: 1,
                        ),
                        SizedBox(height: 16 * s),

                        // Details grid
                        _DetailItem(
                          icon: Icons.email_outlined,
                          label: 'Email',
                          value: dev.email.isNotEmpty ? dev.email : 'Not provided',
                          color: color,
                          scale: s,
                        ),
                        SizedBox(height: 12 * s),
                        _DetailItem(
                          icon: Icons.facebook_rounded,
                          label: 'Facebook',
                          value: dev.Facebook.isNotEmpty ? dev.Facebook : 'Not provided',
                          color: color,
                          scale: s,
                        ),
                        SizedBox(height: 12 * s),
                        _DetailItem(
                          icon: Icons.code_rounded,
                          label: 'Contribution',
                          value: dev.contribution.isEmpty ? 'Not specified' : dev.contribution,
                          color: color,
                          scale: s,
                          isMultiline: true,
                        ),
                        SizedBox(height: 12 * s),
                        _DetailItem(
                          icon: Icons.phone_android_rounded,
                          label: 'Contact',
                          value: dev.phone,
                          color: color,
                          scale: s,
                        ),
                        SizedBox(height: 12 * s),
                        _DetailItem(
                          icon: Icons.groups_rounded,
                          label: 'Team Members',
                          value: dev.groups.isEmpty ? 'Not specified' : dev.groups,
                          color: color,
                          scale: s,
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
  final double scale; // Added scale

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.isMultiline = false,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final s = scale;

    return Row(
      crossAxisAlignment: isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Container(
          width: 32 * s,
          height: 32 * s,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10 * s),
          ),
          child: Icon(icon, size: 16 * s, color: color),
        ),
        SizedBox(width: 12 * s),
        
        // Changed from fixed SizedBox to Flexible so labels don't crush values on tiny screens
        Flexible(
          flex: 0, 
          child: Container(
            constraints: BoxConstraints(minWidth: 70 * s, maxWidth: 90 * s), // Responsive width bounds
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12 * s,
                fontWeight: FontWeight.w600,
                color: FinalsTheme.textSecondary(context),
              ),
            ),
          ),
        ),
        
        // Value text takes remaining space safely
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13 * s,
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