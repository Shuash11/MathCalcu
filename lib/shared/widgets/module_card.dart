import 'package:flutter/material.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class ModuleCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? accentColor;

  const ModuleCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.accentColor,
  });

  @override
  State<ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<ModuleCard> {
  bool _hovered = false;
  bool _pressed = false;

  Color get _accent => widget.accentColor ?? const Color(0xFF9CA3AF);

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: _hovered
                  ? theme.card.withValues(alpha: 0.95)
                  : theme.card.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _hovered
                    ? _accent.withValues(alpha: 0.4)
                    : theme.textSecondary.withValues(alpha: 0.12),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: _accent.withValues(alpha: _hovered ? 0.12 : 0.06),
                  blurRadius: _hovered ? 20 : 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                // Icon container
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _accent.withValues(alpha: _hovered ? 0.15 : 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _accent.withValues(alpha: _hovered ? 0.3 : 0.15),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    widget.icon,
                    color: _accent,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                // Title and subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: theme.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: theme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Arrow
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  transform: _hovered
                      ? Matrix4.translationValues(3.0, 0.0, 0.0)
                      : Matrix4.identity(),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: _hovered
                        ? _accent
                        : theme.textSecondary.withValues(alpha: 0.5),
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
