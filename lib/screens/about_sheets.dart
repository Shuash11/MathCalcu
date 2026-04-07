import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calculus_system/theme/theme_provider.dart';

// ── Developer data ───────────────────────────────────────────────────────────

class _Developer {
  final String name;
  final String program;
  final String role;
  // ─── ADD YOUR EXTRA INFO HERE ───
  final String email;
  final String contribution;

  final String Phone;
  final String groups;
  final String facebook;

  const _Developer({
    required this.name,
    required this.program,
    required this.role,
    this.email = '', // ← put email or leave blank
    this.contribution = '', // ← what they worked on
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
        'Mary Chris Malinao\nKym Alinsonorin\nAljhun Gallego(gwapo)\nCresa Delacruz',
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
        'Marie Joy Sebusana\nSusan Rhea Tamboby\nVenus Caliguid\nAlche Paye\nVincent Padillio',
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
        'Anjelyn Campos\nAlthea Sumalpong\nHearty Abugatal\nRafol Shayne Lowelle\nNoel Sale Jr',
  ),
  _Developer(
    name: 'Clifford Probetso',
    program: 'BS Computer Science',
    role: 'Developer 6',
    email: 'clifford.probetso@gmail.com',
    contribution: 'Point Slope, Finding the Center Radius',
    facebook: 'Clifford Probetso',
    Phone: '09510069125',
    groups: 'Angelie Jerusalem\nIvan Rabanzo',
  ),
  _Developer(
    name: 'Johnlin Redido',
    program: 'BS Computer Science',
    role: 'Developer 6',
    facebook: 'Johnlin Redido',
    email: 'linzy21x@gmail.com',
    contribution: 'Slope-Intercept_form',
    Phone: '09700455407',
    groups: 'Gretechen Tumilap\nGonzaga\nJemson Tubis',
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
                    // ── App badge ──────────────────────────────────────
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
                        child: Image.asset(
                          'assets/images/app_icon.png',
                          width: 42,
                          height: 42,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── App name & description ────────────────────────
                    Center(
                      child: Text(
                        'MathCalc',
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
                        'A collaborative math solving app covering only \n'
                        'slope, distance, inequalities, and more.\n'
                        'It only solves Specific Discussions of Miss K class\n'
                        'For more information Contact the Lead Developer.\n'
                        'All The Glory and Honor Belongs To Jesus',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: theme.textSecondary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── Divider label ─────────────────────────────────
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

                    // ── Tap hint ──────────────────────────────────────
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'Tap a card to see more info',
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.textSecondary.withValues(alpha: 0.5),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Developer cards ───────────────────────────────
                    ..._developers.asMap().entries.map(
                          (e) => _DeveloperTile(
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
  }
}

// ── Single expandable developer tile ──────────────────────────────────────────

class _DeveloperTile extends StatefulWidget {
  final _Developer developer;
  final int index;
  final Color accent;

  const _DeveloperTile({
    super.key,
    required this.developer,
    required this.index,
    required this.accent,
  });

  @override
  State<_DeveloperTile> createState() => _DeveloperTileState();
}

class _DeveloperTileState extends State<_DeveloperTile>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;

  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  late final Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

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
    final color = _avatarColors[widget.index % _avatarColors.length];
    final initials = dev.name
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: _toggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: _expanded ? color.withValues(alpha: 0.04) : theme.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _expanded
                  ? color.withValues(alpha: 0.35)
                  : color.withValues(alpha: 0.15),
              width: _expanded ? 1.5 : 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            children: [
              // ── Top row (always visible) ────────────────────────
              Row(
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
                          dev.name,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: theme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          dev.program,
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      dev.role,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Arrow indicator
                  RotationTransition(
                    turns: _rotationAnimation,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: theme.textSecondary.withValues(alpha: 0.5),
                      size: 22,
                    ),
                  ),
                ],
              ),

              // ── Expandable section (dropdown info) ──────────────
              SizeTransition(
                sizeFactor: _expandAnimation,
                axisAlignment: -1,
                child: Column(
                  children: [
                    const SizedBox(height: 14),

                    // Thin divider
                    Divider(
                      color: color.withValues(alpha: 0.15),
                      height: 1,
                    ),
                    const SizedBox(height: 14),

                    // ─── INFO ROWS ── FILL IN YOUR DATA ───────────
                    //
                    // Each _InfoRow is one line of detail.
                    // Change the labels or add/remove rows as needed.

                    _InfoRow(
                      icon: Icons.email_outlined,
                      label: 'Email', // ← LABEL
                      value: dev.email.isNotEmpty
                          ? dev.email
                          : 'Not provided', // ← VALUE
                      color: color,
                      theme: theme,
                    ),
                    const SizedBox(height: 10),
                    _InfoRow(
                      icon: Icons.emoji_emotions,
                      label: 'Facebook', // ← LABEL
                      value: dev.facebook.isNotEmpty
                          ? dev.facebook
                          : 'Not provided', // ← VALUE
                      color: color,
                      theme: theme,
                    ),
                    const SizedBox(height: 10),
                    _InfoRow(
                      icon: Icons.code_rounded,
                      label: 'Contribution', // ← LABEL
                      value: dev.contribution.isNotEmpty
                          ? dev.contribution
                          : 'Not provided', // ← VALUE
                      color: color,
                      theme: theme,
                    ),

                    const SizedBox(height: 10),
                    _InfoRow(
                      icon: Icons.phone_android,
                      label: 'Phone', // ← LABEL
                      value: dev.Phone.toString(), // ← VALUE
                      color: color,
                      theme: theme,
                    ),

                    const SizedBox(height: 10),
                    _InfoRow(
                      icon: Icons.group_add_outlined,
                      label: 'Memebers', // ← LABEL
                      value: dev.groups.toString(), // ← VALUE
                      color: color,
                      theme: theme,
                    ),
                    // ─── ADD MORE ROWS HERE IF NEEDED ─────────────
                    // const SizedBox(height: 10),
                    // _InfoRow(
                    //   icon: Icons.link_rounded,
                    //   label: 'GitHub',
                    //   value: 'github.com/username',
                    //   color: color,
                    //   theme: theme,
                    // ),
                  ],
                ),
              ),
            ],
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

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Small icon
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: color),
        ),

        const SizedBox(width: 12),

        // Label
        SizedBox(
          width: 85,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: theme.textSecondary,
            ),
          ),
        ),

        // Value
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: theme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
