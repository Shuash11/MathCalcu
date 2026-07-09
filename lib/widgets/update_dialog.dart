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
  bool _downloading = false;
  double _progress = 0;
  String? _error;

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
            child: _downloading
                ? SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      value: _progress > 0 ? _progress : null,
                      strokeWidth: 3,
                      color: _accent,
                    ),
                  )
                : const Icon(Icons.system_update_rounded, size: 32, color: _accent),
          ),
          const SizedBox(height: 16),
          Text(
            _downloading ? 'Downloading...' : 'Update Available',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: theme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          if (_downloading)
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
            )
          else
            Text(
              'v${widget.info.latestVersion} is now available',
              style: const TextStyle(
                fontSize: 14,
                color: _accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: const TextStyle(fontSize: 12, color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _downloading ? null : () => Navigator.of(context).pop(),
          child: Text(
            _downloading ? 'Downloading...' : 'Later',
            style: TextStyle(color: theme.textSecondary),
          ),
        ),
        if (!_downloading)
          FilledButton.icon(
            onPressed: () => _error != null ? _startDownload() : _startDownload(),
            style: FilledButton.styleFrom(
              backgroundColor: _accent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: Icon(_error != null ? Icons.refresh_rounded : Icons.download_rounded, size: 18),
            label: Text(_error != null ? 'Retry' : 'Update Now'),
          ),
      ],
    );
  }

  void _startDownload() {
    setState(() {
      _downloading = true;
      _error = null;
      _progress = 0;
    });

    UpdateService.downloadAndInstall((p) {
      if (mounted) setState(() => _progress = p);
    }).then((error) {
      if (!mounted) return;
      if (error != null) {
        setState(() {
          _downloading = false;
          _error = error;
        });
      } else {
        Navigator.of(context).pop();
      }
    });
  }
}
