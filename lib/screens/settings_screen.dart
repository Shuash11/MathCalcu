import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:calculus_system/widgets/donate_sheet.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _accent = Color(0xFF6C63FF);
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) setState(() => _appVersion = 'v${info.version}');
    } catch (_) {
      if (mounted) setState(() => _appVersion = 'v1.2.0');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    return Scaffold(
      backgroundColor: theme.surface,
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          _sectionHeader('Theme'),
          _SettingsRow(
            icon: theme.isLight ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            label: 'Dark Mode',
            trailing: Switch.adaptive(
              value: !theme.isLight,
              onChanged: (_) => theme.toggle(),
            ),
          ),
          const SizedBox(height: 24),
          _sectionHeader('Support'),
          _SettingsRow(
            icon: Icons.coffee_rounded,
            label: 'Donate',
            subtitle: 'Support the developer',
            trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: _accent.withValues(alpha: 0.6)),
            onTap: () => showDonateSheet(context),
          ),
          const SizedBox(height: 24),
          _sectionHeader('GitHub'),
          _SettingsRow(
            icon: Icons.code_rounded,
            label: 'Shuash11',
            subtitle: 'View developer profile & repos',
            trailing: const Icon(Icons.open_in_new_rounded, size: 16, color: _accent),
            onTap: () async {
              final uri = Uri.parse('https://github.com/Shuash11');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          ),
          const SizedBox(height: 24),
          _sectionHeader('About'),
          _SettingsRow(
            icon: Icons.info_outline_rounded,
            label: 'MathCalcu',
            subtitle: _appVersion,
          ),
          const SizedBox(height: 12),
          const _SettingsRow(
            icon: Icons.person_rounded,
            label: 'Developer',
            subtitle: 'Joashua Marl Barimbao',
          ),
          const SizedBox(height: 12),
          _SettingsRow(
            icon: Icons.email_outlined,
            label: 'Contact',
            subtitle: 'joashuabarimbao10@gmail.com',
            onTap: () async {
              final uri = Uri.parse('mailto:joashuabarimbao10@gmail.com');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            },
          ),
          const SizedBox(height: 12),
          _SettingsRow(
            icon: Icons.language_rounded,
            label: 'Website',
            subtitle: 'mathcalc-calculus.netlify.app',
            trailing: const Icon(Icons.open_in_new_rounded, size: 16, color: _accent),
            onTap: () async {
              final uri = Uri.parse('https://mathcalc-calculus.netlify.app/');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: _accent,
          letterSpacing: 0.5,
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
  final VoidCallback? onTap;

  const _SettingsRow({
    required this.icon,
    required this.label,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.card,
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
      ),
    );
  }
}
