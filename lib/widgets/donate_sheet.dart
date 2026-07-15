import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:calculus_system/theme/theme_provider.dart';

void showDonateSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _DonateSheet(),
  );
}

class _DonateSheet extends StatelessWidget {
  const _DonateSheet();

  static const _accent = Color(0xFF334155);
  static const _gcashNumber = '09334375611';
  static const _baseDesignWidth = 400.0;

  void _showZoomedQR(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(20),
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: EdgeInsets.all(16),
                child: Image.asset(
                  'assets/images/qr.jpeg',
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.width * 0.8,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Tap anywhere to close',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final double s = (constraints.maxWidth / _baseDesignWidth).clamp(0.75, 1.1);

            return Container(
              decoration: BoxDecoration(
                color: theme.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32 * s)),
              ),
              child: ListView(
                controller: scrollController,
                padding: EdgeInsets.fromLTRB(24 * s, 16 * s, 24 * s, 40 * s),
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 48 * s,
                      height: 5 * s,
                      decoration: BoxDecoration(
                        color: _accent.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(3 * s),
                      ),
                    ),
                  ),

                  SizedBox(height: 24 * s),

                  // Coffee icon
                  Center(
                    child: Container(
                      width: 72 * s,
                      height: 72 * s,
                      decoration: BoxDecoration(
                        color: _accent.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.coffee_rounded,
                        size: 36 * s,
                        color: _accent,
                      ),
                    ),
                  ),

                  SizedBox(height: 20 * s),

                  // Title
                  Center(
                    child: Text(
                      'Buy us a Coffee',
                      style: TextStyle(
                        fontSize: 24 * s,
                        fontWeight: FontWeight.w800,
                        color: theme.textPrimary,
                        letterSpacing: -0.5 * s,
                      ),
                    ),
                  ),

                  SizedBox(height: 14 * s),

                  // Friendly pitch
                  Text(
                    'Hey! If MathCalc helped you pass an exam '
                    'or understand a tough lesson, consider '
                    'buying us a coffee.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14 * s,
                      height: 1.5,
                      color: theme.textSecondary,
                    ),
                  ),

                  SizedBox(height: 6 * s),

                  Text(
                    'Even a small amount goes a long way for\n'
                    'a broke dev student.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13 * s,
                      height: 1.4,
                      color: theme.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                  SizedBox(height: 24 * s),

                  // QR Code (tap to zoom)
                  Center(
                    child: GestureDetector(
                      onTap: () => _showZoomedQR(context),
                      child: Container(
                        width: 200 * s,
                        height: 200 * s,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20 * s),
                          border: Border.all(
                            color: _accent.withValues(alpha: 0.2),
                            width: 2,
                          ),
                        ),
                        padding: EdgeInsets.all(12 * s),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10 * s),
                          child: Image.asset(
                            'assets/images/qr.jpeg',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 8 * s),
                  Center(
                    child: Text(
                      'Tap image to zoom',
                      style: TextStyle(
                        fontSize: 11 * s,
                        color: theme.textSecondary.withValues(alpha: 0.6),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),

                  SizedBox(height: 20 * s),

                  // GCash number + copy
                  Container(
                    padding: EdgeInsets.all(16 * s),
                    decoration: BoxDecoration(
                      color: _accent.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(16 * s),
                      border: Border.all(
                        color: _accent.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.phone_android_rounded,
                          size: 20 * s,
                          color: _accent,
                        ),
                        SizedBox(width: 10 * s),
                        Expanded(
                          child: Text(
                            _gcashNumber,
                            style: TextStyle(
                              fontSize: 18 * s,
                              fontWeight: FontWeight.w700,
                              color: theme.textPrimary,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(
                              const ClipboardData(text: _gcashNumber),
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Number copied!'),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14 * s,
                              vertical: 8 * s,
                            ),
                            decoration: BoxDecoration(
                              color: _accent,
                              borderRadius: BorderRadius.circular(12 * s),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.copy_rounded,
                                  size: 16 * s,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 4 * s),
                                Text(
                                  'Copy',
                                  style: TextStyle(
                                    fontSize: 13 * s,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20 * s),

                  // Footer
                  Center(
                    child: Text(
                      'Salamat! \u2764\uFE0F',
                      style: TextStyle(
                        fontSize: 16 * s,
                        fontWeight: FontWeight.w600,
                        color: _accent,
                      ),
                    ),
                  ),
                  SizedBox(height: 4 * s),
                  Center(
                    child: Text(
                      '\u2014 The MathCalc Team',
                      style: TextStyle(
                        fontSize: 13 * s,
                        color: theme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
