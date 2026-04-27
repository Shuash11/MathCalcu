import 'package:calculus_system/Finals/finals_theme.dart';
import 'package:flutter/material.dart';

class DerivativeInputField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onVariableChanged;
  final String currentVariable;
  final VoidCallback onSolve;

  const DerivativeInputField({
    Key? key,
    required this.controller,
    required this.onVariableChanged,
    required this.currentVariable,
    required this.onSolve,
  }) : super(key: key);

  void _insertText(String text) {
    final selection = controller.selection;
    final newText = controller.text.replaceRange(
      selection.start,
      selection.end,
      text,
    );
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: selection.start + text.length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: FinalsTheme.card(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: FinalsTheme.primary.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    FinalsTheme.shadowColor(context).withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => _showVariablePicker(context),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  decoration: BoxDecoration(
                    color: FinalsTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'd/d$currentVariable',
                    style: FinalsTheme.labelStyle(context).copyWith(
                      color: FinalsTheme.primary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  onSubmitted: (_) => onSolve(),
                  style: FinalsTheme.titleStyle(context).copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: 'e.g. x² + 3x + ln(x)',
                    hintStyle:
                        FinalsTheme.subtitleStyle(context).copyWith(
                      color:
                          FinalsTheme.textSecondary(context).withValues(alpha: 0.5),
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(4),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: onSolve,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: FinalsTheme.headerGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color:
                                FinalsTheme.primary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _QuickInputButton(label: 'x²', onTap: () => _insertText('^2')),
            const SizedBox(width: 8),
            _QuickInputButton(label: 'e^x', onTap: () => _insertText('e^')),
            const SizedBox(width: 8),
            _QuickInputButton(label: '√x', onTap: () => _insertText('√')),
          ],
        ),
      ],
    );
  }

  void _showVariablePicker(BuildContext context) {
    final variables = ['x', 'y', 'z', 't', 'u'];
    showModalBottomSheet(
      context: context,
      backgroundColor: FinalsTheme.card(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: variables.map((v) {
            final isSelected = v == currentVariable;
            return ListTile(
              title: Text(
                'd/d$v',
                style: FinalsTheme.titleStyle(ctx).copyWith(
                  color: isSelected ? FinalsTheme.primary : null,
                ),
              ),
              onTap: () {
                onVariableChanged(v);
                Navigator.pop(ctx);
              },
              trailing: isSelected
                  ? const Icon(Icons.check, color: FinalsTheme.primary)
                  : null,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _QuickInputButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickInputButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(
              color: FinalsTheme.primary.withValues(alpha: 0.2),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: FinalsTheme.labelStyle(context).copyWith(
              color: FinalsTheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}