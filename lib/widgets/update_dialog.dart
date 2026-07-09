import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calculus_system/services/update_service.dart';
import 'package:calculus_system/theme/theme_provider.dart';

void showUpdateDialog(BuildContext context, UpdateInfo info) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => _UpdateDialog(info: info),
  );
}

class _UpdateDialog extends StatefulWidget {
  final UpdateInfo info;
  const _UpdateDialog({required this.info});

  @override
  State<_UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<_UpdateDialog> {
  double _progress = 0;

  static const _accent = Color(0xFF6C63FF);

  @override
  void initState() {
    super.initState();
    _startDownload();
  }

  void _startDownload() {
    UpdateService.downloadAndInstall((p) {
      if (mounted) setState(() => _progress = p);
    }).then((error) {
      if (!mounted) return;
      if (error == null) Navigator.of(context).pop();
    });
  }

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
            child: SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                value: _progress > 0 ? _progress : null,
                strokeWidth: 3,
                color: _accent,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Updating...',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: theme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: _progress,
                minHeight: 6,
                backgroundColor: theme.card,
                color: _accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
