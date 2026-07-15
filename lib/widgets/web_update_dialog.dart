import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'web_update_helper.dart';

void showWebUpdateDialog(BuildContext context, String latestVersion) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => _WebUpdateDialog(latestVersion: latestVersion),
  );
}

class _WebUpdateDialog extends StatelessWidget {
  final String latestVersion;
  const _WebUpdateDialog({required this.latestVersion});

  static const _accent = Color(0xFF334155);

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
            'Update available',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: theme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Version $latestVersion',
            style: TextStyle(fontSize: 14, color: theme.textSecondary),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.textSecondary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Later'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    reloadPage();
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: _accent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Update'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
