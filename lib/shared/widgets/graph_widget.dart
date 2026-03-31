import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ─────────────────────────────────────────────────────────────
// GRAPH WIDGET — shared container shell
// Each module's graph/ class renders inside this shell.
// The shell provides the dark card background + label.
// ─────────────────────────────────────────────────────────────

class GraphWidget extends StatelessWidget {
  final SolveResult result;
  final Color accentColor;
  final Widget graphBody; // pass your module's BaseGraph here

  const GraphWidget({
    super.key,
    required this.result,
    required this.accentColor,
    required this.graphBody,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    return Container(
      height: 260,
      decoration: BoxDecoration(
        color: theme.cardSecondary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Grid lines (decorative)
            CustomPaint(
              size: const Size(double.infinity, 260),
              painter: _GridPainter(accentColor: accentColor),
            ),

            // Module graph body
            Positioned.fill(child: graphBody),

            // "Graph" label top-left
            Positioned(
              top: 12,
              left: 16,
              child: Text(
                'Graph',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: accentColor.withValues(alpha: 0.5),
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final Color accentColor;
  _GridPainter({required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = accentColor.withValues(alpha: 0.05)
      ..strokeWidth = 0.5;

    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
