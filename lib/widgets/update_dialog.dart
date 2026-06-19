import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:calculus_system/services/update_service.dart';
import 'package:calculus_system/theme/theme_provider.dart';

void showUpdateDialog(BuildContext context, UpdateInfo info) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => _UpdateDialog(info: info),
  );
}

class _UpdateDialog extends StatelessWidget {
  final UpdateInfo info;
  const _UpdateDialog({required this.info});

  static const _accent = Color(0xFF6C63FF);

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return AlertDialog(
      backgroundColor: theme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.system_update_rounded, size: 32, color: _accent),
          ),
          const SizedBox(height: 16),
          Text(
            'Update Available',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: theme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'v${info.latestVersion} is now available',
            style: const TextStyle(
              fontSize: 14,
              color: _accent,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'You are running v${info.currentVersion}',
            style: TextStyle(fontSize: 13, color: theme.textSecondary),
          ),
          if (info.releaseNotes.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.card,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                info.releaseNotes,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.5,
                  color: theme.textSecondary,
                ),
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Download the new version from the release page, then run the installer to update.',
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
                color: theme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Later',
            style: TextStyle(color: theme.textSecondary),
          ),
        ),
        FilledButton.icon(
          onPressed: () => _openRelease(context),
          style: FilledButton.styleFrom(
            backgroundColor: _accent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          icon: const Icon(Icons.open_in_new_rounded, size: 18),
          label: const Text('Open Download Page'),
        ),
      ],
    );
  }

  Future<void> _openRelease(BuildContext context) async {
    final uri = Uri.parse(info.releaseUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    if (context.mounted) Navigator.of(context).pop();
  }
}
