import 'package:flutter/material.dart';

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
    final bgColor = theme ? const Color(0xFF1E1E2E) : Colors.white;
    final handleColor = theme ? Colors.white24 : Colors.black26;
    final textColor = theme ? Colors.white : const Color(0xFF1E1E2E);

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
                        color: const Color(0xFF2A2A3E),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.list_alt_rounded, color: Color(0xFFFFD600), size: 16),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
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
                          color: Color(0xFFFFD600),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Color(0xFF1E1E2E),
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
