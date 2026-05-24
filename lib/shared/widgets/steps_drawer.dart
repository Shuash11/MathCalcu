import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:provider/provider.dart';

Future<void> showStepsDrawer({
  required BuildContext context,
  required List<StepModel> steps,
  required Color accentColor,
  required String title,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => StepsDrawer(
      steps: steps,
      accentColor: accentColor,
      title: title,
    ),
  );
}

class StepsDrawer extends StatefulWidget {
  final List<StepModel> steps;
  final Color accentColor;
  final String title;

  const StepsDrawer({
    super.key,
    required this.steps,
    required this.accentColor,
    required this.title,
  });

  @override
  State<StepsDrawer> createState() => _StepsDrawerState();
}

class _StepsDrawerState extends State<StepsDrawer> {
  final Set<int> _expanded = {};

  String _buildCopyText() {
    final buf = StringBuffer();
    buf.writeln(widget.title);
    buf.writeln('-' * widget.title.length);
    buf.writeln();
    for (final s in widget.steps) {
      buf.write('${s.stepNumber}. ');
      if (s.hint != null && s.hint!.isNotEmpty) {
        buf.writeln(s.hint);
        buf.write('   ');
      }
      buf.writeln(s.latex ?? '');
      if (s.subLatex != null) {
        for (final sub in s.subLatex!) {
          buf.writeln('   $sub');
        }
      }
      buf.writeln();
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        final theme = context.watch<ThemeProvider>();
        return Container(
          decoration: BoxDecoration(
            color: theme.card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.textSecondary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: widget.accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${widget.steps.length} steps',
                        style: TextStyle(fontSize: 12, color: widget.accentColor, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: theme.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: _buildCopyText()));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Solution copied to clipboard'),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: Icon(Icons.copy_rounded, color: theme.textSecondary, size: 20),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.close_rounded, color: theme.textSecondary, size: 20),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: theme.textSecondary.withValues(alpha: 0.1)),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: theme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: widget.accentColor.withValues(alpha: 0.2)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(widget.steps.length, (i) {
                        final s = widget.steps[i];
                        final last = i == widget.steps.length - 1;
                        final hasDetails = s.details != null && s.details!.isNotEmpty;
                        final isExpanded = _expanded.contains(i);

                        return Padding(
                          padding: EdgeInsets.only(bottom: last ? 0 : 16),
                          child: GestureDetector(
                            onTap: hasDetails
                                ? () => setState(() {
                                      if (isExpanded) {
                                        _expanded.remove(i);
                                      } else {
                                        _expanded.add(i);
                                      }
                                    })
                                : null,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 2),
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: widget.accentColor.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${s.stepNumber}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: widget.accentColor,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SelectableMath.tex(
                                        s.latex ?? '',
                                        mathStyle: MathStyle.text,
                                        textStyle: TextStyle(
                                          fontSize: 16,
                                          color: theme.textPrimary,
                                          height: 1.5,
                                        ),
                                      ),
                                      if (s.subLatex != null && s.subLatex!.isNotEmpty)
                                        ...s.subLatex!.map((l) => Padding(
                                          padding: const EdgeInsets.only(top: 8),
                                          child: SelectableMath.tex(
                                            l,
                                            mathStyle: MathStyle.text,
                                            textStyle: TextStyle(
                                              fontSize: 16,
                                              color: theme.textPrimary,
                                              height: 1.5,
                                            ),
                                          ),
                                        )),
                                      if (s.hint != null && s.hint!.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 6),
                                          child: Text(
                                            s.hint!,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: theme.textSecondary,
                                              fontStyle: FontStyle.italic,
                                              height: 1.3,
                                            ),
                                          ),
                                        ),
                                      if (hasDetails)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Row(
                                            children: [
                                              AnimatedRotation(
                                                turns: isExpanded ? 0.5 : 0,
                                                duration: const Duration(milliseconds: 200),
                                                child: Icon(
                                                  Icons.expand_more_rounded,
                                                  size: 16,
                                                  color: theme.textSecondary,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                isExpanded ? 'Hide work' : 'Show work',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: widget.accentColor,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      AnimatedSize(
                                        duration: const Duration(milliseconds: 250),
                                        curve: Curves.easeInOut,
                                        alignment: Alignment.topCenter,
                                        child: isExpanded && hasDetails
                                            ? Padding(
                                                padding: const EdgeInsets.only(top: 10),
                                                child: Container(
                                                  width: double.infinity,
                                                  padding: const EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                    color: theme.surface,
                                                    borderRadius: BorderRadius.circular(8),
                                                    border: Border.all(
                                                      color: widget.accentColor.withValues(alpha: 0.12),
                                                    ),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: s.details!.map((d) => Padding(
                                                      padding: const EdgeInsets.only(bottom: 6),
                                                      child: Row(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            '\u2022',
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color: widget.accentColor,
                                                              height: 1.8,
                                                            ),
                                                          ),
                                                          const SizedBox(width: 6),
                                                          Expanded(
                                                            child: SelectableMath.tex(
                                                              d,
                                                              mathStyle: MathStyle.text,
                                                              textStyle: TextStyle(
                                                                fontSize: 13,
                                                                color: theme.textSecondary,
                                                                height: 1.6,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )).toList(),
                                                  ),
                                                ),
                                              )
                                            : const SizedBox.shrink(),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
