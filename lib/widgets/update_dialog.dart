import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calculus_system/services/update_service.dart';
import 'package:calculus_system/theme/theme_provider.dart';

void showUpdateDialog(BuildContext context, UpdateInfo info) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => _UpdateDialog(info: info),
  );
}

class _UpdateDialog extends StatefulWidget {
  final UpdateInfo info;
  const _UpdateDialog({required this.info});

  @override
  State<_UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<_UpdateDialog>
    with WidgetsBindingObserver {
  double _progress = 0;
  String? _error;
  bool _downloading = false;
  bool _waitingForPermission = false;

  static const _accent = Color(0xFF6C63FF);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _waitingForPermission) {
      _checkPermissionThenDownload();
    }
  }

  Future<void> _checkPermissionThenDownload() async {
    final canInstall = await UpdateService.canInstallPackages();
    if (!mounted) return;
    if (!canInstall) {
      setState(() {
        _waitingForPermission = true;
        _error = 'NEED_PERMISSION';
        _downloading = false;
      });
      return;
    }
    _waitingForPermission = false;
    _startDownload();
  }

  void _startDownload() {
    _error = null;
    _downloading = true;
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
          _downloading = false;
        });
      } else {
        debugPrint('Update error: $error');
        setState(() {
          _error = error;
          _downloading = false;
        });
      }
    });
  }

  Future<void> _openSettings() async {
    _waitingForPermission = true;
    await UpdateService.openInstallSettings();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    // Error state
    if (_error != null) {
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
                color: Colors.red.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 32,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _error == 'NEED_PERMISSION' ? 'Permission required' : 'Update failed',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: theme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                _error == 'NEED_PERMISSION'
                    ? 'MathCalcu needs permission to install updates.\n'
                        'Tap "Open Settings" and enable "Allow from this source"'
                    : _error!,
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
                    onPressed: _openSettings,
                    style: FilledButton.styleFrom(backgroundColor: _accent),
                    child: const Text('Open Settings'),
                  )
                else
                  FilledButton(
                    onPressed: _startDownload,
                    style: FilledButton.styleFrom(backgroundColor: _accent),
                    child: const Text('Retry'),
                  ),
              ],
            ),
          ],
        ),
      );
    }

    // Downloading state
    if (_downloading) {
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
              child: const Icon(
                Icons.system_update_rounded,
                size: 32,
                color: _accent,
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
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(foregroundColor: theme.textSecondary),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
    }

    // Initial state — show update info with Update/Later buttons
    final releaseNotes = widget.info.releaseNotes;
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
            child: const Icon(
              Icons.system_update_rounded,
              size: 32,
              color: _accent,
            ),
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
            'v${widget.info.latestVersion}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _accent,
            ),
          ),
          if (releaseNotes.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.maxFinite,
              constraints: const BoxConstraints(maxHeight: 200),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.card,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SingleChildScrollView(
                child: Text(
                  releaseNotes,
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],
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
                    setState(() => _downloading = true);
                    _checkPermissionThenDownload();
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
