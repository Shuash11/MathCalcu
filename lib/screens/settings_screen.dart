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
      if (mounted) setState(() => _appVersion = 'v1.1.0');
    }
  }
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _sectionHeader('Appearance'),
          Card(
            child: ListTile(
              leading: Icon(themeProvider.isLight ? Icons.dark_mode_rounded : Icons.light_mode_rounded),
              title: const Text('Dark Mode'),
              trailing: Switch.adaptive(
                value: !themeProvider.isLight,
                onChanged: (_) => themeProvider.toggle(),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _sectionHeader('Support'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.coffee_rounded),
              title: const Text('Donate'),
              subtitle: const Text('Support the developer'),
              onTap: () => showDonateSheet(context),
            ),
          ),
          const SizedBox(height: 24),
          _sectionHeader('GitHub'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.code_rounded),
              title: const Text('Shuash11'),
              subtitle: const Text('View developer profile & repos'),
              trailing: const Icon(Icons.open_in_new_rounded, size: 18),
              onTap: () async {
                final uri = Uri.parse('https://github.com/Shuash11');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
          ),
          const SizedBox(height: 24),
          _sectionHeader('About'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: const Text('MathCalcu'),
              subtitle: Text(_appVersion),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.person_rounded),
              title: const Text('Developer'),
              subtitle: const Text('Joashua Marl Barimbao'),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
  Widget _sectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
