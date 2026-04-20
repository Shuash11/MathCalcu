import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calculus_system/theme/theme_provider.dart';

// ── Developer data ───────────────────────────────────────────────────────────

class _Developer {
  final String name;
  final String program;
  final String role;
  final String email;
  final String contribution;

  final String Phone;
  final String groups;
  final String facebook;

  const _Developer({
    required this.name,
    required this.program,
    required this.role,
    this.email = '',
    this.contribution = '',
    required this.Phone,
    this.groups = '',
    this.facebook = '',
  });
}

const _developers = [
  _Developer(
    name: 'Joashua Marl Barimbao',
    program: 'BS Computer Science',
    role: 'Lead\nDeveloper',
    email: 'joashuabarimbao10@gmail.com',
    facebook: 'Joashua Marl Barimbao',
    contribution:
        'Wiring, Debugging, Deploying, Absolute , Strict , Non Strict, Radical , Continued , Finding the Center , Finding the Radius',
    Phone: '09639201328',
    groups:
        'Mary Chris Malinao\nKym Alinsonorin\nAljhun Gallego(gwapo)\nCresa Delacruz(Documentation)\nJoseph Rebamonte\nMerjohn Pagente',
  ),
  _Developer(
    name: 'Michaela Denise Ong',
    program: 'BS Computer Science',
    role: 'Developer 2 / Docs',
    facebook: 'Michaela Denise Ong',
    email: 'michaeladenis11@gmail.com',
    contribution: 'Slope, Distance , Midpoint, Documentation',
    Phone: '09452238406',
    groups:
        'Marie Joy Sebusana\nSusan Rhea Tamboboy\nVenus Caliguid\nAlche Paye\nVincent Padillio\nStephen Mark Maluto',
  ),
  _Developer(
    name: 'Nash Bruce Quiros',
    program: 'BS Computer Science',
    role: 'Developer 3',
    email: 'quirosnash2@gmail.com',
    facebook: 'Nash Bruce Quiros',
    contribution: 'Basic , Quadratic, Rational',
    Phone: '09953941510',
    groups:
        'Cabrera Carl Edward\nTyrus Regine\nRhea Mae Bustamante\nJoshua Barientos',
  ),
  _Developer(
    name: 'John Carlo Legaste',
    program: 'BS Computer Science',
    role: 'Developer 4',
    email: 'johncarlolegaste@gmail.com',
    facebook: 'John Carlo legaste',
    contribution: 'Parallel & Perpendicular(Slope), Two-Point Slope',
    Phone: '09639201328',
    groups:
        'Anjelyn Campos\nAlthea Sumalpong\nHearty Abugatal\nRafol Shayne Lowelle\nNoel Sale Jr\nJeomark Jumawan\nGraceselle Managing',
  ),
  _Developer(
    name: 'Clifford Probetso',
    program: 'BS Computer Science',
    role: 'Developer 5',
    email: 'clifford.probetso@gmail.com',
    contribution: 'Point Slope, Finding the Center Radius',
    facebook: 'Clifford Probetso',
    Phone: '09510069125',
    groups:
        'Angelie Jerusalem\nIvan Rabanzo\nLausa Dave\nJanwell Nacario\nRoynuj Plaza ',
  ),
  _Developer(
    name: 'Johnlin Redido',
    program: 'BS Computer Science',
    role: 'Developer 6',
    facebook: 'Johnlin Redido',
    email: 'linzy21x@gmail.com',
    contribution: 'Slope-Intercept_form',
    Phone: '09700455407',
    groups:
        'Gretechen Tumilap\nGonzaga Blessy\nJemson Tubis\nAllysa Sharise Cagui-at\nAlyssa Jean Toso',
  ),
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
                                '${_developers.length} developers · Math Solving App',
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
                        ..._developers.asMap().entries.map(
                              (e) => _DeveloperTile(
                                key: ValueKey(e.value.name),
                                developer: e.value,
                                index: e.key,
                                accent: accent,
                                scale: s,
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

// ── Single expandable developer tile ──────────────────────────────────────────

class _DeveloperTile extends StatefulWidget {
  final _Developer developer;
  final int index;
  final Color accent;
  final double scale;

  const _DeveloperTile({
    super.key,
    required this.developer,
    required this.index,
    required this.accent,
    required this.scale,
  });

  @override
  State<_DeveloperTile> createState() => _DeveloperTileState();
}

class _DeveloperTileState extends State<_DeveloperTile> {
  bool _expanded = false;

  static const _avatarColors = [
    Color(0xFF6C63FF),
    Color(0xFF00BFA5),
    Color(0xFFFF6B6B),
    Color(0xFFFFB300),
    Color(0xFF42A5F5),
    Color(0xFFAB47BC),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final dev = widget.developer;
    final s = widget.scale;
    final color = _avatarColors[widget.index % _avatarColors.length];
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
            color: _expanded ? color.withValues(alpha: 0.04) : theme.card,
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
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24 * s),
            child: Column(
              children: [
                // Top accent bar
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

                // Main content
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
                          color: _expanded
                              ? color.withValues(alpha: 0.15)
                              : color.withValues(alpha: 0.08),
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
                              color: color,
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
                                color: theme.textPrimary,
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
                                color: theme.textSecondary,
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
                                : theme.card,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 20 * s,
                            color: _expanded ? color : theme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Expanded details
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

                        // Details
                        _InfoRow(
                          icon: Icons.email_outlined,
                          label: 'Email',
                          value: dev.email.isNotEmpty ? dev.email : 'Not provided',
                          color: color,
                          theme: theme,
                          scale: s,
                        ),
                        SizedBox(height: 12 * s),
                        _InfoRow(
                          icon: Icons.emoji_emotions,
                          label: 'Facebook',
                          value: dev.facebook.isNotEmpty ? dev.facebook : 'Not provided',
                          color: color,
                          theme: theme,
                          scale: s,
                        ),
                        SizedBox(height: 12 * s),
                        _InfoRow(
                          icon: Icons.code_rounded,
                          label: 'Contribution',
                          value: dev.contribution.isNotEmpty ? dev.contribution : 'Not provided',
                          color: color,
                          theme: theme,
                          scale: s,
                          isMultiline: true,
                        ),
                        SizedBox(height: 12 * s),
                        _InfoRow(
                          icon: Icons.phone_android,
                          label: 'Contact',
                          value: dev.Phone,
                          color: color,
                          theme: theme,
                          scale: s,
                        ),
                        SizedBox(height: 12 * s),
                        _InfoRow(
                          icon: Icons.groups_rounded,
                          label: 'Members',
                          value: dev.groups.isNotEmpty ? dev.groups : 'Not specified',
                          color: color,
                          theme: theme,
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

// ── Single info row inside the dropdown ───────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final ThemeProvider theme;
  final double scale;
  final bool isMultiline;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.theme,
    required this.scale,
    this.isMultiline = false,
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

        Flexible(
          flex: 0,
          child: Container(
            constraints: BoxConstraints(minWidth: 70 * s, maxWidth: 90 * s),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12 * s,
                fontWeight: FontWeight.w600,
                color: theme.textSecondary,
              ),
            ),
          ),
        ),

        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13 * s,
              fontWeight: FontWeight.w500,
              color: theme.textPrimary,
              height: isMultiline ? 1.5 : 1.2,
            ),
          ),
        ),
      ],
    );
  }
}
