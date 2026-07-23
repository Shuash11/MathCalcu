import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calculus_system/models/developer.dart';
import 'package:calculus_system/theme/theme_provider.dart';

class DeveloperTile extends StatefulWidget {
  final Developer developer;
  final int index;
  final Color accent;

  const DeveloperTile({
    super.key,
    required this.developer,
    required this.index,
    this.accent = const Color(0xFF334155),
  });

  @override
  State<DeveloperTile> createState() => _DeveloperTileState();
}

class _DeveloperTileState extends State<DeveloperTile> {
  bool _expanded = false;

  static const _avatarColors = [
    Color(0xFF334155),
    Color(0xFF16A34A),
    Color(0xFFDC2626),
    Color(0xFFD97706),
    Color(0xFF0C0C09),
    Color(0xFF334155),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final dev = widget.developer;
    final baseColor = _avatarColors[widget.index % _avatarColors.length];
    final color = theme.isDark ? theme.accentColor : baseColor;
    final initials = dev.name
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Semantics(
        label: '${dev.name}, ${dev.role}',
        button: true,
        toggled: _expanded,
        onTap: () => setState(() => _expanded = !_expanded),
        excludeSemantics: true,
        child: GestureDetector(
          excludeFromSemantics: true,
          onTap: () => setState(() => _expanded = !_expanded),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: _expanded ? color.withValues(alpha: 0.04) : theme.card,
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
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Column(
                children: [
                  // Top accent bar
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

                  // Main content
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
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: color,
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
                                  color: theme.textPrimary,
                                  letterSpacing: -0.3,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                dev.program,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: theme.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
                                  : theme.card,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 20,
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
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Column(
                        children: [
                          Divider(
                            color: color.withValues(alpha: 0.2),
                            height: 1,
                          ),
                          const SizedBox(height: 16),

                          // Details
                          _InfoRow(
                            icon: Icons.email_outlined,
                            label: 'Email',
                            value: dev.email.isNotEmpty
                                ? dev.email
                                : 'Not provided',
                            color: color,
                            theme: theme,
                          ),
                          const SizedBox(height: 12),
                          _InfoRow(
                            icon: Icons.emoji_emotions,
                            label: 'Facebook',
                            value: dev.facebook.isNotEmpty
                                ? dev.facebook
                                : 'Not provided',
                            color: color,
                            theme: theme,
                          ),
                          const SizedBox(height: 12),
                          _InfoRow(
                            icon: Icons.code_rounded,
                            label: 'Contribution',
                            value: dev.contribution.isNotEmpty
                                ? dev.contribution
                                : 'Not provided',
                            color: color,
                            theme: theme,
                            isMultiline: true,
                          ),
                          const SizedBox(height: 12),
                          _InfoRow(
                            icon: Icons.phone_android,
                            label: 'Contact',
                            value: dev.phone,
                            color: color,
                            theme: theme,
                          ),
                          const SizedBox(height: 12),
                          _InfoRow(
                            icon: Icons.groups_rounded,
                            label: 'Members',
                            value: dev.groups.isNotEmpty
                                ? dev.groups
                                : 'Not specified',
                            color: color,
                            theme: theme,
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
      ),
    );
  }
}

// -- Single info row inside the dropdown ---------------------------------------

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final ThemeProvider theme;
  final bool isMultiline;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.theme,
    this.isMultiline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
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
        Flexible(
          flex: 0,
          child: Container(
            constraints: const BoxConstraints(minWidth: 70, maxWidth: 90),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
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
              fontSize: 13,
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
