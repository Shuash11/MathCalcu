import 'package:flutter/material.dart';
import 'package:calculus_system/shared/widgets/responsive_text.dart';

/// Shows a modal bottom sheet containing [child] (typically a steps widget).
///
/// The modal features:
/// - Rounded top corners (28px radius)
/// - Semi-transparent backdrop (tap to dismiss)
/// - Drag handle indicator at top
/// - Header with title and close (X) button
/// - Scrollable content area
/// - Swipe-down dismiss via DraggableScrollableSheet
Future<void> showSolutionStepsModal({
  required BuildContext context,
  required Widget child,
  String title = 'Solution Steps',
  Color? accentColor,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _SolutionStepsModal(
      title: title,
      child: child,
    ),
  );
}

class _SolutionStepsModal extends StatelessWidget {
  final String title;
  final Widget child;

  const _SolutionStepsModal({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).brightness == Brightness.dark;
    final bgColor = theme ? const Color(0xFFF4F4F1) : Colors.white;
    final handleColor = theme ? Colors.black26 : Colors.black26;
    final textColor = theme ? const Color(0xFF0C0C09) : const Color(0xFF0C0C09);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.3,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) {
          final bottomInset = MediaQuery.of(context).viewPadding.bottom;
          return Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: handleColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF312C85),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.list_alt_rounded, color: Color(0xFFF4F4F1), size: 16),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ResponsiveText(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Color(0xFF312C85),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Color(0xFFF4F4F1),
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Divider
              Divider(height: 1, color: handleColor),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 32 + bottomInset),
                  child: child,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
