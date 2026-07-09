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
  String? _error;
  bool _installing = false;

  static const _accent = Color(0xFF6C63FF);

  @override
  void initState() {
    super.initState();
    _checkPermissionAndDownload();
  }

  Future<void> _checkPermissionAndDownload() async {
    if (await UpdateService.hasInstallPermission() == false) {
      if (mounted) setState(() {
        _error =
            'MathCalcu needs permission to install updates.\n'
            'Tap "Open Settings" and enable "Allow from this source"';
        _installing = false;
      });
      return;
    }
    _startDownload();
  }

  void _startDownload() {
    _error = null;
    _installing = true;
    UpdateService.downloadAndInstall((p) {
      if (mounted) setState(() => _progress = p);
    }).then((error) {
      if (!mounted) return;
      if (error == null) {
        Navigator.of(context).pop();
      } else if (error == 'NEED_PERMISSION') {
        setState(() {
          _error =
              'MathCalcu needs permission to install updates.\n'
              'Tap "Open Settings" and enable "Allow from this source"';
          _installing = false;
        });
      } else {
        setState(() {
          _error = error;
          _installing = false;
        });
      }
    });
  }

  void _openSettings() async {
    await UpdateService.openInstallSettings();
    if (!mounted) return;
    _checkPermissionAndDownload();
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
              color: _error != null
                  ? Colors.red.withValues(alpha: 0.12)
                  : _accent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _error != null ? Icons.error_outline_rounded : Icons.system_update_rounded,
              size: 32,
              color: _error != null ? Colors.red : _accent,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _error != null ? 'Update failed' : 'Updating...',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: theme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          if (_error != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.textSecondary,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(foregroundColor: theme.textSecondary),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                if (_error == 'NEED_PERMISSION')
                  FilledButton(
                    onPressed: _installing ? null : _openSettings,
                    style: FilledButton.styleFrom(backgroundColor: _accent),
                    child: const Text('Open Settings'),
                  )
                else
                  FilledButton(
                    onPressed: _installing ? null : _checkPermissionAndDownload,
                    style: FilledButton.styleFrom(backgroundColor: _accent),
                    child: const Text('Retry'),
                  ),
              ],
            ),
          ] else ...[
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
        ],
      ),
    );
  }
}
