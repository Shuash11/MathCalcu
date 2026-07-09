import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:calculus_system/widgets/donate_sheet.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  static const _accent = Color(0xFF6C63FF);
  static const _owner = 'Shuash11';
  static const _repo = 'MathCalcu';
  String _appVersion = '';
  String _latestVersion = '';
  late final AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _loadVersion();
    _loadLatestVersion();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) setState(() => _appVersion = 'v${info.version}');
    } catch (_) {
      if (mounted) setState(() => _appVersion = 'v1.4.2');
    }
  }

  Future<void> _loadLatestVersion() async {
    try {
      final uri = Uri.parse('https://api.github.com/repos/$_owner/$_repo/releases/latest');
      final res = await http.get(uri, headers: {'Accept': 'application/vnd.github.v3+json'});
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final tag = data['tag_name'] as String? ?? '';
        if (mounted) setState(() => _latestVersion = tag);
      }
    } catch (_) {}
  }

  String get _versionSubtitle {
    if (_latestVersion.isEmpty) return _appVersion;
    if (_appVersion == _latestVersion) return '$_appVersion — up to date';
    return '$_appVersion · update to $_latestVersion';
  }

  Animation<double> _fadeFor(int index) {
    final start = (index * 0.07).clamp(0.0, 0.8);
    final end = (start + 0.25).clamp(0.0, 1.0);
    return CurvedAnimation(
      parent: _staggerController,
      curve: Interval(start, end, curve: Curves.easeOut),
    );
  }

  Animation<Offset> _slideFor(int index) {
    final start = (index * 0.07).clamp(0.0, 0.8);
    final end = (start + 0.3).clamp(0.0, 1.0);
    return Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    Widget buildAnimatedRow(int index, Widget row) {
      return FadeTransition(
        opacity: _fadeFor(index),
        child: SlideTransition(
          position: _slideFor(index),
          child: row,
        ),
      );
    }

    Widget sectionDivider() {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                _accent.withValues(alpha: 0.2),
                Colors.transparent,
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.surface,
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        backgroundColor: theme.surface,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          _sectionHeader('Theme'),
          buildAnimatedRow(0, _buildCard(
            child: _SettingsRow(
              icon: theme.isLight ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              label: 'Dark Mode',
              trailing: Switch.adaptive(
                value: !theme.isLight,
                onChanged: (_) => theme.toggle(),
              ),
            ),
          )),
          sectionDivider(),
          _sectionHeader('Support'),
          buildAnimatedRow(1, _buildTappableCard(
            child: _SettingsRow(
              icon: Icons.coffee_rounded,
              label: 'Donate',
              subtitle: 'Support the developer',
              trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: _accent.withValues(alpha: 0.6)),
            ),
            onTap: () => showDonateSheet(context),
          )),
          sectionDivider(),
          _sectionHeader('About'),
          buildAnimatedRow(2, _buildCard(
            child: _SettingsRow(
              icon: Icons.info_outline_rounded,
              label: 'MathCalcu',
              subtitle: _versionSubtitle,
            ),
          )),
          buildAnimatedRow(3, _buildTappableCard(
            child: const _SettingsRow(
              icon: Icons.language_rounded,
              label: 'Website',
              subtitle: 'mathcalc-calculus.netlify.app',
              trailing: Icon(Icons.open_in_new_rounded, size: 16, color: _accent),
            ),
            onTap: () async {
              try {
                await launchUrl(Uri.parse('https://mathcalc-calculus.netlify.app/'), mode: LaunchMode.externalApplication);
              } catch (_) {}
            },
          )),
          buildAnimatedRow(4, _buildTappableCard(
            child: const _SettingsRow(
              icon: Icons.code_rounded,
              label: 'GitHub',
              subtitle: 'Shuash11',
              trailing: Icon(Icons.open_in_new_rounded, size: 16, color: _accent),
            ),
            onTap: () async {
              try {
                await launchUrl(Uri.parse('https://github.com/Shuash11'), mode: LaunchMode.externalApplication);
              } catch (_) {}
            },
          )),
          sectionDivider(),
          _sectionHeader('Team'),
          buildAnimatedRow(5, _buildTappableCard(
            child: const _SettingsRow(
              icon: Icons.group_rounded,
              label: 'Meet the Team',
              subtitle: 'mathcalcu-build.netlify.app',
              trailing: Icon(Icons.open_in_new_rounded, size: 16, color: _accent),
            ),
            onTap: () async {
              try {
                await launchUrl(Uri.parse('https://mathcalcu-build.netlify.app/'), mode: LaunchMode.externalApplication);
              } catch (_) {}
            },
          )),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    final theme = context.watch<ThemeProvider>();
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: theme.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _accent.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildTappableCard({required Widget child, required VoidCallback onTap}) {
    return _TappableCard(onTap: onTap, child: child);
  }

  Widget _sectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4, top: 8),
      child: Row(
        children: [
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _accent,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 1.5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _accent.withValues(alpha: 0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TappableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _TappableCard({required this.onTap, required this.child});

  @override
  State<_TappableCard> createState() => _TappableCardState();
}

class _TappableCardState extends State<_TappableCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: theme.card,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _SettingsScreenState._accent.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Widget? trailing;

  const _SettingsRow({
    required this.icon,
    required this.label,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF6C63FF)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.textPrimary,
                  ),
                ),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}


